unit Handle_Unit;

interface
uses
    Windows, db, dbclient, IBStoredProc, IBSQL, IBDatabase, vIBDB, dbtables,
    SysUtils, Classes, MathFunc, StrFunc, MemoryFunc, ShowErrorFunc, dReplica,
    ConstVarUnit, StrUtils, ProgressForm, UtilFunc_Unit;

function ParseIncomFile(const FileName: string; var Res: Integer; Sync: Boolean = False): Integer;
function CreateOutgoinFile(const FileName, Depart: String; Year, Month, Day: Cardinal; PayKind:Cardinal = 0): Integer;

implementation

//====================================================================AddBarCode
Procedure AddBarCode(cdsG, cds:  TClientDataSet);
var
    UpdProc,
    TempProc:        TvIBStoredProc;
    cFBC_IncrMtu,
    cFBC_LocalCode,
    cFBC_BarCode,
    cFBC_Name,
    cFBC_Scale:     TField;
    P_Res,
    P_IMTU,
    P_BarCode,
    P_Zoom,
    P_Change:       TParam;
    i:              Integer;

    procedure AddToInfMem(const Msg: String; DirectMsg: String = Null_Str);
    begin
        if InfMem = nil then InfMem := TStringList.Create;
        if DirectMsg = Null_Str then
            InfMem.Append(Format(Format(BCFormatMsg,[Msg, BCGeneralMsg]),
                            [cFBC_LocalCode.AsInteger, cFBC_Name.AsString,
                            cFBC_BarCode.AsString, cFBC_Scale.AsFloat]))
        else
            InfMem.Append(DirectMsg);
    end;

