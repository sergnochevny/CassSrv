unit dReplica;

interface

uses
  Db, DBClient,
  IBDatabase, ConstVarUnit, vIBDB;

type
  TdmReplica = class(TObject)
    cdsTemp: TClientDataSet;
    cdsBarCode: TClientDataSet;
    Dukat: TvIBDataBase;
    DefTrans: TvIBTransaction;
    
    procedure cdsAfterOpen(DataSet: TDataSet);
  private
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  dmReplica: TdmReplica;

implementation

procedure TdmReplica.cdsAfterOpen(DataSet: TDataSet);
begin
  TClientDataSet(DataSet).LogChanges:=False;
end;

constructor TdmReplica.Create;
begin
    inherited Create;
    cdsTemp := TClientDataSet.Create(nil) ;
    cdsBarCode := TClientDataSet.Create(nil) ;
    cdsTemp.AfterOpen := cdsAfterOpen;
    cdsBarCode.AfterOpen := cdsAfterOpen;
    Dukat := TvIBDataBase.Create(nil);
    DefTrans := TvIBTransaction.Create(nil);
    With Dukat do begin
      DatabaseName := sDBName;
      Params.Clear;
      Params.Append('user_name=SYSDBA');
      Params.Append('password=masterkey');
      Params.Append('lc_ctype=WIN1251');
      LoginPrompt := False;
      SQLDialect := 3;
      TraceFlags := [];
      DefaultTransaction := DefTrans;
    end;
    with DefTrans do begin
      Params.Clear;
      Params.Append('read_committed');
      Params.Append('rec_version');
      Params.Append('nowait');
      DefaultDatabase := Dukat;
      DefaultAction := TACommit;
    end;
    Dukat.Open;
end;

destructor TdmReplica.Destroy;
begin
    Dukat.Close;
    cdsTemp.Free;
    cdsBarCode.Free;
    Dukat.Free;
    DefTrans.Free;
    inherited;
end;

end.
