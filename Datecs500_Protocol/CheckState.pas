unit CheckState;

interface
  uses  Windows, Messages, LogFunc, 
  ConnectionStream, Const_Type, SysUtils,
  dbclient;

type
  PCheckState = ^TCheckState;
  TCheckState = class
    __CheckData:  TClientDataSet;
    __Total:      Currency;
    __TotalPay:   Currency;
    __PayCheck,
    __PayCredit,
    __PayCash:    Currency;
    __Return: Boolean;
    __FileName,
    __TmpDir: String;
    __tReject: Boolean;
    __SaveServiceCheck: Integer;
    __WriteProtocol: integer;
    
    function __CheckDataCreate(_SerialNum: Integer): TClientDataSet;
  public
    constructor Create(_TmpDir: String);
    function SaveSale( _DevEnum: PDevEnum; _P: TGoodsParam; _ChkNum, _Row: Integer ): Boolean;
    procedure AppendLast(_DevEnum: PDevEnum; _ChkNum: Integer );
    procedure RejectSaleCode(_DevEnum: PDevEnum; _P: TGoodsParam);
    procedure RejectSale(_DevEnum: PDevEnum);
    procedure Payment( _MainTHId: Cardinal; _DevEnum: PDevEnum; _tKnd: String; _ChkNum:Integer; _TotalSum, _Sum: Currency);
    procedure RegisterAnnul( _DevEnum: PDevEnum; _ChkNum:Integer );
    procedure ConfirmAnnul( _MainTHId: Cardinal; _DevEnum: PDevEnum );
    procedure RegisterDiscount(_DevEnum: PDevEnum; _ChkNum : Integer; _BSum, _ASum, _Val: Double; _tDKind: Integer);
    property CheckData: TClientDataSet read __CheckData;
  end;
  
implementation

  uses db, StrUtils;
{ TCheckState }

function TCheckState.__CheckDataCreate(_SerialNum: Integer): TClientDataSet;
var
  _tmp: TClientDataSet;
begin
  try
    __CheckData := nil;
    __Total := 0.00;
    __TotalPay := 0.00;
    __PayCheck := 0.00;
    __PayCredit := 0.00;
    __PayCash := 0.00;
    __Return := False;

    _tmp := TClientDataSet.Create(nil);
    with _tmp do begin
  //fields  
      with FieldDefs.AddFieldDef do begin
        Name := 'SerialNum';
        DataType := ftInteger;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Operation';
        DataType := ftInteger;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Row';
        DataType := ftInteger;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'DT';
        DataType := ftString;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'ChkNum';
        DataType := ftInteger;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Code';
        DataType := ftInteger;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'BarCode';
        DataType := ftString;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'GoodsID';
        DataType := ftInteger;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Count';
        DataType := ftFloat;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Price';
        DataType := ftCurrency;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Tax';
        DataType := ftInteger;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Discount';
        DataType := ftFloat;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Sum';
        DataType := ftFloat;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Knd';
        DataType := ftString;
      end;
      with FieldDefs.AddFieldDef do begin
        Name := 'Return';
        DataType := ftInteger;
      end;
      
  //indeces    
{  
      with IndexDefs.AddIndexDef do begin
        Fields := 'Operation';
        Name := 'IntIndex';
      end;
}      
    end;
    _tmp.CreateDataSet;
    _tmp.LogChanges:=False;
    Result := _tmp;
    __FileName := __TmpDir+IntToStr(_SerialNum)+__tmpand+
                  ReplaceStr(ReplaceStr(ReplaceStr(DateTimeToStr(Now),'.',''),' ',''),':','')+
                  __tmpext;
    _tmp := nil;
  except
    Result := nil;
  end;
end;

constructor TCheckState.Create(_TmpDir: String);
begin
  inherited Create;
  __CheckData := nil;
  __Total := 0.00;
  __TotalPay := 0.00;
  __PayCheck := 0.00;
  __PayCredit := 0.00;
  __PayCash := 0.00;
  __Return := False;
  __TmpDir := _TmpDir;
  __tReject := False;
  __SaveServiceCheck := __DefSaveServiceCheck;
  __WriteProtocol := __DefWriteProtocol;
  if (LastDelimiter(PathDelimiter, __TmpDir) <> Length(__TmpDir)) then
    __TmpDir := __TmpDir + PathDelimiter;
