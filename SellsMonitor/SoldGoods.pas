unit SoldGoods;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  IBSQL, IBDatabase, vIBDB,
  db, dbclient, vIBProvide, IBQuery, IBCustomDataSet, vStdCtrl,
  StdCtrls, ComCtrls, Grids, DBGrids, RXDBCtrl, ExtCtrls, Placemnt, RXSplit,
  vDB, Menus, RxMenus;

const
  __NoInfo = 'Информация отсутствует';
  
  __DATE_BEGIN  = '%DATE_BEGIN%';
  __DATE_END    = '%DATE_END%';
  __ECRPAY      = '%ECRPAYID%';
  __SALESID     = '%SALESID%';
  
  __SQL =   'Select g.Id as GoodsID, g.Code as Code, g.Name as Name, sum(a.Quantity) as Quantity'+
            ' from "EcrSells" a'+
            ' left join "EcrPays" b on (b.id=a.EcrPayID)'+
            ' left join "Goods" g on (a.goodsid=g.id)'+
            ' where ((a.moment >= ''%DATE_BEGIN%'') and (a.moment < ''%DATE_END%'')) and'+
            '       (((b.oper in (1,2)) and (b.total = 0)) or'+
            '        ((b.oper in (5,10,11)) and (b.chknumber <> a.chknumber)) or'+
            '        ((b.oper in (1,2)) and (b.total <> 0)))'+
            ' Group by g.Id, g.Code, g.Name'+
            ' having sum(a.Quantity) <> 0'+
            ' Order by 2';

  __PathDelimiter     = '\';
  __SoldGoodsSQLFile       = 'SoldGoods.sql';
  
  __Code      = 'code';           __fnCode      = 'Код товара';
  __Name      = 'name';           __fnName      = 'Наименование';
  __Price     = 'Price';          __fnPrice     = 'Цена';
  __Quantity  = 'Quantity';       __fnQuantity  = 'Количество';
  __Summa     = 'Summa';          __fnSumma     = 'Сумма';
  __Discount  = 'Discount';       __fnDiscount  = 'Скидка';
  __Total     = 'Total';          __fnTotal     = 'Итого';
  __GoodsID   = 'GoodsID';
  
type
  TSoldGoodsForm = class(TForm)
    vPSoldGoods: TvPanel;
    vPParams: TvPanel;
    vPGrid: TvPanel;
    dgSoldGoods: TRxDBGrid;
    dtpBegin: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    dtpEnd: TDateTimePicker;
    fsSoldGoods: TFormStorage;
    bGo: TButton;
    StatusBar1: TStatusBar;
    dsSoldGoods: TvDataSource;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dtpBeginChange(Sender: TObject);
    procedure bGoClick(Sender: TObject);
    procedure dtpEndChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dgSoldGoodsDblClick(Sender: TObject);
    procedure dgSoldGoodsKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    __DataModified: Boolean;
    __DB_FileName: String;
    __DB_user: String;
    __DB_pass: String;    
    __ProtocolDir: String;
    __cdsSoldGoods: TClientDataSet;

    function __GetParams: Boolean;
    procedure __cdsAfterOpen(_DataSet: TDataSet);
    procedure __SelectData(var _cds: TClientDataSet; _SQL: String);
    procedure __GetSoldGoods(var _cds: TClientDataSet);
  public
    { Public declarations }
  end;

var
  SoldGoodsForm: TSoldGoodsForm;

implementation

uses
  Const_Type, DateUtil, StrUtils, SysUtils, WorkUtil;  

{$R *.DFM}

function TSoldGoodsForm.__GetParams: Boolean;
var
  _RegIniFileName: String;
  _K:              DWORD;
  _TempStr:        String;
  _Def__Protocol,
  _Def__TmpDir:   String;
  
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

    _Def__TmpDir := Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0)));
    if (LastDelimiter(PathDelimiter, _Def__TmpDir) <> Length(_Def__TmpDir)) then
      _Def__TmpDir := _Def__TmpDir + PathDelimiter;
    _Def__Protocol := _Def__TmpDir + 'Protocol';

    SetLength(_TempStr, LenIniStr);
    FillChar(Pointer(_TempStr)^, LenIniStr, $0);
    _K:=GetPrivateProfileString(PChar(SectionLibrary), PChar(ProtocolDirK),
                              PChar(_Def__Protocol), PChar(_TempStr), LenIniStr,
                              PChar(_RegIniFileName));
    __ProtocolDir := Trim(_TempStr);
    if (__ProtocolDir = '')or(not BOOL(_K)) then __ProtocolDir := _Def__Protocol;
    if (LastDelimiter(PathDelimiter, __ProtocolDir) <> Length(__ProtocolDir)) then
      __ProtocolDir := __ProtocolDir + PathDelimiter;
  except
    Result := False;
  end;
end;

procedure TSoldGoodsForm.__cdsAfterOpen(_DataSet: TDataSet);
begin
  TClientDataSet(_DataSet).LogChanges:=False;
end;

