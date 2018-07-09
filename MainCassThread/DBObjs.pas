unit DBObjs;

interface
  uses  Windows, Messages,
  Const_Type, SysUtils,
  IBSQL, IBDatabase, vIBDB, myIBEvents,
  db, dbclient, DBObj, LogFunc,
{$ifdef debug}  
  fDbGrid, 
{$endif}   
  vIBProvide, IBQuery;  

type  

  TOnChange = procedure() of object;
  
  PMainDBObj = ^TMainDBObj;
  TMainDBObj = class(TDBObj)
    protected
      procedure __InitDB; override;
    private
		  __EventLogger: TEventLogger;
      __Ev: TIBEvents;
      __OnGoodsChange: TOnChange;
      __OnBarCodesChange: TOnChange;
      __OnDepPriceChange: TOnChange;
      procedure __ProcEventsAlert(_Sender: TObject; _EventName: string;
                                _EventCount: Integer; var _CancelAlerts: Boolean); virtual;
    public
      constructor Create;
      destructor Destroy; override;
      procedure SaveData(_cds: TClientDataSet; _TmpDir: String = ''); virtual;
      function GetPorts(_where: String = ''): TClientDataSet;
      property OnGoodsChange: TOnChange read __OnGoodsChange write __OnGoodsChange;
      property OnBarCodesChange: TOnChange read __OnBarCodesChange write __OnBarCodesChange;
      property OnDepPriceChange: TOnChange read __OnDepPriceChange write __OnDepPriceChange;
  end;

  
implementation

procedure TMainDBObj.__InitDB;
var
  _HighBound,
  _i: Integer;
begin
  inherited __InitDB;
  if assigned( Self.DB ) then begin
    __Ev := TIBEvents.Create(nil);
    __Ev.Database := Self.DB;
    _HighBound := SizeOf(HandleEvents) div SizeOf(HandleEvents[0]);
    for _i:= 0 to _HighBound - 1 do
      __Ev.Events.Append(HandleEvents[_i]);
    __Ev.OnEventAlert := self.__ProcEventsAlert;
    __Ev.Registered := True;
  end;
end;

procedure TMainDBObj.__ProcEventsAlert(_Sender: TObject; _EventName: string;
  _EventCount: Integer; var _CancelAlerts: Boolean);
begin
  try
    if ( ( _EventName = HandleEvents[0] ) or
      ( _EventName = HandleEvents[1] ) or 
      ( _EventName = HandleEvents[2] ) ) then begin
      if assigned( __OnGoodsChange ) then  __OnGoodsChange();
    end
    else
      if ( ( _EventName = HandleEvents[3] ) or
        ( _EventName = HandleEvents[4] ) or 
        ( _EventName = HandleEvents[5] ) ) then begin
        if assigned( __OnBarCodesChange ) then  __OnBarCodesChange();
      end
      else
        if ( ( _EventName = HandleEvents[6] ) or
          ( _EventName = HandleEvents[7] ) or 
          ( _EventName = HandleEvents[8] ) ) then begin
          if assigned( __OnDepPriceChange ) then  __OnDepPriceChange();
        end;
  except
    on e: Exception do begin
      __EventLogger.LogError('_0 '+e.Message);
    end;
  end;
end;

destructor TMainDBObj.Destroy;
begin
  if assigned(__EventLogger) then __EventLogger.Free;
  if ( assigned( __Ev ) ) then FreeandNil( __Ev );
  inherited;
end;

procedure TMainDBObj.SaveData(_cds: TClientDataSet; _TmpDir: String = '');
var
  _DB: TvIBDataBase;
  _T: TvIBTransaction;
  _Q: TIBQuery;
  _SQL: String;
  _rc, _oper, _knd: Integer;
  idxCheck: Integer;
  __TmpDir,
  __ChkFile: String;