end;

function TCheckState.SaveSale(_DevEnum: PDevEnum; _P: TGoodsParam; _ChkNum, _Row: Integer): Boolean;
var
  _tmp: String;
  _rpt: integer;
begin
  Result := False;
  __tReject := False;
  try
    _rpt := __DefRepCountCreateCheckData;
    while ((not assigned(__CheckData)) and (_rpt > 0)) do begin
      __CheckData := __CheckDataCreate(_DevEnum^.SerialNum);
      Dec(_rpt);
    end;
    if assigned(__CheckData) then begin
      if ((StrToFloat(_P.Count) < 0) and ( __CheckData.RecordCount <= 0 )) then __Return := True;
      if (StrToFloat(_P.Count) > 0) and ( not __Return ) then begin
        __CheckData.IndexFieldNames := '';
        __CheckData.Last;
        __CheckData.Append;
        try
          with __CheckData do begin
            FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
            FieldByName('Operation').AsInteger := __opSale;
            FieldByName('Row').AsInteger := _Row;
            FieldByName('ChkNum').AsInteger := _ChkNum;
            FieldByName('Code').AsInteger := StrToInt(_P.Code);
            if _P.isBarCode then FieldByName('BarCode').AsString := _P.BarCode;
            FieldByName('GoodsID').AsInteger := StrToInt(_P.GoodsID);
            FieldByName('Count').AsFloat := StrToFloat(_P.Count);
            FieldByName('Price').AsCurrency := StrToCurr(_P.Price);
            FieldByName('Tax').AsInteger := StrToInt(_P.Tax);
            FieldByName('Return').AsInteger := 0;
            FieldByName('Discount').AsCurrency := 0;
            if StrToFloat(_P.Count) > 0 then
              FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100+0.5)/100
            else
              FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100-0.5)/100;
            FieldByName('DT').AsString := DateTimeToStr(Now);
          end;
          __CheckData.Post;
          try
            __CheckData.SaveToFile(__FileName);
            _tmp := '-> '+IntToStr(_DevEnum^.SerialNum)+';'+IntToStr(_ChkNum)+';'+_P.Code+';'+_P.GoodsID+';'+_P.Count+';'+_P.Price+';'+DateTimeToStr(Now);
            if BOOL(__WriteProtocol) then
              _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
          finally
            __tReject := True;
            Result := True;
          end;
        except
          on E:Exception do begin
            __CheckData.Cancel;
            _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
            Result := False;
          end;
        end;
      end
      else 
        if ( not __Return ) then begin
          with __CheckData do begin
            if not _P.isBarCode then begin
              IndexFieldNames := 'Code';
              EditKey;
              FieldByName('Code').AsInteger := StrToInt(_P.Code);
              if GotoKey then begin
                while True do begin
                  if (FieldByName('Code').AsInteger <> StrToInt(_P.Code))then break;
                  if (FieldByName('Return').AsInteger = 0) and (Length(FieldByName('BarCode').AsString) = 0) and
                    (abs(FieldByName('Count').AsFloat + StrToFloat(_P.Count)) < 0.001)  then begin
                    Edit;
                    FieldByName('Return').AsInteger := 1;
                    Post;
                    IndexFieldNames := '';
                    Last;
                    Append;
                    try
                      FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
                      FieldByName('Operation').AsInteger := __opSale;
                      FieldByName('Row').AsInteger := _Row;
                      FieldByName('ChkNum').AsInteger := _ChkNum;
                      FieldByName('Code').AsInteger := StrToInt(_P.Code);
                      FieldByName('GoodsID').AsInteger := StrToInt(_P.GoodsID);
                      FieldByName('Count').AsFloat := StrToFloat(_P.Count);
                      FieldByName('Price').AsCurrency := StrToCurr(_P.Price);
                      FieldByName('Tax').AsInteger := StrToInt(_P.Tax);
                      FieldByName('Return').AsInteger := 1;
                      FieldByName('Discount').AsCurrency := 0;
                      if (StrToFloat(_P.Count) > 0) then
                        FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100+0.5)/100
                      else
                        FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100-0.5)/100;
                      FieldByName('DT').AsString := DateTimeToStr(Now);
                      Post;
                      try
                        SaveToFile(__FileName);
                        _tmp := '-> '+IntToStr(_DevEnum^.SerialNum)+';'+IntToStr(_ChkNum)+';'+_P.Code+';'+_P.GoodsID+';'+_P.Count+';'+_P.Price+';'+DateTimeToStr(Now);
                        if BOOL(__WriteProtocol) then
                          _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
                      finally
                        __tReject := True;
                        Result := True;
                      end;
                    except
                      on E:Exception do begin
                        __CheckData.Cancel;
                        _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
                      end;
                    end;
                    break;
                  end
                  else begin
                    if not Eof then Next
                    else break;
                  end;
                end;
              end;
            end
            else begin
              IndexFieldNames := 'BarCode';
              EditKey;
              FieldByName('BarCode').AsString := _P.BarCode;
              if GotoKey then begin
                while True do begin
                  if (FieldByName('BarCode').AsString <> _P.BarCode) then Break;
                  if (FieldByName('Return').AsInteger = 0) and (FieldByName('Code').AsInteger = StrToInt(_P.Code)) and
                    (abs(FieldByName('Count').AsFloat + StrToFloat(_P.Count)) < 0.001)  then begin
                    Edit;
                    FieldByName('Return').AsInteger := 1;
                    Post;
                    IndexFieldNames := '';
                    Last;
                    Append;
                    try
                      FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
                      FieldByName('Operation').AsInteger := __opSale;
                      FieldByName('Row').AsInteger := _Row;
                      FieldByName('ChkNum').AsInteger := _ChkNum;
                      FieldByName('Code').AsInteger := StrToInt(_P.Code);
                      FieldByName('BarCode').AsString := _P.BarCode;
                      FieldByName('GoodsID').AsInteger := StrToInt(_P.GoodsID);
                      FieldByName('Count').AsFloat := StrToFloat(_P.Count);
                      FieldByName('Price').AsCurrency := StrToCurr(_P.Price);
                      FieldByName('Tax').AsInteger := StrToInt(_P.Tax);
                      FieldByName('Return').AsInteger := 1;
                      FieldByName('Discount').AsCurrency := 0;
                      if (StrToFloat(_P.Count) > 0) then
                        FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100+0.5)/100
                      else
                        FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100-0.5)/100;
                      FieldByName('DT').AsString := DateTimeToStr(Now);
                      Post;
                      try
                        SaveToFile(__FileName);
                        _tmp := '-> '+IntToStr(_DevEnum^.SerialNum)+';'+IntToStr(_ChkNum)+';'+_P.Code+';'+_P.GoodsID+';'+_P.Count+';'+_P.Price+';'+DateTimeToStr(Now);
                        if BOOL(__WriteProtocol) then
                          _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
                      finally
                        __tReject := True;
                        Result := True;
                      end;
                    except
                      on E:Exception do begin
                        __CheckData.Cancel;
                        _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
                      end;
                    end;
                    break;
                  end
                  else begin
                    if not Eof then Next
                    else break;
                  end;
                end;
              end;
            end;
            IndexFieldNames := '';
            Last;
          end;
        end
        else
          if ( __Return ) then begin
            if (StrToFloat(_P.Count) < 0) then begin
              __CheckData.IndexFieldNames := '';
              __CheckData.Last;
              __CheckData.Append;
              try
                with __CheckData do begin
                  FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
                  FieldByName('Operation').AsInteger := __opSale;
                  FieldByName('Row').AsInteger := _Row;
                  FieldByName('ChkNum').AsInteger := _ChkNum;
                  FieldByName('Code').AsInteger := StrToInt(_P.Code);
                  if _P.isBarCode then FieldByName('BarCode').AsString := _P.BarCode;
                  FieldByName('GoodsID').AsInteger := StrToInt(_P.GoodsID);
                  FieldByName('Count').AsFloat := StrToFloat(_P.Count);
                  FieldByName('Price').AsCurrency := StrToCurr(_P.Price);
                  FieldByName('Tax').AsInteger := StrToInt(_P.Tax);
                  FieldByName('Return').AsInteger := 0;
                  FieldByName('Discount').AsCurrency := 0;
                  if (StrToFloat(_P.Count)>0) then
                    FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100+0.5)/100
                  else
                    FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100-0.5)/100;
                  FieldByName('DT').AsString := DateTimeToStr(Now);
                end;
                __CheckData.Post;
                try
                  __CheckData.SaveToFile(__FileName);
                  _tmp := '-> '+IntToStr(_DevEnum^.SerialNum)+';'+IntToStr(_ChkNum)+';'+_P.Code+';'+_P.GoodsID+';'+_P.Count+';'+_P.Price+';'+DateTimeToStr(Now);
                  if BOOL(__WriteProtocol) then
                    _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
                finally
                  __tReject := True;
                  Result := True;
                end;
              except
                on E:Exception do begin
                  __CheckData.Cancel;
                  _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
                  Result := False;
                end;
              end;
            end
            else begin
              with __CheckData do begin
                if not _P.isBarCode then begin
                  IndexFieldNames := 'Code';
                  EditKey;
                  FieldByName('Code').AsInteger := StrToInt(_P.Code);
                  if GotoKey then begin
                    while True do begin
                      if (FieldByName('Code').AsInteger <> StrToInt(_P.Code))then break;
                      if (FieldByName('Return').AsInteger = 0) and (Length(FieldByName('BarCode').AsString) = 0) and
                        (abs(FieldByName('Count').AsFloat + StrToFloat(_P.Count)) < 0.001)  then begin
                        Edit;
                        FieldByName('Return').AsInteger := 1;
                        Post;
                        IndexFieldNames := '';
                        Last;
                        Append;
                        try
                          FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
                          FieldByName('Operation').AsInteger := __opSale;
                          FieldByName('Row').AsInteger := _Row;
                          FieldByName('ChkNum').AsInteger := _ChkNum;
                          FieldByName('Code').AsInteger := StrToInt(_P.Code);
                          FieldByName('GoodsID').AsInteger := StrToInt(_P.GoodsID);
                          FieldByName('Count').AsFloat := StrToFloat(_P.Count);
                          FieldByName('Price').AsCurrency := StrToCurr(_P.Price);
                          FieldByName('Tax').AsInteger := StrToInt(_P.Tax);
                          FieldByName('Return').AsInteger := 1;
                          FieldByName('Discount').AsCurrency := 0;
                          if (StrToFloat(_P.Count) > 0) then
                            FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100+0.5)/100
                          else
                            FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100-0.5)/100;
                          FieldByName('DT').AsString := DateTimeToStr(Now);
                          Post;
                          try
                            SaveToFile(__FileName);
                            _tmp := '-> '+IntToStr(_DevEnum^.SerialNum)+';'+IntToStr(_ChkNum)+';'+_P.Code+';'+_P.GoodsID+';'+_P.Count+';'+_P.Price+';'+DateTimeToStr(Now);
                            if BOOL(__WriteProtocol) then
                              _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
                          finally
                            __tReject := True;
                            Result := True;
                          end;
                        except
                          on E:Exception do begin
                            __CheckData.Cancel;
                            _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
                          end;
                        end;
                        break;
                      end
                      else begin
                        if not Eof then Next
                        else break;
                      end;
                    end;
                  end;
                end
                else begin
                  IndexFieldNames := 'BarCode';
                  EditKey;
                  FieldByName('BarCode').AsString := _P.BarCode;
                  if GotoKey then begin
                    while True do begin
                      if (FieldByName('BarCode').AsString <> _P.BarCode) then Break;
                      if (FieldByName('Return').AsInteger = 0) and (FieldByName('Code').AsInteger = StrToInt(_P.Code)) and
                        (abs(FieldByName('Count').AsFloat + StrToFloat(_P.Count)) < 0.001)  then begin
                        Edit;
                        FieldByName('Return').AsInteger := 1;
                        Post;
                        IndexFieldNames := '';
                        Last;
                        Append;
                        try
                          FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
                          FieldByName('Operation').AsInteger := __opSale;
                          FieldByName('Row').AsInteger := _Row;
                          FieldByName('ChkNum').AsInteger := _ChkNum;
                          FieldByName('Code').AsInteger := StrToInt(_P.Code);
                          FieldByName('BarCode').AsString := _P.BarCode;
                          FieldByName('GoodsID').AsInteger := StrToInt(_P.GoodsID);
                          FieldByName('Count').AsFloat := StrToFloat(_P.Count);
                          FieldByName('Price').AsCurrency := StrToCurr(_P.Price);
                          FieldByName('Tax').AsInteger := StrToInt(_P.Tax);
                          FieldByName('Return').AsInteger := 1;
                          FieldByName('Discount').AsCurrency := 0;
                          if (StrToFloat(_P.Count) > 0) then
                            FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100+0.5)/100
                          else
                            FieldByName('Sum').AsCurrency := Trunc(StrToFloat(_P.Count)*StrToCurr(_P.Price)*100-0.5)/100;
                          FieldByName('DT').AsString := DateTimeToStr(Now);
                          Post;
                          try
                            SaveToFile(__FileName);
                            _tmp := '-> '+IntToStr(_DevEnum^.SerialNum)+';'+IntToStr(_ChkNum)+';'+_P.Code+';'+_P.GoodsID+';'+_P.Count+';'+_P.Price+';'+DateTimeToStr(Now);
                            if BOOL(__WriteProtocol) then
                              _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
                          finally
                            __tReject := True;
                            Result := True;
                          end;
                        except
                          on E:Exception do begin
                            __CheckData.Cancel;
                            _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
                          end;
                        end;
                        break;
                      end
                      else begin
                        if not Eof then Next
                        else break;
                      end;
                    end;
                  end;
                end;
                IndexFieldNames := '';
                Last;
              end;
            end;
          end;
    end
    else begin
      try
        raise Exception.Create('__CheckData is null');
      except
        on E:Exception do begin
          _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
          Result := False;
        end;
      end;
    end;
  except
    on E:Exception do begin
      _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
      Result := False;
    end;
  end;
