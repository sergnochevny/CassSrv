unit ConnectionStream;

interface
  uses Windows, Const_Type, LogFunc;

type

  PConnectionStream = ^TConnectionStream;
  TConnectionStream = class
    __DevEnum: PDevEnum;
    __S_Info: TInfo;
    __Terminated: Boolean;
    __DevArr: array of Integer;
    __DataStreamTHId: Cardinal;
    __StreamHandle: THandle;
    __StreamThID: Cardinal;
    __LastopType: Byte;
    __Port: Integer;
    __BaudNumber: Integer;
    __DataStream: Pointer;
{$ifdef CS}    
    __CS: TRTLCriticalSection;
{$else}    
    __Ev: Cardinal;
{$endif}    
    __opType: Byte;
    
    __WriteProtocol: Integer;
    __WriteFullProtocol: Integer;
    __RejectNoAnswer: Integer;
    __NoRejectIfNull: Integer;
    __SendNullIfReadError: Integer;
  private
    procedure __WriteToLogCmd(_DevEnum: PDevEnum);
    procedure __WriteToLogDat(_DevEnum: PDevEnum);
    procedure __CloseStream;
    function __SendData(_DevEnum: PDevEnum; _opType: Byte): boolean;
    function __ProcessDataWSend(_P: Pointer; _opType: Byte; _DevEnum: PDevEnum): boolean;
    procedure __ProcessDataWOSend(_P: Pointer; _opType: Byte; _DevEnum: PDevEnum);
    function __Annul(_DevEnum: PDevEnum): boolean;
    function __QeryDisc(_DevEnum: PDevEnum): boolean;
    function __SaleCode(_DevEnum: PDevEnum): boolean;
    function __SaleBar(_DevEnum: PDevEnum): boolean;
    function __QueryKey(_DevEnum: PDevEnum): boolean;
    procedure __Discount(_DevEnum: PDevEnum);
    procedure __SaleArt(_DevEnum: PDevEnum);
    procedure __Payment(_DevEnum: PDevEnum);
    procedure __RejectAnnul(_DevEnum: PDevEnum);
    procedure __RejectSale(_DevEnum: PDevEnum);
    procedure __RejectSaleCode(_DevEnum: PDevEnum);
    procedure __RejectSaleBar(_DevEnum: PDevEnum);
  public
    procedure __WriteToLogInDat(_DevEnum: PDevEnum);
    procedure __WriteToLogInCmd(_DevEnum: PDevEnum);
    procedure CleanPort;
    procedure ClearBreakPort;
    function ReadStream(_tErrorDataLen: Boolean; var _Res, _Read: Integer): Cardinal;
    procedure InitData;
    procedure CleanDataBuff;
    function CheckDataBuff: boolean;
    procedure SendRestore(_DevEnum: PDevEnum);
    procedure SendNULL(_DevEnum: PDevEnum);
    procedure SendTAKE(_DevEnum: PDevEnum);
    procedure SendOk(_DevEnum: PDevEnum; log: boolean = false);
    procedure SendNAK(_DevEnum: PDevEnum; log: boolean = false);
    function SendLastData(_DevEnum: PDevEnum): boolean;
    function CheckData: boolean;
    function CheckDataLen: boolean;
    function CheckDataNull: boolean;
    procedure RejectLastData(_DevEnum: PDevEnum);
    function ProcessData(_DevEnum: PDevEnum): boolean;
    procedure ConfirmLastData(_DevEnum: PDevEnum);
    constructor Create;
    function InitializeStream( _P: Pointer; _THId: Cardinal; _Proc: FarProc ): BOOL;
    destructor Destroy; override;
    procedure Terminate;
    procedure Resume;
    procedure WaitForExit;
    property Terminated: Boolean read __Terminated write __Terminated;
    property DevEnum: PDevEnum read __DevEnum write __DevEnum;
    property StreamHandle: THandle read __StreamHandle;
{$ifdef CS}    
    property CS: TRTLCriticalSection read __CS write __CS;
{$else}    
    property Ev: Cardinal read __Ev write __Ev;
{$endif}    
    property Port: Integer read __Port write __Port;
    property BaudNumber: Integer read __BaudNumber write __BaudNumber;
    property S_Info: TInfo read __S_Info;
    property DataStream: Pointer read __DataStream write __DataStream;
  end;

