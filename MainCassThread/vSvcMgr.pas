unit vSvcMgr;
{$J+}

interface

uses
	Windows, SysUtils, Classes, WinSvc, SyncObjs;

type

	TObjectToFarProc = packed record
		POPEDX: Byte;
		MOVEAX: Byte;
		SelfPtr: Pointer;
		PUSHEAX: Byte;
		PUSHEDX: Byte;
		MOVEAX1: Byte;
		JmpOffset: Integer;
		JMP: WORD;
	end;

	TServiceTableEntryArray = array of TServiceTableEntry;

	{ TEventLogger }

	TEventLogger = class(TObject)
	private
		FName: String;
		FEventLog: Integer;
	public
		constructor Create(Name: String);
		destructor Destroy; override;
		procedure LogMessage(Message: String; EventType: DWord = 1;
			Category: Word = 0; ID: DWord = 0);
	end;

	{ TDependency }

	TDependency = class(TCollectionItem)
	private
		FName: String;
		FIsGroup: Boolean;
	protected
		function GetDisplayName: string; override;
	published
		property Name: String read FName write FName;
		property IsGroup: Boolean read FIsGroup write FIsGroup;
	end;

	{ TDependencies }

	TDependencies = class(TCollection)
	private
		FOwner: TObject;
		function GetItem(Index: Integer): TDependency;
		procedure SetItem(Index: Integer; Value: TDependency);
	protected
		function GetOwner: TObject; reintroduce; overload;
	public
		constructor Create(Owner: TObject);
		property Items[Index: Integer]: TDependency read GetItem write SetItem; default;
	end;

  LPVOID = Pointer;
  {$EXTERNALSYM LPVOID}
  LPCVOID = Pointer;
  {$EXTERNALSYM LPCVOID}
  LPLPVOID = ^LPVOID;
  {$NODEFINE LPVOID}

  _SC_ACTION_TYPE = (SC_ACTION_NONE, SC_ACTION_RESTART, SC_ACTION_REBOOT,
    SC_ACTION_RUN_COMMAND);
  {$EXTERNALSYM _SC_ACTION_TYPE}
  SC_ACTION_TYPE = _SC_ACTION_TYPE;
  {$EXTERNALSYM SC_ACTION_TYPE}
  TScActionType = _SC_ACTION_TYPE;

  LPSC_ACTION = ^SC_ACTION;
  {$EXTERNALSYM LPSC_ACTION}
  _SC_ACTION = record
    Type_: SC_ACTION_TYPE;
    Delay: DWORD;
  end;
  {$EXTERNALSYM _SC_ACTION}
  SC_ACTION = _SC_ACTION;
  {$EXTERNALSYM SC_ACTION}
  TScAction = SC_ACTION;
  PScAction = LPSC_ACTION;

  LPSERVICE_FAILURE_ACTIONSA = ^SERVICE_FAILURE_ACTIONSA;
  {$EXTERNALSYM LPSERVICE_FAILURE_ACTIONSA}
  _SERVICE_FAILURE_ACTIONSA = record
    dwResetPeriod: DWORD;
    lpRebootMsg: LPSTR;
    lpCommand: LPSTR;
    cActions: DWORD;
    lpsaActions: LPSC_ACTION;
  end;
  {$EXTERNALSYM _SERVICE_FAILURE_ACTIONSA}
  SERVICE_FAILURE_ACTIONSA = _SERVICE_FAILURE_ACTIONSA;
  {$EXTERNALSYM SERVICE_FAILURE_ACTIONSA}
  TServiceFailureActionsA = SERVICE_FAILURE_ACTIONSA;
  PServiceFailureActionsA = LPSERVICE_FAILURE_ACTIONSA;

  LPSERVICE_FAILURE_ACTIONSW = ^SERVICE_FAILURE_ACTIONSW;
  {$EXTERNALSYM LPSERVICE_FAILURE_ACTIONSW}
  _SERVICE_FAILURE_ACTIONSW = record
    dwResetPeriod: DWORD;
    lpRebootMsg: LPWSTR;
    lpCommand: LPWSTR;
    cActions: DWORD;
    lpsaActions: LPSC_ACTION;
  end;
  {$EXTERNALSYM _SERVICE_FAILURE_ACTIONSW}
  SERVICE_FAILURE_ACTIONSW = _SERVICE_FAILURE_ACTIONSW;
  {$EXTERNALSYM SERVICE_FAILURE_ACTIONSW}
  TServiceFailureActionsW = SERVICE_FAILURE_ACTIONSW;
  PServiceFailureActionsW = LPSERVICE_FAILURE_ACTIONSW;