end;

procedure TCheckState.AppendLast(_DevEnum: PDevEnum; _ChkNum: Integer );
var
  _Row, _Code, _GoodsID, _Tax: Integer;
  _Price: Currency;
  _Count: Double;
  
begin
  __tReject := False;
  if assigned(__CheckData) then begin
    with __CheckData do begin
      if FieldByName('Operation').AsInteger = __opSale then begin
        try
          _Code := FieldByName('Code').AsInteger;
          _Price := FieldByName('Price').AsCurrency;
          _Tax := FieldByName('Tax').AsInteger;
          _Row := FieldByName('Row').AsInteger;
          _GoodsID := FieldByName('GoodsID').AsInteger;
          _Count := FieldByName('Count').AsFloat;
          IndexFieldNames := '';
          Last;
          Append;
          FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
          FieldByName('Operation').AsInteger := __opSale;
          FieldByName('Row').AsInteger := _Row;
          FieldByName('ChkNum').AsInteger := _ChkNum;
          FieldByName('Code').AsInteger := _Code;
          FieldByName('GoodsID').AsInteger := _GoodsID;
          FieldByName('Count').AsFloat := _Count;
          FieldByName('Price').AsCurrency := _Price;
          FieldByName('Tax').AsInteger := _Tax;
          FieldByName('Discount').AsCurrency := 0;
          if _Count > 0 then
            FieldByName('Sum').AsCurrency := Trunc(_Count*_Price*100+0.5)/100
          else
            FieldByName('Sum').AsCurrency := Trunc(_Count*_Price*100-0.5)/100;

          FieldByName('DT').AsString := DateTimeToStr(Now);
          Post;
          try
            SaveToFile(__FileName);
          finally end;
        except
          on E:Exception do begin
            __CheckData.Cancel;
            _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
          end;
        end;
      end;
    end;
  end;
