unit ProcessDBObj;

interface
  uses  Windows, Messages, LogFunc,
  Const_Type, SysUtils,
  IBSQL, IBDatabase, vIBDB, myIBEvents,
  db, dbclient, DBObj,
{$ifdef debug}  
  fDbGrid, 
{$endif}   
  vIBProvide, IBQuery;  

type  

  TOnChange = procedure() of object;
  
  PSecondDBObj = ^TSecondDBObj;
  TSecondDBObj = class(TDBObj)
    public
      function GetGoods(_where: String = ''): TClientDataSet;
      function GetBarCodes(_where: String = ''): TClientDataSet;
      function GetDepPrice(_where: String = ''): TClientDataSet;
      function GetEcrs(_where: String = ''): TClientDataSet;
  end;

implementation

function TSecondDBObj.GetBarCodes(_where: String = ''): TClientDataSet;
var
  _SQL: String;
begin
  _SQL := __select__+__all__+__from__+'"BarCodes" b';
  if Length( _where )>0 then
    _SQL := _SQL + __where__ + _where;
  SelectData( Result,  _SQL);
  Result.AddIndex('Idx_BARCODE', 'BARCODE',[], 'BARCODE');
end;

function TSecondDBObj.GetDepPrice(_where: String = ''): TClientDataSet;
var
  _SQL: String;
begin
  _SQL := __select__+__all__+__from__+'"DepPrice" dp';
  if Length( _where )>0 then
    _SQL := _SQL + __where__ + _where;
  SelectData( Result, _SQL );
  Result.AddIndex('Idx_GOOD_DEPART','GOODSID;DEPARTID',[],'GOODSID;DEPARTID');
end;

function TSecondDBObj.GetEcrs(_where: String = ''): TClientDataSet;
var
  _SQL: String;
begin
  _SQL := __select__+__all__+__from__+'"Ecrs" e';
  if Length( _where )>0 then
    _SQL := _SQL + __where__ + _where;
  SelectData( Result,  _SQL );
end;

function TSecondDBObj.GetGoods(_where: String = ''): TClientDataSet;
var
  _SQL: String;
begin
  _SQL := __select__+__all__+__from__+'"Goods" g'+__where__+'DISABLED <> ''T''';
  if Length( _where )>0 then
    _SQL := _SQL + __and__ + _where;
  SelectData( Result, _SQL );
  Result.AddIndex('Idx_ID','ID',[],'ID'); 
  Result.AddIndex('Idx_CODE','CODE',[],'CODE'); 
end;

initialization

finalization  

end.