{$IFDEF UNICODE}
  SERVICE_FAILURE_ACTIONS = SERVICE_FAILURE_ACTIONSW;
  {$EXTERNALSYM SERVICE_FAILURE_ACTIONS}
  LPSERVICE_FAILURE_ACTIONS = LPSERVICE_FAILURE_ACTIONSW;
  {$EXTERNALSYM LPSERVICE_FAILURE_ACTIONS}
  TServiceFailureActions = TServiceFailureActionsW;
  PServiceFailureActions = PServiceFailureActionsW;
{$ELSE}
  SERVICE_FAILURE_ACTIONS = SERVICE_FAILURE_ACTIONSA;
  {$EXTERNALSYM SERVICE_FAILURE_ACTIONS}
  LPSERVICE_FAILURE_ACTIONS = LPSERVICE_FAILURE_ACTIONSA;
  {$EXTERNALSYM LPSERVICE_FAILURE_ACTIONS}
  TServiceFailureActions = TServiceFailureActionsA;
  PServiceFailureActions = PServiceFailureActionsA;
{$ENDIF}

const
  SERVICE_CONFIG_DESCRIPTION     = 1;
  {$EXTERNALSYM SERVICE_CONFIG_DESCRIPTION}
  SERVICE_CONFIG_FAILURE_ACTIONS = 2;
  {$EXTERNALSYM SERVICE_CONFIG_FAILURE_ACTIONS}

{$EXTERNALSYM ChangeServiceConfig2A}
function ChangeServiceConfig2A(
  hService: SC_HANDLE; 
  dwInfoLevel: DWORD;
  lpInfo: LPVOID): BOOL; stdcall;
{$EXTERNALSYM ChangeServiceConfig2W}
function ChangeServiceConfig2W(  
  hService: SC_HANDLE; 
  dwInfoLevel: DWORD;
  lpInfo: LPVOID): BOOL; stdcall;
{$EXTERNALSYM ChangeServiceConfig2}
function ChangeServiceConfig2(  
  hService: SC_HANDLE; 
  dwInfoLevel: DWORD;
  lpInfo: LPVOID): BOOL; stdcall;
{$EXTERNALSYM QueryServiceConfig2A}
function QueryServiceConfig2A(hService: SC_HANDLE;
  dwInfoLevel: DWORD;
  lpServiceConfig: Pointer; cbBufSize: DWORD;
  var pcbBytesNeeded: DWORD): BOOL; stdcall;
{$EXTERNALSYM QueryServiceConfig2W}
function QueryServiceConfig2W(hService: SC_HANDLE;
  dwInfoLevel: DWORD;
  lpServiceConfig: Pointer; cbBufSize: DWORD;
  var pcbBytesNeeded: DWORD): BOOL; stdcall;
{$EXTERNALSYM QueryServiceConfig2}
function QueryServiceConfig2(hService: SC_HANDLE;
  dwInfoLevel: DWORD;
  lpServiceConfig: Pointer; cbBufSize: DWORD;
  var pcbBytesNeeded: DWORD): BOOL; stdcall;
  
