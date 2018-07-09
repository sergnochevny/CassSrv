unit Comm_Procedures;

interface
uses
	Windows, SysUtils, Const_Type;

  function OpenConnection(Port_N: ShortInt; BaudRate: Cardinal; ByteSize,
                          Parity, StopBits: Byte; var S_Info: TInfo): Boolean;
	procedure CloseConnection(var S_Info: TInfo);
	function CommandWriteCommBuff(const S_Info: PInfo) :Cardinal; stdcall;
	function WriteCommBuff(const S_Info: PInfo) :Cardinal; stdcall;
  function ReadCommBuff (const S_Info: PInfo; Count: Cardinal): Cardinal; stdcall;
  function CommandReadCommBuff (const S_Info: PInfo; Count: Cardinal): Cardinal; stdcall;
	procedure CleanCommPort(const S_Info: TInfo);
  procedure ClearBreakCommPort(const S_Info: TInfo);
  procedure InitPacket(const S_Info: PInfo);

implementation
uses
	Error_Procedures, Math;

//==============================================================================
//==============================================================================
function CommandWriteCommBuff(const S_Info: PInfo) :Cardinal; stdcall;
var
	  fWriteState, dwLength: Cardinal;
begin
	Result := 0;
	with S_Info^ do begin
		BOOL(fWriteState) := WriteFile(CommInfo^.CommHandle, CommandWriteBuffer^,
										CommandWriteCount, dwLength, nil);
		if BOOL(fWriteState) then Result := dwLength;
	end;
end;

//==============================================================================
//==============================================================================
function WriteCommBuff(const S_Info: PInfo) :Cardinal; stdcall;
var
	  fWriteState, dwLength: Cardinal;
begin
	Result := 0;
	with S_Info^ do begin
		BOOL(fWriteState) := WriteFile(CommInfo^.CommHandle, BigWriteBuffer^, BigWriteCount,
										dwLength, nil);
		if BOOL(fWriteState) then Result := dwLength;
	end;
end;

//==============================================================================
//==============================================================================
function CommandReadCommBuff (const S_Info: PInfo; Count: Cardinal): Cardinal; stdcall;
var
   dwLength: Cardinal;
{$ifdef Comm_Mask}
   dwEvtMask:   	Cardinal;
{$endif}

begin
  Result := 0;
  with S_Info^ do begin
    if BOOL(ReadFile(CommInfo^.CommHandle, CommandReadBuffer^,
							 Count, dwLength, nil)) then result := dwLength;
	  S_Info^.CommandReadCount := Result;
  end;
end;

//==============================================================================
//==============================================================================
function ReadCommBuff (const S_Info: PInfo; Count:Cardinal): Cardinal; stdcall;
var
   dwLength: Cardinal;

begin
   Result := 0;

   with S_Info^ do begin
    if BOOL(ReadFile(CommInfo^.CommHandle, BigReadBuffer^,
            Count, dwLength, nil)) then result := dwLength;
		S_Info^.BigReadCount := Result;
   end;
end;

//==============================================================================
//==============================================================================
function SetDCB(const S_Info: PInfo): Boolean; stdcall;
var
  S: String;
begin
	with S_Info^.CommInfo^ do begin
    S := 'COM'+IntToStr(Port)+': dtr=on';
    result := BuildCommDCB(PChar(S),DCB);
    if result then begin
      DCB.BaudRate := BaudRate;
      DCB.ByteSize := ByteSize;
      DCB.Parity := Parity;
      DCB.StopBits := StopBits;
      result := SetCommState(CommHandle, DCB);
    end;
	end;
end;

//==============================================================================
//==============================================================================
procedure CleanCommPort(const S_Info: TInfo);
begin
	with S_Info.CommInfo^ do
		PurgeComm(CommHandle, PURGE_RXABORT or PURGE_TXABORT
							or PURGE_RXCLEAR or PURGE_TXCLEAR);
end;

//==============================================================================
//==============================================================================
function OpenCommPort(const S_Info: PInfo): Boolean;
begin
	 with S_Info^.CommInfo^ do begin
		CommHandle := CreateFile( PChar('\\.\COM' + IntToStr(Port)),
									GENERIC_READ or GENERIC_WRITE,
									0, SA, OPEN_EXISTING,
									FILE_ATTRIBUTE_NORMAL, 0);
		if BOOL(CommHandle) then begin
{$ifdef Comm_Mask}
			SetCommMask(CommHandle, EV_RXCHAR);
{$endif}
			SetupComm(CommHandle, LenBigRow, LenBigRow);
			SetCommTimeOuts(CommHandle, CommTimeOuts);

			if (SetDCB(S_Info)) then begin
				Connected := True;
			end;
		end;
		Result := Connected;
	 end;
