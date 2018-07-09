Library Neon;

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\FastMM\FastMM4Messages.pas',
  Windows,
  SysUtils,
  Comm_Procedures in 'Comm_Procedures.pas',
  LogFunc in '..\MainCassThread\LogFunc.pas',
  Protocols in 'Protocols.pas',
  Error_Procedures in '..\MainCassThread\Error_Procedures.pas',
  myIBEvents in '..\MainCassThread\myIBEvents.pas',
  CheckState in 'CheckState.pas',
  DataStream in 'DataStream.pas',
  ConnectionStream in 'ConnectionStream.pas',
  DBObj in '..\MainCassThread\DBObj.pas',
{$ifdef debug}  
  fDbGrid in '..\MainCassThread\Debugform\fDbGrid.pas',
{$endif}  
  Const_Type in '..\MainCassThread\Const_Type.pas',
  ProcessDBObj in 'ProcessDBObj.pas';

function InitProtocol(PortNo, Bps: integer): TDataStream; stdcall;
begin
  Result := TDataStream.Create;//(__DataStream);
  Result.BaudNumber := Bps;
  Result.Port := PortNo;
end;

exports
  InitProtocol;
  
end.