type
	TConsoleService = class;

	{ TConsoleService }

	TServiceType = (stWin32, stDevice, stFileSystem);

	TCurrentStatus = (csStopped, csStartPending, csStopPending, csRunning,
		csContinuePending, csPausePending, csPaused);

	TErrorSeverity = (esIgnore, esNormal, esSevere, esCritical);

	TStartType = (stBoot, stSystem, stAuto, stManual, stDisabled);

	TServiceEvent = procedure(Svc: Integer; Sender: TConsoleService) of object;
	TShutdownEvent = procedure(Sender: TConsoleService) of object;
	TContinueEvent = procedure(Sender: TConsoleService; var Continued: Boolean) of object;
	TPauseEvent = procedure(Sender: TConsoleService; var Paused: Boolean) of object;
	TStartEvent = procedure(Sender: TConsoleService; var Started: Boolean) of object;
	TStopEvent = procedure(Sender: TConsoleService; var Stopped: Boolean) of object;

	TConsoleService = class
	private
		FCloseEvent: TSimpleEvent;
		FAllowStop: Boolean;
		FAllowPause: Boolean;
		FDependencies: TDependencies;
		FDisplayName: String;
		FErrCode: DWord;
		FErrorSeverity: TErrorSeverity;
		FEventLogger: TEventLogger;
		FInteractive: Boolean;
		FLoadGroup: String;
		FParams: TStringList;
		FAccountName: String;
		FPassword: String;
		FServiceStartName: String;
		FServiceType: TServiceType;
		FStartType: TStartType;
		FStatus: TCurrentStatus;
		FStatusHandle: THandle;
		FTagID: DWord;
		FWaitHint: Integer;
		FWin32ErrorCode: DWord;
		FBeforeInstall: TServiceEvent;
		FAfterInstall: TServiceEvent;
		FBeforeUninstall: TServiceEvent;
		FAfterUninstall: TServiceEvent;
		FOnContinue: TContinueEvent;
		FOnExecute: TStartEvent;
		FOnPause: TPauseEvent;
		FOnShutdown: TShutdownEvent;
		FOnBeforeStart: TStartEvent;
		FOnStart: TStartEvent;
		FOnStop: TStopEvent;
		function GetDisplayName: String;
		function GetParamCount: Integer;
		function GetParam(Index: Integer): String;
		procedure SetStatus(Value: TCurrentStatus);
		procedure SetDependencies(Value: TDependencies);
		function GetNTDependencies: String;
		function GetNTServiceType: Integer;
		function GetNTStartType: Integer;
		function GetNTErrorSeverity: Integer;
		function GetNTControlsAccepted: Integer;
		procedure SetOnContinue(Value: TContinueEvent);
		procedure SetOnPause(Value: TPauseEvent);
		procedure SetOnStop(Value: TStopEvent);
		function AreDependenciesStored: Boolean;
		procedure SetInteractive(Value: Boolean);
		procedure SetPassword(const Value: string);
		procedure SetServiceStartName(const Value: string);
		function GetServiceStartName: String;
	protected
		procedure Main(Argc: DWord; Argv: PLPSTR); stdcall;
		procedure Controller(CtrlCode: DWord); stdcall;
		procedure DoStart; virtual;
		function DoStop: Boolean; virtual;
		function DoPause: Boolean; virtual;
		function DoContinue: Boolean; virtual;
		procedure DoInterrogate; virtual;
		procedure DoShutdown; virtual;
		procedure RegisterServices(Install, Silent: Boolean);
		procedure ReportStatus;
	public
		constructor Create;
		destructor Destroy; override;
		procedure Run;
		procedure LogMessage(Message: String; EventType: DWord = 1;
			Category: Integer = 0; ID: Integer = 0);
		procedure Terminate;
		property ErrCode: DWord read FErrCode write FErrCode;
		property ParamCount: Integer read GetParamCount;
		property Param[Index: Integer]: String read GetParam;
		property Status: TCurrentStatus read FStatus write SetStatus;
		property Win32ErrCode: DWord read FWin32ErrorCode write FWin32ErrorCode;
	published
		property AllowStop: Boolean read FAllowStop write FAllowStop default True;
		property AllowPause: Boolean read FAllowPause write FAllowPause default True;
		property Dependencies: TDependencies read FDependencies write SetDependencies stored AreDependenciesStored;
		property DisplayName: String read GetDisplayName write FDisplayName;
		property ErrorSeverity: TErrorSeverity read FErrorSeverity write FErrorSeverity default esNormal;
		property Interactive: Boolean read FInteractive write SetInteractive default False;
		property LoadGroup: String read FLoadGroup write FLoadGroup;
		property AccountName: String read FAccountName write FAccountName;
		property Password: String read FPassword write SetPassword;
		property ServiceStartName: String read GetServiceStartName write SetServiceStartName;
		property ServiceType: TServiceType read FServiceType write FServiceType default stWin32;
		property StartType: TStartType read FStartType write FStartType default stAuto;
		property TagID: DWord read FTagID write FTagID default 0;
		property WaitHint: Integer read FWaitHint write FWaitHint default 5000;
		property BeforeInstall: TServiceEvent read FBeforeInstall write FBeforeInstall;
		property AfterInstall: TServiceEvent read FAfterInstall write FAfterInstall;
		property BeforeUninstall: TServiceEvent read FBeforeUninstall write FBeforeUninstall;
		property AfterUninstall: TServiceEvent read FAfterUninstall write FAfterUninstall;
		property OnContinue: TContinueEvent read FOnContinue write SetOnContinue;
		property OnExecute: TStartEvent read FOnExecute write FOnExecute;
		property OnPause: TPauseEvent read FOnPause write SetOnPause;
		property OnShutdown: TShutdownEvent read FOnShutdown write FOnShutdown;
		property OnBeforeStart: TStartEvent read FOnBeforeStart write FOnBeforeStart;
		property OnStart: TStartEvent read FOnStart write FOnStart;
		property OnStop: TStopEvent read FOnStop write SetOnStop;
	end;

	TCustomServiceApplication = class
	protected
		ConsoleService: TConsoleService;
    function GetServiceName: String;
		procedure BeforeStartService(Sender: TConsoleService; var Started: Boolean);virtual; abstract;
		procedure StartService(Sender: TConsoleService; var Started: Boolean);virtual; abstract;
		procedure StopService(Sender: TConsoleService; var Stopped: Boolean);virtual; abstract;
		procedure ContinueService(Sender: TConsoleService; var Continued: Boolean);virtual; abstract;
		procedure ExecuteService(Sender: TConsoleService; var Started: Boolean);virtual; abstract;
		procedure PauseService(Sender: TConsoleService; var Paused: Boolean);virtual; abstract;
		procedure ShutDownService(Sender: TConsoleService);virtual; abstract;
		procedure BeforeInstallService(Svc: Integer; Sender: TConsoleService);virtual; abstract;
		procedure AfterInstallService(Svc: Integer; Sender: TConsoleService);virtual; abstract;
		procedure BeforeUninstallService(Svc: Integer; Sender: TConsoleService);virtual; abstract;
		procedure AfterUninstallService(Svc: Integer; Sender: TConsoleService);virtual; abstract;
		procedure RunInitialize; virtual; abstract;
	public
		constructor Create;
		destructor Destroy; override;
		procedure ShowException(E: Exception);
		procedure HandleException(Sender: TObject);
		procedure Initialize;
		procedure Run;
    property ServiceName: String read GetServiceName;
	end;

  function Installing: Boolean;
  function Registering: Boolean;
  function StartService: Boolean;

  procedure PControllHandler(CtrlCode: DWord); stdcall;
  procedure PServiceMain(Argc: DWORD; Argv: PLPSTR);stdcall;

