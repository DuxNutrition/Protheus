#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} ZFATS002
Schedule de envio das confirmação para a VTex
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 21/10/2024
@param _aParam, array, parametros do Job
/*/
User Function ZFATS002(_aParam)

Local _lJob 		:= IsBlind()
Local _lRet			:= .T.
Local _cEmpresa 	:= ""
Local _cFilial		:= ""
Local _cChave		:= ""
Local _nPos

	If _lJob

		ConOut("----------- [ ZFATS002 ] - Inicio da funcionalidade "+DtoC(Date())+" as "+Time() + CRLF)

		If ValType(_aParam) == "A"

			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]

			CONOUT("----------- [ ZFATS002 ] INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("----------- [ ZFATS002 ] INICIANDO FILIAL  "+_cFilial)

			RpcClearEnv()
			RpcSetType(3)

			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "FAT"

		ElseIf Type("cFilAnt") <> "C"

			_cEmpresa	:=	"01"
			_cFilial	:=  "04"

			CONOUT("----------- [ ZFATS002 ] - INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("----------- [ ZFATS002 ] - INICIANDO FILIAL  "+_cFilial)

			RpcClearEnv()
			RpcSetType(3)

			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "FAT"

		EndIf
	EndIf

	//Garantir que o processamento seja unico
	_cChave := AllTrim(FWCodEmp())+AllTrim(FWCodFil())+"ZFATS002"
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
				MsgInfo("Já existe um processamento em execução rotina ZFATS002, aguarde!")
			Else
				ConOut("----------- [ ZFATS002 ]  - Já existe um processamento em execução rotina ZFATS002 -------------------------" + CRLF)
			EndIf
			Break
		EndIf
	Else
		U_ZWSR007("", "", .T.)
		UnLockByName(_cChave,.T.,.T.)
		ConOut("----------- [ ZFATS002 ] - Fim da funcionalidade "+DtoC(Date())+" as "+Time() + CRLF)
	EndIf

Return()
