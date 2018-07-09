unit Protocols;

interface
  uses Windows, Const_Type;

type
  TWathProc = function ( _lpData: Pointer ): DWORD stdcall;
  
  procedure CRC( _nextn: BYTE; var _CRCH, _CRCL: BYTE );
  procedure MakeData( _Buf: PBuffer; var _Len: Cardinal );
  function CheckCRC( var _stt: TBuffer; _sz: Integer ): BOOL;
  function DatecsProc( _lpData: Pointer ): DWORD stdcall;

implementation

uses  
  Comm_Procedures, SysUtils, ConnectionStream, DataStream,
  LogFunc, StrUtils, StrFunc;

procedure CRC(_nextn: BYTE; var _CRCH, _CRCL: BYTE);
var
   _AL, _AH, _DH, _DL: BYTE;
   _i: Integer;
begin
  _AL := _nextn; _AH := _CRCH; _DH := _CRCH; _DL := _CRCL;

	for _i:=0 to 6 do
   	_DH := (_DH shr 1) xor _AH;

  _CRCL := _AL xor _DH;
  _DH := (_DH shl 7) or (_DH shr 1);
  _DH := _DH and $80;
  _CRCH := _DH xor _DL;

end;
 
procedure MakeData(_Buf: PBuffer; var _Len: Cardinal);
var 
  _i: Integer;
  _CRCH, _CRCL, _AL: Byte;
begin
  _CRCH := 0; _CRCL := 0; _AL := 0;
  for _i:=1 to _Len - 1 do 
    CRC(TBuffer(_Buf)[_i], _CRCH, _CRCL);
   
  CRC(_AL, _CRCH, _CRCL);
  CRC(_AL, _CRCH, _CRCL);

  TBuffer(_Buf)[_i] := _CRCH;
  TBuffer(_Buf)[_i+1] := _CRCL;
  Inc(_Len, 2);
end;

function CheckCRC( var _stt: TBuffer; _sz: Integer ): BOOL;
var 
   _i: Integer;
   _CRCH, _CRCL: BYTE;
begin
  _CRCH := 0; _CRCL := 0;
  for _i := 1 to _sz-1 do CRC(_stt[_i], _CRCH, _CRCL);
  Result := not( BOOL( _CRCH or _CRCL ) );
end;

function DatecsProc( _lpData: Pointer ): DWORD stdcall;
var
  _tErrorDataLen,
  _NoRejectIfNull,
  _tSendInit: Boolean;
  _PortStream: PConnectionStream;   
  _Read,
  _ResRead: Integer;
  _vErrorReadNum: Integer;
  _vNAKNum,
  _vInNAKNum: Integer;
  _LastOpType: Byte;
  _tmp: PDevEnum;