begin
    TempProc := nil;
    
    if (cds = nil) or (cds.RecordCount <=0) then begin
        AddToInfMem(Null_Str, NoBCExistsMsg);
        Exit;
    end;

  if ShowProgr = 1 then begin
    ProgressF.pbMain.Position := 0;
    ProgressF.pbMain.Max := cds.RecordCount;
    ProgressF.lblMain.Caption := 'Добавление штрихкодов.';
    ProgressF.ProcessMessages;
  end;
    
    try
      TempProc := TvIBStoredProc.Create(nil);
      try
          with TempProc do begin
            Database := dmReplica.Dukat;
            Transaction := dmReplica.DefTrans;
            StoredProcName := 'ADD_BARCODE';
            P_Res := Params.CreateParam(ftInteger,'RES',ptOutput);
            P_IMTU := Params.CreateParam(ftInteger,'IMTU',ptInput);
            P_Barcode := Params.CreateParam(ftString,'BARCODE',ptInput);
            P_Zoom := Params.CreateParam(ftFloat,'ZOOM',ptInput);
            P_Change := Params.CreateParam(ftInteger,'CHANGE',ptInput);

            cFBC_IncrMtu := cds.FieldByName('IncrMtu');
            cFBC_LocalCode := cds.FieldByName('LocalCode');
            cFBC_Name := cds.FieldByName('Name');
            cFBC_BarCode := cds.FieldByName('BarCode');
            cFBC_Scale := cds.FieldByName('Scale');
              
            cds.First;

            if ( not Database.TestConnected ) then
              Database.Open;

            for i := 0 to cds.RecordCount - 1 do begin
              try
                if not Transaction.InTransaction  then 
                  Transaction.StartTransaction;
                try
                  P_IMTU.AsInteger := cFBC_IncrMtu.AsInteger;
                  P_Barcode.AsString := cFBC_BarCode.AsString;
                  P_Zoom.AsFloat := cFBC_Scale.AsFloat;
                  P_Change.AsInteger := 0;

                  ExecProc;
                  Transaction.Commit;

                  if (P_Res.AsInteger < 0) then begin
                    if P_Res.AsInteger = -1 then
                      raise Exception.Create(BCErrInstMsg)
                    else
                      if P_Res.AsInteger = -2 then begin
                      
                        if MessageBox(TempHandle, PChar(Format(DiffersCodeMsg,
                                      [cFBC_BarCode.AsString ,cFBC_Name.AsString])),
                                      PChar(ErrorCaption),
                                      MB_YESNO or MB_ICONERROR or
                                      MB_TOPMOST or MB_DEFBUTTON1) = IDYES then begin
                    
                          if not Transaction.InTransaction  then 
                            Transaction.StartTransaction;
                          try
                            P_IMTU.AsInteger := cFBC_IncrMtu.AsInteger;
                            P_Barcode.AsString := cFBC_BarCode.AsString;
                            P_Zoom.AsFloat := cFBC_Scale.AsFloat;
                            P_Change.AsInteger := 1;

                            ExecProc;
                            Transaction.Commit;
                          except
                            Transaction.Rollback;
                            raise;
                          end;
                        end;
                      end;
                  end;
                except
                  Transaction.Rollback;
                  raise;
                end;
              except
                on E: Exception do
                  AddToInfMem(E.Message+#13+#10+BCErrGoodMsg);
              end;
              cds.Next;

              if ShowProgr = 1 then begin
                ProgressF.pbMain.StepIt;
                ProgressF.ProcessMessages;
              end;
            end;
          end;
      except
        raise;
      end;
    except
      on E: Exception do
        AddToInfMem(Null_Str, E.Message+#13+#10+BCGenErrMsg);
    end;

    if (TempProc <> nil) then begin
      TempProc.Free;
    end;
end;

//=====================================================================AddPrices
function AddPrices(cds: TClientDataSet): Integer;
var
    UpdProc,
    TempProc:           TvIBStoredProc;
    cF_IncrMtu,
    cF_Code,
    cF_Name,
    cF_Price,
    cF_TaxID,
    cF_Department:      TField;
    P_Res,
    P_IMTU,
    P_Depart,
    P_TaxID,
    P_Price:            TParam;
    TransAmountGoods,
    i:                  Integer;
      
    procedure AddToInfMem(const Msg: String; DirectMsg: String = Null_Str);
    begin
        if InfMem = nil then InfMem := TStringList.Create;
        if DirectMsg = Null_Str then
            InfMem.Append(Format(Format(FormatMsg,[Msg, GeneralPriceMsg]),
                            [cF_IncrMtu.AsInteger, cF_Name.AsString, 0,
                            cF_Price.AsFloat, cF_Code.AsInteger, 0]))
        else
            InfMem.Append(DirectMsg);
    end;

begin

  Result := 0; TempProc := nil;
  if (cds = nil) or (cds.RecordCount <= 0) then begin
    AddToInfMem(Null_Str, WrongTransPrice);
    Exit;
  end;

  if ShowProgr = 1 then begin
    ProgressF.pbMain.Position := 0;
    ProgressF.pbMain.Max := cds.RecordCount;
    ProgressF.lblMain.Caption := 'Добавление и изменение цен.';
    ProgressF.ProcessMessages;
  end;

  try
    TempProc := TvIBStoredProc.Create(nil);
    try
        with TempProc do begin
            Database := dmReplica.Dukat;
            Transaction := dmReplica.DefTrans;
            StoredProcName := 'ADD_PRICE';
            P_Res := Params.CreateParam(ftInteger,'RES',ptOutput);
            P_IMTU := Params.CreateParam(ftInteger,'IMTU',ptInput);
            P_Depart := Params.CreateParam(ftInteger,'DEPART',ptInput);
            P_Price := Params.CreateParam(ftFloat,'PRICE',ptInput);
            P_TaxID := Params.CreateParam(ftInteger,'TAXID',ptInput);

            cF_IncrMtu := cds.FieldByName('IncrMTU');
            cF_Code := cds.FieldByName('LocalCode');
            cF_Name := cds.FieldByName('ShortName');
            cF_Price := cds.FieldByName('Price');
            cF_Department := cds.FieldByName('Department');
            cF_TaxID := cds.FieldByName('TaxGroup');

            cds.First;

            if ( not Database.TestConnected ) then
              Database.Open;

            TransAmountGoods := 0;
            for i := 0 to cds.RecordCount - 1 do begin
              try
                if not Transaction.InTransaction  then 
                  Transaction.StartTransaction;
                try
                  P_IMTU.AsInteger := cF_IncrMtu.AsInteger;
                  P_Depart.AsInteger := cF_Department.AsInteger;
                  P_Price.AsFloat := cF_Price.AsFloat;
                  P_TaxID.AsSmallInt := cF_TaxID.AsInteger;
                  
                  ExecProc;
                  Transaction.CommitRetaining;
                  
                  if P_Res.AsInteger = -1 then
                    raise Exception.Create(WrongTransform);
                    
                  Inc(TransAmountGoods);
                except
                  Transaction.Rollback;
                  raise;
                end;
              except
                on e:Exception do
                  AddToInfMem(e.Message+#13+#10+WrongTransPrice);
              end;

              cds.Next;

              if ShowProgr = 1 then begin
                ProgressF.pbMain.StepIt;
                ProgressF.ProcessMessages;
              end;

            end;
        end;
    except
      raise;
    end;
    AddToInfMem(Null_Str, Format(TransPricesMsg, [TransAmountGoods]));
    Result := TransAmountGoods;
  except
    on E: Exception do
      AddToInfMem(Null_Str, E.Message+#13+#10+WrongTransPrices);
  end;
  
  if (TempProc <> nil) then begin
    TempProc.Free;
  end;

end;

//======================================================================AddGoods
function AddGoods(cds, cdsBC:  TClientDataSet): Integer;
var
    UpdProc,
    TempProc: TvIBStoredProc;
    cF_IncrMtu,
    cF_IncrEd,
    cF_Code,
    cF_Name,
    cF_SName,
    cF_Dividable,
    cF_ValidCount:      TField;
    P_Res,
    P_IMTU,
    P_IED,
    P_Code,
    P_Name,
    P_AnyPrice,
    P_ChckInt,
    P_ChckCnt:          TParam;
    i:                  Integer;
    TransAmountGoods:   Longint;

    procedure AddToInfMem(const Msg: String; DirectMsg: String = Null_Str);
    begin
        if InfMem = nil then InfMem := TStringList.Create;
        if DirectMsg = Null_Str then
            InfMem.Append(Format(Format(FormatMsg,[Msg, GeneralMsg]),
                            [cF_IncrMtu.AsInteger, cF_Name.AsString,
                            0, 0, cF_Code.AsInteger,0]))
        else
            InfMem.Append(DirectMsg);
    end;

begin

  Result := 0; TempProc := nil;
  if (cds = nil) or (cds.RecordCount <= 0) then begin
    AddToInfMem(Null_Str, WrongTransGoods);
    Exit;
  end;
  
  if ShowProgr = 1 then begin
    ProgressF.pbMain.Position := 0;
    ProgressF.pbMain.Max := cds.RecordCount;
    ProgressF.lblMain.Caption := 'Передача параметров МТУ.';
    ProgressF.ProcessMessages;
  end;

  try
    TempProc := TvIBStoredProc.Create(nil);
    try
        with TempProc do begin
            Database := dmReplica.Dukat;
            Transaction := dmReplica.DefTrans;
            StoredProcName := 'ADD_GOODS';
            P_Res := Params.CreateParam(ftInteger,'RES',ptOutput);
            P_Code := Params.CreateParam(ftInteger,'CODE',ptInput);
            P_IMTU := Params.CreateParam(ftInteger,'IMTU',ptInput);
            P_IED :=  Params.CreateParam(ftInteger,'IED',ptInput);
            P_Name := Params.CreateParam(ftString,'NAME',ptInput);
            P_AnyPrice := Params.CreateParam(ftString,'ANYPRICE',ptInput);
            P_ChckInt := Params.CreateParam(ftString,'CHCKINT',ptInput);
            P_ChckCnt := Params.CreateParam(ftString,'CHCKCNT',ptInput);
            
            cF_IncrMtu := cds.FieldByName('IncrMTU');
            cF_IncrEd := cds.FieldByName('IncrEd');
            cF_Code := cds.FieldByName('LocalCode');
            cF_Name := cds.FieldByName('Name');
            cF_SName := cds.FieldByName('ShortName');
            cF_Dividable := cds.FieldByName('Dividable');
            cF_ValidCount := cds.FieldByName('ValidCount');
            
            cds.First;

            if ( not Database.TestConnected ) then
              Database.Open;
            TransAmountGoods := 0;
            for i := 0 to cds.RecordCount - 1 do begin
              try
                if not Transaction.InTransaction  then 
                  Transaction.StartTransaction;
                try
                  P_Code.AsInteger := cF_Code.AsInteger;
                  P_IMTU.AsInteger := cF_IncrMtu.AsInteger;
                  P_IED.AsInteger := cF_IncrEd.AsInteger;
                  if Length(Trim(cF_SName.AsString)) >0 then
                    P_Name.AsString := cF_SName.AsString
                  else
                    P_Name.AsString := Copy(Trim(cF_Name.AsString),1,14);
                  P_AnyPrice.AsString := 'F';
                  if (cF_Dividable.AsInteger > 0) then
                    P_ChckInt.AsString := 'T'
                  else
                    P_ChckInt.AsString := 'F';
                  if (cF_ValidCount.AsInteger > 0) then
                    P_ChckCnt.AsString := 'T'
                  else
                    P_ChckCnt.AsString := 'F';

                  ExecProc;
                  Transaction.Commit;
                  
                  if P_Res.AsInteger = -1 then
                    raise Exception.Create(WrongTransform);
                    
                  Inc(TransAmountGoods);
                except
                    Transaction.Rollback;
                    raise;
                end;
              except
                on E: Exception do begin
                  AddToInfMem(Null_Str,E.Message+#13+#10+WrongTransGood);
                end;
              end;
              cds.Next;

              if ShowProgr = 1 then begin
                ProgressF.pbMain.StepIt;
                ProgressF.ProcessMessages;
              end;

            end;

            AddPrices(cds);
            AddBarCode(cds, cdsBC);
            UpdProc := TvIBStoredProc.Create(nil);
            try
              with UpdProc do begin
                Database := dmReplica.Dukat;
                Transaction := dmReplica.DefTrans;
                StoredProcName := 'UPD_GOODS';
                Transaction.StartTransaction;
                ExecProc;
                Transaction.Commit;
              end;
            finally
              UpdProc.Free;
            end;
        end;
    except
      raise;
    end;
    AddToInfMem(Null_Str, Format(ResultMsg, [InitialAmountGoods, TransAmountGoods]));
    Result := TransAmountGoods;
  except
    on e:Exception do
      AddToInfMem(Null_Str, e.Message+#13+#10+WrongTransGoods);
  end;
  if (TempProc <> nil) then begin
    TempProc.Free;
  end;
end;

//================================================================ParceIncomFile
function ParseIncomFile(const FileName: string; var Res: Integer; Sync: Boolean = False): Integer;
var
    IntermPoint,
    hFile,
    hMapFile:       Cardinal;
    hMapViewFile:   Pointer;
    RangeSize,
    SizeWord,
    SizeFile,
    Point:          Cardinal;
    FBC_IncrMtu,
    FBC_LocalCode,
    FBC_Name,
    FBC_BarCode,
    FBC_Scale,
    F_IncrMTU,
    F_LocalCode,
    F_Name,
    F_ShortName,
    F_BarCode,
    F_Department,
    F_TaxGroup,
    F_Price,
    F_Count,
    F_Dividable,
    F_IncrED,
    F_ValidCount:   TField;
    TokenHandles,
    TokenGS,
    Stuff:          Boolean;

    procedure AddToInfMem(const Msg: String);
    begin
        if InfMem = nil then InfMem := TStringList.Create;
        InfMem.Append(Msg);
    end;

    function HandlesPrimParam: Boolean;
    var
        T_Docs:     TTable;
        FD_Field1,
        FD_Field2,
        FD_Field3,
        FD_Data,
        FD_Time:    TField;
        TempStr:    String;
    begin
        Result := False;
        if Sync then begin
            Result := True;
            Exit;
        end;
        SetLength(TempStr,SizeWord);
        move(Pointer(IntermPoint)^, Pointer(TempStr)^, SizeWord);
        if StrFunc.ExtractWord(TempStr, Char(US), 1) <> ExportIndent then Exit;
        T_Docs := TTable.Create(nil);
        with T_Docs do begin
            try
                DatabaseName := sDatabaseName;
                TableType := ttParadox;
                TableName := InDocTableName;
                Open;
                FD_Field1 := FieldByName('FIELD1');
                FD_Field2 := FieldByName('FIELD2');
                FD_Field3 := FieldByName('FIELD3');
                FD_Data := FieldByName('DATA');
                FD_Time := FieldByName('TIME');
                IndexFieldNames := 'FIELD1;FIELD2;FIELD3';
                EditKey;
                FD_Field1.AsString := StrFunc.ExtractWord(TempStr, Char(US), 2);
                FD_Field2.AsString := StrFunc.ExtractWord(TempStr, Char(US), 3);
                FD_Field3.AsString := StrFunc.ExtractWord(TempStr, Char(US), 4);
                if GotoKey then begin
                    if MessageBox(TempHandle, PChar(Format(InDocExistsMsg,
                                  [FD_Data.AsString, FD_Time.AsString])),
                                  PChar(WarningCaption),
                                  MB_YESNO or MB_ICONWARNING or
                                  MB_TOPMOST or MB_DEFBUTTON2) = IDYES then begin
                        Edit;
                        try
                            FD_Data.AsDateTime := Date;
                            FD_Time.AsDateTime := Time;
                            Post;
                            AddToInfMem(RetreatDocMsg);
                            Result := True;
                        except
                          on E: Exception do begin
                            Cancel;
                            AddToInfMem(E.Message+#13+#10+ErrHandlHeadMsg);
                          end;
                        end;
                    end
                    else AddToInfMem(RefusDocMsg);
                end
                else begin
                    Append;
                    try
                        FD_Field1.AsString := StrFunc.ExtractWord(TempStr, Char(US), 2);
                        FD_Field2.AsString := StrFunc.ExtractWord(TempStr, Char(US), 3);
                        FD_Field3.AsString := StrFunc.ExtractWord(TempStr, Char(US), 4);
                        FD_Data.AsDateTime := Date;
                        FD_Time.AsDateTime := Time;
                        Post;
                        Result := True;
                    except
                      on E:Exception do begin
                        Cancel;
                        AddToInfMem(E.Message+#13+#10+ErrHandlHeadMsg);
                      end;
                    end;
                end;
            finally
                T_Docs.Close;
                T_Docs.Free;
            end;
        end;
    end;

    procedure IntErrorOfRoutine;
    var
        TempStr:    String;
    begin
        SetLength(TempStr, SizeWord);
        move(Pointer(IntermPoint)^, Pointer(TempStr)^, SizeWord);
        AddToInfMem(Format(IntErrRoutnMsg, [TempStr]));
    end;

    procedure InitFields;
    begin
        with dmReplica do begin
            FBC_IncrMtu := cdsBarCode.FieldByName('IncrMtu');
            FBC_LocalCode := cdsBarCode.FieldByName('LocalCode');
            FBC_Name := cdsBarCode.FieldByName('Name');
            FBC_BarCode := cdsBarCode.FieldByName('BarCode');
            FBC_Scale := cdsBarCode.FieldByName('Scale');
            F_IncrMtu := cdsTemp.FieldByName('IncrMtu');
            F_LocalCode := cdsTemp.FieldByName('LocalCode');
            F_Name := cdsTemp.FieldByName('Name');
            F_ShortName := cdsTemp.FieldByName('ShortName');
            F_BarCode := cdsTemp.FieldByName('BarCode');
            if not Sync then begin
                F_Department := cdsTemp.FieldByName('Department');
                F_TaxGroup := cdsTemp.FieldByName('TaxGroup');
                F_Price := cdsTemp.FieldByName('Price');
                F_Count := cdsTemp.FieldByName('Count');
                F_Dividable := cdsTemp.FieldByName('Dividable');
                F_ValidCount := cdsTemp.FieldByName('ValidCount');
            end;
            F_IncrED := cdsTemp.FieldByName('IncrED');
        end;
    end;

    procedure FillcdsGoodsFields;
    var
        TempStr:    String;
    begin
        with dmReplica do begin
            SetLength(TempStr,SizeWord);
            move(Pointer(IntermPoint)^, Pointer(TempStr)^, SizeWord);
            try F_IncrMTU.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 1)); except end;
            try F_LocalCode.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 2)); except end;
            try F_Name.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 3)); except end;
            try F_ShortName.AsString := Copy(Trim(StrFunc.ExtractWord(TempStr, Char(US), 4)), 1, 22); except end;
            try F_BarCode.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 5)); except end;
            if not Sync then begin
              if WDep = 0 then begin
                F_Department.AsInteger := 1;
                try F_TaxGroup.AsInteger := StrToInt(Trim(StrFunc.ExtractWord(TempStr, Char(US), 6)));
                except F_TaxGroup.AsInteger := 1; end;
                try F_Price.AsCurrency := StrToFloatEx(Trim(StrFunc.ExtractWord(TempStr, Char(US), 7)));
                except F_Price.AsCurrency := 0; end;
                try F_Count.AsFloat := StrToFloatEx(Trim(StrFunc.ExtractWord(TempStr, Char(US), 8)));
                except F_Count.AsFloat := 0; end;
                try F_Dividable.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 9));
                except F_Dividable.AsInteger := 1; end;
                try F_ValidCount.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 10));
                except F_ValidCount.AsInteger := 1; end;
                try F_IncrED.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 11)); except end;
              end
              else begin                
                try F_Department.AsInteger := StrToInt(Trim(StrFunc.ExtractWord(TempStr, Char(US), 6)));
                except F_Department.AsInteger := 1; end;
                try F_TaxGroup.AsInteger := StrToInt(Trim(StrFunc.ExtractWord(TempStr, Char(US), 7)));
                except F_TaxGroup.AsInteger := 1; end;
                try F_Price.AsCurrency := StrToFloatEx(Trim(StrFunc.ExtractWord(TempStr, Char(US), 8)));
                except F_Price.AsCurrency := 0; end;
                try F_Count.AsFloat := StrToFloatEx(Trim(StrFunc.ExtractWord(TempStr, Char(US), 9)));
                except F_Count.AsFloat := 0; end;
                try F_Dividable.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 10));
                except F_Dividable.AsInteger := 1; end;
                try F_ValidCount.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 11));
                except F_ValidCount.AsInteger := 1; end;
                try F_IncrED.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 12)); except end;
              end;              
            end
            else
              try F_IncrED.AsString := Trim(StrFunc.ExtractWord(TempStr, Char(US), 6)); except end;
        end;
    end;

    procedure FillcdsBarCodeFields;
    var
        WordCounter:    Integer;
        TempStr:        String;
    begin
        with dmReplica do begin
            SetLength(TempStr, SizeWord);
            move(Pointer(IntermPoint)^, Pointer(TempStr)^, SizeWord);
            WordCounter := 1;
            while True do begin
                if StrFunc.ExtractWord(TempStr, Char(US), WordCounter + OffsetScale) = '' then break;
                try
                    with cdsBarCode do begin