implementation

uses  
  Protocols, Comm_Procedures, SysUtils, 
  StrUtils, StrFunc, DataStream;

var
  CommWatchProc: TWathProc;
    
{ TConnectionStream }

constructor TConnectionStream.Create;
begin
  inherited;
  __WriteProtocol := __DefWriteProtocol;
  __WriteFullProtocol := __DefWriteFullProtocol;
  __RejectNoAnswer := __DefRejectNoAnswer;
  __NoRejectIfNull := __DefNoRejectIfNull;
  __SendNullIfReadError := __DefSendNullIfReadError;
  __Terminated := False;
  __DataStream := nil;
end;

destructor TConnectionStream.Destroy;
begin
  __CloseStream;
  inherited Destroy;
end;

function TConnectionStream.__SendData(_DevEnum: PDevEnum; _opType: Byte): boolean;
begin
  if ( __S_Info.BigWriteCount > 0 ) then begin
    __LastopType := _opType;
    MakeData(__S_Info.BigWriteBuffer, __S_Info.BigWriteCount);
    WriteCommBuff( @__S_Info );
    SendNull(_DevEnum);
    __WriteToLogDat(_DevEnum);      
    Result := False;
  end
  else Result := True;
end;

function TConnectionStream.__ProcessDataWSend(_P: Pointer; _opType: Byte; _DevEnum: PDevEnum): boolean;
var
  _tmp: POpData;
begin
  SendNull(_DevEnum);
  GetMem(_tmp, SizeOf(TOpData));
  FillChar(_tmp^,SizeOf(TOpData),$00);
  _tmp^.__opType := _opType;
  _tmp^.__DevEnum := _DevEnum;
  TDataStream(__DataStream).ProcessPacket(_P, _tmp);
  Result := __SendData( _DevEnum, _opType );
end;

procedure TConnectionStream.__ProcessDataWOSend(_P: Pointer; _opType: Byte; _DevEnum: PDevEnum);
var
  _tmp: POpData;
begin
  GetMem(_tmp, SizeOf(TOpData));
  FillChar(_tmp^,SizeOf(TOpData),$00);
  _tmp^.__opType := _opType;
  _tmp^.__DevEnum := _DevEnum;
  TDataStream(__DataStream).ProcessPacket(_P, _tmp);
end;

procedure TConnectionStream.__SaleArt(_DevEnum: PDevEnum);
var
  _opType: Byte;
begin
  _opType := opSaleArt;
  __ProcessDataWOSend( @__S_Info, _opType, _DevEnum );
end;

procedure TConnectionStream.__Payment(_DevEnum: PDevEnum);
var
  _opType: Byte;
begin
  _opType := opPayment;
  __ProcessDataWOSend( @__S_Info, _opType, _DevEnum );
end;

procedure TConnectionStream.__RejectAnnul(_DevEnum: PDevEnum);
var
  _opType: Byte;
begin
  _opType := opRejectAnnul;
  __ProcessDataWOSend( @__S_Info, _opType, _DevEnum );
end;

procedure TConnectionStream.__RejectSale(_DevEnum: PDevEnum);
var
  _opType: Byte;
begin
  _opType := opRejectSale;
  __ProcessDataWOSend( @__S_Info, _opType, _DevEnum );
end;

procedure TConnectionStream.__RejectSaleCode(_DevEnum: PDevEnum);
var
  _opType: Byte;
begin
  _opType := opRejectSaleCode;
  __ProcessDataWOSend( @__S_Info, _opType, _DevEnum );
end;

procedure TConnectionStream.__RejectSaleBar(_DevEnum: PDevEnum);
var
  _opType: Byte;
