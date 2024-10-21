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

User Function ZFATS001(_aParam)

Local _lJob 		:= IsBlind()
Local _lLockByName	:= .T.
Local _cEmpresa 	:= ""
Local _cFilial		:= ""
Local _cChave		:= ""
Local _nPos

	If _lJob
		
		ConOut("----------- [ ZFATS001 ] - Inicio da funcionalidade "+DtoC(Date())+" as "+Time() + CRLF)
		
		If ValType(_aParam) == "A"
			
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			
			CONOUT("----------- [ ZFATS001 ] INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("----------- [ ZFATS001 ] INICIANDO FILIAL  "+_cFilial)
			
			RpcClearEnv()
			RpcSetType(3)
			
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "FAT"

		ElseIf Type("cFilAnt") <> "C"
			
			_cEmpresa	:=	"01"
			_cFilial	:=  "02"
			
			CONOUT("----------- [ ZFATS001 ] - INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("----------- [ ZFATS001 ] - INICIANDO FILIAL  "+_cFilial)
			
			RpcClearEnv()
			RpcSetType(3)
			
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "FAT"
			
		EndIf
	EndIf

	//Garantir que o processamento seja unico
	_cChave := AllTrim(FWCodEmp())+AllTrim(FWCodFil())+"ZFATS001"
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lLockByName := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName(_cChave,.T.,.T.)
				_lLockByName := .T.
			EndIf
		Next	

		If !(_lLockByName)
			If !_lJob
				MsgInfo("Já existe um processamento em execução rotina ZFATS001, aguarde!")
			Else
				ConOut("----------- [ ZFATS001 ]  - Já existe um processamento em execução rotina ZFATS001 -------------------------" + CRLF)
			EndIf
			Break
		EndIf
	EndIf

	If (_lLockByName)
		U_ZWSR004(.T.)
		UnLockByName(_cChave,.T.,.T.)
		ConOut("----------- [ ZFATS001 ] - Fim da funcionalidade "+DtoC(Date())+" as "+Time() + CRLF)
	EndIf
	
Return()
