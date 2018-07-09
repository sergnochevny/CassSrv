unit fDbGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, dbClient, StdCtrls, ExtCtrls, IBCustomDataSet, vIBDB;

type
  TfrmDbGrid = class(TForm)
    dbg: TDBGrid;
    ds: TDataSource;
    pnlTop: TPanel;
    Edit: TEdit;
    btnIndex: TButton;
    Memo1: TMemo;
    procedure btnIndexClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowDebugGrid(cds: TDataSet);
  
var
  frmDbGrid: TfrmDbGrid;

implementation

{$R *.DFM}

procedure TfrmDbGrid.btnIndexClick(Sender: TObject);
begin
//  TClientDataSet(ds.DataSet).IndexFieldNames:=Edit.Text;
end;

procedure TfrmDbGrid.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
        VK_ESCAPE: Close;
    end;
end;

procedure ShowDebugGrid(cds: TDataSet);
begin
    frmDbGrid:=TfrmDbGrid.Create(nil);
    frmDbGrid.ds.DataSet:=TDataSet(cds);
    frmDbGrid.Caption:=TDataSet(cds).Name;
    if cds.ClassType = TvIBDataSet then
      frmDbGrid.Memo1.Text := TvIBDataSet(cds).SQL.Text;
    frmDbGrid.ShowModal;
    frmDbGrid.Free;
end;

end.
 