begin
  _opType := opRejectSaleBar;
  __ProcessDataWOSend( @__S_Info, _opType, _DevEnum );
end;

function TConnectionStream.__Annul(_DevEnum: PDevEnum): boolean;
var
  _opType: Byte;
begin
  _opType := opAnnul;
  Result := __ProcessDataWSend( @__S_Info, _opType, _DevEnum );
end;

function TConnectionStream.__QeryDisc(_DevEnum: PDevEnum): boolean;
var
  _opType: Byte;
begin
  _opType := opQeryDisc;
  Result := __ProcessDataWSend( @__S_Info, _opType, _DevEnum );
end;

function TConnectionStream.__SaleCode(_DevEnum: PDevEnum): boolean;
var
  _opType: Byte;
begin
  _opType := opSaleCode;
  Result := __ProcessDataWSend( @__S_Info, _opType, _DevEnum );
end;

procedure TConnectionStream.__Discount(_DevEnum: PDevEnum);
var
  _opType: Byte;
begin
  _opType := opDiscount;
  __ProcessDataWOSend( @__S_Info, _opType, _DevEnum );
end;

function TConnectionStream.__SaleBar(_DevEnum: PDevEnum): boolean;
var
  _opType: Byte;
begin
  _opType := opSaleBar;
  Result := __ProcessDataWSend( @__S_Info, _opType, _DevEnum );
end;

function TConnectionStream.__QueryKey(_DevEnum: PDevEnum): boolean;
var
  _opType: Byte;
begin
  _opType := opQueryKey;
  Result := __ProcessDataWSend( @__S_Info, _opType, _DevEnum );
end;

procedure TConnectionStream.RejectLastData(_DevEnum: PDevEnum);
begin
  case __opType of
    opAnnul: __RejectAnnul(_DevEnum);
    opSaleCode,
    opSaleBar: begin
      __RejectSale(_DevEnum);
    end;        
  end;
end;

procedure TConnectionStream.ConfirmLastData(_DevEnum: PDevEnum);
begin
  case __opType of
    opAnnul: TDataStream(__DataStream).ConfirmAnnul(_DevEnum);
  end;
end;

function TConnectionStream.ProcessData(_DevEnum: PDevEnum): boolean;
var
  _ProcStr: String;
begin
  Result := True;
  _ProcStr := PChar(TBuffer(__S_Info.BigReadBuffer));
  if ( Length(_ProcStr)>0 ) then begin
    try
      if (Length(Trim(StrFunc.ExtractWord(_ProcStr, DlmField,3)))>0) then
        __opType := Ord(StrFunc.ExtractWord(_ProcStr, DlmField,3)[1])
      else
        __opType := FF;
    except
      __opType := FF;
    end;
    case __opType of
      FF: if BOOL(__WriteFullProtocol) then __WriteToLogInDat(_DevEnum);
      else begin
        __WriteToLogInDat(_DevEnum);
        case __opType of
          opAnnul: Result := __Annul(_DevEnum);
          opQeryDisc: Result := __QeryDisc(_DevEnum);
          opSaleCode: Result := __SaleCode(_DevEnum);
          opSaleBar: Result := __SaleBar(_DevEnum);
          opQueryKey: Result := __QueryKey(_DevEnum);
          opDiscount: __Discount(_DevEnum);
          opSaleArt: __SaleArt(_DevEnum);
          opPayment: __Payment(_DevEnum);
          opRejectSaleCode: __RejectSaleCode(_DevEnum); 
          opRejectSaleBar: __RejectSaleBar(_DevEnum);
        end;
      end;
    end;
  end;
end;

procedure TConnectionStream.CleanPort;
begin
  CleanCommPort( __S_Info );
end;

procedure TConnectionStream.ClearBreakPort;
begin
  ClearBreakCommPort( __S_Info );
end;