end;

procedure TCheckState.RejectSaleCode(_DevEnum: PDevEnum; _P: TGoodsParam);
var
  _SerialNum: Integer;
  _tmp: String;
begin
  if __tReject and assigned(__CheckData) then begin
    if __CheckData.RecordCount > 0 then begin
      _SerialNum := __CheckData.FieldByName('SerialNum').AsInteger;
      if (((not _P.isBarCode) and (__CheckData.FieldByName('Code').AsInteger = StrToInt(_P.Code))) and
          ((abs(__CheckData.FieldByName('Count').AsFloat + StrToFloat(_P.Count)) < 0.001)) or 
          ((_P.isBarCode and (__CheckData.FieldByName('BarCode').AsString = _P.BarCode)) and 
          (abs(abs(__CheckData.FieldByName('Count').AsFloat) - 
           abs(Trunc(abs(StrToFloat(_P.Count))*_P.Zoom*10000+0.5)/10000)) < 0.001))) then begin
        __CheckData.Delete;
        try
          __CheckData.SaveToFile(__FileName);
          _tmp := '<- '+IntToStr(_SerialNum)+';'+_P.Code+';'+_P.Count+';'+DateTimeToStr(Now);
          if BOOL(__WriteProtocol) then
            _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
        finally end;
      end;
    end;
  end;
  __tReject := False;
