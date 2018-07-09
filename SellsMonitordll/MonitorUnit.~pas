unit MonitorUnit;

interface

uses
  Windows, SysUtils, Classes,
  IBSQL, IBDatabase, vIBDB,
  db, dbclient, vIBProvide, IBQuery, IBCustomDataSet;

const
  __DATE_BEGIN = '%DATE_BEGIN%';
  __DATE_END = '%DATE_END%';
  __SQL = 'Select SUM(a.Total) as TotalSum, COUNT(Distinct a.ChkNumber) as CheckCount '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          'Where '+
          ' (((b.oper = 2) and (b.total = 0)) or '+
          ' ((b.oper = 2) and (b.total <> 0)) or '+
          ' ((b.oper in (5,10,11)) and (b.chknumber <> a.chknumber))) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 '+
          'union all '+
          'Select SUM(a.Total) as TotalSum, COUNT(Distinct a.ChkNumber) as CheckCount '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          'Where '+
          ' (b.oper = 2) and '+
          ' (b.paycash <> 0) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 '+
          'union all '+
          'Select SUM(a.Total) as TotalSum, COUNT(Distinct a.ChkNumber) as CheckCount '+
          'From "EcrSells" a '+
          ' left join "EcrPays" b on (b.id=a.EcrPayID) '+
          ' left join "Ecrs" c on (c.sernumber=b.sernumber) '+
          'Where '+
          ' (b.oper = 2) and '+
          ' ((b.paycheck <> 0) or (b.paycredit <> 0) or (b.paycard <> 0)) and '+
          ' (b.moment >= ''%DATE_BEGIN%'') and '+
          ' (b.moment < ''%DATE_END%'') and '+
          ' (a.moment >= ''%DATE_BEGIN%'') and '+
          ' (a.moment < ''%DATE_END%'') '+
          'having sum(a.Quantity) <> 0 ';
  
  __PathDelimiter   = '\';
  __SalesSQLFile    = 'sales.sql';

type
  TMonitor = class(TObject)
  private
    { Private declarations }
  
    __DB: TvIBDataBase;
    __T: TvIBTransaction;
    __DB_FileName: String;
    __DB_user: String;
    __DB_pass: String;    
    procedure __cdsAfterOpen(_DataSet: TDataSet);
    procedure __SelectData(var _cds: TClientDataSet; _SQL: String);

  public
    { Public declarations }
    constructor Create;
    procedure __InitDB;
    function __GetData: String;
    destructor Destroy; override;
    property DB: String  read __DB_FileName write __DB_FileName;
    property user: String read __DB_user write __DB_user ;
    property pass: String read __DB_pass write __DB_pass;    
  end;

implementation

uses
  DateUtil, StrUtils;  

procedure TMonitor.__InitDB;
begin
  try
    __T := TvIBTransaction.Create(nil);
    try
      if not Assigned(__DB) then begin
        __DB := TvIBDataBase.Create(nil);
        try
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
        except
          FreeAndNil(__DB);
          raise;
        end;    
      end;
      if Assigned(__DB) and __DB.Connected then
        with __T do begin
          Params.Clear;
          Params.Append('read_committed');
          Params.Append('rec_version');
          Params.Append('nowait');
          DefaultDatabase := __DB;
          DefaultAction := taCommit;
        end;
    except
      FreeAndNil(__T);
    end;
  except
  end;
end;

procedure TMonitor.__cdsAfterOpen(_DataSet: TDataSet);
begin
  TClientDataSet(_DataSet).LogChanges:=False;
end;

procedure TMonitor.__SelectData(var _cds: TClientDataSet; _SQL: String);
var
  _Q: TvIBDataSet;
  _P: TvIBDataSetProvider;
begin
  if Assigned(__T) or Assigned(__DB) then begin
    _Q := TvIBDataSet.Create(nil);
    _Q.Database := __DB;
    _Q.Transaction := __T;
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
      __ShowDebugGrid(_cds);
  {$endif}    
      __T.Commit;
    except
      __T.RollBack;
      _P.Free;
      _Q.Free;
      raise;
    end;
    _P.Free;
    _Q.Free;
  end  
  else
    raise Exception.Create('');
end;

function TMonitor.__GetData: String;
var
  _SQL: TStrings;
  _Res: TClientDataSet;
  Sum, Checks: String;
begin
  Result := '';
  try
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
    if TClientDataSet(_Res).RecordCount > 0 then
      while not _Res.Eof do begin
        try
          Sum := CurrToStr(_Res.Fields[0].AsCurrency);
        except
          Sum := '0.00';
        end;
        try
          Checks := IntToStr(_Res.Fields[1].asInteger);
        except
          Checks := '0';
        end;
        Result :=  Result + Sum +';'+Checks+';';
        _Res.Next;
      end
    else
      Result := '0.00;0;0.00;0;0.00;0;';
    _Res.Close;
    _Res.Free;
  except
    Result := '0.00;0;0.00;0;0.00;0;';
  end
end;

destructor TMonitor.Destroy;
begin
  inherited;
  if ( assigned( __DB ) ) then FreeAndNil( __DB );
  if ( assigned( __T ) ) then FreeAndNil( __T );
end;

constructor TMonitor.Create;
begin
  inherited;
  __DB_user := 'SYSDBA';
  __DB_pass := 'masterkey';    
end;

end.
