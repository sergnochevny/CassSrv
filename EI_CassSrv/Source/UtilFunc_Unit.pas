unit UtilFunc_Unit;

interface
uses
    Forms,
    Windows,
    SysUtils,
    db,
    dbclient,
    dbtables,
    vIBDB, 
    Classes,
    MemoryFunc,
    ShowErrorFunc,
    fDbGrid,
    ConstVarUnit,
    FormInfMsg;

function TryEdit(DataSet: TDataSet; Timeout: cardinal): boolean;
function TryInsert(DataSet: TDataSet; Timeout: cardinal): boolean;
procedure ShowDebugGrig(cds: TDataSet);

procedure ShowInformMemo(var Strings: TStrings);
function CreateFields_cdsGoods(var cds: TClientDataSet; Sync: Boolean = false): Boolean;
function CreateFields_cdsBarCode(var cds: TClientDataSet): Boolean;
function GetTokenJournalize: Boolean;
procedure AddMsgToJournal(const Msg: String);
procedure SaveJournal;
function GetValuesFromIni: Boolean;

implementation

//=======================================================================TryEdit
function TryEdit(DataSet: TDataSet; Timeout: cardinal): boolean;
var
    i: cardinal;
begin
    i:=GetTickCount+Timeout;
    repeat
        try
            DataSet.Edit;
        except
            Sleep(10);
        end;
    until (GetTickCount>i) or (DataSet.State=dsEdit);
    Result:=DataSet.State=dsEdit;
end;

//=====================================================================TryInsert
function TryInsert(DataSet: TDataSet; Timeout: cardinal): boolean;
var
    i: cardinal;
begin
    i:=GetTickCount+Timeout;
    repeat
        try
            DataSet.Append;
        except
            Sleep(10);
        end;
    until (GetTickCount>i) or (DataSet.State=dsInsert);
    Result:=DataSet.State=dsInsert;
end;

//=================================================================ShowDebugGrig
procedure ShowDebugGrig(cds: TDataSet);
begin
    frmDbGrid:=TfrmDbGrid.Create(nil);
    frmDbGrid.ds.DataSet:=TDataSet(cds);
    frmDbGrid.Caption:=TDataSet(cds).Name;
    if cds.ClassType = TvIBDataSet then
      frmDbGrid.Memo1.Text := TvIBDataSet(cds).SQL.Text;
    frmDbGrid.ShowModal;
    frmDbGrid.Free;
end;

//=================================================================ShowErrorMemo
procedure ShowInformMemo(var Strings: TStrings);
begin
    case TokenLog of
        TokenLogShow: begin
            if ((Strings <> nil)and(Strings.Count > 0)) then begin
                FormMsg := TFormMsg.Create(nil);
                FormMsg.ErrorMemo.Lines.AddStrings(Strings);
                FormMsg.ShowModal;
                FormMsg.Free;
            end;
        end;
        TokenLogWrite: begin
            Strings.SaveToFile(LogFileName);
        end;
    end;
    Strings.Free;
    Strings := nil;
end;

