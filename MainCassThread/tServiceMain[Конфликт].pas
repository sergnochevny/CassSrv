unit tServiceMain;

interface
uses
	Windows, Classes, SysUtils, vSvcMgr,
  CassSrvAppObj;
  
type

	TServiceApplication = class(TCustomServiceApplication)
  private
    __GeneralThHandle: THandle;
    __GeneralThID: Cardinal;
    CassSrvAppObject: TCassSrvAppObj;
	protected
		procedure BeforeStartService(Sender: TConsoleService; var Started: Boolean); override;
		procedure StartService(Sender: TConsoleService; var Started: Boolean); override;
		procedure StopService(Sender: TConsoleService; var Stopped: Boolean); override;
		procedure ContinueService(Sender: TConsoleService; var Continued: Boolean); override;
		procedure ExecuteService(Sender: TConsoleService; var Started: Boolean); override;
		procedure PauseService(Sender: TConsoleService; var Paused: Boolean); override;
		procedure ShutDownService(Sender: TConsoleService); override;
		procedure BeforeInstallService(Svc: Integer; Sender: TConsoleService); override;
		procedure AfterInstallService(Svc: Integer; Sender: TConsoleService); override;
		procedure BeforeUninstallService(Svc: Integer; Sender: TConsoleService); override;
		procedure AfterUninstallService(Svc: Integer; Sender: TConsoleService); override;
		procedure RunInitialize; override;
	public
		constructor Create;
    destructor Destroy; override;
    property ServiceName;
	end;

var
	Application: TServiceApplication = nil;

implementation
uses
  WinSvc;


function ServiceThreadProc( _lpData: Pointer ): DWORD stdcall;
begin
  Result := 0;
  if assigned(Application) then begin
    if Application.CassSrvAppObject.Initialize then
      Application.CassSrvAppObject.Run;
  end;
  ExitThread(Result);
end;

{ TServiceApplication }

constructor TServiceApplication.Create;
begin
	inherited Create;
 	with ConsoleService do begin
    DisplayName := 'CassSrv';
    ServiceStartName := 'CassSrv';
    CassSrvAppObject := TCassSrvAppObj.Create;
  end;
end;

destructor TServiceApplication.Destroy;
begin
 	with ConsoleService do begin
    CassSrvAppObject.Destroy;
  end;
	inherited;
end;

procedure TServiceApplication.BeforeStartService(Sender: TConsoleService;
	var Started: Boolean);
begin
	Started := True;
end;

procedure TServiceApplication.StartService(Sender: TConsoleService;
	var Started: Boolean);
begin
	Started := True;
  __GeneralThHandle := 0;
end;

procedure TServiceApplication.StopService(Sender: TConsoleService;
	var Stopped: Boolean);
begin
  if assigned(CassSrvAppObject) then begin
    CassSrvAppObject.Terminate;
  end;
  if BOOL(__GeneralThHandle) then begin
    WaitForSingleObject(__GeneralThHandle, INFINITE);
    CloseHandle(__GeneralThHandle);
    __GeneralThHandle := 0;
  end;
end;

procedure TServiceApplication.AfterInstallService(Svc: Integer;
  Sender: TConsoleService);
begin
  {Ваш код}
end;

procedure TServiceApplication.AfterUninstallService(Svc: Integer;
  Sender: TConsoleService);
begin
  {Ваш код}
end;

procedure TServiceApplication.BeforeInstallService(Svc: Integer;
  Sender: TConsoleService);
begin
  {Ваш код}
end;

procedure TServiceApplication.BeforeUninstallService(Svc: Integer;
  Sender: TConsoleService);
begin
  {Ваш код}
end;

procedure TServiceApplication.ContinueService(Sender: TConsoleService;
  var Continued: Boolean);
begin
  Continued := True;
end;

procedure TServiceApplication.ExecuteService(Sender: TConsoleService;
  var Started: Boolean);
begin
  Started := True;
  __GeneralThHandle := CreateThread( nil, 0, @ServiceThreadProc, nil, CREATE_SUSPENDED, __GeneralThID );
  if BOOL(__GeneralThHandle) then begin
    CassSrvAppObject.ThreadID := __GeneralThID;
    CassSrvAppObject.ThreadHandle := __GeneralThHandle;
    ResumeThread(__GeneralThHandle);
  end
  else Started := False;
end;

procedure TServiceApplication.PauseService(Sender: TConsoleService;
  var Paused: Boolean);
begin
  Paused := True;
end;

procedure TServiceApplication.ShutDownService(Sender: TConsoleService);
begin
  ConsoleService.LogMessage('CassSrvApp shutdown service');
end;

procedure TServiceApplication.RunInitialize;
begin
  with ConsoleService do begin
//		Dependencies: TDependencies ;
//		LoadGroup: String ;
//		AccountName: String ;
//		Password: String ;
		ErrorSeverity := esNormal;
		StartType := stAuto;
		Interactive:= False;
		AllowStop := True;
		AllowPause := False;
		WaitHint := 5000;
		TagID := 0;
  end;
end;

procedure NewExceptProc(ExceptObject: TObject; ExceptAddr: Pointer); far;
begin
	if ExceptObject is Exception then begin
		if not (ExceptObject is EAbort) then
				Application.ShowException(Exception(ExceptObject));
	end else
		SysUtils.ShowException(ExceptObject, ExceptAddr);
end;

procedure InitApplication;
begin
	Application := TServiceApplication.Create;
  ExceptProc := @NewExceptProc;
end;

procedure DoneApplication;
begin
	Application.Free;
	Application := nil;
end;

initialization
	InitApplication;

finalization
	DoneApplication;

end. 