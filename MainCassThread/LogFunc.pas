unit LogFunc;

interface
uses
	Windows, StrUtils, SysUtils;

type
  
 	TEventLogger = class(TObject)
	private
		FName: String;
		FEventLog: Integer;
	public
		constructor Create(Name: String);
		destructor Destroy; override;
		procedure LogMessage(Message: String; EventType: DWord = 1; Category: Word = 0; ID: DWord = 0);
		procedure LogError(Message: String);
		procedure LogWarning(Message: String);
		procedure LogInformation(Message: String);
		procedure LogSucces(Message: String);
	end;

  TLog = class
  private
    __FullName: String;
    __Name: String;
    __HandleLog:	Cardinal;
    __EnableLog:	Boolean;
  
    procedure OpenLog;
    procedure CloseLog;
    procedure CheckLog;
  public
    constructor Create(_Name: String);
    destructor Destroy; override;
    procedure WriteToLog(_P: Pointer; _Amount: Cardinal);
  end;
  
const
	SizeDelim			= 2;
	DelimLofFile: WORD	= WORD($0A0D);

implementation

uses 
  Const_Type;
  
//-----------------------------------------------------------------------------
//                TEventLogger class
//-----------------------------------------------------------------------------

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

procedure TEventLogger.LogError(Message: String);
begin
  LogMessage(Message, EVENTLOG_ERROR_TYPE);
end;

procedure TEventLogger.LogInformation(Message: String);
begin
  LogMessage(Message, EVENTLOG_INFORMATION_TYPE);
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

procedure TEventLogger.LogSucces(Message: String);
begin
  LogMessage(Message, EVENTLOG_SUCCESS);
end;

procedure TEventLogger.LogWarning(Message: String);
begin
  LogMessage(Message, EVENTLOG_WARNING_TYPE);
end;

//-----------------------------------------------------------------------------
//                TLog class
//-----------------------------------------------------------------------------

constructor TLog.Create(_Name: String);
begin
  inherited Create;
	__Name := _Name;
  __FullName := __Name+ReplaceStr(DateTimeToStr(Date),'.','')+__logext;
  OpenLog;
end;

destructor TLog.Destroy;
begin
  CloseLog;
  inherited;
end;

//=======================================================================OpenLog
procedure TLog.OpenLog;
begin
	__HandleLog := CreateFile(PChar(__FullName), GENERIC_READ or GENERIC_WRITE,
							 FILE_SHARE_READ, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
	__EnableLog := (__HandleLog <> INVALID_HANDLE_VALUE)and(__HandleLog > 0);
  if __EnableLog then
    SetFilePointer(__HandleLog, 0, nil, FILE_END);
end;

//====================================================================WriteToLog
procedure TLog.WriteToLog(_P: Pointer; _Amount: Cardinal);
var
	_AmountWritten:	Cardinal;
begin
//  CheckLog;
	if __EnableLog then begin
		_AmountWritten := 0;
		if WriteFile(__HandleLog, _P^, _Amount, _AmountWritten, nil) then
			if BOOL(_AmountWritten) then
				WriteFile(__HandleLog, DelimLofFile, SizeDelim, _AmountWritten, nil);
	end;
end;

procedure TLog.CloseLog;
begin
	if __EnableLog then begin
    CloseHandle(__HandleLog);
    __HandleLog := 0;
  end;
end;

procedure TLog.CheckLog;
var 
  _Name: String;
begin
  _Name := __Name + ReplaceStr(DateTimeToStr(Date),'.','')+__logext;
  if BOOL(CompareStr(__FullName, _Name)) then begin
    CloseLog;
    __FullName := __Name + ReplaceStr(DateTimeToStr(Date),'.','')+__logext;
    OpenLog;
  end;
end;

end.