end;

procedure TCheckState.RejectSale(_DevEnum: PDevEnum);
var
  _SerialNum: Integer;
  _tmp: String;
begin
  if __tReject and assigned(__CheckData) then begin
    if __CheckData.RecordCount > 0 then begin
      _SerialNum := _DevEnum^.SerialNum; //__CheckData.FieldByName('SerialNum').AsInteger;
      __CheckData.Delete;
      try
        __CheckData.SaveToFile(__FileName);
        _tmp := '<- '+IntToStr(_SerialNum)+';'+DateTimeToStr(Now);
        if BOOL(__WriteProtocol) then
          _DevEnum^.Log.WriteToLog(PChar(_tmp), Length(_tmp));
      finally end;
    end;
  end;
  __tReject := False;
end;

procedure TCheckState.RegisterDiscount(_DevEnum: PDevEnum; _ChkNum: Integer; _BSum,
  _ASum, _Val: Double; _tDKind: Integer);
begin
  __tReject := False;
  if assigned(__CheckData) then
    if __CheckData.RecordCount > 0 then begin
      case _tDKind of
        __DiscOnLastPerc: begin
          __CheckData.Edit;
          try
            if ((_BSum > 0) and (_Val>0)) or
              ((_BSum < 0) and (_Val<0)) then
              __CheckData.FieldByName('Discount').AsCurrency := Trunc(_BSum * _Val*100+0.5)/10000
            else
              __CheckData.FieldByName('Discount').AsCurrency := Trunc(_BSum * _Val*100-0.5)/10000;
            if _BSum > 0 then
              __CheckData.FieldByName('Sum').AsCurrency := Trunc((_BSum + __CheckData.FieldByName('Discount').AsCurrency)*100+0.5)/100
            else
              __CheckData.FieldByName('Sum').AsCurrency := Trunc((_BSum + __CheckData.FieldByName('Discount').AsCurrency)*100-0.5)/100;
            __CheckData.Post;
            try
              __CheckData.SaveToFile(__FileName);
            finally end;
          except
            on E:Exception do begin
              __CheckData.Cancel;
              _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
            end;
          end;
        end;
        __DiscOnLastSum: begin
          __CheckData.Edit;
          try
            if ((_BSum > 0) and (_Val>0)) or
              ((_BSum < 0) and (_Val<0)) then
              __CheckData.FieldByName('Discount').AsCurrency := Trunc(_Val*100+0.5)/100
            else
              __CheckData.FieldByName('Discount').AsCurrency := Trunc(_Val*100+0.5)/100;
            if _BSum > 0 then
              __CheckData.FieldByName('Sum').AsCurrency := Trunc((_BSum + __CheckData.FieldByName('Discount').AsCurrency)*100+0.5)/100
            else
              __CheckData.FieldByName('Sum').AsCurrency := Trunc((_BSum + __CheckData.FieldByName('Discount').AsCurrency)*100+0.5)/100;
            __CheckData.Post;
            try
              __CheckData.SaveToFile(__FileName);
            finally end;
          except
            on E:Exception do begin
              __CheckData.Cancel;
              _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
            end;
          end;
        end;
        __DiscPerc: begin
          while not __CheckData.Bof do begin
            if ( __CheckData.FieldByName('ChkNum').AsInteger = _ChkNum ) then begin
              __CheckData.Edit;
              try
                if (Length(Trim(__CheckData.FieldByName('Discount').AsString)) > 0) then begin
                  if ((_BSum > 0) and (_Val>0)) or
                    ((_BSum < 0) and (_Val<0)) then
                    __CheckData.FieldByName('Discount').AsCurrency := __CheckData.FieldByName('Discount').AsCurrency + Trunc(__CheckData.FieldByName('Sum').AsCurrency * _Val*100+0.5)/10000
                  else
                    __CheckData.FieldByName('Discount').AsCurrency := __CheckData.FieldByName('Discount').AsCurrency + Trunc(__CheckData.FieldByName('Sum').AsCurrency * _Val*100-0.5)/10000
                end
                else
                  if ((__CheckData.FieldByName('Sum').AsCurrency > 0) and (_Val>0)) or
                    ((__CheckData.FieldByName('Sum').AsCurrency < 0) and (_Val<0)) then
                    __CheckData.FieldByName('Discount').AsCurrency := Trunc(__CheckData.FieldByName('Sum').AsCurrency * _Val*100+0.5)/10000
                  else
                    __CheckData.FieldByName('Discount').AsCurrency := Trunc(__CheckData.FieldByName('Sum').AsCurrency * _Val*100-0.5)/10000;
                if (__CheckData.FieldByName('Sum').AsCurrency > 0) then
                  __CheckData.FieldByName('Sum').AsCurrency := __CheckData.FieldByName('Sum').AsCurrency + Trunc(__CheckData.FieldByName('Sum').AsCurrency * _Val*100+0.5)/10000
                else
                  __CheckData.FieldByName('Sum').AsCurrency := __CheckData.FieldByName('Sum').AsCurrency + Trunc(__CheckData.FieldByName('Sum').AsCurrency * _Val*100-0.5)/10000;
                __CheckData.Post;
                _ASum := _ASum - __CheckData.FieldByName('Sum').AsCurrency;
                if _ASum <= 0 then break;
              except
                on E:Exception do begin
                  __CheckData.Cancel;
                  _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
                end;
              end;
            end 
            else break;
            __CheckData.Prior;
          end;
          try
            __CheckData.Last;
            __CheckData.SaveToFile(__FileName);
          finally end;
        end;
        __DiscSum: begin
          while not __CheckData.Bof do begin
            if ( __CheckData.FieldByName('ChkNum').AsInteger = _ChkNum ) then begin
              __CheckData.Edit;
              try
                if (Length(Trim(__CheckData.FieldByName('Discount').AsString)) > 0) then begin
                  if ((_BSum > 0) and (_Val>0)) or
                    ((_BSum < 0) and (_Val<0)) then
                    __CheckData.FieldByName('Discount').AsCurrency := __CheckData.FieldByName('Discount').AsCurrency + Trunc(_Val*_Val/__CheckData.FieldByName('Sum').AsCurrency * 100+0.5)/100
                  else
                    __CheckData.FieldByName('Discount').AsCurrency := __CheckData.FieldByName('Discount').AsCurrency + Trunc(_Val*_Val/__CheckData.FieldByName('Sum').AsCurrency *100-0.5)/100;
                end
                else
                  if ((_BSum > 0) and (_Val>0)) or
                    ((_BSum < 0) and (_Val<0)) then
                    __CheckData.FieldByName('Discount').AsCurrency := Trunc(_Val*__CheckData.FieldByName('Sum').AsCurrency/_BSum *100+0.5)/100
                  else
                    __CheckData.FieldByName('Discount').AsCurrency := Trunc(_Val*__CheckData.FieldByName('Sum').AsCurrency/_BSum*100-0.5)/100;
                if (__CheckData.FieldByName('Sum').AsCurrency > 0) then
                  __CheckData.FieldByName('Sum').AsCurrency := __CheckData.FieldByName('Sum').AsCurrency + Trunc(_Val*__CheckData.FieldByName('Sum').AsCurrency/_BSum *100+0.5)/100
                else
                  __CheckData.FieldByName('Sum').AsCurrency := __CheckData.FieldByName('Sum').AsCurrency + Trunc(_Val*__CheckData.FieldByName('Sum').AsCurrency/_BSum *100-0.5)/100;
                __CheckData.Post;
                _ASum := _ASum - __CheckData.FieldByName('Sum').AsCurrency;
                if _ASum <= 0 then break;
              except
                on E:Exception do begin
                  __CheckData.Cancel;
                  _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
                end;
              end;
            end 
            else break;
            __CheckData.Prior;
          end;
          try
            __CheckData.Last;
            __CheckData.SaveToFile(__FileName);
          finally end;
        end;
      end;
    end;
