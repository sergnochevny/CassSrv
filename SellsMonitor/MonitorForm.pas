unit MonitorForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Sells, Menus, RxMenus, RXShell;

type
  TMonitor = class(TForm)
    MonitorIcon: TRxTrayIcon;
    GenMenu: TRxPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    procedure N2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
  private
  
  public
    { Public declarations }
  end;

var
  Monitor: TMonitor;

implementation

uses WorkUtil, SoldGoods;

{$R *.DFM}


procedure TMonitor.N2Click(Sender: TObject);
begin
  Close;
end;

procedure TMonitor.FormCreate(Sender: TObject);
begin
  Application.ShowMainForm := False;
end;

procedure TMonitor.N1Click(Sender: TObject);
begin
  SellsForm.Show;
end;

procedure TMonitor.N4Click(Sender: TObject);
var
  _Form : TWorkForm;
begin
  _Form := TWorkForm.Create(nil);
  _Form.fsWork.IniSection := 'F_ANNUL';
  _Form.fsWork.Active := True;
  _Form.bGo.OnClick := _Form.bAnnulGoClick;
  _Form.Caption := __AnnulFName;
  _Form.FormShow(Sender);
  _Form.bAnnulGoClick(Sender);
  _Form.ShowModal;  
  FreeAndNil(_Form);
end;

procedure TMonitor.N5Click(Sender: TObject);
var
  _Form : TWorkForm;
begin
  _Form := TWorkForm.Create(nil);
  _Form.fsWork.IniSection := 'F_DIFF';
  _Form.fsWork.Active := True;
  _Form.dgWork.OnDblClick := _Form.dgWorkDblClick;
  _Form.dgWork.OnKeyPress := _Form.dgWorkKeyPress;
  _Form.dgWork.OnGetCellParams := _Form.dgWorkGetCellParams;
  _Form.bGo.OnClick := _Form.bDiffGoClick;
  _Form.Caption := __DiffFName;
  _Form.dgWorkDetail.ReadOnly := false;
  _Form.FormShow(Sender);
  _Form.bDiffGoClick(Sender);
  _Form.ShowModal;  
  FreeAndNil(_Form);
end;

procedure TMonitor.N8Click(Sender: TObject);
var
  _Form : TWorkForm;
  i: integer;
begin
  _Form := TWorkForm.Create(nil);
  _Form.fsWork.IniSection := 'F_SOLDG';
  _Form.fsWork.Active := True;
  _Form.dgWork.OnDblClick := _Form.dgSoldDblClick;
  _Form.dgWork.OnKeyPress := _Form.dgSoldKeyPress;
  _Form.bGo.OnClick := _Form.bSoldGoClick;
  _Form.Filter.OnExecute := _Form.SoldFilterExecute;
  _Form.Caption := __SoldFName;
  _Form.RemoveControl(_Form.RxSplitter1);
  _Form.RemoveControl(_Form.vPWorkDetail);
  _Form.vPWork.Align := alClient;
  _Form.FormShow(Sender);
  _Form.bSoldGoClick(Sender);
  _Form.ShowModal;
  FreeAndNil(_Form);
end;

procedure TMonitor.N10Click(Sender: TObject);
var
  _Form : TWorkForm;
begin
{$ifdef UpdateDB}
  _Form := TWorkForm.Create(nil);
  _Form.UpdateDB;  
  FreeAndNil(_Form);
{$endif}  
end;

procedure TMonitor.N11Click(Sender: TObject);
var
  _Form : TWorkForm;
  i: integer;
begin
  _Form := TWorkForm.Create(nil);
  _Form.fsWork.IniSection := 'F_CHECKS';
  _Form.fsWork.Active := True;
  _Form.dgWork.OnDblClick := _Form.dgWorkDblClick;
  _Form.dgWork.OnKeyPress := _Form.dgWorkKeyPress;
  _Form.dgWork.OnGetCellParams := _Form.dgWorkGetCellParamsForChecks;
  _Form.Filter.OnExecute := _Form.ChecksFilterExecute;
  _Form.bGo.OnClick := _Form.bChecksGoClick;
  _Form.Caption := __ChecksFName;
  _Form.dgWorkDetail.ReadOnly := false;
  _Form.FormShow(Sender);
  _Form.bChecksGoClick(Sender);
  _Form.ShowModal;  
  FreeAndNil(_Form);
  FreeAndNil(_Form);
end;

end.
