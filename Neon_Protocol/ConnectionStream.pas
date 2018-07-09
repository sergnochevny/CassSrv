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
    __DataStreamEvent: THandle;
    __LastopType: Byte;
    __Port: Integer;
    __BaudNumber: Integer;
{$ifdef CS}    
    __CS: TRTLCriticalSection;
{$else}    
    __Ev: Cardinal;
{$endif}    
    __opType: Byte;
    __CheckAck: Boolean;
{$ifdef Log}    
    __WriteProtocol: Integer;
{$endif}    
    
  private
{$ifdef Log}    
    procedure __WriteToLogCmd(_DevEnum: PDevEnum);
    procedure __WriteToLogDat(_DevEnum: PDevEnum);
{$endif}    
    procedure __CloseStream;
    procedure __WaitDataStreamEvent;
    function __SendData(_opType: Byte; _DevEnum: PDevEnum): boolean;
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
    procedure __RejectSale(_DevEnum: PDevEnum);
    procedure __RejectSaleCode(_DevEnum: PDevEnum);
    procedure __RejectSaleBar(_DevEnum: PDevEnum);
  public
{$ifdef Log}    
    procedure __WriteToLogInDat(_DevEnum: PDevEnum);
    procedure __WriteToLogInCmd(_DevEnum: PDevEnum);
{$endif}    
    procedure CleanPort;
    function ReadStream(var _Res: Integer): Cardinal;
    procedure InitData;
    procedure SendRestore;
    procedure SendNULL;
    procedure SendTAKE(_DevN: ShortInt);
    procedure SendOk;
    procedure SendNAK;
    function SendLastData(_DevEnum: PDevEnum): boolean;
    function CheckData: boolean;
    function CheckDataLen: boolean;
    procedure RejectLastData(_DevEnum: PDevEnum);
    function ProcessData(_DevEnum: PDevEnum): boolean;
    constructor Create;
    function InitializeStream( _P: Pointer; _THId: Cardinal; _Proc: FarProc ): BOOL;
    destructor Destroy; override;
    procedure Terminate;
    procedure Resume;
    procedure WaitForExit;
    function WaitFor: Boolean;
    property Terminated: Boolean read __Terminated write __Terminated;
    property DataStreamEvent: THandle write __DataStreamEvent;
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
    
  end;

implementation

uses  
  Protocols, Comm_Procedures, SysUtils, 
  StrUtils, StrFunc;

var
  CommWatchProc: TWathProc;
    
{ TConnectionStream }

constructor TConnectionStream.Create;
begin
  inherited;
  __WriteProtocol := __DefWriteProtocol;
  __Terminated := False;
end;

destructor TConnectionStream.Destroy;
begin
  __CloseStream;
  inherited Destroy;
end;

function TConnectionStream.__SendData(_opType: Byte; _DevEnum: PDevEnum): boolean;
begin
  if ( __S_Info.BigWriteCount > 0 ) then begin
    __LastopType := _opType;
    MakeData(__S_Info.BigWriteBuffer, __S_Info.BigWriteCount);
    WriteCommBuff( @__S_Info );
    SendNull;
  {$ifdef Log}
    __WriteToLogDat(_DevEnum);      
  {$endif}
    Result := False;
  end
  else Result := True;
end;

function TConnectionStream.__ProcessDataWSend(_P: Pointer; _opType: Byte; _DevEnum: PDevEnum): boolean;
var
  _tmp: POpData;
begin
  SendNull;
  GetMem(_tmp, SizeOf(POpData));
  _tmp^.__opType := _opType;
  _tmp^.__DevEnum := _DevEnum;
  PostThreadMessage(__DataStreamTHId, THREAD_PROCESS_PACKET,Cardinal(_P),Cardinal(_tmp));
  Sleep(0);
  __WaitDataStreamEvent;
  Result := __SendData( _opType, _DevEnum );
end;