end;

procedure TCheckState.RegisterAnnul( _DevEnum: PDevEnum; _ChkNum:Integer);
begin
  __tReject := False;
  if assigned(__CheckData) then begin
    with __CheckData do begin
      try
        First;
        Insert;
        FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
        FieldByName('Operation').AsInteger := __opAnnul;
        FieldByName('ChkNum').AsInteger := _ChkNum;
        FieldByName('DT').AsString := DateTimeToStr(Now);
        FieldByName('Knd').AsString := '0';
        Post;
        __tReject := True;
        try
          __CheckData.SaveToFile(__FileName);
        finally end;
      except
        on E:Exception do begin
          __CheckData.Cancel;
          _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
        end;
      end;
    end;
  end;
end;

procedure TCheckState.ConfirmAnnul( _MainTHId: Cardinal; _DevEnum: PDevEnum );
var
  _tmp: PSaveDataRec;
begin
  __tReject := False;
  if assigned(__CheckData) then begin
    try
      GetMem(_tmp, SizeOf(TSaveDataRec));
      FillChar(_tmp^,SizeOf(TSaveDataRec),$00);
      _tmp^.__CheckData := Pointer(__CheckData);
      SetString(_tmp^.__FileName,PChar(__FileName),Length(__FileName));
      SetString(_tmp^.__TmpDir,PChar(__TmpDir),Length(__TmpDir));
      __CheckData := nil;
      PostThreadMessage(_MainTHId,THREAD_PROCESS_DATA,0,Cardinal(_tmp));
    except
      on E: Exception do begin
        _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
      end;
    end;
  end;