var
	ServiceMain: TObjectToFarProc;
	ControllHandler: TObjectToFarProc;

implementation

uses
  tServiceMain,
	Consts;

function ChangeServiceConfig2A;   external advapi32 name 'ChangeServiceConfig2A';
function ChangeServiceConfig2W;   external advapi32 name 'ChangeServiceConfig2W';
function ChangeServiceConfig2;   external advapi32 name 'ChangeServiceConfig2A';
function QueryServiceConfig2A;    external advapi32 name 'QueryServiceConfig2A';
function QueryServiceConfig2W;    external advapi32 name 'QueryServiceConfig2W';
function QueryServiceConfig2;    external advapi32 name 'QueryServiceConfig2A';

{ TEventLogger }

constructor TEventLogger.Create(Name: String);
begin
	FName := Name;
	FEventLog := 0;
end;

destructor TEventLogger.Destroy;
begin
	if FEventLog <> 0 then
		DeregisterEventSource(FEventLog);
	inherited Destroy;
end;

procedure TEventLogger.LogMessage(Message: String; EventType: DWord;
	Category: Word; ID: DWord);
var
	P: Pointer;
begin
	P := PChar(Message);
	if FEventLog = 0 then
		FEventLog := RegisterEventSource(nil, PChar(FName));
	ReportEvent(FEventLog, EventType, Category, ID, nil, 1, 0, @P, nil);
end;

{ TDependency }

function TDependency.GetDisplayName: string;
begin
	if Name <> '' then
		Result := Name else
		Result := inherited GetDisplayName;
end;

{ TDependencies }

constructor TDependencies.Create(Owner: TObject);
begin
	FOwner := Owner;
	inherited Create(TDependency);
end;

function TDependencies.GetItem(Index: Integer): TDependency;
begin
	Result := TDependency(inherited GetItem(Index));
end;

procedure TDependencies.SetItem(Index: Integer; Value: TDependency);
begin
	inherited SetItem(Index, TCollectionItem(Value));
end;

function TDependencies.GetOwner: TObject;
begin
	Result := FOwner;
end;

{ TConsoleService }

constructor TConsoleService.Create;
begin
	inherited Create;
	FEventLogger := TEventLogger.Create(ExtractFileName(ParamStr(0)));
	FWaitHint := 5000;
	FInteractive := False;
	FServiceType := stWin32;
	FParams := TStringList.Create;
	FDependencies := TDependencies.Create(Self);
	FErrorSeverity := esNormal;
	FStartType := stAuto;
	FTagID := 0;
	FAllowStop := True;
	FAllowPause := True;
	FCloseEvent := TSimpleEvent.Create;
end;

destructor TConsoleService.Destroy;
begin
	FCloseEvent.Free;
	FParams.Free;
	FEventLogger.Free;
	inherited Destroy;
end;

function TConsoleService.GetDisplayName: String;
begin
	Result := FDisplayName;
end;

procedure TConsoleService.SetInteractive(Value: Boolean);
begin
	if Value = FInteractive then Exit;
	if Value then
	begin
		Password := '';
	end;
	FInteractive := Value;
end;

procedure TConsoleService.SetPassword(const Value: string);
begin
	if Value = FPassword then Exit;
	if Value <> '' then Interactive := False;
	FPassword := Value;
end;

procedure TConsoleService.SetServiceStartName(const Value: string);
begin
	if Value = FServiceStartName then Exit;
	FServiceStartName := Value;
end;

function TConsoleService.GetParamCount: Integer;
begin
	Result := FParams.Count;
