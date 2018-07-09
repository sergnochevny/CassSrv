unit Error_Procedures;

interface
uses
	Const_Type;
	
	procedure ErrorMsg;
  
//	procedure ErrorFiskalMsg(ErrorCode: WORD; Code: Byte);

implementation
uses
	ShowErrorFunc;

procedure ErrorMsg;
begin
	ShowErrorMsg(GeneralError);
end;
{
procedure ErrorFiskalMsg(ErrorCode: WORD; Code: Byte);
var
	MessageStr:	String;
begin
	Case ErrorCode of
		ccFatalError: begin
			Case Code of
				erWrongOperator: MessageStr := WrongOperator;
				erExceedingSIncDec: MessageStr := ExceedingSIncDec;
				erExceedingPIncDec: MessageStr := ExceedingPIncDec;
				erWrongIncDec: MessageStr := WrongIncDec;
				erWrongData: MessageStr := WrongData;
				erWrongTax: MessageStr := WrongTax;
				erWrongLink: MessageStr := WrongLink;
				erEndPaper: MessageStr := EndPaper;
				erWrongFiskalMem: MessageStr := WrongFiskalMem;
				erWrongPasswordOp: MessageStr := WrongPasswordOp;
			else
				MessageStr := UnknownError;
			end;
			TokenFiskal := False;
		end;
		ccErrorAnswer: begin
			Case Code of
				erWrongTKS: MessageStr := WrongTKS;
				erOtherQuery: MessageStr := OtherQuery;
				erWrongNDS: MessageStr := WrongNDS;
			else
				MessageStr := UnknownError;
			end;
		end;
	else
		MessageStr := UnknownErrorCode;
	end;
	ShowErrorMsg(MessageStr);
end;
}
end.



 