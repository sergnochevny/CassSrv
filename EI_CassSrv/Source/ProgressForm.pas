unit ProgressForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls;

type
  TProgressF = class(TForm)
    pnlM: TPanel;
    pbMain: TProgressBar;
    lblMain: TLabel;
  private
    { Private declarations }
  public
    procedure ProcessMessages;
    { Public declarations }
  end;

var
  ProgressF: TProgressF;

implementation
  

{$R *.DFM}

{ TProgressF }

procedure TProgressF.ProcessMessages;
begin
  Application.ProcessMessages;
end;

end.