procedure TConnectionStream.__CloseStream;
begin
  if not __Terminated then Terminate;
  CloseConnection(__S_Info);
  if BOOL(__StreamHandle) then begin
    WaitForSingleObject(__StreamHandle, INFINITE);    
    CloseHandle(__StreamHandle);
    __StreamHandle := 0;
  end;
end;

procedure TConnectionStream.InitData;
begin
  InitPacket(@__S_Info);
end;

function TConnectionStream.InitializeStream( _P: Pointer; _THId: Cardinal; _Proc: FarProc ): BOOL;
begin
  Result := False;
  @CommWatchProc := _Proc;
  if OpenConnection(TConnectionStream(_P^).Port, TConnectionStream(_P^).BaudNumber, 8, NOPARITY, ONESTOPBIT, __S_Info) then begin
    __StreamHandle := CreateThread( nil, 0, @CommWatchProc, _P, CREATE_SUSPENDED, __StreamThID );
    __DataStreamTHId := _THId;
    Result := BOOL(__StreamHandle);
    if not Result then
		  CloseConnection(__S_Info);
	end;
end;

function TConnectionStream.ReadStream(_tErrorDataLen: Boolean; var _Res, _Read: Integer): Cardinal;
var 
  _dwLength: Cardinal;
  _tBeg, _tEnd: Boolean; 
  _lpszPoint: Cardinal;
  _cEnd: Integer;
  _TroubleRepCount: Integer;
begin
  _Res := 0; _Read:= 0; _TroubleRepCount := DefTroubleRepCount;
  _cEnd := 2; _lpszPoint := __S_Info.H_BigReadBuffer;
  if not _tErrorDataLen then begin
    FillChar(__S_Info.BigReadBuffer^, Size_BigBuffer, $00);
    Result := 0; _tBeg := False; _tEnd:= False;
    __S_Info.BigReadCount := 0;
  end
  else begin
    _tBeg := TBuffer(__S_Info.BigReadBuffer)[0] = pBEG;
    if (_tBeg) then begin
      Result := __S_Info.BigReadCount; 
      _lpszPoint := _lpszPoint + Result;
      _tEnd:= False;
    end
    else begin
      FillChar(__S_Info.BigReadBuffer^, Size_BigBuffer, $00);
      Result := 0; _tBeg := False; _tEnd:= False;
      __S_Info.BigReadCount := 0;
    end;
  end;
  repeat
    _dwLength := CommandReadCommBuff(@__S_Info, 1);
		if ( _dwLength > 0 ) then
    begin
      case ( TBuffer(__S_Info.CommandReadBuffer)[0] ) of
        pBEG: _tBeg := True;
        ACK: begin
          if (( _tBeg = False ) and ( _tEnd = False )) then begin
            Result := 1; _dwLength := 0;
            _Res := resAck;
          end;
        end; 
        NAK: begin
          if (( _tBeg = False ) and ( _tEnd = False )) then begin
            Result := 1; _dwLength := 0;
            _Res := resNak;
          end;
        end;
        pEnd: if (_tBeg) then _tEnd := True;
      end;
      if ( TBuffer(__S_Info.CommandReadBuffer)[0] <> FF ) or (_tBeg) then begin
        move( __S_Info.CommandReadBuffer^, Pointer(_lpszPoint)^, _dwLength );
        _lpszPoint := _lpszPoint + _dwLength ;
        __S_Info.BigReadCount := __S_Info.BigReadCount + _dwLength;
        if ( not BOOL(_cEnd) ) then begin
          Result := Result + _dwLength;
          _Read := _Read + _dwLength;
          _dwLength := 0;
        end;
        if ( _tEnd ) then Dec(_cEnd);
      end;
    end
    else begin
      _dwLength := 0;
      if ( ( _tBeg = True ) and ( _tEnd = False ) ) then Dec(_TroubleRepCount);
    end;
    Result := Result + _dwLength;
    _Read := _Read + _dwLength;
  until ( ( _dwLength < 1 ) and ( ( ( _tBeg = False ) and ( _tEnd = False ) ) 
         or ( ( _tBeg = True ) and ( _tEnd = True ) ) or ( _TroubleRepCount < 1 ) ) );
