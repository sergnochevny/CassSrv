unit DModule;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, ConstVarUnit, vIBDB, IBCustomDataSet, IBStoredProc;

type
  TDukatDM = class(TDataModule)
    Dukat: TvIBDataBase;
    DefTrans: TvIBTransaction;
    vIBStoredProc1: TvIBStoredProc;
    vIBDataSet1: TvIBDataSet;
    IBDataSet1: TIBDataSet;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DukatDM: TDukatDM;

implementation

{$R *.DFM}

end.