procedure TConnectionStream.__ProcessDataWOSend(_P: Pointer; _opType: Byte; _DevEnum: PDevEnum);
var
  _tmp: POpData;
begin
  GetMem(_tmp, SizeOf(POpData));
  _tmp^.__opType := _opType;
  _tmp^.__DevEnum := _DevEnum;
  PostThreadMessage(__DataStreamTHId, THREAD_PROCESS_PACKET,Cardinal(_P),Cardinal(_tmp));
  Sleep(0);
  __WaitDataStreamEvent;
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
  __CheckAck := True;
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
  __CheckAck := True;
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
  if __CheckAck then __RejectSale(_DevEnum);
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
      FF: ;
      opAnnul: begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        Result := __Annul(_DevEnum);
      end;
      opQeryDisc:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        Result := __QeryDisc(_DevEnum);
      end;        
      opSaleCode:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        Result := __SaleCode(_DevEnum);
      end;        
      opSaleBar:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        Result := __SaleBar(_DevEnum);
      end;        
      opQueryKey:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        Result := __QueryKey(_DevEnum);
      end;
      opDiscount:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        __Discount(_DevEnum);
      end;        
      opSaleArt:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        __SaleArt(_DevEnum);
      end;        
      opPayment:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        __Payment(_DevEnum);
      end;
      opRejectSaleCode:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        __RejectSaleCode(_DevEnum); 
      end;
      opRejectSaleBar:  begin
{$ifdef Log}              
        __WriteToLogInDat(_DevEnum);
{$endif}       
        __RejectSaleBar(_DevEnum);
      end;
    end;
  end;
end;

procedure TConnectionStream.CleanPort;
begin
  CleanCommPort( __S_Info );
end;

procedure TConnectionStream.__CloseStream;
begin
  if not __Terminated then Terminate;
  CloseConnection(__S_Info);
  if BOOL(__StreamHandle) then begin
    WaitForSingleObject(__StreamHandle, INFINITE);    
    CloseHandle(__StreamHandle);
    __StreamHandle := 0;
    CloseHandle(__DataStreamEvent);
    __DataStreamEvent := 0;
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
    __CheckAck := False;
    Result := BOOL(__StreamHandle);
    if not Result then
		  CloseConnection(__S_Info);
	end;
end;

function TConnectionStream.ReadStream(var _Res: Integer): Cardinal;
var 
  _dwLength: Cardinal;
  _tBeg, _tEnd: Boolean; 
  _lpszPoint: Cardinal;
  _cEnd: Integer;
  _TroubleRepCount: Integer;
begin
  _Res := 0; _TroubleRepCount := DefTroubleRepCount;
  _cEnd := 2; _lpszPoint := __S_Info.H_BigReadBuffer;
  FillChar(__S_Info.BigReadBuffer^, Size_BigBuffer, $00);
  Result := 0; _tBeg := False; _tEnd:= False;
  __S_Info.BigReadCount := 0;
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
  until ( ( _dwLength < 1 ) and ( ( ( _tBeg = False ) and ( _tEnd = False ) ) 
         or ( ( _tBeg = True ) and ( _tEnd = True ) ) or ( _TroubleRepCount < 1 ) ) );
end;

procedure TConnectionStream.SendOk;
var
  _Buff: Pointer;
  _HBuff: Cardinal;
  _V: Cardinal;
begin
  _Buff := __S_Info.CommandWriteBuffer;
  _HBuff := __S_Info.H_CommandWriteBuffer;
  _V := ACK;
	FillChar(_Buff^, Size_Buffer, FF);
  move(_V, Pointer(_HBuff)^, 1);
  __S_Info.CommandWriteCount := SizeACKBuff;
  CommandWriteCommBuff(@__S_Info);
{$ifdef LogAll and Log}
//  __WriteToLogCmd;
{$endif}  
end;

procedure TConnectionStream.SendRestore;
var
  _Buff: Pointer;
  _HBuff: Cardinal;