end;

function TConsoleService.GetParam(Index: Integer): String;
begin
	Result := FParams[Index];
end;

procedure TConsoleService.SetOnContinue(Value: TContinueEvent);
begin
	FOnContinue := Value;
	AllowPause := True;
end;

procedure TConsoleService.SetOnPause(Value: TPauseEvent);
begin
	FOnPause := Value;
	AllowPause := True;
end;

procedure TConsoleService.SetOnStop(Value: TStopEvent);
begin
	FOnStop := Value;
	AllowStop := True;
end;

function TConsoleService.GetNTDependencies: String;
var
	i, Len: Integer;
	P: PChar;
begin
	Result := '';
	Len := 0;
	for i := 0 to Dependencies.Count - 1 do
	begin
		Inc(Len, Length(Dependencies[i].Name) + 1); // For null-terminator
		if Dependencies[i].IsGroup then Inc(Len);
	end;
	if Len <> 0 then
	begin
		Inc(Len); // For final null-terminator;
		SetLength(Result, Len);
		P := @Result[1];
		for i := 0 to Dependencies.Count - 1 do
		begin
			if Dependencies[i].IsGroup then
			begin
				P^ := SC_GROUP_IDENTIFIER;
				Inc(P);
			end;
			P := StrECopy(P, PChar(Dependencies[i].Name));
			Inc(P);
		end;
		P^ := #0;
	end;
end;

function TConsoleService.GetNTServiceType: Integer;
const
	NTServiceType: array[TServiceType] of Integer = ( SERVICE_WIN32_OWN_PROCESS,
		SERVICE_KERNEL_DRIVER, SERVICE_FILE_SYSTEM_DRIVER);
begin
	Result := NTServiceType[FServiceType];
	if (FServiceType = stWin32) and Interactive then
		Result := Result or SERVICE_INTERACTIVE_PROCESS;
end;

function TConsoleService.GetNTStartType: Integer;
const
	NTStartType: array[TStartType] of Integer = (SERVICE_BOOT_START,
		SERVICE_SYSTEM_START, SERVICE_AUTO_START, SERVICE_DEMAND_START,
		SERVICE_DISABLED);
begin
	Result := NTStartType[FStartType];
	if (FStartType in [stBoot, stSystem]) and (FServiceType <> stDevice) then
		Result := SERVICE_AUTO_START;
end;

function TConsoleService.GetNTErrorSeverity: Integer;
const
	NTErrorSeverity: array[TErrorSeverity] of Integer = (SERVICE_ERROR_IGNORE,
		SERVICE_ERROR_NORMAL, SERVICE_ERROR_SEVERE, SERVICE_ERROR_CRITICAL);
begin
	Result := NTErrorSeverity[FErrorSeverity];
end;

function TConsoleService.GetNTControlsAccepted: Integer;
begin
	Result := SERVICE_ACCEPT_SHUTDOWN;
	if AllowStop then Result := Result or SERVICE_ACCEPT_STOP;
	if AllowPause then Result := Result or SERVICE_ACCEPT_PAUSE_CONTINUE;
end;

procedure TConsoleService.LogMessage(Message: String; EventType: DWord; Category, ID: Integer);
begin
	FEventLogger.LogMessage(Message, EventType, Category, ID);
end;

procedure TConsoleService.ReportStatus;
const
	LastStatus: TCurrentStatus = csStartPending;
	NTServiceStatus: array[TCurrentStatus] of Integer = (SERVICE_STOPPED,
		SERVICE_START_PENDING, SERVICE_STOP_PENDING, SERVICE_RUNNING,
		SERVICE_CONTINUE_PENDING, SERVICE_PAUSE_PENDING, SERVICE_PAUSED);
	PendingStatus: set of TCurrentStatus = [csStartPending, csStopPending,
		csContinuePending, csPausePending];
var
	ServiceStatus: TServiceStatus;
begin
	with ServiceStatus do
	begin
		dwWaitHint := FWaitHint;
		dwServiceType := GetNTServiceType;
		if FStatus = csStartPending then
			dwControlsAccepted := 0 else
			dwControlsAccepted := GetNTControlsAccepted;
		if (FStatus in PendingStatus) and (FStatus = LastStatus) then
			Inc(dwCheckPoint) else
			dwCheckPoint := 0;
		LastStatus := FStatus;
		dwCurrentState := NTServiceStatus[FStatus];
		dwWin32ExitCode := Win32ErrCode;
		dwServiceSpecificExitCode := ErrCode;
		if ErrCode <> 0 then
			dwWin32ExitCode := ERROR_SERVICE_SPECIFIC_ERROR;
		if not SetServiceStatus(FStatusHandle, ServiceStatus) then
			LogMessage(SysErrorMessage(GetLastError));
	end;
