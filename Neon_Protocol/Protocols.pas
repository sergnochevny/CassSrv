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
  Comm_Procedures, SysUtils, ConnectionStream,
{$ifdef Log}    
  LogFunc, 
{$endif}  
  StrUtils, StrFunc;

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
  _NumDev: Integer;
  _tSendInit: Boolean;
  _PortStream: PConnectionStream;   
  _ResRead: Integer;
  _vNAKNum: Integer;
  _LastOpType: Byte;
  _tmp: PDevEnum;
begin
  Result := 0; _tSendInit := True; _LastOpType := FF;
  _PortStream := PConnectionStream(_lpData);
  _PortStream^.CleanPort;
  _PortStream^.InitData;
  
  while ( _PortStream^.S_Info.CommInfo^.Connected and ( not _PortStream^.Terminated ) ) do begin
    try
  {$ifdef CS}
      EnterCriticalSection(_PortStream^.__CS);
  {$else}  
      WaitForSingleObject(_PortStream^.__Ev, INFINITE);
  {$endif}  
      try
        if ( _tSendInit ) then begin
          _vNAKNum := defNAKNum;
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
            _NumDev := _PortStream^.DevEnum^.DevNum;
            _PortStream^.SendRestore;
            _PortStream^.SendTake( _NumDev );
          end;
        end;
        _ResRead := 0;
        if ( not _PortStream^.Terminated ) then begin
          if ( _PortStream^.ReadStream( _ResRead ) > 0 ) then 
          begin
            Case _ResRead of
              resAck: begin
                _tSendInit := True;
    {$ifdef Log}              
                _PortStream^.__WriteToLogInCmd(_PortStream^.DevEnum);
    {$endif}       
              end;
      {
      //MP-50
                if (_LastOpType = opAnnul) then _tSendInit := False
                else _tSendInit := True;
      }          
              resNak: begin
    {$ifdef Log}              
                _PortStream^.__WriteToLogInCmd(_PortStream^.DevEnum);
    {$endif}       
                if BOOL( _vNAKNum ) then begin
                  _PortStream^.SendNull;
                  _tSendInit := _PortStream^.SendLastData(_PortStream^.DevEnum);
                end
                else begin
                  _PortStream^.RejectLastData(_PortStream^.DevEnum);
                  _tSendInit := True;
                end;
              end;
              else
                if ( _PortStream^.CheckData ) then begin
                  if ( _PortStream^.CheckDataLen ) then begin
                    _PortStream^.SendNull;
                    _PortStream^.SendOk;
                    _tSendInit := _PortStream^.ProcessData(_PortStream^.DevEnum);
                    _LastOpType := _PortStream^.__opType;
                  end 
                  else _tSendInit := True;
                end 
                else begin
                  if BOOL( _vNAKNum ) then begin
                    _PortStream^.SendNull;
                    _PortStream^.SendNAK;
                    _tSendInit := False;
                    Dec( _vNAKNum, _vNAKNum );
                  end
                  else begin
                    _PortStream^.SendNull;
                    _PortStream^.SendOk;
                    _tSendInit := True;
                  end;
                end;
            end;
          end
          else 
            _PortStream^.RejectLastData(_PortStream^.DevEnum);
      
          if ( _tSendInit ) then _PortStream^.DevEnum := _PortStream^.DevEnum^.Next
          else if BOOL( _vNAKNum ) then begin
              _tSendInit := False;
              Dec( _vNAKNum );
          end
          else _tSendInit := True;
    {
    //MP-50
            if (_LastOpType <> opAnnul) then _tSendInit := True
            else _tSendInit := False;
    }
        end;
      finally
  {$ifdef CS}
        LeaveCriticalSection(_PortStream^.__CS);
  {$else}  
        SetEvent(_PortStream^.__Ev);
  {$endif}  
      end;
    except
      on E:Exception do begin
{$ifdef Log}                  
        _PortStream^.DevEnum.Log.WriteToLog(PChar(E.Message), Length(E.Message));
{$endif}          
      end;
    end;
  end;
  PostThreadMessage(_PortStream^.__DataStreamTHId, THREAD_BREAK_CONNECT, 0, 0);
  ExitThread(Result);
end;


end.