//                        IndexFieldNames := 'LocalCode;BarCode';
                        IndexName := 'LocalCode_BarCode';
                        EditKey;
                        FBC_LocalCode.AsInteger := F_LocalCode.AsInteger;
                        FBC_BarCode.AsString := StrFunc.ExtractWord(TempStr, Char(US), WordCounter + OffsetBarCode);
                        if not GotoKey then begin
                            Append;
                            try
                                FBC_IncrMtu.AsInteger := F_IncrMtu.AsInteger;
                                FBC_LocalCode.AsInteger := F_LocalCode.AsInteger;
                                FBC_Name.AsString := F_Name.AsString;
                                FBC_BarCode.AsString := StrFunc.ExtractWord(TempStr, Char(US), WordCounter + OffsetBarCode);
                                try FBC_Scale.AsFloat := StrToFloatEx(StrFunc.ExtractWord(TempStr, Char(US), WordCounter + OffsetScale));
                                except FBC_Scale.AsFloat := 1; end;
                                Post;
                            except
                                Cancel;
                            end;
                        end;
                    end;
                except
                    break;
                end;
                Inc(WordCounter, StepParsingBC);
            end;
        end;
    end;

begin
  if ShowProgr = 1 then begin
    ProgressF := TProgressF.Create(nil);
    ProgressF.Show;
  end;
    TokenHandles := False;
    TokenGS := True;
    Result := 0; Res := 0;
    Stuff := False;
    InitialAmountGoods := 0;
    hFile := CreateFile(PChar(Copy(ParamStr(0), 1, LastDelimiter(__PathDelimiter, ParamStr(0)))+FileName),
                        GENERIC_READ,
                        0,
                        nil,
                        OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL,
                        0);
    if (hFile <> INVALID_HANDLE_VALUE) and (hFile > 0) then begin
        SizeFile := Windows.GetFileSize(hFile, nil);
        hMapFile := CreateFileMapping(hFile, nil, PAGE_READONLY, 0, 0, nil);
        if BOOL(hMapFile) then begin
            hMapViewFile := MapViewOfFile(hMapFile, FILE_MAP_READ, 0, 0, 0);
            if Assigned(hMapViewFile) then begin
                dmReplica:=TdmReplica.Create;
                with dmReplica do begin
                    if CreateFields_cdsGoods(cdsTemp, Sync) and
                       CreateFields_cdsBarCode(cdsBarCode) then begin
                        InitFields;
                        Point := Cardinal(hMapViewFile);
                        IntermPoint := Point;
                        RangeSize := Point + SizeFile;
                        while Point < RangeSize do begin
                            case Byte(Pointer(Point)^) of
                                GS: begin
                                    Inc(Point);
                                    IntermPoint := Point;
                                    while Point < RangeSize do begin
                                        case Byte(Pointer(Point)^) of
                                            RS: begin
                                                SizeWord := Point - IntermPoint;
                                                if BOOL(SizeWord) then begin
                                                    Inc(InitialAmountGoods);
                                                    try
                                                        cdsTemp.Append;
                                                        try
                                                            FillcdsGoodsFields;
                                                            cdsTemp.Post;
                                                        except
                                                            cdsTemp.Cancel;
                                                            raise;
                                                        end;
                                                    except
                                                        IntErrorOfRoutine;
                                                    end;
                                                end;
                                                IntermPoint := Point + 1;
                                            end;
                                            FS: begin
                                                SizeWord := Point - IntermPoint;
                                                if BOOL(SizeWord) then begin
                                                    Inc(InitialAmountGoods);
                                                    try
                                                        cdsTemp.Append;
                                                        try
                                                            FillcdsGoodsFields;
                                                            cdsTemp.Post;
                                                            Stuff := True;
                                                        except
                                                            cdsTemp.Cancel;
                                                            raise;
                                                        end;
                                                    except
                                                        Stuff := false;
                                                        IntErrorOfRoutine;
                                                    end;
                                                end;
                                                IntermPoint := Point + 1;
                                                while Point < RangeSize do begin
                                                    if Byte(Pointer(Point)^) = RS then begin
                                                        SizeWord := Point - IntermPoint;
                                                        if BOOL(SizeWord) and Stuff then FillcdsBarCodeFields;
                                                        IntermPoint := Point + 1;
                                                        break;
                                                    end;
                                                    Inc(Point);
                                                end;
                                            end;
                                            GS: begin
                                                if TokenHandles then begin
                                                    if not Sync then begin
                                                      Result := AddGoods(cdsTemp, cdsBarCode);
                                                    end;
                                                    Res := InitialAmountGoods;
                                                    if TDebug = 1 then begin
                                                      ShowDebugGrig(cdsTemp);
                                                      ShowDebugGrig(cdsBarCode);
                                                    end;
                                                end
                                                else AddToInfMem(CorFileFrmtMsg);
                                                TokenGS := False;
                                            end;
                                        end;
                                        Inc(Point);
                                    end;
                                end;
                                RS: begin
                                    SizeWord := Point - IntermPoint;
                                    if BOOL(SizeWord) then begin
                                        if not HandlesPrimParam then break;
                                        TokenHandles := True;
                                    end
                                    else break;
                                    IntermPoint := Point + 1;
                                end;
                            end;
                            Inc(Point);
                        end;
                        if TokenGS then AddToInfMem(CorFileFrmtMsg);
                        ShowInformMemo(InfMem);
                        cdsTemp.Close;
                        cdsBarCode.Close;
                    end;
                end;
                dmReplica.Free;
                UnMapViewOfFile(hMapViewFile);
            end
            else ShowSystemErrorMsg;
            CloseHandle(hMapFile);
        end
        else ShowSystemErrorMsg;
        CloseHandle(hFile);
        if DelF = 1 then
          Windows.DeleteFile(PChar(Copy(ParamStr(0), 1, LastDelimiter(__PathDelimiter, ParamStr(0)))+FileName));
    end
    else ShowSystemErrorMsg;
  if ShowProgr = 1 then begin
    ProgressF.Close;
    ProgressF.Free;
  end;