end;

procedure TConnectionStream.SendOk(_DevEnum: PDevEnum; log: boolean);
var
  _Buff: Pointer;
  _HBuff: Cardinal;
  _V: Cardinal;
  _ProcStr: String;
  _opType: Byte;
begin
  _Buff := __S_Info.CommandWriteBuffer;
  _HBuff := __S_Info.H_CommandWriteBuffer;
  _V := ACK;
	FillChar(_Buff^, Size_Buffer, FF);
  move(_V, Pointer(_HBuff)^, 1);
  __S_Info.CommandWriteCount := SizeACKBuff;
  CommandWriteCommBuff(@__S_Info);
  if BOOL(__WriteFullProtocol) then
    __WriteToLogCmd(_DevEnum)
  else begin
    if ( log and BOOL(__WriteProtocol) ) then begin
      _ProcStr := PChar(TBuffer(__S_Info.BigReadBuffer));
      if ( Length(_ProcStr)>0 ) then begin
        try
          if (Length(Trim(StrFunc.ExtractWord(_ProcStr, DlmField,3)))>0) then
            _opType := Ord(StrFunc.ExtractWord(_ProcStr, DlmField,3)[1])
          else
            _opType := FF;
        except
          _opType := FF;
        end;
        if _opType <> FF then  
          __WriteToLogCmd(_DevEnum);
      end;
    end;
  end;
end;

procedure TConnectionStream.SendRestore(_DevEnum: PDevEnum);
var
  _Buff: Pointer;
  _HBuff: Cardinal;
begin
  _Buff := __S_Info.CommandWriteBuffer;
  _HBuff := __S_Info.H_CommandWriteBuffer;
	FillChar(_Buff^, Size_Buffer, FF);
	FillChar(Pointer(_HBuff + ( SizeRESTOREBuff div 2 ) - 2 )^, 2, RESTORE);
	FillChar(Pointer(_HBuff +  SizeRESTOREBuff - 2 )^, 2, RESTORE);
  __S_Info.CommandWriteCount := SizeRESTOREBuff;
  CommandWriteCommBuff(@__S_Info);
  if BOOL(__WriteFullProtocol) then __WriteToLogCmd(_DevEnum);
end;

procedure TConnectionStream.SendNULL(_DevEnum: PDevEnum);
var
  _Buff: Pointer;
begin
  _Buff := S_Info.CommandWriteBuffer;
	FillChar(_Buff^, Size_Buffer, FF);
  __S_Info.CommandWriteCount := SizeNullBuff;
  CommandWriteCommBuff(@__S_Info);
  if BOOL(__WriteFullProtocol) then __WriteToLogCmd(_DevEnum);
end;

procedure TConnectionStream.SendTake(_DevEnum: PDevEnum);
var
  _Buff: Pointer;
  _HBuff: Cardinal;
  _S: String;
  _V: Byte;
  _DevN: ShortInt;
begin
  __opType := FF;
  _DevN := _DevEnum^.DevNum;
  _Buff := __S_Info.CommandWriteBuffer;
  _HBuff := __S_Info.H_CommandWriteBuffer;
  _V := $30;
	FillChar(_Buff^, Size_Buffer, FF);
	FillChar(Pointer(_HBuff + ( SizeTAKEBuff div 2 ) - 4)^, 2, TAKE);
  _S := IntToStr(_DevN);
  if (Length(_S) > 0) then begin
    if (Length(_S) > 1) then
      move(Char(_S[Length(_S)-1]) ,Pointer(_HBuff + ( SizeTAKEBuff div 2 ) - 2)^, 1)
    else
      move(_V, Pointer(_HBuff + ( SizeTAKEBuff div 2 ) - 2)^, 1);
      move(Char(_S[Length(_S)]) ,Pointer(_HBuff + ( SizeTAKEBuff div 2 ) - 1)^, 1);
  end;
  __S_Info.CommandWriteCount := SizeTAKEBuff;
  CommandWriteCommBuff(@__S_Info);
  if BOOL(__WriteFullProtocol) then __WriteToLogCmd(_DevEnum);
