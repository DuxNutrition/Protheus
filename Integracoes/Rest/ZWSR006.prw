#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} ZWSR006
Busca o XML da nota fiscal na Infracommerce
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param cId, character, Id VTex
@param cPedido, character, Pedido Protheus
@param lJob, logical, Executa via Job
/*/
User Function ZWSR006(cId, cPedido, lJob)

	Local _lExecWSR006 	:= SuperGetMv("DUX_API020",.F., .T.) //Executa a rotina ZWSR007 .T. = SIM / .F. = NAO
	Local cUrlRest      := AllTrim( SuperGetMv("DUX_API007"		,.F.	,""))
	Local cEndPoint    	:= AllTrim( SuperGetMv("DUX_API012"  	,.F.	,""))
	Local cApiKey   	:= "Api-Key: " + AllTrim( SuperGetMv("DUX_API009"	,.F.	,""))
	Local cBearer   	:= "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdWIiOiIwIiwibmFtZSI6IkR1eCBOdXRyaXRpb24iLCJpc3MiOiJNV2d2ZGp2VHVvbm12WlFZeDBjbUV2RlBmY2lDcDFaciIsIm5iZiI6MTcyNjc2NDQ3MCwiZXhwIjoyMjAwMDYzNjcwLCJpYXQiOjE3MjY3NjQ0NzB9.m3yRVKAPGHhiqCKZCb1LkRSJl8Ypu7namsb-KPaDJZw"
	Local oOBj
	Local aHeader 		:= {}
	Local aJson 		:= {}
	Local cXmlD 		:= ""
	Local cResponse
	Local cHeaderRet as char
	
	Default lJob		:= .F.

	If (_lExecWSR006) //Se .T. executa a rotina

		If lJob		
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR006] - Inicio Processamento")
		Endif

		Aadd(aHeader	,'Authorization: Bearer '+cBearer)
		Aadd(aHeader	,'Content-Type: application/json;charset=UTF-8')
		Aadd(aHeader	,cApiKey)

		DbSelectArea("ZFR")
		ZFR->(DBSetOrder(2))
		If ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))

			If AllTrim(ZFR->ZFR_STATUS) == "20"
				cResponse := HTTPQuote(cUrlRest+cEndPoint+AllTrim(ZFR->ZFR_ID)+"/xml", "GET",,,120,aHeader,@cHeaderRet)
				
				If !Empty(cResponse) 
					FwJsonDeserialize(cResponse,@oOBj)
				EndIf 

				aJson := oObj

				If !Empty(aJson)
				
					cXmlD := aJson:CONTENT
					cXmlD := Decode64(cXmlD)
			
						If !Empty(cXmlD)

							RecLock("ZFR",.F.)
								ZFR->ZFR_STATUS := "30"
								ZFR->ZFR_DATAX 	:= Date()
								ZFR->ZFR_HORAX 	:= Time()
								ZFR->ZFR_XML   	:= cXmlD
							ZFR->(MsUnlock())

							If lJob
								ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR006] - Processando a escrituracao da invoice: " + Alltrim(ZFR->ZFR_INVOIC))
								U_ZFATF007(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob)
							Else
								FWMsgRun(,{|| U_ZFATF007(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob) },,"Processando a escrituracao da invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")
							EndIf
						Else
							RecLock("ZFR",.F.)
								ZFR->ZFR_ERROR 	:= "Erro na leitura do xml da InfraCommerce "
								ZFR->ZFR_STERRO := "20"
							ZFR->(MsUnlock())
						Endif
				Endif
			EndIf
		EndIf
		If lJob
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR006] - Fim Processamento")
		Endif
	Else
		If lJob
            ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR006] - Bloqueado a execucao da rotina, verifique o parametro: DUX_API020")
        Else
            ApMsgInfo( 'Bloqueado a execucao da rotina ZWSR006, verifique o parametro: DUX_API020', '[ZWSR006]' )
        Endif
	EndIf
Return()