begin
  __ChkFile := '';
  try
    if (assigned(_cds) and _cds.ClassNameIs(TClientDataSet.ClassName))then begin
    {$ifdef debug}
      if _cds.RecordCount > 0 then
        self.ShowDebugGrid(_cds);
    {$endif}  
      IdxCheck := 0; 
      try
        _DB := TvIBDataBase.Create(nil);
        With _DB do begin
          DatabaseName := __DB_FileName;
          Params.Clear;
          Params.Append('user_name=' + __DB_user);
          Params.Append('password=' + __DB_pass);
          Params.Append('lc_ctype=WIN1251');
          LoginPrompt := False;
          SQLDialect := 3;
          TraceFlags := [];
        end;
        if not _DB.Connected then _DB.Open;
        _Q := TIBQuery.Create(nil);
        _T := TvIBTransaction.Create(nil);
        with _T do begin
          Params.Clear;
          Params.Append('read_committed');
          Params.Append('rec_version');
          Params.Append('nowait');
          DefaultDatabase := _DB;
          DefaultAction := taCommit;
        end;
        _Q.Database := _DB;
        _Q.Transaction := _T;
        _T.StartTransaction;
        try
          _rc := _cds.RecordCount;
          _cds.First; idxCheck := 0; 
          while not _cds.Eof do begin
            _oper := _cds.FieldByName('Operation').AsInteger;
            _knd := 0;
            _Q.Close;
            _Q.SQL.Clear;
            case (_oper) of
              __opPayment,
              __opAnnul: begin
                try
                  if ( _cds.FieldByName('Knd').AsString <> __kndNullCheck ) and
                     (_cds.FieldByName('Knd').AsString <> __kndInOut ) then begin
                    __TmpDir := _TmpDir;
                    if ((Length(__TmpDir)>0) and (LastDelimiter(PathDelimiter, __TmpDir) <> Length(__TmpDir))) then
                      __TmpDir := __TmpDir + PathDelimiter;
                    __ChkFile := __TmpDir+_cds.FieldByName('ChkNum').AsString+__tmpand+_cds.FieldByName('SerialNum').AsString+__tmpext;    
                    try
                      _SQL := Format(__InsertCheck__,[_cds.FieldByName('SerialNum').AsString,
                                                      _cds.FieldByName('DT').AsString,
                                                      _cds.FieldByName('ChkNum').AsString,
                                                      CurrToStr(_cds.FieldByName('Sum').AsCurrency),
                                                      _cds.FieldByName('Knd').AsString,
                                                      IntToStr(_oper)]);
                    except
                      on E: Exception do begin
                        __EventLogger.LogError('TMainDBObj.SaveData __opPayment _SQL exception: '+e.Message);
                        _SQL := '';
                      end;
                    end;
                  end
                  else begin
                    if ( _cds.FieldByName('Knd').AsString = __kndNullCheck ) then _oper := __opNullCheck
                    else _oper := __opInOut;
                    try
                      _SQL := Format(__InsertCheck__,[_cds.FieldByName('SerialNum').AsString,
                                                      _cds.FieldByName('DT').AsString,
                                                      _cds.FieldByName('ChkNum').AsString,
                                                      CurrToStr(_cds.FieldByName('Sum').AsCurrency),
                                                      IntToStr(_knd), 
                                                      IntToStr(_oper)]);
                    except
                      on E: Exception do begin
                        __EventLogger.LogError('TMainDBObj.SaveData __opNullCheck _SQL exception: '+e.Message);
                        _SQL := '';
                      end;
                    end;
                  end;
                  if Length(_SQL) >0 then begin
                    try
                      _Q.SQL.Append(_SQL);
                    except
                      on E: Exception do begin
                        __EventLogger.LogError('TMainDBObj.SaveData _Q.SQL.Append(_SQL) exception: '+e.Message);
                      end;
                    end;
                    try
                      _Q.Open;
                      try
                        IdxCheck := _Q.FieldByName('Res').AsInteger;
                      except
                        on E: Exception do begin
                          __EventLogger.LogError('TMainDBObj.SaveData _Q.FieldByName(Res).AsInteger exception: '+e.Message);
                          IdxCheck := 0;
                        end;
                      end;
                      _cds.Next;
                      _Q.Close;
                      if _Q.Prepared then _Q.UnPrepare;
                    except
                      on E: Exception do begin
                        __EventLogger.LogError('TMainDBObj.SaveData _Q.Open exception: '+e.Message+' _Q.SQL: '+_Q.SQL.Text);
                        IdxCheck := 0;
                      end;
                    end;
                  end;
                except
                  on E: Exception do begin
                    __EventLogger.LogError('TMainDBObj.SaveData __opPayment exception: '+e.Message);
                    IdxCheck := 0;
                  end;
                end;
              end;
              __opPartPayment: begin
                try
                  if IdxCheck > 0 then begin
                    _SQL := Format(__UpdateCheck__,[IntToStr(IdxCheck),
                                                    _cds.FieldByName('SerialNum').AsString,
                                                    _cds.FieldByName('DT').AsString,
                                                    _cds.FieldByName('ChkNum').AsString,
                                                    CurrToStr(_cds.FieldByName('Sum').AsCurrency),
                                                    _cds.FieldByName('Knd').AsString,
                                                    IntToStr(_oper)]);
                    _Q.SQL.Append(_SQL);
    //                _Q.Prepare;
                    _Q.Open;
                  end;
                  try
                    IdxCheck := _Q.FieldByName('Res').AsInteger;
                  except
                    on E: Exception do begin
                      __EventLogger.LogError('TMainDBObj.SaveData _Q.FieldByName(Res).AsInteger exception: '+e.Message);
                      IdxCheck := 0;
                    end;
                  end;
                  _cds.Next;
                  _Q.Close;
                  if _Q.Prepared then _Q.UnPrepare;
                except
                  on E: Exception do begin
                    __EventLogger.LogError('TMainDBObj.SaveData __opPartPayment exception: '+e.Message);
                    IdxCheck := 0;
                  end;
                end;
              end;
              __opSale: begin
                try
                  if IdxCheck > 0 then
                    _SQL := Format(__InsertSale__,[_cds.FieldByName('SerialNum').AsString,
                                                   _cds.FieldByName('DT').AsString,
                                                   _cds.FieldByName('Code').AsString,
                                                   _cds.FieldByName('GoodsID').AsString,
                                                   CurrToStr(_cds.FieldByName('Price').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Count').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Sum').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Discount').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Sum').AsCurrency),
                                                   _cds.FieldByName('Tax').AsString,
                                                   IntToStr(IdxCheck),
                                                   _cds.FieldByName('ChkNum').AsString])
                  else
                    _SQL := Format(__InsertSale__,[_cds.FieldByName('SerialNum').AsString,
                                                   _cds.FieldByName('DT').AsString,
                                                   _cds.FieldByName('Code').AsString,
                                                   _cds.FieldByName('GoodsID').AsString,
                                                   CurrToStr(_cds.FieldByName('Price').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Count').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Sum').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Discount').AsCurrency),
                                                   CurrToStr(_cds.FieldByName('Sum').AsCurrency),
                                                   _cds.FieldByName('Tax').AsString,
                                                   'null',
                                                   _cds.FieldByName('ChkNum').AsString]);
                  _Q.SQL.Append(_SQL);
  //                _Q.Prepare;
                  _Q.ExecSQL;
                  _cds.Next;
                except
                  on E: Exception do begin
                    __EventLogger.LogError('TMainDBObj.SaveData __opSale exception: '+e.Message);
                  end;
                end;
              end;
            end;
            _oper := __opNull;
          end;
          if _T.InTransaction then _T.Commit;
          try
            if LogCheck and (Length(__ChkFile)>0) then 
              _cds.SaveToFile(__ChkFile);
          except
            on e: Exception do begin
              __EventLogger.LogError('TMainDBObj.SaveData _cds.SaveToFile exception: '+e.Message);
            end;
          end;
        except
          on e: Exception do begin
            __EventLogger.LogError('TMainDBObj.SaveData exception: '+e.Message);
            if _T.InTransaction then _T.RollBack;
          end;
        end;
        _DB.Close;
      finally
        _Q.Free;
        _T.Free;
        _DB.Free;
      end;
    end
    else
      __EventLogger.LogError('TMainDBObj.SaveData _cds is null');
  except
    __EventLogger.LogError('TMainDBObj.SaveData _cds is not TClientDataSet');
  end;
end;

function TMainDBObj.GetPorts(_where: String = ''): TClientDataSet;
var
  _SQL: String;
begin
  _SQL := __select__+__all__+__from__+'"Ports" p';
  if Length( _where )>0 then
    _SQL := _SQL + __where__ + _where;
  SelectData( Result, _SQL );
end;

constructor TMainDBObj.Create;
begin
  inherited;
  __EventLogger := TEventLogger.Create('CassSrv DBObjs');
end;

initialization

finalization  

end.
