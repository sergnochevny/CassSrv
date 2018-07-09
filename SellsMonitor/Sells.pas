unit Sells;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBSQL, IBDatabase, vIBDB,
  db, dbclient, vIBProvide, IBQuery, IBCustomDataSet, vStdCtrl,
  StdCtrls, Placemnt, ExtCtrls;

const
  __DATE_BEGIN = '%DATE_BEGIN%';
  __DATE_END = '%DATE_END%';
  __SQL = 'Select SUM(a.Total) as TotalSum '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          ' left join "Departs" d on (d.id=c.departid) '+
          'Where '+
          ' (b.oper in (5,10,11)) and (b.chknumber <> a.chknumber) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 '+
          'union all '+
          'Select SUM(a.Total) as TotalSum '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          ' left join "Departs" d on (d.id=c.departid) '+
          'Where '+
          ' (b.oper = 2) and (b.total = 0) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 '+
          'union all '+
          'Select SUM(a.Total) as TotalSum '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          ' left join "Departs" d on (d.id=c.departid) '+
          'Where '+
          ' (b.oper = 2) and '+
          ' (b.paycash <> 0) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 '+
          'union all '+
          'Select SUM(a.Total) as TotalSum '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          ' left join "Departs" d on (d.id=c.departid) '+
          'Where '+
          ' (b.oper = 2) and '+
          ' (b.paycheck <> 0) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 '+
          'union all '+
          'Select SUM(a.Total) as TotalSum '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          ' left join "Departs" d on (d.id=c.departid) '+
          'Where '+
          ' (b.oper = 2) and '+
          ' (b.paycredit <> 0) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 '+
          'union all '+
          'Select SUM(a.Total) as TotalSum '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          ' left join "Departs" d on (d.id=c.departid) '+
          'Where '+
          ' (b.oper = 2) and '+
          ' (b.paycard <> 0) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 ';

  __PathDelimiter   = '\';
  __SalesSQLFile    = 'sales.sql';

type
  TSellsForm = class(TForm)
    lSum: TLabel;
    fsSales: TFormStorage;
    vPSumm: TvPanel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    __DB_FileName: String;
    __DB_user: String;
    __DB_pass: String;    

    function __GetParams: Boolean;
    procedure __cdsAfterOpen(_DataSet: TDataSet);
    procedure __SelectData(var _cds: TClientDataSet; _SQL: String);
    function __GetSells: String;
  public
    { Public declarations }
  end;

var
  SellsForm: TSellsForm;

implementation

uses
  Const_Type, DateUtil, StrUtils;  
  
{$R *.DFM}

function TSellsForm.__GetParams: Boolean;
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

  except
    Result := False;
  end;
end;

procedure TSellsForm.__cdsAfterOpen(_DataSet: TDataSet);
begin
  TClientDataSet(_DataSet).LogChanges:=False;
end;

procedure TSellsForm.__SelectData(var _cds: TClientDataSet; _SQL: String);
var
  _DB: TvIBDataBase;
  _T: TvIBTransaction;
  _Q: TvIBDataSet;
  _P: TvIBDataSetProvider;
begin
  _T := TvIBTransaction.Create(nil);
  _DB := TvIBDataBase.Create(nil);
  try
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
    if not _DB.Connected then
      _DB.Open;                  
    with _T do begin
      Params.Clear;
      Params.Append('read_committed');
      Params.Append('rec_version');
      Params.Append('nowait');
      DefaultDatabase := _DB;
      DefaultAction := taCommit;
    end;
    _Q := TvIBDataSet.Create(nil);
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
    _T.StartTransaction;
    try
      _Q.Prepare;
      _Q.Open;
      _Q.First;
    
      _cds.Data := _P.Data;
      _T.Commit;
    except
      _T.RollBack;
      _P.Free;
      _Q.Free;
      raise;
    end;
    _P.Free;
    _Q.Free;
  finally
    if ( assigned( _DB ) ) then FreeandNil( _DB );
    if ( assigned( _T ) ) then FreeandNil( _T );
  end;
end;

function TSellsForm.__GetSells: String;
var
  _SQL: TStrings;
  _Res: TClientDataSet;
  _Sum: Currency;
begin
  _Sum := 0;
  if __GetParams then begin
    _SQL := TStringList.Create;
    if FileExists(Copy(ParamStr(0), 1, LastDelimiter(__PathDelimiter, ParamStr(0)))+__PathDelimiter+__SalesSQLFile) then begin
      _SQL.LoadFromFile(Copy(ParamStr(0), 1, LastDelimiter(__PathDelimiter, ParamStr(0)))+__PathDelimiter+__SalesSQLFile)
    end      
    else 
      _SQL.Text := __SQL;
    _SQL.Text := ReplaceStr(_SQL.Text, __DATE_BEGIN, DateToStr(Date));
    _SQL.Text := ReplaceStr(_SQL.Text, __DATE_END, DateToStr(IncDay(Date, 1)));
    __SelectData( _Res, _SQL.Text );
    FreeAndNil(_SQL);
    _Res.First;
    while not _Res.Eof do begin
      _Sum := _Sum + _Res.Fields[0].AsCurrency;
      _Res.Next;
    end;
    _Res.Close;
    _Res.Free;
  end;
  Result := CurrToStr(_Sum);
end;

procedure TSellsForm.FormShow(Sender: TObject);
begin
  lSum.Caption := __GetSells;
end;

end.
