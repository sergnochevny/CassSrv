library Sells;

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\FastMM\FastMM4Messages.pas',
  LogFunc in '..\MainCassThread\LogFunc.pas',
  Const_Type in '..\MainCassThread\Const_Type.pas',
  Sysutils,
  MonitorUnit in 'MonitorUnit.pas';


{$R *.RES}

//==============================================================================
function GetSales(Value: OleVariant): OleVariant; stdcall;
var
 _DB: String;
 _M: TMonitor;
begin
  Result := '0.00';
  if not (VarIsNull(Value) or VarIsEmpty(Value)) then begin
    try
      _DB := VarToStr(Value);
      if Length(_DB)>0 then begin
        _M := TMonitor.Create;
        if assigned(_M) then begin
          _M.DB := _DB;
          _M.__InitDB;
          Result := _M.__GetData;
          FreeAndNil(_M);
        end;
      end;
    except
      on E: Exception do
        Result := E.Message;
    end;
  end;
  Result:=VarAsType(Result, varOleStr);
end;

exports
 GetSales;
 
begin
end.
