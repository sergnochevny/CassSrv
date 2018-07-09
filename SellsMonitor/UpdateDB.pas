unit UpdateDB;

interface

uses
  Windows, Messages, Classes, SysUtils, Dialogs,
  IBSQL, IBDatabase, vIBDB,
  db, dbclient, dbtables, vIBProvide, IBQuery, IBCustomDataSet;
  
const
  __UpdSQL = 'update "Goods" set IncrMtu = <IMTU>, IncrED = <IED> where Code = <CODE>';
  __IMTU = '<IMTU>';
  __CODE = '<CODE>';
  __IED = '<IED>';
  __MTUTableName = 'mtu.db';

const
  __SQL: array[1..7] of string = (
    'ALTER TABLE "Goods"'+#$0D+#$0A+
    ' ADD INCRMTU INTEGER',
    'ALTER TABLE "Goods"'+#$0D+#$0A+
    ' ADD INCRED INTEGER',
    'DROP PROCEDURE ADD_CHANGES',
    'DROP PROCEDURE CNG_GOODS',
    'CREATE OR ALTER procedure ADD_GOODS ('+#$0D+#$0A+
    '    CODE integer,'+#$0D+#$0A+
    '    IMTU integer,'+#$0D+#$0A+
    '    IED integer,'+#$0D+#$0A+
    '    NAME varchar(30),'+#$0D+#$0A+
    '    ANYPRICE char(1),'+#$0D+#$0A+
    '    CHCKINT char(1),'+#$0D+#$0A+
    '    CHCKCNT char(1))'+#$0D+#$0A+
    ' returns ('+#$0D+#$0A+
    '    RES integer)'+#$0D+#$0A+
    ' AS'+#$0D+#$0A+
    ' declare variable ID_GOODS integer;'+#$0D+#$0A+
    ' begin'+#$0D+#$0A+
    '    res = -1;'+#$0D+#$0A+
    '    if ((code is null) or (name is null)) then'+#$0D+#$0A+
    '        exit;'+#$0D+#$0A+
    '    if (anyprice is null) then anyprice = ''f'';'+#$0D+#$0A+
    '    if (chckint is null) then chckint = ''f'';'+#$0D+#$0A+
    '    if (chckcnt is null) then chckcnt = ''f'';'+#$0D+#$0A+
    '    select id from "Goods" where INCRMTU = :IMTU'+#$0D+#$0A+
    '    into :id_goods;'+#$0D+#$0A+
    '    if (id_goods is not null) then begin'+#$0D+#$0A+
    '        update "Goods"'+#$0D+#$0A+
    '        set'+#$0D+#$0A+
    '            CODE = :code,'+#$0D+#$0A+
    '            NAME = :name,'+#$0D+#$0A+
    '            ECRNAME = :name,'+#$0D+#$0A+
    '            CHKINTEGER = :chckint,'+#$0D+#$0A+
    '            ANYPRICE = :anyprice,'+#$0D+#$0A+
    '            CHKCOUNT = :chckcnt'+#$0D+#$0A+
    '        where id = :id_goods;'+#$0D+#$0A+
    '        res = 1;'+#$0D+#$0A+
    '    end'+#$0D+#$0A+
    '    else begin'+#$0D+#$0A+
    '        id_goods = GEN_ID(GEN_GOODS_ID, 1);'+#$0D+#$0A+
    '        insert into "Goods" (ID,CODE,NAME,ECRNAME,'+#$0D+#$0A+
    '                            DISABLED,CHKINTEGER,ANYPRICE,CHKCOUNT,INCRMTU,INCRED)'+#$0D+#$0A+
    '        values (:id_goods,:code,:name,:name,''F'',:chckint,:anyprice,:chckcnt, :imtu, :ied);'+#$0D+#$0A+
    '        res = 1;'+#$0D+#$0A+
    '    end'+#$0D+#$0A+
    ' end',#$0D+#$0A+
    'CREATE OR ALTER procedure ADD_BARCODE ('+#$0D+#$0A+
    '    IMTU integer,'+#$0D+#$0A+
    '    BARCODE varchar(13),'+#$0D+#$0A+
    '    ZOOM double precision,'+#$0D+#$0A+
    '    CHANGE integer)'+#$0D+#$0A+
    ' returns ('+#$0D+#$0A+
    '    RES integer)'+#$0D+#$0A+
    ' AS'+#$0D+#$0A+
    ' declare variable id_barcode integer;'+#$0D+#$0A+
    ' declare variable id_goods integer;'+#$0D+#$0A+
    ' declare variable goods_id integer;'+#$0D+#$0A+
    ' begin'+#$0D+#$0A+
    '  res = -1;'+#$0D+#$0A+
    '  if ((IMTU is null) or (barcode is null)) then'+#$0D+#$0A+
    '    exit;'+#$0D+#$0A+
    '  select id from "Goods" where IncrMTU = :IMTU'+#$0D+#$0A+
    '  into :id_goods;'+#$0D+#$0A+
    '  select id, goodsid from "BarCodes" where BARCODE = :barcode'+#$0D+#$0A+
    '  into :id_barcode, :goods_id;'+#$0D+#$0A+
    '  if (id_barcode is not null) then begin'+#$0D+#$0A+
    '    if (goods_id <> id_goods) then begin'+#$0D+#$0A+
    '      if (change = 0) then begin'+#$0D+#$0A+
    '        res = -2;'+#$0D+#$0A+
    '        exit;'+#$0D+#$0A+
    '      end'+#$0D+#$0A+
    '      else begin'+#$0D+#$0A+
    '        update "BarCodes" '+#$0D+#$0A+
    '        set GOODSID = :id_goods,'+#$0D+#$0A+
    '            ZOOM = :zoom'+#$0D+#$0A+
    '        where id = :id_barcode;'+#$0D+#$0A+
    '        res = 2;'+#$0D+#$0A+
    '      end'+#$0D+#$0A+
    '    end'+#$0D+#$0A+
    '    else begin'+#$0D+#$0A+
    '      update "BarCodes" '+#$0D+#$0A+
    '      set ZOOM = :zoom'+#$0D+#$0A+
    '      where id = :id_barcode;'+#$0D+#$0A+
    '      res = 2;'+#$0D+#$0A+
    '    end'+#$0D+#$0A+
    '  end'+#$0D+#$0A+
    '  else begin'+#$0D+#$0A+
    '    id_barcode = GEN_ID(GEN_BARCODES_ID, 1);'+#$0D+#$0A+
    '    insert into "BarCodes" values (:id_barcode, :id_goods, :barcode, :zoom);'+#$0D+#$0A+
    '    res = 1;'+#$0D+#$0A+
    '  end'+#$0D+#$0A+
    ' end',
    'CREATE OR ALTER procedure ADD_PRICE ('+#$0D+#$0A+
    '    IMTU integer,'+#$0D+#$0A+
    '    DEPART integer,'+#$0D+#$0A+
    '    PRICE double precision,'+#$0D+#$0A+
    '    TAXID integer)'+#$0D+#$0A+
    ' returns ('+#$0D+#$0A+
    '    RES integer)'+#$0D+#$0A+
    ' AS'+#$0D+#$0A+
    ' declare variable ID_GOODS integer;'+#$0D+#$0A+
    ' declare variable ID_DEPART integer;'+#$0D+#$0A+
    ' declare variable ID_PRICES integer;'+#$0D+#$0A+
    ' begin'+#$0D+#$0A+
    '    res = -1;'+#$0D+#$0A+
    '    if ((imtu is null) or (depart is null) or (price is null)) then'+#$0D+#$0A+
    '        exit;'+#$0D+#$0A+
    '    select id from "Goods" where IncrMtu = :IMTU'+#$0D+#$0A+
    '    into :id_goods;'+#$0D+#$0A+
    '    if (id_goods is null) then '+#$0D+#$0A+
    '        exit;'+#$0D+#$0A+
    '    select id from "Departs" where NUMBER = :depart'+#$0D+#$0A+
    '    into :id_depart;'+#$0D+#$0A+
    '    if (id_depart is null) then '+#$0D+#$0A+
    '        exit;'+#$0D+#$0A+
    '    select id from "DepPrice" '+#$0D+#$0A+
    '    where DEPARTID = :id_depart and GOODSID = :id_goods'+#$0D+#$0A+
    '    into :id_prices;'+#$0D+#$0A+
    '    if (taxid < 0) then taxid = 2;'+#$0D+#$0A+
    '    if (id_prices is not null) then begin'+#$0D+#$0A+
    '        update "DepPrice" '+#$0D+#$0A+
    '        set PRICE = :price, taxid = :taxid'+#$0D+#$0A+
    '        where id = :id_prices;'+#$0D+#$0A+
    '    end'+#$0D+#$0A+
    '    else begin'+#$0D+#$0A+
    '        id_prices = GEN_ID(GEN_DEPPRICE_ID, 1);'+#$0D+#$0A+
    '        insert into "DepPrice" values (:id_prices,:id_depart,:id_goods,:price,:taxid);'+#$0D+#$0A+
    '    end'+#$0D+#$0A+
    '    res = 1;'+#$0D+#$0A+
    ' end'
  );

