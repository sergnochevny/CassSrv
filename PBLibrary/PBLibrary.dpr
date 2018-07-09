library PBLibrary;

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\FastMM\FastMM4Messages.pas',
  LogFunc in '..\MainCassThread\LogFunc.pas',
  SysUtils,
  Classes, Windows,
  inifiles, StrUtils,
  Const_Type in '..\MainCassThread\Const_Type.pas';

{$R *.RES}

const  
	csSettings  ='Settings';
  
var
	__Prefixes:String    ='';

procedure InitParseBar(_HLibrary: THandle); stdcall;
var
	_CfgFile: TINIFile;
  _SPref: TStringList;
  _FailNameLen, _i: Integer;
  _RegIniFileName,
  _TempStr: String;
begin
  __Prefixes := '';
  _CfgFile:=nil;
  if (_HLibrary <> INVALID_HANDLE_VALUE) and (_HLibrary <> 0) then begin
    SetLength(_TempStr, LenFileName);
    _FailNameLen := Integer(GetModuleFileName(_HLibrary, PChar(_TempStr), DWORD(LenFileName)));
    if BOOL(_FailNameLen) then begin
      SetLength(_TempStr, LenFileName);
      _RegIniFileName := Copy(Trim(_TempStr), 1, LastDelimiter('.', Trim(_TempStr))-1)+__iniext;
  
      if FileExists(_RegIniFileName) then
        try
          _CfgFile:=TIniFile.Create(_RegIniFileName);
          try
            _SPref:= TStringList.Create;
            _CfgFile.ReadSectionValues(csSettings, _SPref);
            if _SPref.Count > 0 then
              for _i:= 0 to _SPref.Count - 1 do 
                __Prefixes := __Prefixes + _SPref.Strings[_i] +';'
          finally
            _SPref.Free;
          end;
        finally
          _CfgFile.Free;
        end;
    end;
  end;
end;
  
function ParseBar( var _P: TGoodsParam ): Boolean; stdcall;
var
  _vBarCode: String;
begin
  Result := False;
  try
    if _P.IsBarCode then begin
      if (__Prefixes <> '') then begin
        if (Pos(Copy(_P.BarCode,1,2), __Prefixes)>0) then
          _vBarCode := Copy(__Prefixes, Pos(Copy(_P.BarCode,1,2), __Prefixes)+2, Length(__Prefixes) - 
                        (Pos(Copy(_P.BarCode,1,2), __Prefixes)+1));
        _vBarCode := DelSpace(DelChars(ExtractDelimited(1,_vBarCode,[';']), '='));
        _vBarCode := Copy(_vBarCode,3,Length(_vBarCode)-2);
        if (UpperCase(_vBarCode) = 'TTTTWWWWWWC') then begin
          _P.Code := IntToStr(StrToInt(Copy(_P.BarCode,3,4)));
          _P.Zoom := StrToInt(Copy(_P.BarCode,7,6))/1000;          
          Result := True;
        end
        else if (UpperCase(_vBarCode) = 'TTTTTWWWWWC') then begin
          _P.Code := IntToStr(StrToInt(Copy(_P.BarCode,3,5)));
          _P.Zoom := StrToInt(Copy(_P.BarCode,8,5))/1000;          
          Result := True;
        end
        else if (UpperCase(_vBarCode) = 'TTTTTTWWWWC') then begin
          _P.Code := IntToStr(StrToInt(Copy(_P.BarCode,3,6)));
          _P.Zoom := StrToInt(Copy(_P.BarCode,9,4))/1000;          
          Result := True;
        end;
      end;
    end;
  except
    Result:=False;
  end;
end;

exports

  InitParseBar,
  ParseBar;

end.
 