//=========================================================CreateFields_cdsGoods
function CreateFields_cdsGoods(var cds: TClientDataSet; Sync: Boolean = false): Boolean;
begin
    Result := false;
    try
        with cds.FieldDefs do begin
            Clear;
            with AddFieldDef do begin
                Name := 'IncrMTU';
                DataType := ftInteger;
                Required:=True;
            end;
            with AddFieldDef do begin
                Name := 'LocalCode';
                DataType :=ftInteger;
                Required:=true;
            end;
            with AddFieldDef do begin
                Name := 'Name';
                DataType := ftString;
                Size := 64;
                Required:=True;
            end;
            with AddFieldDef do begin
                Name := 'ShortName';
                DataType := ftString;
                Size := 64;
                Required:=False;
            end;
            with AddFieldDef do begin
                Name := 'BarCode';
                DataType := ftString;
                Required:=false;
            end;
            if not Sync then begin
                with AddFieldDef do begin
                    Name := 'Department';
                    DataType :=ftSmallInt;
                    Required:=false;
                end;
                with AddFieldDef do begin
                    Name := 'TaxGroup';
                    DataType :=ftSmallInt;
                    Required:=false;
                end;
                with AddFieldDef do begin
                    Name := 'Price';
                    DataType := ftCurrency;
                    Required:=True;
                end;
                with AddFieldDef do begin
                    Name := 'Count';
                    DataType :=ftFloat;
                    Required:=True;
                end;
                with AddFieldDef do begin
                    Name := 'Dividable';
                    DataType := ftInteger;
                    Required:=True;
                end;
                with AddFieldDef do begin
                    Name := 'ValidCount';
                    DataType := ftInteger;
                    Required:=True;
                end;
            end;
            with AddFieldDef do begin
                Name := 'IncrEd';
                DataType := ftInteger;
                Required:=false;
            end;
        end;
        cds.CreateDataSet;
        Result := True;
    except
        MessageBox(TempHandle, PChar(Format(ErDatSetCreate,[cds.Name])),
                   PChar(Error), MB_OK or MB_TOPMOST);
    end;
end;

//=======================================================CreateFields_cdsBarCode
function CreateFields_cdsBarCode(var cds: TClientDataSet): Boolean;
begin
    Result := false;
    try
        with cds.FieldDefs do begin
            Clear;
            with AddFieldDef do begin
                Name := 'IncrMTU';
                DataType := ftInteger;
                Required:=True;
            end;
            with AddFieldDef do begin
                Name := 'LocalCode';
                DataType :=ftInteger;
                Required:=true;
            end;
            with AddFieldDef do begin
                Name := 'Name';
                DataType := ftString;
                Size := 64;
                Required:=True;
            end;
            with AddFieldDef do begin
                Name := 'BarCode';
                DataType := ftString;
                Required:=false;
            end;
            with AddFieldDef do begin
                Name := 'Scale';
                DataType := ftFloat;
                Required:=false;
            end;
        end;
        with cds.IndexDefs do begin
          Clear;
          with AddIndexDef do begin
            Name := 'IncrMTUIdx';
            Fields := 'IncrMTU';
            Options := [];
          end;
          with AddIndexDef do begin
            Name := 'LocalCode_BarCode';
            Fields := 'LocalCode;BarCode';
            Options := [];
          end;
        end;
        cds.CreateDataSet;
        Result := True;
    except
        MessageBox(TempHandle, PChar(Format(ErDatSetCreate,[cds.Name])),
                   PChar(Error), MB_OK or MB_TOPMOST);
    end;
end;

//============================================================GetTokenJournalize
function GetTokenJournalize: Boolean;
var
    Value,
    SizeValue,
    rType,
    Disposition:    DWORD;
    SubKey:         HKEY;

begin
    Result := False;
    if RegCreateKeyEx(RKey, PChar(RSubKey), 0, PChar(RClass), dwROptions,
                      KEY_READ or KEY_WRITE, nil, SubKey, @Disposition) = ERROR_SUCCESS then begin
        SizeValue := SizeOf(DWORD);
        case Disposition of
            rOpen: begin
                if RegQueryValueEx(SubKey, PChar(NameVal), nil,
                                   @rType, @Value, @SizeValue) = ERROR_SUCCESS then begin
                    if rType = REG_DWORD then
                        Result := Boolean(Value);
                end
                else ShowSystemErrorMsg;
            end;
            rCreate: begin
                Value := 0;
                if RegSetValueEx(SubKey, PChar(NameVal), 0,
                                 REG_DWORD, @Value, SizeValue)<> ERROR_SUCCESS then
                    ShowSystemErrorMsg;
            end;
        end;
        RegCloseKey(SubKey);
        RegCloseKey(RKey);
    end
    else ShowSystemErrorMsg;
end;