end;

procedure TConsoleService.SetStatus(Value: TCurrentStatus);
begin
	FStatus := Value;
{$ifndef debug}
	ReportStatus;
{$endif}
end;

procedure TConsoleService.Controller(CtrlCode: DWord);
begin
  try
	  Case CtrlCode of
		  SERVICE_CONTROL_STOP: DoStop;
		  SERVICE_CONTROL_PAUSE: DoPause;
		  SERVICE_CONTROL_CONTINUE: DoContinue;
		  SERVICE_CONTROL_SHUTDOWN: DoShutDown;
		  SERVICE_CONTROL_INTERROGATE: DoInterrogate;
	  end;
  except
    Application.HandleException(nil);
  end;
end;

procedure TConsoleService.Main(Argc: DWord; Argv: PLPSTR);
type
	PPCharArray = ^TPCharArray;
	TPCharArray = array [0..1024] of PChar;
var
	i: Integer;
	Started: Boolean;
  dwOldProtect: DWORD;
begin
	for i := 0 to Argc - 1 do
		FParams.Add(PPCharArray(Argv)[i]);
{$ifndef debug}
	ControllHandler.POPEDX := $5A;
	ControllHandler.MOVEAX := $B8;
	ControllHandler.SelfPtr := Self;
	ControllHandler.PUSHEAX := $50;
	ControllHandler.PUSHEDX := $52;
  ControllHandler.MOVEAX1 := $B8;
  ControllHandler.JmpOffset := Integer(@TConsoleService.Controller);
  ControllHandler.JMP     := $E0FF;
  if (VirtualProtect(@PControllHandler, SizeOf(ControllHandler), PAGE_READWRITE, @dwOldProtect)) then
  begin
    Windows.MoveMemory(@PControllHandler, @ControllHandler, SizeOf(ControllHandler));
    VirtualProtect(@PControllHandler, SizeOf(ControllHandler), dwOldProtect, @dwOldProtect);
  end;

	FStatusHandle := RegisterServiceCtrlHandler(PChar(ServiceStartName), TFarProc(@PControllHandler));
{$endif}
  try
{$ifndef debug}
	  if (FStatusHandle = 0) then
		  LogMessage(SysErrorMessage(GetLastError))
	  else begin
		  if Assigned(FOnBeforeStart) then FOnBeforeStart(Self, Started);
		  if Started then	DoStart;
	  end;
{$else}
	  if Assigned(FOnBeforeStart) then FOnBeforeStart(Self, Started);
	  if Started then	DoStart;
{$endif}
  except
    Application.HandleException(nil);
  end;
end;

procedure TConsoleService.DoStart;
var
	Result:	Boolean;
begin
	try
		Status := csStartPending;
		try
			if Assigned(FOnStart) then FOnStart(Self, Result);
			if Result then begin
				Status := csRunning;
				if Assigned(FOnExecute) then FOnExecute(Self, Result);
				if Result then begin
					FCloseEvent.WaitFor(INFINITE);
				end;
			end;
			Status := csStopPending;
			if Assigned(FOnStop) then FOnStop(Self, Result);
		finally
			Status := csStopped;
		end;
	except
		on E: Exception do
			LogMessage(Format(SServiceFailed,[SExecute, E.Message]));
	end;
end;

function TConsoleService.DoStop: Boolean;
begin
	Result := True;
	Terminate;
end;

procedure TConsoleService.DoShutdown;
begin
	Status := csStopPending;
	try
		if Assigned(FOnShutdown) then FOnShutdown(Self);
	finally
		Terminate;
	end;
end;

function TConsoleService.AreDependenciesStored: Boolean;
begin
	Result := FDependencies.Count > 0;
end;

function TConsoleService.DoContinue: Boolean;
begin
	Result := True;
	Status := csContinuePending;
	if Assigned(FOnContinue) then FOnContinue(Self, Result);
	if Result then
		Status := csRunning;
end;

procedure TConsoleService.DoInterrogate;
begin
	  ReportStatus;
end;

function TConsoleService.DoPause: Boolean;
begin
	Result := True;
	Status := csPausePending;
	if Assigned(FOnPause) then FOnPause(Self, Result);
  if Result then Status := csPaused;
end;

procedure TConsoleService.SetDependencies(Value: TDependencies);
begin
	FDependencies.Assign(Value);
end;

procedure TConsoleService.Terminate;
begin
	FCloseEvent.SetEvent;
end;