begin
  _Buff := __S_Info.CommandWriteBuffer;
  _HBuff := __S_Info.H_CommandWriteBuffer;
  __CheckAck := False;
	FillChar(_Buff^, Size_Buffer, FF);
	FillChar(Pointer(_HBuff + ( SizeRESTOREBuff div 2 ) - 2 )^, 2, RESTORE);
	FillChar(Pointer(_HBuff +  SizeRESTOREBuff - 2 )^, 2, RESTORE);
  __S_Info.CommandWriteCount := SizeRESTOREBuff;
  CommandWriteCommBuff(@__S_Info);
{$ifdef LogAll and Log}
//  __WriteToLogCmd;
{$endif}  
end;

procedure TConnectionStream.SendNULL;
var
  _Buff: Pointer;
begin
  _Buff := S_Info.CommandWriteBuffer;
	FillChar(_Buff^, Size_Buffer, FF);
  __S_Info.CommandWriteCount := SizeNullBuff;
  CommandWriteCommBuff(@__S_Info);
{$ifdef LogAll and Log}
//  __WriteToLogCmd;
{$endif}  
end;

procedure TConnectionStream.SendTake(_DevN: ShortInt);
var
  _Buff: Pointer;
  _HBuff: Cardinal;
  _S: String;
  _V: Byte;
begin
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
{$ifdef LogAll and Log}
//  __WriteToLogCmd;
{$endif}  
end;

procedure TConnectionStream.SendNAK;
var
  _Buff: Pointer;
  _HBuff: Cardinal;
  _V: Cardinal;
begin
  _Buff := __S_Info.CommandWriteBuffer;
  _HBuff := __S_Info.H_CommandWriteBuffer;
  _V := NAK;
	FillChar(_Buff^, Size_Buffer, FF);
  move(_V, Pointer(_HBuff)^, 1);
  __S_Info.CommandWriteCount := SizeNakBuff;
  CommandWriteCommBuff(@__S_Info);
{$ifdef LogAll and Log}
//  __WriteToLogCmd;
{$endif}  
end;

procedure TConnectionStream.Terminate;
begin
  __Terminated := True;
end;

{$ifdef Log}    
procedure TConnectionStream.__WriteToLogCmd(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum.Log.WriteToLog(__S_Info.CommandWriteBuffer, __S_Info.CommandWriteCount);
end;

procedure TConnectionStream.__WriteToLogDat(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum.Log.WriteToLog(__S_Info.BigWriteBuffer, __S_Info.BigWriteCount);
end;

procedure TConnectionStream.__WriteToLogInDat(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum.Log.WriteToLog(__S_Info.BigReadBuffer, __S_Info.BigReadCount);
end;

procedure TConnectionStream.__WriteToLogInCmd(_DevEnum: PDevEnum);
begin
  if BOOL(__WriteProtocol) then
    _DevEnum.Log.WriteToLog(__S_Info.CommandReadBuffer, __S_Info.CommandReadCount);
end;
{$endif}

procedure TConnectionStream.Resume;
begin
  ResumeThread(__StreamHandle);
end;

procedure TConnectionStream.__WaitDataStreamEvent;
begin
  WaitForSIngleObject(__DataStreamEvent, INFINITE);
  ResetEvent(__DataStreamEvent);
end;

function TConnectionStream.SendLastData(_DevEnum: PDevEnum): boolean;
begin
  Result := False;
  if (__S_Info.BigWriteCount > 0) then begin
    WriteCommBuff( @__S_Info );
  end 
  else Result := True;
{$ifdef Log}
  __WriteToLogDat(_DevEnum);      
{$endif}
  SendNull;
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

procedure TConnectionStream.WaitForExit;
begin
  WaitForSingleObject(__StreamHandle, INFINITE);
end;

function TConnectionStream.WaitFor: Boolean;
begin
  Result := WaitForSingleObject(__StreamHandle, 0) = WAIT_OBJECT_0;
end;

end.
