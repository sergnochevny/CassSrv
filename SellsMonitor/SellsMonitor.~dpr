program SellsMonitor;

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\FastMM\FastMM4Messages.pas',
  Forms,
  LogFunc in '..\MainCassThread\LogFunc.pas',
  MonitorForm in 'MonitorForm.pas' {Monitor},
  Const_Type in '..\MainCassThread\Const_Type.pas',
  Sells in 'Sells.pas' {SellsForm},
  ListProtocol in 'ListProtocol.pas' {fListProtocol},
  Progress in 'Progress.pas' {fProgress},
  WorkUtil in 'WorkUtil.pas' {WorkForm},
{$ifdef UpdateDB}
  UpdateDB in 'UpdateDB.pas',
{$endif}
  WaitForm in 'WaitForm.pas' {Wait};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMonitor, Monitor);
  Application.CreateForm(TSellsForm, SellsForm);
  Application.Run;
end.