procedure UpdateDB_ToLastVer( _DB_FileName, _DB_user, _DB_pass: String );
procedure SyncDB_MTU( _DB_FileName, _DB_user, _DB_pass: String );

implementation
uses
  Const_Type, StrUtils, StrFunc;

procedure UpdateDB_ToLastVer( _DB_FileName, _DB_user, _DB_pass: String );
var
  _DB: TvIBDataBase;
  _T: TvIBTransaction;
  _Q: TIBSQL;
  _i: integer;
begin
  _T := TvIBTransaction.Create(nil);
  _DB := TvIBDataBase.Create(nil);
  try
    With _DB do begin
      DatabaseName := _DB_FileName;
      Params.Clear;
      Params.Append('user_name=' + _DB_user);
      Params.Append('password=' + _DB_pass);
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
    _Q := TIBSQL.Create(nil);
    _Q.ParamCheck := False;
    _Q.Database := _DB;
    _Q.Transaction := _T;
    for _i := 1 to Length(__SQL) do begin
      _Q.SQL.Clear;
      _Q.SQL.Append(__SQL[_i]);
      _T.StartTransaction;
      try
        _Q.ExecQuery;
        _T.Commit;
      except
        on E: Exception do begin
          _T.RollBack;
          ShowMessage(E.Message);
        end;
      end;
    end;
    _Q.Free;
  finally
    if ( assigned( _DB ) ) then FreeandNil( _DB );
    if ( assigned( _T ) ) then FreeandNil( _T );
  end;
