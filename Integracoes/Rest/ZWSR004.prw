#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PRTOPDEF.ch"

/*/{Protheus.doc} ZWSR004
Busca as notas fiscais faturadas pela Infracommerce
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param lJob, logical, executa via job.
/*/
User Function ZWSR004(lJob)
	
	Local _lExecWSR004 	:= SuperGetMv("DUX_API018",.F., .F.) //Executa a rotina ZWSR007 .T. = SIM / .F. = NAO
	Local cUrlRest		:= AllTrim( SuperGetMv("DUX_API007"		,.F.	,""))
	Local cEndPoint     := AllTrim( SuperGetMv("DUX_API008"  	,.F.	,""))
	Local cApiKey   	:= "Api-Key: " + AllTrim( SuperGetMv("DUX_API009"	,.F.	,""))
	Local cBearer  		:= "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdWIiOiIwIiwibmFtZSI6IkR1eCBOdXRyaXRpb24iLCJpc3MiOiJNV2d2ZGp2VHVvbm12WlFZeDBjbUV2RlBmY2lDcDFaciIsIm5iZiI6MTcyNjc2NDQ3MCwiZXhwIjoyMjAwMDYzNjcwLCJpYXQiOjE3MjY3NjQ0NzB9.m3yRVKAPGHhiqCKZCb1LkRSJl8Ypu7namsb-KPaDJZw"
	Local oRest as object
	Local oOBj
	Local aHeader 		:= {}
	Local aJson 		:= {}
	Local _cFil         := FWCodFil()

	Default lJob		:= .F.

	If (_lExecWSR004) //Se .T. executa a rotina

		If lJob
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR004] - Inicio Processamento")
		Endif

		If AllTrim(_cFil) == "04" //Executa somente na filial 04

			Aadd(aHeader	, 'Authorization: Bearer '+ cBearer)
			Aadd(aHeader	, 'Content-Type: application/json;charset=UTF-8')
			Aadd(aHeader	, cApiKey)

			oRest := FWRest():New(cUrlRest)
			oRest:SetPath(cEndPoint)
			oRest:Get(aHeader)

			FwJsonDeserialize(oRest:GetResult(),@oOBj)
			
			aJson := oObj
			
			If !Empty(aJson)
				If lJob
					ZF01R004(@aJson, lJob)
				Else
					Processa({|| ZF01R004(@aJson, lJob) }, "[ZWSR004] - Buscando notas faturadas na InfraCommerce", "Aguarde ...." )
				EndIf
			EndIf 

			If lJob
				ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR004] - Fim Processamento")
			Else
				ApMsgInfo( 'Processamento Concluido com Sucesso.', '[ZWSR004]' )
			Endif
		Else
			If lJob
				ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR004] - Permitido executar a rotina somente na Filial 04")
			Else
				ApMsgInfo( 'Permitido executar a rotina somente na Filial 04', '[ZWSR004]' )
			Endif
		EndIf
	Else
		If lJob
            ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR004] - Bloqueado a execucao da rotina, verifique o parametro: DUX_API018")
        Else
            ApMsgInfo( 'Bloqueado a execucao da rotina ZWSR004, verifique o parametro: DUX_API018', '[ZWSR004]' )
        Endif
	EndIf

Return()

/*/{Protheus.doc} ZF01R004
Get trazendo todas as invoice alimentando a tabela ZFR com base no Resultado
@type function
@version 12.1.2310
@author Dux | Allan Rabelo 
@since 21/10/2024
@param aJson, array, json
@param lJob, logical, executa via job
/*/
Static Function ZF01R004(aJson, lJob)

	Local nCont 	:= 0
	Local nTotReg	:= 0
	Local aDados 	:= {}
	Local aInvoices	:= {}
	Local cOper   	:= AllTrim( SuperGetMv("DUX_API011"	,.F.	,""))
	
	Default lJob		:= .F.
	
	If !(lJob)
        nTotReg := Len(aJson["invoices"])
        ProcRegua( nTotReg )
    EndIf

	For nCont := 1 to Len(aJson["invoices"])

		If lJob
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR004] - Processando Invoice: " + Alltrim(aJson["invoices"][nCont]["invoiceNumber"]) + " | ID: " + Alltrim(aJson["invoices"][nCont]["_id"] ))
		Else
			IncProc( "Processando Invoice: " + Alltrim(aJson["invoices"][nCont]["invoiceNumber"]) + " | ID: " + Alltrim(aJson["invoices"][nCont]["_id"] ))
		EndIf

		If (aJson["invoices"][nCont]["operationType"] == cOper)
			aadd(aDados,aJson["invoices"][nCont]["_id"])
			aadd(aDados,aJson["invoices"][nCont]["status"])
			aadd(aDados,aJson["invoices"][nCont]["invoiceNumber"])
			aadd(aDados,aJson["invoices"][nCont]["operationType"])
			aadd(aDados,aJson["invoices"][nCont]["emissionDate"])
			aadd(aDados,aJson["invoices"][nCont]["isOut"])
			//aadd(aDados,aJson["invoices"][nCont]["sellerCode"])
			aadd(aDados,"")
			//aadd(aDados,aJson["invoices"][nCont]["sellerId"])
			aadd(aDados,"")
			aadd(aDados,aJson["invoices"][nCont]["updatedAt"])
			//sefaz
			aadd(aDados,aJson["invoices"][nCont]["Sefaz"]["Key"])
			//documento
			aadd(aDados,aJson["invoices"][nCont]["receiver"]["document"])
			aadd(aDados,aJson["invoices"][nCont]["receiver"]["documentType"])
			aadd(aDados,aJson["invoices"][nCont]["receiver"]["name"])
			If AllTrim(aJson["invoices"][nCont]["status"]) == "authorized"
				//order
				aadd(aDados,aJson["invoices"][nCont]["order"]["internalNumber"])
				aadd(aDados,aJson["invoices"][nCont]["order"]["originNumber"])
				aadd(aDados,SubStr(aJson["invoices"][nCont]["order"]["platformNumber"],3))
			Else
				//order
				aadd(aDados,"")
				aadd(aDados,"")
				aadd(aDados,"")
			EndIf
			aadd(aDados,aJson["invoices"][nCont]["storeId"])

			aadd(aInvoices,aDados)
		endif 
		aDados := {}
	Next

	If !Empty(aInvoices)
		ZF02R004(aInvoices, lJob)
	EndIf