end;

procedure InitPacket(const S_Info: PInfo);
begin
	with S_Info^.CommInfo^ do begin
    ClearCommBreak(CommHandle);
    EscapeCommFunction(CommHandle, SETDTR);
//    EscapeCommFunction(CommHandle, CLRDTR);
//    EscapeCommFunction(CommHandle, SETRTS);
  end;
end;

//==============================================================================
//==============================================================================
procedure CloseCommPort(const S_Info: PInfo);
begin
	with S_Info^.CommInfo^ do begin
    if Connected then begin
		  Connected := false;
      CleanCommPort( S_Info^ );
      CloseHandle(CommHandle);
		  CommHandle := 0;
    end;
	end;
end;

//==============================================================================
//==============================================================================
procedure GetTimeOutsFromIni(Port_N: Integer; 
      var _ReadIntervalTimeout,
	        _ReadTotalTimeoutMultiplier,
	        _ReadTotalTimeoutConstant,
	        _WriteTotalTimeoutMultiplier,
	        _WriteTotalTimeoutConstant: DWORD);
var
    RegIniFileName:    String;
begin
    RegIniFileName := Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0))) + __cfg_com + IntToStr(Port_N)+__iniext;
    if FileExists(RegIniFileName) then begin
      _ReadIntervalTimeout := GetPrivateProfileInt(PChar(SectionCommon), PChar(__kReadIntervalTimeout),
                                       tcReadIntervalTimeout, PChar(RegIniFileName));
      _ReadTotalTimeoutMultiplier := GetPrivateProfileInt(PChar(SectionCommon), PChar(__kReadTotalTimeoutMultiplier),
                                             tcReadTotalTimeoutMultiplier, PChar(RegIniFileName));
      _ReadTotalTimeoutConstant := GetPrivateProfileInt(PChar(SectionCommon), PChar(__kReadTotalTimeoutConstant),
                                             tcReadTotalTimeoutConstant, PChar(RegIniFileName));
      _WriteTotalTimeoutMultiplier := GetPrivateProfileInt(PChar(SectionCommon), PChar(__kWriteTotalTimeoutMultiplier),
                                             tcWriteTotalTimeoutMultiplier, PChar(RegIniFileName));
      _WriteTotalTimeoutConstant := GetPrivateProfileInt(PChar(SectionCommon), PChar(__kWriteTotalTimeoutConstant),
                                             tcWriteTotalTimeoutConstant, PChar(RegIniFileName));
    end  
    else begin
      _ReadIntervalTimeout := tcReadIntervalTimeout;
      _ReadTotalTimeoutMultiplier := tcReadTotalTimeoutMultiplier;
      _ReadTotalTimeoutConstant := tcReadTotalTimeoutConstant;
      _WriteTotalTimeoutMultiplier := tcWriteTotalTimeoutMultiplier;
      _WriteTotalTimeoutConstant := tcWriteTotalTimeoutConstant;
    end;
end;

//==============================================================================
//==============================================================================
function Initialize_General_Struct(Port_N: Integer; var S_Info: TInfo): Boolean;
var
	H_Info: Cardinal;