//===============================================================AddMsgToJournal
procedure AddMsgToJournal(const Msg: String);
begin
    if Journalize then begin
        if Journal = nil then Journal := TStringList.Create;
        Journal.Append(Msg);
    end;
end;

//===================================================================SaveJournal
procedure SaveJournal;
begin
    if Journalize and (Journal <> nil) then begin
        Journal.SaveToFile(JournalName);
        Journal.Free;
        Journal := nil;
    end;
end;

//==============================================================GetValuesFromIni
function GetValuesFromIni: Boolean;
var
    K:          DWORD;
    TempStr:    String;
begin
    Result := True;
    RegIniFileName := Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0))) + RegIniFileNameC;
    SetLength(TempStr, LenIniStr);
    FillChar(Pointer(TempStr)^, LenIniStr, $0);
    K := GetPrivateProfileString(SectionCommon, PathBasaK,
                                 Null_Str, PChar(TempStr), LenIniStr,
                                 PChar(RegIniFileName));
    sDatabaseName := trim(TempStr);
    if (sDatabaseName = '') or (not BOOL(K)) then begin
        Result := false;
        exit;
    end;
    FillChar(Pointer(TempStr)^, LenIniStr, $0);
    K := GetPrivateProfileString(SectionDB, PathBasaK,
                                 Null_Str, PChar(TempStr), LenIniStr,
                                 PChar(RegIniFileName));
    sDBName := trim(TempStr);
    if (sDBName = '') or (not BOOL(K)) then begin
        Result := false;
        exit;
    end;
    FillChar(Pointer(TempStr)^, LenIniStr, $0);
    GetPrivateProfileString(SectionFiles, ImpFileNameK,
                            DefImpFileName, PChar(TempStr), LenIniStr,
                            PChar(RegIniFileName));
    ImpFileName := Trim(TempStr);
    if (ImpFileName = '') then ImpFileName := DefImpFileName;
    FillChar(Pointer(TempStr)^, LenIniStr, $0);
    GetPrivateProfileString(SectionFiles, ExpFileNameK,
                            DefExpFileName, PChar(TempStr), LenIniStr,
                            PChar(RegIniFileName));
    ExpFileName := Trim(TempStr);
    if (ExpFileName = '') then ExpFileName := DefExpFileName;
    FillChar(Pointer(TempStr)^, LenIniStr, $0);
    GetPrivateProfileString(SectionFiles, SyncFileNameK,
                            DefSyncFileName, PChar(TempStr), LenIniStr,
                            PChar(RegIniFileName));
    SyncFileName := Trim(TempStr);
    if (SyncFileName = '') then SyncFileName := DefSyncFileName;
    TokenLog := GetPrivateProfileInt(SectionTokens, TokenLogK,
                                     DefTokenLog, PChar(RegIniFileName));
    TokenWriteWOSn := GetPrivateProfileInt(SectionTokens, TokenWriteWOSnK,
                                           DefTokenWriteWOSn, PChar(RegIniFileName));
    DVer := GetPrivateProfileInt(SectionCommon, DVerK,
                                           DefDVer, PChar(RegIniFileName));
    ChngCode := GetPrivateProfileInt(SectionCommon, ChngCodeK,
                                           DefChngCode, PChar(RegIniFileName));
    WDep := GetPrivateProfileInt(SectionCommon, WDepK,
                                           DefWDep, PChar(RegIniFileName));
    TDebug := GetPrivateProfileInt(SectionCommon, TDebugK,
                                           DefTDebug, PChar(RegIniFileName));
    Pack := GetPrivateProfileInt(SectionCommon, PackK,
                                           DefPack, PChar(RegIniFileName));
    DelF := GetPrivateProfileInt(SectionCommon, DelFK,
                                           DefDelF, PChar(RegIniFileName));
    ShowProgr := GetPrivateProfileInt(SectionCommon, ShowProgrK,
                                           DefShowProgr, PChar(RegIniFileName));
                                           
end;

end.