end;

//================================================================FillingResFile
function FillingResFile(const hFile: Cardinal;  Depart: String; Year, Month, 
  Day, PayKind: Cardinal; var Res: Integer): Boolean;
var
    TempPointMem,
    SizeBlok,
    SizeMem,
    I_PointMem,
    PointMem:       Cardinal;
    TempStr:        String;
    QSales:         TvIBDataSet;
    FS_Dep,
    FS_Code:        TField;
    RCounter:       Cardinal;
    TokenWrite:     Boolean;
    WriteCount:     Cardinal;
    GS_Str,
    RS_Str,
    US_Str:         String;
    TWDep,
    k, i:           Integer;
    PSQL: TIBSQL;
    Source: string;

    procedure AddToInfMem(const Msg: String);
    begin
        if InfMem = nil then InfMem := TStringList.Create;
        InfMem.Append(Msg);
    end;

    procedure AddToInfMemF(const Msg: String; DirectMsg: String = Null_Str);
    begin
        if InfMem = nil then InfMem := TStringList.Create;
        if DirectMsg = Null_Str then
            InfMem.Append(Format(Format(OutDFormatMsg,[Msg, OutDGeneralMsg]),
                            [FS_Code.AsInteger]))
        else
            InfMem.Append(DirectMsg);
    end;

    function WriteHeader: Boolean;
    var
        T_OutDocs:     TTable;
        FD_Field1,
        FD_Field2,
        FD_Field3,
        FD_Field4,
        FD_Data,
        FD_Time:    TField;

        v_KeyFind,
        v_KeyFindAny: Boolean;
        
    begin
        Result := False;
        if FS_Code.AsInteger = 0 then begin
            AddToInfMem(NotDataMsg);
            exit;
        end;
        US_Str := Char(US);
        RS_Str := Char(RS);
        GS_Str := Char(GS);
        TokenWrite := False;
        T_OutDocs := TTable.Create(nil);
        with T_OutDocs do begin
            try
                DatabaseName := sDatabaseName;
                TableType := ttParadox;
                TableName := OutDocTableName;
                Open;
                FD_Field1 := FieldByName('FIELD1');
                FD_Field2 := FieldByName('FIELD2');
                FD_Field3 := FieldByName('FIELD3');
                FD_Field4 := FieldByName('FIELD4');
                FD_Data := FieldByName('DATA');
                FD_Time := FieldByName('TIME');
                IndexFieldNames := 'FIELD1;FIELD2;FIELD3;FIELD4';
                EditKey;
                FD_Field1.AsString := IntToStr(Year);
                FD_Field2.AsString := IntToStr(Month);
                FD_Field3.AsString := IntToStr(Day);
                FD_Field4.AsString := IntToStr(PayKind);
                if GotoKey then begin
                  while not(Eof) and (
                        (Trim(FD_Field1.AsString) = Trim(IntToStr(Year))) and 
                        (Trim(FD_Field2.AsString) = Trim(IntToStr(Month))) and
                        (Trim(FD_Field3.AsString) = Trim(IntToStr(Day))) and
                        (Trim(FD_Field4.AsString) = Trim(IntToStr(PayKind)))) do
                    Next;
                  Prior;
                  if MessageBox(TempHandle, PChar(Format(OutDocExistsMsg,
                                  [FD_Data.AsString, FD_Time.AsString])),
                                  PChar(WarningCaption),
                                  MB_YESNO or MB_ICONWARNING or
                                  MB_TOPMOST or MB_DEFBUTTON2) = IDYES then begin
                    Append;
                    try
                      FD_Field1.AsString := IntToStr(Year);
                      FD_Field2.AsString := IntToStr(Month);
                      FD_Field3.AsString := IntToStr(Day);
                      FD_Field4.AsString := IntToStr(PayKind);
                      FD_Data.AsDateTime := Date;
                      FD_Time.AsDateTime := Time;
                      Post;
                      Result := True;
                    except
                      on E:Exception do begin
                        Cancel;
                        AddToInfMem(E.Message+#13+#10+ErrHandlHeadMsg);
                        raise;
                      end;
                    end;
                  end;
                end
                else begin
                  Append;
                  try
                    FD_Field1.AsString := IntToStr(Year);
                    FD_Field2.AsString := IntToStr(Month);
                    FD_Field3.AsString := IntToStr(Day);
                    FD_Field4.AsString := IntToStr(PayKind);
                    FD_Data.AsDateTime := Date;
                    FD_Time.AsDateTime := Time;
                    Post;
                    Result := True;
                  except
                    on E:Exception do begin
                      Cancel;
                      AddToInfMem(E.Message+#13+#10+ErrHandlHeadMsg);
                      raise;
                    end;
                  end;
                end;

                if Result then begin
                    TempStr := FormatHeader + US_Str + US_Str +
                               IntToStr(Year) + US_Str +
                               IntToStr(Month) + US_Str +
                               IntToStr(Day) + US_Str + RS_Str + GS_Str;
                    SizeBlok := Length(TempStr);
                    move(Pointer(TempStr)^, Pointer(PointMem + TempPointMem)^, SizeBlok);
                    Inc(TempPointMem, SizeBlok);
                end;
            finally
                Close;
                Free;
            end;
        end;
    end;

    function PrepareSales(Q: TvIBDataSet): Boolean;
    var
      m,n,
      I,J: Integer;
      Res, TRes,
      Source: string;
    begin
        Result := false;
        try
            Q.SQL.Clear;
            if FileExists(SQLFile) then begin
              Q.SQL.LoadFromFile(SQLFile);
              Q.SQL.Text := ReplaceStr(Q.SQL.Text,'%DATE_BEGIN%',IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 00:00');
              Q.SQL.Text := ReplaceStr(Q.SQL.Text,'%DATE_END%',IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 23:59');
              Q.SQL.Text := ReplaceStr(Q.SQL.Text,'%DEPART%',Trim(Depart));
              repeat
                Source := Q.SQL.Text;
                Res := '';
                I := Pos('%PAYTYPE_B%', Q.SQL.Text);
                J := Pos('%PAYTYPE_E%', Q.SQL.Text)+Length('%PAYTYPE_E%');
                if (I > 0) and (J > 0) then begin
                  TRes := Copy(Source, I, J-I);
                  repeat
                    m := Pos('%P_B%', TRes);
                    n := Pos('%P_E%', TRes);
                    if (m > 0) and (n > 0) then begin
                      if StrToInt(StrFunc.ExtractWord(Copy(TRes, m+length('%P_B%'), n-m-length('%P_B%')), ':', 1)) = PayKind
                      then begin
                        Res :=StrFunc.ExtractWord(Copy(TRes, m+length('%P_B%'), n-m-length('%P_B%')), ':', 2);
                        break;
                      end
                      else
                        TRes := Copy(TRes, n+length('%P_E%'), Length(TRes)-n-length('%P_E%'));
                    end;
                  until (m <= 0) or (n <= 0);
                  if Res <> '' then
                    Q.SQL.Text := Copy(Source, 1, I - 1)+Res+Copy(Source, J, Length(Source)-J)
                  else
                    Q.SQL.Text := Copy(Source, 1, I - 1)+IntToStr(PayKind)+Copy(Source, J, Length(Source)-J);
                end;
              until (I <= 0) or (J <= 0);
            end
            else
              if Pack = 0 then begin
                Q.SQL.Add('Select a.Depart, a.EcrCode as Code, a.Price,');
                Q.SQL.Add('sum(a.Quantity) as Quantity, sum(a.Total) as Summa, sum(a.TaxSum) as TaxSum,');
                Q.SQL.Add('sum(a.Addition - a.Discount) as AddDisc');
                Q.SQL.Add('From "EcrSells" a, "EcrPays" b');
                Q.SQL.Add('Where (b.id=a.EcrPayID) and');
                Q.SQL.Add('(b.moment >= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 00:00'') and');            
                Q.SQL.Add('(b.moment <= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 23:59'') and');            
                case PayKind of            
                  0:Q.SQL.Add('(b.paycash <> 0) and');
                  1:Q.SQL.Add('(b.paycheck <> 0) and');
                  2:Q.SQL.Add('(b.paycredit <> 0) and');
                  3:Q.SQL.Add('(b.paycard <> 0) and');
                end;
                Q.SQL.Add('(a.moment >= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 00:00'') and');
                Q.SQL.Add('(a.moment <= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 23:59'')');
                if Trim(Depart) <> Null_Str then Q.SQL.Add('and (a.Depart = '+Trim(Depart)+')');
                Q.SQL.Add('Group by a.Depart, a.EcrCode, a.Price, a.TaxNumber');
                Q.SQL.Add('having sum(a.Quantity) <> 0');
                Q.SQL.Add('Order by a.Depart, a.EcrCode');
              end
              else begin    
                Q.SQL.Add('Select a.Depart, a.EcrPayID, a.EcrCode as Code, a.Price,');
                Q.SQL.Add('sum(a.Quantity) as Quantity, sum(a.Total) as Summa, sum(a.TaxSum) as TaxSum,');
                Q.SQL.Add('sum(a.Addition - a.Discount) as AddDisc');
                Q.SQL.Add('From "EcrSells" a, "EcrPays" b');
                Q.SQL.Add('Where (b.id=a.EcrPayID) and');
                Q.SQL.Add('(b.moment >= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 00:00'') and');            
                Q.SQL.Add('(b.moment <= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 23:59'') and');            
                case PayKind of            
                  0:Q.SQL.Add('(b.paycash <> 0) and');
                  1:Q.SQL.Add('(b.paycheck <> 0) and');
                  2:Q.SQL.Add('(b.paycredit <> 0) and');
                  3:Q.SQL.Add('(b.paycard <> 0) and');
                end;
                Q.SQL.Add('(a.moment >= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 00:00'') and');
                Q.SQL.Add('(a.moment <= '''+IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 23:59'')');
                if Trim(Depart) <> Null_Str then Q.SQL.Add('and (a.Depart = '+Trim(Depart)+')');
                Q.SQL.Add('Group by a.Depart, a.EcrPayID, a.EcrCode, a.Price, a.TaxNumber');
                Q.SQL.Add('having sum(a.Quantity) <> 0');
                Q.SQL.Add('Order by a.Depart, a.EcrCode');
              end;
            try
              if TDebug = 1 then
                ShowDebugGrig(Q);
              Q.Open;
              Q.FetchAll;
              Result:=BOOL(Q.RecordCount);
              if TDebug = 1 then
                ShowDebugGrig(Q);
            except
              Q.Transaction.Rollback;
              raise;
            end;
        except
			    on e:Exception do 
            AddToInfMem(ErrHandSalesMsg+#$0d+#$0a+e.Message);
		    end;
    end;

begin
    Result := false; Res := 0; SizeMem := BegMemSize;
    Pointer(PointMem) := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, SizeMem);
    if PointMem > 0 then begin

      if ShowProgr = 1 then begin
        ProgressF := TProgressF.Create(nil);
        ProgressF.Show;
      end;
    
      dmReplica:=TdmReplica.Create;
      with dmReplica do begin

        try
          QSales := TvIBDataSet.Create(nil);
          QSales.Database := Dukat;
          QSales.Transaction := DefTrans;
          QSales.BufferChunks := 10000;
          QSales.CachedUpdates := False;
          QSales.RequestLive := False;

          try
            if ( not QSales.Database.TestConnected ) then
              QSales.Database.Open;
            if not QSales.Transaction.InTransaction  then 
              QSales.Transaction.StartTransaction;
            if FileExists(PSQLFileName) then begin
              PSQL := TIBSQL.Create(nil);
              try
                PSQL.Database := Dukat;
                PSQL.Transaction := DefTrans;
                PSQL.SQL.LoadFromFile(PSQLFileName);
                Source := ReplaceStr(PSQL.SQL.Text,#13#10,' ');
                repeat
                  PSQL.SQL.Clear;
                  if Length(Source)>0 then begin
                    k := Pos('---',Source);
                    if k>0 then
                      PSQL.SQL.Text := Copy(Source, 1, k-1)
                    else
                      PSQL.SQL.Text := Source;
                    if Length(PSQL.SQL.Text)>0 then begin
                      PSQL.SQL.Text := ReplaceStr(PSQL.SQL.Text,'%DATE_BEGIN%',IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 00:00');
                      PSQL.SQL.Text := ReplaceStr(PSQL.SQL.Text,'%DATE_END%',IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 23:59');
                      PSQL.SQL.Text := ReplaceStr(PSQL.SQL.Text,'%DEPART%',Trim(Depart));
                      PSQL.ExecQuery;
                    end;
                    if k>0 then
                      Source := Copy(Source, k+3, Length(Source)-k-2);
                  end
                  else
                    break;
                until k=0;
                PSQL.Close;
                PSQL.Free;
              except
                  PSQL.Close;
                  PSQL.Free;
                  raise;
              end;
            end;
            if PrepareSales(QSales) then begin
              try
                With QSales do begin
                  try
                    FS_Dep := FieldByName('Depart');
                    TWDep := 1;
                  except
                    TWDep := 0;
                  end;
                  FS_Code := FieldByName('Code');
                  First;
                  TempPointMem := 0;
                  if WriteHeader then begin
                    if ShowProgr = 1 then begin
                      ProgressF.pbMain.Position := 0;
                      ProgressF.pbMain.Max := QSales.RecordCount;
                      ProgressF.lblMain.Caption := 'Формирование перечня продаж.';
                      ProgressF.ProcessMessages;
                    end;    
                    for RCounter:= 0 to RecordCount - 1 do begin
                      try
                        TempStr := '';
                        if (not FileExists(SQLFile)) and
                          (WDep = 1) and (TWDep = 1) then
                          TempStr := TempStr + ReplaceChar(Trim(Fields[0].AsString), ',', '.') + US_Str;
                        for i := 0 to FieldCount - 1 do begin 
                          if (not FileExists(SQLFile)) and (TWDep = 1) and (i < 1) then continue;
                          if Fields[i].FieldName <> 'ED' then
                            TempStr := TempStr + ReplaceChar(Trim(Fields[i].AsString), ',', '.') + US_Str;
                        end;
                        TempStr := TempStr + Trim(FieldByName('ED').AsString) + US_Str + RS_Str;
                        SizeBlok := Length(TempStr);
                        if (TempPointMem + SizeBlok) > SizeMem then begin
                          Inc(SizeMem, MinMemSize);
                          Pointer(I_PointMem) :=HeapRealloc(GetProcessHeap, HEAP_ZERO_MEMORY,
                                                            Pointer(PointMem), SizeMem);
                          if I_PointMem > 0 then PointMem := I_PointMem
                          else begin
                              TokenWrite := False;
                              ShowSystemErrorMsg;
                              break;
                          end;
                        end;
                        move(Pointer(TempStr)^, Pointer(PointMem + TempPointMem)^, SizeBlok);
                        Inc(TempPointMem, SizeBlok); Inc(RecWriteCount);
                        TokenWrite := True;
                      except
                        on e: Exception do begin 
                          AddToInfMemF(Error+': '+e.Message);
                          Res := -1;
                        end;
                      end;
                      Next;
                      if ShowProgr = 1 then begin
                        ProgressF.pbMain.StepIt;
                        ProgressF.ProcessMessages;
                      end;
                    end;
                    if TokenWrite then begin
                      move(Pointer(GS_Str)^, Pointer(PointMem + TempPointMem)^, 1);
                      Inc(TempPointMem);
                      Pointer(I_PointMem) :=HeapRealloc(GetProcessHeap, HEAP_ZERO_MEMORY,
                                                        Pointer(PointMem), TempPointMem);
                      if I_PointMem > 0 then begin
                        if Boolean(TokenWriteWOSn) then begin
                          PointMem := I_PointMem;
                          WriteFile(hFile, Pointer(PointMem)^, TempPointMem, WriteCount, nil);
                          if (WriteCount <> TempPointMem) then raise Exception.Create(Null_Str);
                          AddToInfMem(Format(ResCountRecMsg, [RecWriteCount]));
                          Res := RecWriteCount;
                          Result := True;
                        end
                        else
                          if Res >= 0 then begin
                            PointMem := I_PointMem;
                            WriteFile(hFile, Pointer(PointMem)^, TempPointMem, WriteCount, nil);
                            if (WriteCount <> TempPointMem) then raise Exception.Create(Null_Str);
                            AddToInfMem(Format(ResCountRecMsg, [RecWriteCount]));
                            Res := RecWriteCount;
                            Result := True;
                          end;
                      end
                      else ShowSystemErrorMsg;
                    end;
                  end;
                end;
              except
                on e:Exception do AddToInfMem(Error+': '+e.Message);
              end;
            end
            else AddToInfMem(ErrHandSalesMsg);
            if FileExists(PosSQLFileName) then begin
              PSQL := TIBSQL.Create(nil);
              try
                PSQL.Database := Dukat;
                PSQL.Transaction := DefTrans;
                PSQL.SQL.LoadFromFile(PosSQLFileName);
                Source := ReplaceStr(PSQL.SQL.Text,#13#10,'');
                repeat
                  PSQL.SQL.Clear;
                  if Length(Source)>0 then begin
                    k := Pos('---',Source);
                    if k>0 then
                      PSQL.SQL.Text := Copy(Source, 1, k-1)
                    else
                      PSQL.SQL.Text := Source;
                    if Length(PSQL.SQL.Text)>0 then begin
                      PSQL.SQL.Text := ReplaceStr(PSQL.SQL.Text,'%DATE_BEGIN%',IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 00:00');
                      PSQL.SQL.Text := ReplaceStr(PSQL.SQL.Text,'%DATE_END%',IntToStr(Day)+'.'+IntToStr(Month)+'.'+IntToStr(Year)+' 23:59');
                      PSQL.SQL.Text := ReplaceStr(PSQL.SQL.Text,'%DEPART%',Trim(Depart));
                      PSQL.ExecQuery;
                    end;
                    if k>0 then
                      Source := Copy(Source, k+3, Length(Source)-k-2);
                  end
                  else
                    break;
                until k=0;
                PSQL.Close;
                PSQL.Free;
              except
                  PSQL.Close;
                  PSQL.Free;
                  raise;
              end;
            end;
          except
            on e:Exception do begin 
              AddToInfMem(ErrHandSalesMsg+#$0d+#$0a+e.Message);
              if QSales.Transaction.InTransaction then
                QSales.Transaction.Rollback;
            end;
          end;
          QSales.Close;
          if QSales.Transaction.InTransaction then
            if Res >= 0 then QSales.Transaction.Commit
            else QSales.Transaction.Rollback;
          QSales.Free;
        except
          on e:Exception do AddToInfMem(ErrHandSalesMsg+#$0d+#$0a+e.Message);
        end;
      end;
      dmReplica.Free;
      if not HeapFree(GetProcessHeap, HEAP_NO_SERIALIZE,
                      Pointer(PointMem)) then ShowSystemErrorMsg;
                      
      if ShowProgr = 1 then begin
        ProgressF.Close;
        ProgressF.Free;
      end;
                      
    end
    else ShowSystemErrorMsg;
end;

//=============================================================CreateOutgoinFile
function CreateOutgoinFile(const FileName, Depart: String; Year, Month, 
  Day: Cardinal; PayKind: Cardinal=0): Integer;
var
    hFile:          Cardinal;
    TokenDelete:    Boolean;
begin
    Result := -2;
    hFile := CreateFile(PChar(Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0)))+FileName),
                        GENERIC_READ or GENERIC_WRITE,
                        0,
                        nil,
                        CREATE_ALWAYS,
                        FILE_ATTRIBUTE_NORMAL,
                        0);
    if (hFile <> INVALID_HANDLE_VALUE) and (hFile > 0) then begin
        TokenDelete := FillingResFile(hFile, Depart, Year, Month, 
          Day, PayKind, Result);
        CloseHandle(hFile);
        if not TokenDelete then DeleteFile(Copy(ParamStr(0), 1, LastDelimiter(PathDelimiter, ParamStr(0)))+FileName);
        ShowInformMemo(InfMem);
    end
    else ShowSystemErrorMsg;
end;

end.


