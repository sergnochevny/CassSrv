library EI_CassSrv;

uses
  FastMM4 in '..\..\..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\..\..\FastMM\FastMM4Messages.pas',
  Forms,
  StrFunc,
  SysUtils,
  ConstVarUnit in '..\ConstVarUnit.pas',
  fDbGrid in '..\Debugform\fDbGrid.pas',
  dReplica in '..\dReplica.pas',
  FormInfMsg in '..\FormInfMsg.pas' {FormMsg},
  UtilFunc_Unit in '..\UtilFunc_Unit.pas',
  Handle_Unit in '..\Handle_Unit.pas',
  ProgressForm in '..\ProgressForm.pas' {ProgressF};

{$R ../ECR.res}
    
//===================================================================InitLibrary
function InitLibrary(Value: OleVariant): OleVariant; stdcall;
var
    Intermed_Str:   String;
begin
    Result := '0';
    Journalize := GetTokenJournalize;
    TokenHandle := GetValuesFromIni;
    if (not (VarIsNull(Value) or VarIsEmpty(Value))) then try
        Intermed_Str := VarToStr(Value);
        AddMsgToJournal('InializeLibrary ' + Intermed_Str);
        TempHandle := Application.Handle;
        Application.Handle := StrToInt(Intermed_Str);
        Result := '1';
    except
        TokenHandle := False;
    end;
    Result:=VarAsType(Result, VarOleStr);
end;

//====================================================================ExportData
function ExportData(Value: OleVariant): OleVariant; stdcall;
var
    BCountRow:  Integer;
begin
    Result := '0;0';
    try
        if not TokenHandle then raise Exception.Create(NotDataMsg);
        Result := IntToStr(ParseIncomFile(ExpFileName, BCountRow));
        Result := Result + ';' + IntToStr(BCountRow);
    except
        Result := '-3;0';
    end;
    AddMsgToJournal('ExportData ' + ExpFileName);
    SaveJournal;
    Application.Handle := TempHandle;
    Result:=VarAsType(Result, VarOleStr);
end;

//====================================================================ImportData
function ImportData(Value: OleVariant): OleVariant; stdcall;
var
    tSqlFile,
    Intermed_Str:   String;
begin
    Result := '0';
    try
        if not TokenHandle then raise Exception.Create(NotDataMsg);
        if not (VarIsNull(Value) or VarIsEmpty(Value)) then begin
            Intermed_Str := VarToStr(Value);
            tSQLFile := ExtractWord(Intermed_Str, Str_Delimiter, 6);
            if ( length(tSQLFile)>0 ) then SQLFile := Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0))) + tSQLFile
            else SQLFile := Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0))) + SQLFileName;
            RecWriteCount := 0;
            Result := IntToStr(CreateOutgoinFile(ImpFileName,
                                ExtractWord(Intermed_Str, Str_Delimiter, 1),
                                StrToInt(ExtractWord(Intermed_Str, Str_Delimiter, 2)),
                                StrToInt(ExtractWord(Intermed_Str, Str_Delimiter, 3)),
                                StrToInt(ExtractWord(Intermed_Str, Str_Delimiter, 4)),
                                StrToInt(ExtractWord(Intermed_Str, Str_Delimiter, 5))));
            AddMsgToJournal('ImportData ' + Intermed_Str);
            SaveJournal;
        end;
    except
        Result := '-3';
    end;
    Application.Handle := TempHandle;
    Result:=VarAsType(Result, VarOleStr);
end;

exports
    ExportData,
    ImportData,
    InitLibrary;

begin
    isMultiThread := True;
end.