begin
  Result := 0; _tSendInit := True; _LastOpType := FF;
  _PortStream := PConnectionStream(_lpData);
  _PortStream^.CleanPort;
  _PortStream^.InitData;
  _vErrorReadNum := defErrorReadNum;
  
  try
{$ifdef CS}
    EnterCriticalSection(_PortStream^.__CS);
{$else}  
    WaitForSingleObject(_PortStream^.__Ev, INFINITE);
{$endif}  
    while ( _PortStream^.S_Info.CommInfo^.Connected and ( not _PortStream^.Terminated ) ) do begin
      try
        if ( _tSendInit ) then begin
          _NoRejectIfNull := False; _tErrorDataLen := false;
          _vInNAKNum := defNAKNum; _vNAKNum := defNAKNum;
          _tmp := _PortStream^.DevEnum;
          while assigned(_tmp) and ((not BOOL(_PortStream^.DevEnum^.DevNum)) or
                (not BOOL(_PortStream^.DevEnum^.SerialNum)) or
                (BOOL(_PortStream^.DevEnum^.Off))) do begin
            _PortStream^.DevEnum := _PortStream^.DevEnum^.Next;
            if (_tmp = _PortStream^.DevEnum) then begin
              _PortStream^.Terminate;
              break;
            end;
          end;
          if (not assigned(_tmp)) then _PortStream^.Terminate;
          if ( not _PortStream^.Terminated ) then begin
            _PortStream^.CleanDataBuff;
            _vErrorReadNum := defErrorReadNum;
            _PortStream^.SendRestore(_PortStream^.DevEnum);
            _PortStream^.SendTake(_PortStream^.DevEnum);
          end;
        end;
        _ResRead := 0;
        if ( not _PortStream^.Terminated ) then begin
          if ( _PortStream^.ReadStream( _tErrorDataLen, _ResRead, _Read ) > 0 ) then begin
            Case _ResRead of
              resAck: begin
                _PortStream^.__WriteToLogInCmd(_PortStream^.DevEnum);
                _PortStream^.ConfirmLastData(_PortStream^.DevEnum);
                _tSendInit := True;
      {
      //MP-50 отличия протокола при анулировании чека.
                if (_LastOpType = opAnnul) then _tSendInit := False
                else _tSendInit := True;
      }          
              end;
              resNak: begin
                _PortStream^.__WriteToLogInCmd(_PortStream^.DevEnum);
                if BOOL( _vInNAKNum ) then begin
                  _PortStream^.SendNull(_PortStream^.DevEnum);
                  _tSendInit := _PortStream^.SendLastData(_PortStream^.DevEnum);
                  Dec(_vInNAKNum);
                end
                else begin
                  _PortStream^.RejectLastData(_PortStream^.DevEnum);
                  _tSendInit := True;
                end;
              end;
              else
                if ( _PortStream^.CheckDataNull ) then begin
                  if ( _PortStream^.CheckDataLen ) then begin                
                    if ( _PortStream^.CheckData ) then begin
                      _PortStream^.SendNull(_PortStream^.DevEnum);
                      _PortStream^.SendOk(_PortStream^.DevEnum, true);
                      _tSendInit := _PortStream^.ProcessData(_PortStream^.DevEnum);
                      _LastOpType := _PortStream^.__opType;
                    end 
                    else begin
                      if BOOL( _vNAKNum ) then begin
                        _PortStream^.SendNull(_PortStream^.DevEnum);
                        _PortStream^.SendNAK(_PortStream^.DevEnum, true);
                        _tSendInit := False;
                        Dec( _vNAKNum, _vNAKNum );
                      end
                      else begin
                        _PortStream^.SendNull(_PortStream^.DevEnum);
                        _PortStream^.SendOk(_PortStream^.DevEnum, true);
                        _tSendInit := True;
                      end;
                    end;
                  end
                  else begin
                    if not _tErrorDataLen then begin
                      if BOOL(_PortStream^.__SendNullIfReadError) then 
//                        _PortStream^.ClearBreakPort(_PortStream^.DevEnum);
                        _PortStream^.SendNULL(_PortStream^.DevEnum);
                      _tErrorDataLen := True;
                      _tSendInit := False;
                    end
                    else begin
                      if not BOOL(_Read) then begin
                        _PortStream^.ClearBreakPort(_PortStream^.DevEnum);
                        _PortStream^.CleanPort;
                        _tSendInit := True;
                      end;
                    end;
                  end;
                end 
                else begin
                  if BOOL( _vErrorReadNum ) then begin
                    if BOOL(_PortStream^.__SendNullIfReadError) then 
                      _PortStream^.ClearBreakPort(_PortStream^.DevEnum);
                    _NoRejectIfNull := True;
                    _tSendInit := False;
                    Dec(_vErrorReadNum);
                  end 
                  else begin
                    _PortStream^.CleanPort;
                    if (_PortStream^.CheckDataBuff 
                        and (not (BOOL(_PortStream^.__NoRejectIfNull) 
                             and _NoRejectIfNull))) then
                      _PortStream^.RejectLastData(_PortStream^.DevEnum);
                    _tSendInit := True;
                  end;
                end;
            end;
          end
          else begin
            if BOOL(_PortStream^.__RejectNoAnswer) then begin
              if BOOL( _vErrorReadNum ) then begin
                _tSendInit := False;
                Dec(_vErrorReadNum);
              end 
              else begin
                _PortStream^.CleanPort;
                if (_PortStream^.CheckDataBuff 
                    and (not (BOOL(_PortStream^.__NoRejectIfNull) 
                         and _NoRejectIfNull))) then
                  _PortStream^.RejectLastData(_PortStream^.DevEnum);
                _tSendInit := True;
              end;
            end
            else _tSendInit := True;
          end;
    {
    //MP-50 отличия протокола при анулировании чека.
            if (_LastOpType <> opAnnul) then _tSendInit := True
            else _tSendInit := False;
    }
          if ( _tSendInit ) then _PortStream^.DevEnum := _PortStream^.DevEnum^.Next;
        end;
      except
        on E:Exception do begin
          TDataStream(_PortStream^.__DataStream).EventLogger.LogError('550_DatecsProc exception: '+E.Message);
        end;
      end;
    end;
  finally
{$ifdef CS}
    LeaveCriticalSection(_PortStream^.__CS);
{$else}  
    SetEvent(_PortStream^.__Ev);
{$endif}  
  end;
  PostThreadMessage(_PortStream^.__DataStreamTHId, THREAD_BREAK_CONNECT, 0, 0);
  ExitThread(Result);
end;


end.
