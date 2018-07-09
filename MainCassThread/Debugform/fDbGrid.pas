unit fDbGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, dbClient, StdCtrls, ExtCtrls, IBDatabase, IBEvents;

type
  TfrmDbGrid = class(TForm)
    dbg: TDBGrid;
    pnlTop: TPanel;
    Edit: TEdit;
    btnIndex: TButton;
    mF: TMemo;
    ds: TDataSource;
    procedure btnIndexClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDbGrid: TfrmDbGrid;

implementation

{$R *.DFM}

procedure TfrmDbGrid.btnIndexClick(Sender: TObject);
begin
  TClientDataSet(ds.DataSet).IndexFieldNames:=Edit.Text;
end;

procedure TfrmDbGrid.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
        VK_ESCAPE: Close;
    end;
end;

end.
 