procedure TConsoleService.RegisterServices(Install, Silent: Boolean);

	procedure InstallService(tSvcMgr: Integer);
	var
		TmpTagID, Svc: Integer;
		PTag, PSSN: Pointer;
		Path: string;
    Actions: TServiceFailureActions;
    lpsaActions: array of SC_ACTION;
	begin
		Path := ParamStr(0);
		if Assigned(BeforeInstall) then BeforeInstall(tSvcMgr, Self);
		TmpTagID := TagID;
		if TmpTagID > 0 then PTag := @TmpTagID else PTag := nil;
		if AccountName = '' then PSSN := nil
		else PSSN := PChar(AccountName);
		Svc := CreateService(tSvcMgr, PChar(ServiceStartName), PChar(DisplayName),
												 SERVICE_ALL_ACCESS, GetNTServiceType,
												 GetNTStartType, GetNTErrorSeverity,
												 PChar(Path+' -s'), PChar(LoadGroup),
												 PTag, PChar(GetNTDependencies),
												 PSSN, PChar(Password));
		TagID := TmpTagID;
		if Svc = 0 then
			RaiseLastWin32Error;
      
    Setlength(lpsaActions, 3);
    lpsaActions[0].Delay:=5000;
    lpsaActions[0].Type_:=SC_ACTION_RESTART;
    lpsaActions[1].Delay:=5000;
    lpsaActions[1].Type_:=SC_ACTION_RESTART;
    lpsaActions[2].Delay:=5000;
    lpsaActions[2].Type_:=SC_ACTION_RESTART;
    Actions.dwResetPeriod:=INFINITE;
    Actions.cActions:=3;
    Actions.lpsaActions:=LPSC_ACTION(lpsaActions);
    Actions.lpCommand:=nil;
    Actions.lpRebootMsg:=nil;

    if not ChangeServiceConfig2(Svc, SERVICE_CONFIG_FAILURE_ACTIONS, @Actions) then
      RaiseLastWin32Error;
      
		try
			try
				if Assigned(AfterInstall) then AfterInstall(Svc, Self);
			except
				on E: Exception do begin
					DeleteService(Svc);
					raise;
				end;
			end;
		finally
			CloseServiceHandle(Svc);
		end;
	end;

  procedure ExternalStopService(Svc: Integer);
  var
    lpServiceStatus: TServiceStatus;
  begin
    ControlService(Svc,SERVICE_CONTROL_INTERROGATE,lpServiceStatus);
    if lpServiceStatus.dwCurrentState = SERVICE_RUNNING then
      ControlService(Svc,SERVICE_CONTROL_STOP,lpServiceStatus);
  end;

	procedure UninstallService(tSvcMgr: Integer);
	var
		Svc: Integer;
	begin
		Svc := OpenService(tSvcMgr, PChar(ServiceStartName), SERVICE_ALL_ACCESS);
		if Svc = 0 then RaiseLastWin32Error;
    ExternalStopService(Svc);
		if Assigned(BeforeUninstall) then BeforeUninstall(Svc, Self);
		try
			if not DeleteService(Svc) then RaiseLastWin32Error;
		finally
			if Assigned(AfterUninstall) then AfterUninstall(Svc, Self);
			CloseServiceHandle(Svc);
		end;
	end;


var
	tSvcMgr: Integer;
	Success: Boolean;
	Msg: string;
begin
	Success := True;
	tSvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
	if tSvcMgr = 0 then RaiseLastWin32Error;
	try
			try
				if Install then
					InstallService(tSvcMgr) else
					UninstallService(tSvcMgr)
			except
				on E: Exception do begin
					Success := False;
					if Install then
						Msg := SServiceInstallFailed else
						Msg := SServiceUninstallFailed;
						MessageBox(0,PChar(Format(Msg, [DisplayName, E.Message])), 'Error!',
											 $00042010 or MB_SERVICE_NOTIFICATION);
				end;
			end;
		if Success and not Silent then
			if Install then begin
				MessageBox(0,PChar(SServiceInstallOK), 'Ok!',
										 MB_OK or MB_SYSTEMMODAL or MB_SERVICE_NOTIFICATION)
      end
			else
				MessageBox(0,PChar(SServiceUninstallOK), 'Ok!',
										 MB_OK or MB_SYSTEMMODAL or MB_SERVICE_NOTIFICATION);
	finally
		CloseServiceHandle(tSvcMgr);
	end;
end;

procedure TConsoleService.Run;

	function FindSwitch(const Switch: string): Boolean;
	begin
		Result := FindCmdLineSwitch(Switch, ['-', '/'], True);
	end;