Return()

/*/{Protheus.doc} ZF02R004
Grava os dados na Tabela ZFR
@type function
@version 12.1.2310
@author Dux | Allan Rabelo 
@since 21/10/2024
@param aInvoices, array, notas
@param lJob, logical, executa via job
/*/
Static Function ZF02R004(aInvoices, lJob)

	Local nCont 	:= 0
	Local lEnviaIc	:= .F.

	Default lJob		:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³  Gravo Conteudo na tabela PONTE                                           ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nCont := 1 to Len(aInvoices)

		lEnviaIc := .F.
		If AllTrim(aInvoices[nCont][02]) == "authorized" //Json status da nota é autorizado.
		
			DbSelectArea("ZFR")
			ZFR->(DBSetOrder(2))
			If !(ZFR->(DbSeek(xFilial("ZFR") + PADR(AllTrim(aInvoices[nCont][01]), TamSX3("ZFR_ID")[1]))))

				RecLock("ZFR",.T.)
					ZFR->ZFR_FILIAL 	:= cFilAnt
					ZFR->ZFR_ID     	:= aInvoices[nCont][01]
					ZFR->ZFR_STATIN 	:= aInvoices[nCont][02]
					ZFR->ZFR_INVOIC 	:= aInvoices[nCont][03]
					ZFR->ZFR_OPER   	:= aInvoices[nCont][04]
					ZFR->ZFR_EMISSA 	:= aInvoices[nCont][05]
					ZFR->ZFR_ITOUTS 	:= aInvoices[nCont][06]
					ZFR->ZFR_CODSEL 	:= aInvoices[nCont][07]
					ZFR->ZFR_IDSELL 	:= aInvoices[nCont][08]
					ZFR->ZFR_UPDAT  	:= aInvoices[nCont][09]
					ZFR->ZFR_CHAVE  	:= aInvoices[nCont][10]
					ZFR->ZFR_DOC    	:= Upper(aInvoices[nCont][11])
					ZFR->ZFR_DOCTIP 	:= Upper(aInvoices[nCont][12])
					ZFR->ZFR_NOME   	:= aInvoices[nCont][13]
					//ZFR->ZFR_PDINT	  := aContd[nCont][14]
					ZFR->ZFR_PEDIDO 	:= aInvoices[nCont][16]
					ZFR->ZFR_PLATNU 	:= aInvoices[nCont][16]
					ZFR->ZFR_STOREI 	:= aInvoices[nCont][17]
					ZFR->ZFR_STATUS 	:= "01"
					ZFR->ZFR_DATAPD 	:= Date()
					ZFR->ZFR_HORAPD 	:= Time()
				ZFR->(MsUnlock())

				lEnviaIc := .T.

			EndIf

		ElseIf AllTrim(aInvoices[nCont][02]) == "canceled" //Json status da nota é cancelado.

			DbSelectArea("ZFR")
			ZFR->(DBSetOrder(2))
			If ZFR->(DbSeek(xFilial("ZFR") + PADR(AllTrim(aInvoices[nCont][01]), TamSX3("ZFR_ID")[1])))

				If AllTrim(ZFR->ZFR_STATUS) <> "C1"

					RecLock("ZFR",.F.)
						ZFR->ZFR_STATIN 	:= aInvoices[nCont][02]
						ZFR->ZFR_STATUS 	:= "C1"
						ZFR->ZFR_DATCAN 	:= Date()
						ZFR->ZFR_HORCAN 	:= Time()
					ZFR->(MsUnlock())
					
					lEnviaIc := .T.

				EndIf
			EndIf
		EndIf
			
		//Apos gravar, envia a confirmação da nota fiscal para a infracommerce
		If !Empty(ZFR->ZFR_ID) .And. lEnviaIc
			If lJob
				ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR004] - Enviando a confirmacao de Recebimento da Invoice: " + Alltrim(ZFR->ZFR_INVOIC))
				U_ZWSR005(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob)
			Else
				FWMsgRun(,{|| U_ZWSR005(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob) },,"Enviando a confirmação de Recebimento da Invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")
			EndIf				
		Endif
	Next

Return()