begin
	Result := False;
	GetMem(Pointer(H_Info), Size_Info);
	If BOOL(H_Info) then begin
		S_Info := PInfo(H_Info)^;
		GetMem(Pointer(S_Info.H_CommInfo), Size_CommInfo);
		if BOOL(S_Info.H_CommInfo) then begin
			GetMem(Pointer(S_Info.H_CommandWriteBuffer), Size_Buffer);
			if not BOOL(S_Info.H_CommandWriteBuffer) then begin ErrorMsg; exit; end;
			GetMem(Pointer(S_Info.H_CommandReadBuffer), Size_Buffer);
			if not BOOL(S_Info.H_CommandReadBuffer) then begin ErrorMsg; exit; end;
			GetMem(Pointer(S_Info.H_BigWriteBuffer), Size_BigBuffer);
			if not BOOL(S_Info.H_BigWriteBuffer) then begin ErrorMsg; exit; end;
			GetMem(Pointer(S_Info.H_BigReadBuffer), Size_BigBuffer);
			if not BOOL(S_Info.H_BigReadBuffer) then begin ErrorMsg; exit; end;
			with S_Info.CommInfo^ do begin
				with CommTimeOuts do 
          GetTimeOutsFromIni(Port_N, ReadIntervalTimeout,
                                    ReadTotalTimeoutMultiplier,
                                    ReadTotalTimeoutConstant,
                                    WriteTotalTimeoutMultiplier,
                                    WriteTotalTimeoutConstant);
        FillChar(DCB, sizeof(DCB), $00);
				DCB.DCBlength := SizeOf(TDCB);
				GetMem(Pointer(pSD), SECURITY_DESCRIPTOR_MIN_LENGTH);
				if BOOL(pSD) then begin
					if InitializeSecurityDescriptor(SD, Size_SD) then begin
						GetMem(Pointer(pSA), Size_SA);
						if BOOL(pSA) then begin
							SA^.nLength := Size_SA;
							SA^.lpSecurityDescriptor := SD;
							SA^.bInheritHandle := false;
						end;
					end;
				end;
				Result := True;
			end;
		end
		else ErrorMsg;
	end
	else ErrorMsg;
end;

//==============================================================================
//==============================================================================
procedure Finalize_General_Struct(var S_Info: TInfo);
var
	H_Info: Pointer;
begin
  with S_Info do begin
    if BOOL(CommInfo^.pSD) then FreeMem(Pointer(CommInfo^.pSD));
    if BOOL(CommInfo^.pSA) then FreeMem(Pointer(CommInfo^.pSA));
    if BOOL(H_CommandWriteBuffer) then FreeMem(Pointer(H_CommandWriteBuffer));
    if BOOL(H_CommandReadBuffer) then FreeMem(Pointer(H_CommandReadBuffer));
    if BOOL(H_BigReadBuffer) then FreeMem(Pointer(H_BigReadBuffer));
    if BOOL(H_BigWriteBuffer) then FreeMem(Pointer(H_BigWriteBuffer));
    if BOOL(H_CommInfo) then FreeMem(Pointer(H_CommInfo));
  end;
end;

//==============================================================================
//==============================================================================
procedure SetNumberPort(Port_N: ShortInt; const S_Info: PInfo);
begin
	with S_Info^.CommInfo^ do begin
		if Port_N > 0 then Port := Port_N
		else Port := PortN2;
	end;
end;

//==============================================================================
//==============================================================================
procedure ClearBreakCommPort(const S_Info: TInfo);
var
   CommState: TComStat;
   dwErrorFlags: Cardinal;
begin
	with S_Info.CommInfo^ do
    ClearCommError(CommHandle, dwErrorFlags, @CommState);
end;

//==============================================================================
//==============================================================================
function OpenConnection(Port_N: ShortInt; BaudRate: Cardinal; ByteSize,
    Parity, StopBits: Byte; var S_Info: TInfo): Boolean;
begin
	Result := Initialize_General_Struct(Port_N, S_Info);
	if Result then begin
    S_Info.CommInfo^.BaudRate := BaudRate;
    S_Info.CommInfo^.ByteSize := ByteSize;
    S_Info.CommInfo^.Parity := Parity;
    S_Info.CommInfo^.StopBits := StopBits;
		SetNumberPort(Port_N, @S_Info);
		Result := OpenCommPort(@S_Info);
		if Result then begin
{$ifdef Process_Priority}
			S_Info.OldPriority := Windows.GetThreadPriority(GetCurrentThread());
//			Windows.SetThreadPriority(GetCurrentThread(),THREAD_PRIORITY_ABOVE_NORMAL);
			Windows.SetThreadPriority(GetCurrentThread(),THREAD_PRIORITY_ABOVE_NORMAL);
{$endif}
		end;
	end;
end;

//==============================================================================
//==============================================================================
procedure CloseConnection(var S_Info: TInfo);
begin
	if Assigned(@S_Info) then begin
		CloseCommPort(@S_Info);
{$ifdef Process_Priority}
		Windows.SetThreadPriority(GetCurrentThread(), S_Info.OldPriority);
{$endif}
		Finalize_General_Struct(S_Info);
	end;
end;

end.
