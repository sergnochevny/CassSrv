unit CassSrvAppObj;

interface
  uses  Windows, Messages, 
  Const_Type, SysUtils, LogFunc,
  IBSQL, IBDatabase, vIBDB, myIBEvents,
  db, dbclient, provider, 
{$ifdef drvdll}  
  AbstractDataStream,
{$else}
  DataStream, 
{$endif}
  DBObj,DBObjs;  
type

{$ifdef drvdll}  
  TInitProtocol = function(PortNo, Bps: integer): TDataStream; stdcall;
{$endif}

  PCassSrvAppObj = ^TCassSrvAppObj;
  TCassSrvAppObj = class
    private
      __ThreadID: Cardinal;
      __ThreadHandle: THandle;
      __MainEvent: THandle;
      __Timeout:   Integer;
      __Terminated: Boolean;
      __DataStreamEnum: PDataStreamEnum;
      __DBObj: TMainDBObj;
 		  __EventLogger: TEventLogger;

{$ifdef drvdll}  
      function __InitProtocol( _ProtocolLibrary: String; _PortNo, _Bps: integer; _HLibrary: THandle ): TDataStream;
{$endif}      
      procedure __DeInitialize;
      procedure __ProcessData(_P: Pointer);
      procedure __ProcEventsAlert(_case: Integer);
      procedure __OnGoodsChange();
      procedure __OnBarCodesChange();
      procedure __OnDepPriceChange();
    public
      constructor Create;
		  destructor Destroy; override;

      procedure Terminate;
      function Initialize: boolean;
      procedure Run;
      procedure WaitForCancel;
      property Terminated: Boolean read __Terminated write __Terminated;
      property MainEvent: THandle read __MainEvent;
      property ThreadID: Cardinal write __ThreadID;
      property ThreadHandle: THandle write __ThreadHandle;
      
  end;

var
  Idx: Integer;
 
implementation

uses 
  StrFunc, StrUtils, tServiceMain;

{ TDataStream }

function TCassSrvAppObj.Initialize: boolean;
var
	_msg: TMsg;
  _Ports: TClientDataSet;
  _tmp: PDataStreamEnum;
  _HLibrary: THandle;
begin
  Result := False;

  __DBObj :=  TMainDBObj.Create;
  __DBObj.OnGoodsChange := Self.__OnGoodsChange;
  __DBObj.OnBarCodesChange := Self.__OnBarCodesChange;
  __DBObj.OnDepPriceChange := Self.__OnDepPriceChange;
  _Ports := __DBObj.GetPorts('exists (select * from "Ecrs" where off = 0 and portid = p.id)');
  _Ports.First;
  __DataStreamEnum := nil;
  while not _Ports.Eof do begin
    GetMem(_tmp, SizeOf(TDataStreamEnum));
    FillChar(_tmp^,SizeOf(TDataStreamEnum),$00);
{$ifdef drvdll}
    TDataStream(_tmp^.DataStream) := Self.__InitProtocol( 
                                    _Ports.FieldByName('PROTOCOL').AsString,
                                    _Ports.FieldByName('NUMBER').AsInteger,
                                    _Ports.FieldByName('BAUDNUMBER').AsInteger,
                                    _HLibrary);
{$else}
    TDataStream(_tmp^.DataStream) := TDataStream.Create;
    TDataStream(_tmp^.DataStream).BaudNumber := _Ports.FieldByName('BAUDNUMBER').AsInteger;
    TDataStream(_tmp^.DataStream).Port := _Ports.FieldByName('NUMBER').AsInteger;
{$endif}          
    TDataStream(_tmp^.DataStream).PortID := _Ports.FieldByName('ID').AsInteger;
    if ( TDataStream(_tmp^.DataStream).InitializeStream(_tmp^.DataStream) ) then
    begin
      PeekMessage(_msg, 0, WM_USER, WM_USER, PM_NOREMOVE);
      TDataStream(_tmp^.DataStream).MainTHId := GetCurrentThreadId();
      TDataStream(_tmp^.DataStream).Resume;
      Result := True;
    end;
    if ( assigned( __DataStreamEnum ) ) then 
      _tmp^.Next := __DataStreamEnum^.Next
    else __DataStreamEnum := _tmp;
    __DataStreamEnum^.Next := _tmp;
    _tmp := nil;
    _Ports.Next;
  end;
  _Ports.Close;
  _Ports.Free;