procedure TSoldGoodsForm.__SelectData(var _cds: TClientDataSet; _SQL: String);
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
  {$ifdef debug}
      __ShowDebugGrid(_cds);
  {$endif}    
      _T.Commit;
    except
      on E: Exception do begin
        _T.RollBack;
        _P.Free;
        _Q.Free;
        ShowMessage(E.Message);
      end;
    end;
    _P.Free;
    _Q.Free;
  finally
    if ( assigned( _DB ) ) then FreeandNil( _DB );
    if ( assigned( _T ) ) then FreeandNil( _T );
  end;
end;

procedure TSoldGoodsForm.__GetSoldGoods(var _cds: TClientDataSet);
var
  _SQL: TStrings;
begin
  if __GetParams then begin
    _SQL := TStringList.Create;
    if FileExists(Copy(ParamStr(0), 1, LastDelimiter(__PathDelimiter, ParamStr(0)))+__PathDelimiter+__SoldGoodsSQLFile) then begin
      _SQL.LoadFromFile(Copy(ParamStr(0), 1, LastDelimiter(__PathDelimiter, ParamStr(0)))+__PathDelimiter+__SoldGoodsSQLFile)
    end      
    else 
      _SQL.Text := __SQL;
    _SQL.Text := ReplaceStr(_SQL.Text, __DATE_BEGIN, DateToStr(dtpBegin.Date));
    _SQL.Text := ReplaceStr(_SQL.Text, __DATE_END, DateToStr(dtpEnd.Date));
    __SelectData( _cds, _SQL.Text );
    FreeAndNil(_SQL);
    _cds.First;
  end;
end;

procedure TSoldGoodsForm.FormShow(Sender: TObject);
begin
  dtpBegin.Date := Date;
  dtpEnd.MinDate := IncDay(dtpBegin.Date, 1);
  __DataModified := true;
  bGoClick(Sender);  
end;

procedure TSoldGoodsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if assigned(__cdsSoldGoods) then FreeAndNil(__cdsSoldGoods);
end;

procedure TSoldGoodsForm.dtpBeginChange(Sender: TObject);
begin
  dtpEnd.MinDate := IncDay(dtpBegin.Date, 1);
  __DataModified := true;
end;

procedure TSoldGoodsForm.bGoClick(Sender: TObject);
var
  i: Integer;
begin
  if (__DataModified) then begin
    if not assigned(__cdsSoldGoods) then begin
      __cdsSoldGoods := TClientDataSet.Create(nil);
    end;
    __GetSoldGoods(__cdsSoldGoods);
    dsSoldGoods.DataSet := TDataSet(__cdsSoldGoods);
    for i:=0 to dgSoldGoods.Columns.Count-1 do begin
      if dgSoldGoods.Columns.Items[i].DisplayName = UpperCase(__Code) then dgSoldGoods.Columns.Items[i].Title.Caption := __fnCode
      else if dgSoldGoods.Columns.Items[i].DisplayName = UpperCase(__Name) then dgSoldGoods.Columns.Items[i].Title.Caption := __fnName
      else if dgSoldGoods.Columns.Items[i].DisplayName = UpperCase(__Quantity) then dgSoldGoods.Columns.Items[i].Title.Caption := __fnQuantity
      else dgSoldGoods.Columns.Items[i].Visible := false;
      if dgSoldGoods.Columns.Items[i].Visible then
        dgSoldGoods.Columns.Items[i].Width := Length(dgSoldGoods.Columns.Items[i].Title.Caption)*10;
    end;
    __cdsSoldGoods.First;
    __DataModified := false;
  end;
end;

procedure TSoldGoodsForm.dtpEndChange(Sender: TObject);
begin
  __DataModified := true;
end;

procedure TSoldGoodsForm.FormCreate(Sender: TObject);
begin
  fsSoldGoods.IniFileName := Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0)))+'SellsMonitor.ini';
end;

procedure TSoldGoodsForm.dgSoldGoodsDblClick(Sender: TObject);
var
  _SoldGoodsDetail: TWorkForm;
begin
  _SoldGoodsDetail := TWorkForm.Create(nil);
  _SoldGoodsDetail.Caption := _SoldGoodsDetail.Caption+' '+
                              TDataSet(dsSoldGoods.DataSet).FieldByName(__Code).AsString+' '+
                              TDataSet(dsSoldGoods.DataSet).FieldByName(__Name).AsString;
  _SoldGoodsDetail.__GoodsIdDetail := TDataSet(dsSoldGoods.DataSet).FieldByName(__GoodsID).AsInteger;
  _SoldGoodsDetail.dtpBegin.Date := dtpBegin.Date;
  _SoldGoodsDetail.dtpEnd.Date := dtpEnd.Date;
  _SoldGoodsDetail.bGo.Visible := False;
  _SoldGoodsDetail.dtpBegin.Enabled := False;
  _SoldGoodsDetail.dtpEnd.Enabled := False;
  _SoldGoodsDetail.bSoldGGoClick(Sender);
  _SoldGoodsDetail.ShowModal;  
  FreeAndNil(_SoldGoodsDetail);
end;

procedure TSoldGoodsForm.dgSoldGoodsKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then dgSoldGoodsDblClick(Sender);
end;

end.
