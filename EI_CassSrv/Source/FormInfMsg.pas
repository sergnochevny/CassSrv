unit FormInfMsg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TFormMsg = class(TForm)
    C_Panel: TPanel;
    Bott_Panel: TPanel;
    ErrorMemo: TMemo;
    SaveB: TSpeedButton;
    SaveLog: TSaveDialog;
    procedure SaveBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMsg: TFormMsg;

implementation

uses Handle_Unit;

{$R *.DFM}

procedure TFormMsg.SaveBClick(Sender: TObject);
begin
    if SaveLog.Execute then begin
        ErrorMemo.Lines.SaveToFile(String(SaveLog.FileName));
        Close;
    end;
end;

procedure TFormMsg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
        VK_ESCAPE: Close;
{VK_S}        $53: if Shift = [ssAlt] then SaveBClick(Sender);
    end;
end;

end.