var
  dwOldProtect: DWORD;
{$ifndef debug}
	ServiceStartTable: TServiceTableEntryArray;
{$endif}
begin
{$ifndef debug}
	if FindSwitch('INSTALL') then
		RegisterServices(True, FindSwitch('SILENT')) else
	if FindSwitch('UNINSTALL') then
		RegisterServices(False, FindSwitch('SILENT')) else begin
		ServiceMain.POPEDX := $5A;
		ServiceMain.MOVEAX := $B8;
		ServiceMain.SelfPtr := Self;
		ServiceMain.PUSHEAX := $50;
		ServiceMain.PUSHEDX := $52;
		ServiceMain.MOVEAX1 := $B8;
		ServiceMain.JmpOffset := Integer(@TConsoleService.Main);
		ServiceMain.JMP     := $E0FF;
    if (VirtualProtect(@PServiceMain, SizeOf(ServiceMain), PAGE_READWRITE, @dwOldProtect)) then
    begin
      Windows.MoveMemory(@PServiceMain, @ServiceMain, SizeOf(ServiceMain));
      VirtualProtect(@PServiceMain, SizeOf(ServiceMain), dwOldProtect, @dwOldProtect);
    end;

		SetLength(ServiceStartTable, 2);
		FillChar(ServiceStartTable[0], SizeOf(TServiceTableEntry)*2, 0);
		ServiceStartTable[0].lpServiceName := PChar(ServiceStartName);
		ServiceStartTable[0].lpServiceProc := @PServiceMain;
		StartServiceCtrlDispatcher(ServiceStartTable[0]);
	end;
{$else}
    Main(0, nil);
{$endif}
end;

function TConsoleService.GetServiceStartName: String;
begin
	Result := FServiceStartName;
end;

{ TCustomServiceApplication }

function TCustomServiceApplication.GetServiceName: String;
begin
  Result := ConsoleService.ServiceStartName;
end;

constructor TCustomServiceApplication.Create;
begin
	inherited Create;
	ConsoleService := TConsoleService.Create;
end;

destructor TCustomServiceApplication.Destroy;
begin
	ConsoleService.Free;
	ConsoleService:=nil;
	inherited;
end;

procedure TCustomServiceApplication.Initialize;
begin
	if InitProc <> nil then TProcedure(InitProc);
	with ConsoleService do begin
		OnBeforeStart := BeforeStartService;
		OnStart := StartService;
		OnStop := StopService;
		OnContinue := ContinueService;
		OnExecute := ExecuteService;
		OnPause := PauseService;
		OnShutdown := ShutDownService;
		BeforeInstall := BeforeInstallService;
		AfterInstall :=  AfterInstallService;
		BeforeUninstall := BeforeUninstallService;
		AfterUninstall := AfterUninstallService;
	end;
  RunInitialize;
end;

procedure TCustomServiceApplication.Run;
begin
  try
	  ConsoleService.Run;
  except
    HandleException(Self);
  end;
end;

procedure TCustomServiceApplication.HandleException(Sender: TObject);
begin
	if ExceptObject is Exception then begin
		if not (ExceptObject is EAbort) then
				ShowException(Exception(ExceptObject));
	end else
		SysUtils.ShowException(ExceptObject, ExceptAddr);
end;

procedure TCustomServiceApplication.ShowException(E: Exception);
var
	Msg: string;
begin
	Msg := E.Message;
	if (Msg <> '') and (AnsiLastChar(Msg) > '.') then Msg := Msg + '.';
	if ConsoleService.Interactive then
		MessageBox(0, PChar(Msg), PChar(ServiceName), MB_OK + MB_ICONSTOP)
	else
		ConsoleService.LogMessage(Msg, EVENTLOG_ERROR_TYPE, 0, 0);
end;

procedure PServiceMain(Argc: DWORD; Argv: PLPSTR);stdcall;
begin
  asm
    mov eax, eax
    mov eax, eax
    mov eax, eax
    mov eax, eax
  end;
end;

procedure PControllHandler(CtrlCode: DWord); stdcall;
begin
  asm
    mov eax, eax
    mov eax, eax
    mov eax, eax
    mov eax, eax
  end;
end;

function Installing: Boolean;
begin
	Result := FindCmdLineSwitch('install',['-','\','/'], True) or
						FindCmdLineSwitch('uninstall',['-','\','/'], True);
end;

function Registering: Boolean;
begin
	Result := FindCmdLineSwitch('regserver',['-','\','/'], True) or
						FindCmdLineSwitch('unregserver',['-','\','/'], True);
end;

function StartService: Boolean;
{$ifndef debug}
var
	Mgr, Svc: Integer;
{$endif}
begin
{$ifndef debug}
	Result := False;
	Mgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
	if Mgr <> 0 then
		begin
			Svc := OpenService(Mgr, PChar(Application.ServiceName), SERVICE_ALL_ACCESS);
			Result := Svc <> 0;
			if Result then
				CloseServiceHandle(Svc);
			CloseServiceHandle(Mgr);
		end;
	if Result then
{$endif}
		Result := FindCmdLineSwitch('s',['-','\','/'], True);
end;

end. 