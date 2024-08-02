#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.CH"
#Include "PROTHEUS.CH"

/*{Protheus.doc} ZESTS001
Schedule para bloquear lote do produto conforme o prazo de dias de vencimento.
@author Jedielson Rodrigues
@since 17/06/2024
@history 
@version 1.0
@database MSSQL
*/

User Function ZESTS001(_aParam)

Local _lJob 		:= IsBlind()
Local _lRet			:= .T.
Local _cEmpresa 	:= ""
Local _cFilial		:= ""
Local _cChave		:= ""
Local _nPos

	If _lJob
		
		ConOut("----------- [ ZESTS001 ] - Inicio da funcionalidade "+DtoC(Date())+" as "+Time() + CRLF)
		
		If ValType(_aParam) == "A"
			
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			
			CONOUT("----------- [ ZESTS001 ] INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("----------- [ ZESTS001 ] INICIANDO FILIAL  "+_cFilial)
			
			RpcClearEnv()
			RpcSetType(3)
			
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EST"

		ElseIf Type("cFilAnt") <> "C"
			
			_cEmpresa	:=	"01"
			_cFilial	:=  "02"
			
			CONOUT("----------- [ ZESTS001 ] - INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("----------- [ ZESTS001 ] - INICIANDO FILIAL  "+_cFilial)
			
			RpcClearEnv()
			RpcSetType(3)
			
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EST"
			
		EndIf
	EndIf

	//Garantir que o processamento seja unico
	_cChave := AllTrim(FWCodEmp())+AllTrim(FWCodFil())+"ZESTS001"
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName(_cChave,.T.,.T.)
				_lRet := .T.
			EndIf
		Next	

		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rotina ZESTS001, aguarde!")
			Else
				ConOut("----------- [ ZESTS001 ]  - Já existe um processamento em execução rotina ZESTS001 -------------------------" + CRLF)
			EndIf
			Break
		EndIf
	Else
		U_ZESTF001()
		UnLockByName(_cChave,.T.,.T.)
		ConOut("----------- [ ZESTS001 ] - Fim da funcionalidade "+DtoC(Date())+" as "+Time() + CRLF)
	EndIf
	
Return()