end;

procedure SyncDB_MTU( _DB_FileName, _DB_user, _DB_pass: String );
var
  _DB: TvIBDataBase;
  _T: TvIBTransaction;
  _Q: TIBSQL;
  _i: integer;
  _MTUTable: TTable;
  _F_IncrMtu,
  _F_Code,
  _F_IncrED: TField;
  _sDatabaseName: String;
begin
  _MTUTable:=TTable.Create(nil);
  try
    if Pos('/', _DB_FileName)>0 then begin
//  127.0.0.1/3053:J:\Dtx550\Data\!MVENGINE.GDB
      _sDatabaseName := Copy(_DB_FileName, Pos(':',_DB_FileName)+1, Length(_DB_FileName)-Pos(':',_DB_FileName));
    end
    else _sDatabaseName := _DB_FileName;
    _sDatabaseName := Copy(_sDatabaseName, 1, LastDelimiter(PathDelimiter, _sDatabaseName));
    _MTUTable.DatabaseName:=_sDatabaseName;
    _MTUTable.TableType:=ttParadox;
    _MTUTable.TableName:=__MTUTableName;

    _T := TvIBTransaction.Create(nil);
    _DB := TvIBDataBase.Create(nil);
    try
      With _DB do begin
        DatabaseName := _DB_FileName;
        Params.Clear;
        Params.Append('user_name=' + _DB_user);
        Params.Append('password=' + _DB_pass);
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
      _Q := TIBSQL.Create(nil);
      _Q.ParamCheck := False;
      _Q.Database := _DB;
      _Q.Transaction := _T;

      _MTUTable.Open;
      _F_IncrMtu := _MTUTable.FieldByName('IncrMtu');
      _F_Code := _MTUTable.FieldByName('LocalCode');
      _F_IncrED := _MTUTable.FieldByName('IncrED');
      _MTUTable.First;
      for _i := 1 to _MTUTable.RecordCount do begin
        _Q.SQL.Clear;
        _Q.SQL.Append(__UpdSQL);
        _Q.SQL.Text := ReplaceStr(_Q.SQL.Text, __IMTU, _F_IncrMtu.AsString);
        _Q.SQL.Text := ReplaceStr(_Q.SQL.Text, __CODE, _F_Code.AsString);
        _Q.SQL.Text := ReplaceStr(_Q.SQL.Text, __IED, _F_IncrED.AsString);
        _T.StartTransaction;
        try
          _Q.ExecQuery;
          _T.Commit;
        except
          on E: Exception do begin
            _T.RollBack;
            ShowMessage(E.Message);
          end;
        end;
        _MTUTable.Next;
      end;
      _Q.Free;
    finally
      if ( assigned( _DB ) ) then FreeandNil( _DB );
      if ( assigned( _T ) ) then FreeandNil( _T );
    end;
  finally
    if ( assigned( _MTUTable ) ) then FreeandNil( _MTUTable );
  end;
end;

end.
 