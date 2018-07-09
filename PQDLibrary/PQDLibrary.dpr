library PQDLibrary;

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\FastMM\FastMM4Messages.pas',
  LogFunc in '..\MainCassThread\LogFunc.pas',
  SysUtils,
  Classes,
  Const_Type in '..\MainCassThread\Const_Type.pas';

{$R *.RES}

procedure InitParseQueryDisc; stdcall;
begin
end;
  
function ParseQueryDisc(_ChkNum: Integer; _Perc, _BSum: Double; var _tDKnd: Integer ): Double; stdcall;
begin
  Result := 0.00;
  if _Perc < 0 then begin
    if _tDKnd in [ __DiscOnLastPerc, __DiscPerc ] then
      _tDKnd := ___DiscPerc
    else
      _tDKnd := ___DiscSum;
  end
  else begin
    if _tDKnd in [ __DiscOnLastPerc, __DiscPerc ] then
      _tDKnd := ___AddPerc
    else
      _tDKnd := ___AddSum;
  end;
end;

exports
  InitParseQueryDisc,
  ParseQueryDisc;

end.
 