end;

procedure TCassSrvAppObj.Run;
var
	_msg: TMsg;
	_WaitTime: DWord;
  _Event: THandle;
begin

  if __Timeout = 0 then
    _WaitTime := INFINITE else
    _WaitTime := 60000;

  _Event := __MainEvent;
  __EventLogger.LogSucces('CassSrv start process');
  while not __Terminated do
  try
    case MsgWaitForMultipleObjects(1, _Event, False, _WaitTime, QS_ALLINPUT) of
      WAIT_OBJECT_0 + 1:
        while PeekMessage(_msg, 0, 0, 0, PM_REMOVE) do begin
          if ((_msg.hwnd = 0) and (_msg.message <> THREAD_PROCESS_DATA)) then
            __EventLogger.LogInformation('CassSrv _msg.hwnd: '+IntToStr(_msg.hwnd)+'; _msg.message: '+IntToStr(_msg.message)+'; _msg.wParam: '+IntToStr(_msg.wParam));
          if (_msg.hwnd = 0) then
            case _msg.message of
              THREAD_BREAK:	begin
                __Terminated := True;
                SetEvent(__MainEvent);
              end;
              THREAD_PROCESS_DATA: begin
                try
                  __ProcessData(Pointer(_msg.lParam));
                except
                  on E: Exception do
                    __EventLogger.LogError('TCassSrvAppObj.Run __ProcessData eception: '+E.Message);
                end;
              end;
            else DispatchMessage(_msg);
            end
          else DispatchMessage(_msg);
        end;
      WAIT_OBJECT_0: 
      begin
        ResetEvent(_Event);
        Sleep(1);
      end;
      else Sleep(1);
//      WAIT_TIMEOUT:
//      begin
//        while PeekMessage(_msg, 0, 0, 0, PM_REMOVE) do
//          DispatchMessage(_msg);
//      end;
    end;
  except
    Application.HandleException(self);
    Terminated := True;
  end;
  __EventLogger.LogSucces('CassSrv stop process');

end;

constructor TCassSrvAppObj.Create;
begin
	inherited Create;
  __MainEvent := 0;
  __TimeOut := __NOINFINITE;
  __MainEvent := CreateEvent(nil, false, false, nil);
  __Terminated := False;
  __EventLogger := TEventLogger.Create('CassSrvAppObj');
end;

destructor TCassSrvAppObj.Destroy;
begin
  __EventLogger.Free;
  if BOOL(__MainEvent) then begin
	  CloseHandle(__MainEvent);
    __MainEvent := 0;
  end;
	inherited Destroy;
end;

function TimerProc(_lpData: Pointer): DWORD; stdcall;
var
  _ThreadID: Cardinal;
//  _time: Integer;
begin
  Result := 0;
  if assigned(_lpData) then begin
    _ThreadID := Cardinal(_lpData^);
//    _time := __WTimeOut * __SECONDS;
//    Sleep(_time);
    PostThreadMessage(_ThreadID, THREAD_BREAK, 0, 0);
  end;
  ExitThread(Result);
end;

procedure TCassSrvAppObj.Terminate;
var
  _HThread: THandle;
  _ThID: Cardinal;
begin
  __DeInitialize;
  _HThread := CreateThread( nil, 0, @TimerProc, @__ThreadID, CREATE_SUSPENDED, _ThID );
  if BOOL(_HThread) then begin
    ResumeThread(_HThread);
    CloseHandle(_HThread);
  end
  else
    PostThreadMessage(__ThreadID, THREAD_BREAK, 0, 0);
  WaitForCancel;
  __DBObj.Free;
end;

{$ifdef drvdll}  
function TCassSrvAppObj.__InitProtocol(_ProtocolLibrary: String; _PortNo, _Bps: integer; _HLibrary: THandle): TDataStream;
var
  _InitProtocol: TInitProtocol;
begin
  Result := nil;
	_HLibrary := LoadLibrary(PChar(Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0)))+PathDelimiter+_ProtocolLibrary+'.dll'));
	if (_HLibrary <> INVALID_HANDLE_VALUE) and (_HLibrary <> 0) then begin
    @_InitProtocol := GetProcAddress(_HLibrary, PChar(__InitProtocol__));
    if @_InitProtocol = nil then begin
		  FreeLibrary(_HLibrary);
      raise Exception.Create('');
    end
    else begin
      Result := _InitProtocol(_PortNo, _Bps);
      Result.HLibrary := _HLibrary;
    end;
  end;
