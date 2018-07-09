unit DBObj;

interface
  uses  Windows, Messages,
  Const_Type, SysUtils,
  IBSQL, IBDatabase, vIBDB, myIBEvents,
  db, dbclient,
{$ifdef debug}  
  fDbGrid, 
{$endif}   
  vIBProvide, IBQuery;  

type  

  PDBObj = ^TDBObj;
  TDBObj = class
    protected
      __DB_FileName,
      __DB_user,
      __DB_pass   : String;

      procedure __InitDB; virtual;
    private
      __T: TvIBTransaction;
      __DB: TvIBDataBase;

      __LogCheck: Boolean;
      
      function __GetParams: Boolean;
      procedure __cdsAfterOpen(_DataSet: TDataSet);
    public
      constructor Create;
      destructor Destroy; override;
      procedure SelectData(var _cds: TClientDataSet; _Sql: String);
{$ifdef debug}
      procedure ShowDebugGrid(_cds: TDataSet);
{$endif}   
      property DB: TvIBDataBase read __DB;
      property LogCheck: Boolean read __LogCheck;
  end;

  __PDBObj = ^__TDBObj;
  __TDBObj = class(TDBObj)
    public
      function GetPorts(_where: String = ''): TClientDataSet;
  end;

implementation

{ TDBObj }

procedure TDBObj.__cdsAfterOpen(_DataSet: TDataSet);
begin
  TClientDataSet(_DataSet).LogChanges:=False;
end;

constructor TDBObj.Create;
begin
  __LogCheck := False;
  if __GetParams then __InitDB;
end;

destructor TDBObj.Destroy;
begin
  if ( assigned( __DB ) ) then FreeandNil( __DB );
  if ( assigned( __T ) ) then FreeandNil( __T );
end;

function TDBObj.__GetParams: Boolean;
var
  _RegIniFileName: String;
  _K:              DWORD;
  _TempStr:        String;
begin
  Result := True;
  try
    _RegIniFileName := Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0))) + RegIniFileNameC;

    SetLength(_TempStr, LenIniStr);
    FillChar(Pointer(_TempStr)^, LenIniStr, $0);
    _K:=GetPrivateProfileString(PChar(SectionCommon), PChar(DBK),
                              PChar(Def_DB_FileName), PChar(_TempStr), LenIniStr,
                              PChar(_RegIniFileName));
    __DB_FileName := Trim(_TempStr);
    if (__DB_FileName = '')or(not BOOL(_K)) then __DB_FileName := Def_DB_FileName;

    SetLength(_TempStr, LenIniStr);
    FillChar(Pointer(_TempStr)^, LenIniStr, $0);
    _K:=GetPrivateProfileString(PChar(SectionCommon), PChar(DBUserK),
                              PChar(Def_DB_user), PChar(_TempStr), LenIniStr,
                              PChar(_RegIniFileName));
    __DB_user := Trim(_TempStr);
    if (__DB_user = '')or(not BOOL(_K)) then __DB_user := Def_DB_user;

    SetLength(_TempStr, LenIniStr);
    FillChar(Pointer(_TempStr)^, LenIniStr, $0);
    _K:=GetPrivateProfileString(PChar(SectionCommon), PChar(DBPassK),
                              PChar(Def_DB_pass), PChar(_TempStr), LenIniStr,
                              PChar(_RegIniFileName));
    __DB_pass := Trim(_TempStr);
    if (__DB_pass = '')or(not BOOL(_K)) then __DB_pass := Def_DB_pass;

	  __LogCheck := BOOL(GetPrivateProfileInt(PChar(SectionCommon), PChar(LogCheckK), 
                                            Def_LogCheck, PChar(_RegIniFileName)));
  except
    Result := False;
  end;
end;

procedure TDBObj.__InitDB;
begin
  __T := TvIBTransaction.Create(nil);
  if not Assigned(__DB) then begin
    __DB := TvIBDataBase.Create(nil);
    With __DB do begin
      DatabaseName := __DB_FileName;
      Params.Clear;
      Params.Append('user_name=' + __DB_user);
      Params.Append('password=' + __DB_pass);
      Params.Append('lc_ctype=WIN1251');
      LoginPrompt := False;
      SQLDialect := 3;
      TraceFlags := [];
    end;
    if not __DB.Connected then
      __DB.Open;
  end;
  with __T do begin
    Params.Clear;
    Params.Append('read_committed');
    Params.Append('rec_version');
    Params.Append('nowait');
    DefaultDatabase := __DB;
    DefaultAction := taCommit;
  end;

end;

{$ifdef debug}
procedure TDBObj.ShowDebugGrid(_cds: TDataSet);
begin
    frmDbGrid:=TfrmDbGrid.Create(nil);
    frmDbGrid.ds.DataSet:=TDataSet(_cds);
    frmDbGrid.Caption:=TDataSet(_cds).Name;
    frmDbGrid.ShowModal;
    frmDbGrid.Free;
end;
{$endif}

procedure TDBObj.SelectData(var _cds: TClientDataSet; _SQL: String);
var
//>>>>>>>>>>>>>>>>>>>>>>>>>>>
  _DB: TvIBDataBase;
  _T: TvIBTransaction;
//>>>>>>>>>>>>>>>>>>>>>>>>>>>  
  _Q: TvIBDataSet;
  _P: TvIBDataSetProvider;
begin
  try
    _DB := TvIBDataBase.Create(nil);
    With _DB do begin
      DatabaseName := __DB_FileName;
      Params.Clear;
      Params.Append('user_name=' + __DB_user);
      Params.Append('password=' + __DB_pass);
      Params.Append('lc_ctype=WIN1251');
      LoginPrompt := False;
      SQLDialect := 3;
      TraceFlags := [];
    end;
    if not _DB.Connected then _DB.Open;
    _T := TvIBTransaction.Create(nil);
    with _T do begin
      Params.Clear;
      Params.Append('read_committed');
      Params.Append('rec_version');
      Params.Append('nowait');
      DefaultDatabase := _DB;
      DefaultAction := taCommit;
    end;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>

    _Q := TvIBDataSet.Create(nil);
//    _Q.Database := __DB;
//    _Q.Transaction := __T;
    _Q.Database := _DB;
    _Q.Transaction := _T;
    _Q.BufferChunks := 10000;
    _Q.CachedUpdates := False;
    _Q.RequestLive := False;

    _Q.SQL.Clear;
    _Q.SQL.Append(_SQL);

    _cds := TClientDataSet.Create(nil);
    _cds.AfterOpen := __cdsAfterOpen;
    _P := TvIBDataSetProvider.Create(nil);
    _P.DataSet := _Q;
    __T.StartTransaction;
    try
      _Q.Prepare;
      _Q.Open;
      _Q.First;
    
      _cds.Data := _P.Data;
  {$ifdef debug}
  //    ShowDebugGrid(cds);
  {$endif}    
      _T.Commit;
    except
      _T.RollBack;
    end;
  finally
    _P.Free;
    _Q.Free;
    _T.Free;
    _DB.Free;
  end;  
end;

{ __TDBObj }

function __TDBObj.GetPorts(_where: String = ''): TClientDataSet;
var
  _SQL: String;
begin
  _SQL := __select__+__all__+__from__+'"Ports" p';
  if Length( _where )>0 then
    _SQL := _SQL + __where__ + _where;
  SelectData( Result, _SQL );
end;

end.
