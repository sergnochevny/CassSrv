unit ListProtocol;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RxRichEd, ComCtrls, Db, vDB, RxMemDS, Grids, DBGrids, RXDBCtrl;

type
  TfListProtocol = class(TForm)
    StatusBar1: TStatusBar;
    dgProtocol: TRxDBGrid;
    rmdProtocol: TRxMemoryData;
    dsProtocol: TvDataSource;
    procedure dgProtocolGetCellParams(Sender: TObject; Field: TField;
      AFont: TFont; var Background: TColor; Highlight: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure __PrepareDataSet();
  end;

implementation

{$R *.DFM}

procedure TfListProtocol.dgProtocolGetCellParams(Sender: TObject;
  Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
begin
  case rmdProtocol.Fields.FieldByNumber(1).AsInteger of
    2: begin
      Background := clRed;
      AFont.Color := clWhite;
    end;
    3: begin
      AFont.Style := [fsBold];
      AFont.Color := clNavy;
      Background := TColor($FFF080);
    end;
    4: begin
      AFont.Style := [fsBold];
      AFont.Color := clWhite;
      Background := clRed;
    end;
  end;
end;

procedure TfListProtocol.__PrepareDataSet;
begin
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := '-';
    DataType := ftInteger;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Время';
    DataType := ftString;
    Size := 20;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Касса';
    DataType := ftString;
    Size := 15;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Операция';
    DataType := ftString;
    Size := 20;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Результат';
    DataType := ftString;
    Size := 20;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Чек';
    DataType := ftString;
    Size := 10;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Код';
    DataType := ftString;
    Size := 15;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Наименование';
    DataType := ftString;
    Size := 25;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Цена';
    DataType := ftString;
    Size := 15;
  end;
  with rmdProtocol.FieldDefs.AddFieldDef do begin
    Name := 'Количество';
    DataType := ftString;
    Size := 15;
  end;
  rmdProtocol.Open;
  dgProtocol.Columns.Items[0].Visible := False;
end;

end.