end;
{$endif}

procedure TCassSrvAppObj.__DeInitialize;
var 
  _tmp: PDataStreamEnum;
{$ifdef drvdll}  
  _HLibrary: Cardinal;
{$endif}
begin
  if assigned(__DataStreamEnum) then begin
    _tmp := __DataStreamEnum;
    while true do begin
      _tmp := _tmp^.Next;
      if _tmp = __DataStreamEnum then begin
{$ifdef drvdll}  
        _HLibrary := TDataStream(_tmp^.DataStream).HLibrary;
{$endif}
        TDataStream(_tmp^.DataStream).Terminate;
        TDataStream(_tmp^.DataStream).WaitForExit;
        TDataStream(_tmp^.DataStream).Free;
{$ifdef drvdll}  
  	    if (_HLibrary <> INVALID_HANDLE_VALUE) and (_HLibrary <> 0) then
          FreeLibrary(_HLibrary);
{$endif}          
        FreeMem(_tmp);
        __DataStreamEnum := nil;
        break;
      end
      else begin
        __DataStreamEnum^.Next := _tmp^.Next;
{$ifdef drvdll}  
        _HLibrary := TDataStream(_tmp^.DataStream).HLibrary;
{$endif}
        TDataStream(_tmp^.DataStream).Terminate;
        TDataStream(_tmp^.DataStream).WaitForExit;
        TDataStream(_tmp^.DataStream).Free;
{$ifdef drvdll}  
  	    if (_HLibrary <> INVALID_HANDLE_VALUE) and (_HLibrary <> 0) then
          FreeLibrary(_HLibrary);
{$endif}          
        FreeMem(_tmp);
        _tmp := __DataStreamEnum^.Next;
      end;
    end;
  end;
end;

procedure TCassSrvAppObj.__ProcessData(_P: Pointer);
var
  _tmp: PSaveDataRec;
  _cds: TClientDataSet;
begin
  _tmp := nil;
  try
    try
      _tmp := PSaveDataRec(_P);
      if assigned(_tmp) then begin
        _cds := TClientDataSet(_tmp^.__CheckData);
        if assigned(_cds) then begin
          __DBObj.SaveData(_cds, _tmp^.__TmpDir);
          _cds.Close; 
          _cds.Free;
          if FileExists(_tmp^.__FileName) then DeleteFile(_tmp^.__FileName);
          SetLength(_tmp^.__FileName,0);
        end else
          __EventLogger.LogError('TCassSrvAppObj.__ProcessData _cds is null');
      end else  
        __EventLogger.LogError('TCassSrvAppObj.__ProcessData _P is null');      
    except
      on E: Exception do begin
        __EventLogger.LogError('TCassSrvAppObj.__ProcessData exception: '+E.Message);
      end;
    end;
  finally
    if assigned(_tmp) then
      FreeMem(_tmp, SizeOf(TSaveDataRec));
  end;
end;

procedure TCassSrvAppObj.__ProcEventsAlert(_case: Integer);
var 
  _tmp: PDataStreamEnum;
begin
  if assigned(__DataStreamEnum) then
  begin
    _tmp := __DataStreamEnum;
    while true do begin
      _tmp := _tmp^.Next;
      if _tmp = __DataStreamEnum then begin
        PostThreadMessage(TDataStream(_tmp^.DataStream).StreamThID, THREAD_REFRESH, _case, 0);
        break;
      end
      else 
        PostThreadMessage(TDataStream(_tmp^.DataStream).StreamThID, THREAD_REFRESH, _case, 0);
    end;
  end;
end;

procedure TCassSrvAppObj.__OnBarCodesChange;
begin
  __ProcEventsAlert(__cBarCodesChange);
end;

procedure TCassSrvAppObj.__OnDepPriceChange;
begin
  __ProcEventsAlert(__cDepPriceChange);
end;

procedure TCassSrvAppObj.__OnGoodsChange;
begin
  __ProcEventsAlert(__cGoodsChange);
end;

procedure TCassSrvAppObj.WaitForCancel;
begin
  WaitForSingleObject(__ThreadHandle, INFINITE);
end;

end.




