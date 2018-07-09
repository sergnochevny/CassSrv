unit Progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls;

type
  TfProgress = class(TForm)
    pbSearch: TProgressBar;
    Panel1: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fProgress: TfProgress;

implementation

{$R *.DFM}

end.
