#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} ZFATF007
Denominação de XML PARCE e Validação de SA1  
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param cId, character, Id VTex
@param cPedido, character, Pedido Protheus
@param lJob, logical, Executa via Job
/*/
User Function ZFATF007(cId, cNumPed, lJob)

	Local _lExecFAT007 	:= SuperGetMv("DUX_API021",.F., .T.) //Executa a rotina ZFATF007 .T. = SIM / .F. = NAO
	Local cError   	:= ""
	Local cWarning 	:= ""
	Local oXml     	:= NIL
	Local cCnpj    	:= ""
	Local cChave   	:= ""

	Default cId 	:= ""
	Default cNumPed	:= ""
	Default lJob	:= .F.

	If (_lExecFAT007) //Se .T. executa a rotina

		If lJob
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZFATF007] - Inicio Processamento")		
		EndIf

		DbSelectArea("ZFR")
		ZFR->(DBSetOrder(2))
		If ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))

			If AllTrim(ZFR->ZFR_STATUS) == "30"

				oXml := XmlParser( ZFR->ZFR_XML, "_", @cError, @cWarning )
				If (oXml == NIL )
					RecLock("ZFR",.F.)
						ZFR->ZFR_ERROR := ("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
						ZFR->ZFR_STERRO := "40"
					ZFR->(MsUnlock())
				Else
					If !Empty(oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:Text)
						
						cCnpj :=  oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:Text
						cChave :=  oXml:_NFEPROC:_NFE:_INFNFE:_ID:Text
						
						If ValCnpj(cCnpj)
							If lJob
								ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZFATF007] - Processando a escrituracao da invoice: " + Alltrim(ZFR->ZFR_INVOIC))
								u_ZFATF008(@oXml, ZFR->ZFR_ID, ZFR->ZFR_PEDIDO)
							Else
								FWMsgRun(,{|| U_ZFATF008(@oXml, ZFR->ZFR_ID, ZFR->ZFR_PEDIDO) },,"Processando a escrituracao da invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")
							EndIf
						Else 
							RecLock("ZFR",.F.)
								ZFR->ZFR_ERROR := ("Falha - CNPJ NÃO ENCONTRADO : "+cError+" / "+cWarning)
								ZFR->ZFR_STERRO := "40"
							ZFR->(MsUnlock())	
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			If lJob
				ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZFATF007] - Nao encontrado registro par gravação R_E_C_N_O_: " + Alltrim(cRecZFR))
			Else
				ApMsgInfo( "Não encontrado registro par gravação R_E_C_N_O_: " + Alltrim(cRecZFR), '[ZWSR006]' )
			EndIf
		EndIf
		If lJob
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZFATF007] - Fim Processamento")
		Endif
	Else
		If lJob
            ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZFATF007] - Bloqueado a execucao da rotina, verifique o parametro: DUX_API021")
        Else
            ApMsgInfo( 'Bloqueado a execucao da rotina ZFATF007, verifique o parametro: DUX_API021', '[ZFATF007]' )
        Endif
	EndIf

Return()

/*/{Protheus.doc} ValCnpj
Valida o CNPJ do cliente
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param cCnpj, character, cnpj
@return logical, .T. or .F.
/*/
Static Function ValCnpj(cCnpj)

	Local cQrySA1	:= ""
	Local cAlsSA1 	:= GetNextAlias()
	Local lRet		:= .F.

	cQrySA1 := " SELECT * FROM "+RetSqlName("SA1")+" AS SA1 " 	+ CRLF
	cQrySA1 += " WHERE SA1.A1_FILIAL = '  '  "					+ CRLF
	cQrySA1 += " AND SA1.A1_CGC = '"+cCnpj+"' "					+ CRLF
	cQrySA1 += " AND SA1.D_E_L_E_T_ <> '*'  "					+ CRLF

	If Select( (cAlsSA1) ) > 0
		(cAlsSA1)->(DbCloseArea())
	EndIf

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQrySA1), cAlsSA1, .T., .T. )
	
	DbSelectArea((cAlsSA1))
	(cAlsSA1)->(dbGoTop())
	If (cAlsSA1)->(!Eof())
		lRet := .T.
	EndIf

Return(lRet)