end;

procedure TCheckState.Payment( _MainTHId: Cardinal; _DevEnum: PDevEnum; _tKnd: String; _ChkNum: Integer; _TotalSum, _Sum: Currency);
var
  _tmp: PSaveDataRec;
  _tPayment: Integer;
begin
  __tReject := False;
  try
    while (not assigned(__CheckData)) do
      __CheckData := __CheckDataCreate(_DevEnum^.SerialNum);
    if assigned(__CheckData) then begin
      with __CheckData do begin
        try
          if _tKnd = ___kndNullCheck then _tKnd := __kndNullCheck;
          if _tKnd = ___kndInOut then _tKnd := __kndInOut;
          if not ((not BOOL(__SaveServiceCheck)) and (( _tKnd = __kndNullCheck ) or
             ( _tKnd = __kndInOut ))) then begin
            First;
            Insert;
            FieldByName('SerialNum').AsInteger := _DevEnum^.SerialNum;
            if ( (( _tKnd <> __kndNullCheck ) and
               ( _tKnd <> __kndInOut ) and 
               (Trunc( (_Sum - _TotalSum)*10000+0.5 )/100 >= 0 )) or 
               (( _tKnd = __kndNullCheck ) or
               ( _tKnd = __kndInOut )) ) then _tPayment := __opPayment
            else _tPayment := __opPartPayment;
            FieldByName('Operation').AsInteger := _tPayment;
            FieldByName('ChkNum').AsInteger := _ChkNum;
            FieldByName('Sum').AsCurrency := _Sum;
            FieldByName('Knd').AsString := _tKnd;
            FieldByName('DT').AsString := DateTimeToStr(Now);
            Post;
            try
              __CheckData.SaveToFile(__FileName);
            finally end;
          end;
          if ( (( _tKnd <> __kndNullCheck ) and
               ( _tKnd <> __kndInOut ) and 
               (Trunc( (_Sum - _TotalSum)*10000+0.5 )/100 >= 0 )) or 
               (BOOL(__SaveServiceCheck) and (( _tKnd = __kndNullCheck ) or
               ( _tKnd = __kndInOut ))) and (_tPayment = __opPayment)) then begin
            GetMem(_tmp, SizeOf(TSaveDataRec));
            FillChar(_tmp^,SizeOf(TSaveDataRec),$00);
            _tmp^.__CheckData := Pointer(__CheckData);
            SetString(_tmp^.__FileName,PChar(__FileName),Length(__FileName));
            SetString(_tmp^.__TmpDir,PChar(__TmpDir),Length(__TmpDir));
            __CheckData := nil;
            if assigned(_tmp) then
              PostThreadMessage(_MainTHId,THREAD_PROCESS_DATA,0,Cardinal(_tmp));
          end;
        except
          on E:Exception do begin
            __CheckData.Cancel;
            _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
          end;
        end;
      end;
    end;
  except
    on E:Exception do begin
      _DevEnum^.Log.WriteToLog(PChar(E.Message), Length(E.Message));
    end;
  end;
end;

end.
 