end;

procedure TConnectionStream.SendNAK(_DevEnum: PDevEnum; log: boolean = false);
var
  _Buff: Pointer;
  _HBuff: Cardinal;
  _V: Cardinal;
  _ProcStr: String;
  _opType: Byte;
begin
  _Buff := __S_Info.CommandWriteBuffer;
  _HBuff := __S_Info.H_CommandWriteBuffer;
  _V := NAK;
	FillChar(_Buff^, Size_Buffer, FF);
  move(_V, Pointer(_HBuff)^, 1);
  __S_Info.CommandWriteCount := SizeNakBuff;
  CommandWriteCommBuff(@__S_Info);
  if BOOL(__WriteFullProtocol) then
    __WriteToLogCmd(_DevEnum)
  else begin
    if ( log and BOOL(__WriteProtocol) ) then begin
      _ProcStr := PChar(TBuffer(__S_Info.BigReadBuffer));
      if ( Length(_ProcStr)>0 ) then begin
        try
          if (Length(Trim(StrFunc.ExtractWord(_ProcStr, DlmField,3)))>0) then
            _opType := Ord(StrFunc.ExtractWord(_ProcStr, DlmField,3)[1])
          else
            _opType := FF;
        except
          _opType := FF;
        end;
        if _opType <> FF then  
          __WriteToLogCmd(_DevEnum);
      end;
    end;
  end;
end;

procedure TConnectionStream.Terminate;
begin
  __Terminated := True;
end;

procedure TConnectionStream.__WriteToLogCmd(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum^.Log.WriteToLog(__S_Info.CommandWriteBuffer, __S_Info.CommandWriteCount);
end;

procedure TConnectionStream.__WriteToLogDat(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum^.Log.WriteToLog(__S_Info.BigWriteBuffer, __S_Info.BigWriteCount);
end;

procedure TConnectionStream.__WriteToLogInDat(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum^.Log.WriteToLog(__S_Info.BigReadBuffer, __S_Info.BigReadCount);
end;

procedure TConnectionStream.__WriteToLogInCmd(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum^.Log.WriteToLog(__S_Info.CommandReadBuffer, __S_Info.CommandReadCount);
end;

procedure TConnectionStream.Resume;
begin
  ResumeThread(__StreamHandle);
end;

procedure TConnectionStream.CleanDataBuff;
begin
  if (__S_Info.BigWriteCount > 0) then begin
    FillChar(__S_Info.BigReadBuffer^, Size_BigBuffer, $00);
    __S_Info.BigWriteCount := 0;
  end;
end;

function TConnectionStream.CheckDataBuff: boolean;
begin
  Result := (__S_Info.BigWriteCount > 0);
end;

function TConnectionStream.SendLastData(_DevEnum: PDevEnum): boolean;
begin
  Result := False;
  if (__S_Info.BigWriteCount > 0) then begin
    WriteCommBuff( @__S_Info );
  end 
  else Result := True;
  __WriteToLogDat(_DevEnum);      
  SendNull(_DevEnum);
end;

function TConnectionStream.CheckData: boolean;
begin
  Result := True;
  if __S_Info.BigReadCount > MinDataSize then
    Result := CheckCRC(TBuffer(__S_Info.BigReadBuffer), __S_Info.BigReadCount);
end;

function TConnectionStream.CheckDataLen: boolean;
begin
  Result := __S_Info.BigReadCount > MinDataSize;
end;

function TConnectionStream.CheckDataNull: boolean;
begin
  Result := __S_Info.BigReadCount > 0;
end;

procedure TConnectionStream.WaitForExit;
begin
  WaitForSingleObject(__StreamHandle, INFINITE);
end;

end.
