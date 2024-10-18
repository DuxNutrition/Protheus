#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PRTOPDEF.ch"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ WSR005.prw º Autor ³ Allan Rabelo º Data ³ 25/09/2024      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Schedule para enviar ZFR já processadas                    º±±
//±±º          ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function ZWSR005(cId, cPedido, lJob)
	
	Local cUrlRest      := AllTrim( SuperGetMv("DUX_API007"		,.F.	,"https://api.stage.ifctech.com.br/ihub/"))
	Local cEndPoint    	:= AllTrim( SuperGetMv("DUX_API012"  	,.F.	,"invoices/"))
	Local cApiKey   	:= "Api-Key: " + AllTrim( SuperGetMv("DUX_API009"	,.F.	,"67JvuGlf3PvuNueA14fsSD3B7GgH6E1u"))
	Local cBearer   	:= AllTrim( SuperGetMv("DUX_API010" 	,.F.	,"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdWIiOiIwIiwibmFtZSI6IkR1eCBOdXRyaXRpb24iLCJpc3MiOiJNV2d2ZGp2VHVvbm12WlFZeDBjbUV2RlBmY2lDcDFaciIsIm5iZiI6MTcyNjc2NDQ3MCwiZXhwIjoyMjAwMDYzNjcwLCJpYXQiOjE3MjY3NjQ0NzB9.m3yRVKAPGHhiqCKZCb1LkRSJl8Ypu7namsb-KPaDJZw"))
	Local aHeader 		:= {}
	Local cAtual 		:= "."
	Local nTamanho 		:= 13
	Local nLinha 		:= 0
	Local cRet 			:= ""
	Local cResponse
	Local cHeaderRet 	as char

	Default lJob		:= .F.

	If lJob
		ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR005] - Inicio Processamento")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT"
	Endif
    
	Aadd(aHeader	,'Authorization: Bearer '+cBearer)
	Aadd(aHeader	,'Content-Type: application/json;charset=UTF-8')
	Aadd(aHeader	,cApiKey)

	DbSelectArea("ZFR")
	ZFR->(DBSetOrder(2))
	If ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))

		If AllTrim(ZFR->ZFR_STATUS) == "01"
		
			cResponse := HTTPQuote(cUrlRest+cEndPoint+cId+"/ack", "PATCH",,,120,aHeader,@cHeaderRet)
			If !Empty(cResponse)
				While !Empty(cAtual) //--> Verifico se existe a palavra STATUS na linha, caso sim ele leve para condição 'ok'
					nLinha++
					cAtual := MemoLine(cResponse,nTamanho,nLinha)
					If !Empty(cAtual)
						If ( cAtual $ "status" )
							cRet   := cAtual
							cAtual := ""
						EndIf
					EndIf
				EndDo

				cRet  := cResponse

				If ( "200" $ cRet )
					RecLock("ZFR",.F.)
						ZFR->ZFR_STATUS := "20"
						ZFR->ZFR_DATACR := Date()
						ZFR->ZFR_HORACR := Time()
					ZFR->(MsUnlock())

					If lJob
						ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR005] - Processando a leitura do XML da Invoice: " + Alltrim(ZFR->ZFR_INVOIC))
						U_ZWSR006(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob)
					Else
						FWMsgRun(,{|| U_ZWSR006(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob) },,"Processando a leitura do XML da Invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")
					EndIf
				Else
					RecLock("ZFR",.F.)
						ZFR->ZFR_ERROR := "Erro ao enviar a confirmacao para a InfraCommerce"
						ZFR->ZFR_STERRO := "20"
					ZFR->(MsUnlock())

					If lJob
						ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR005] - Erro ao enviar a confirmacao de Recebimento da Invoice: " + Alltrim(ZFR->ZFR_INVOIC))
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	ZFR->(dbCloseArea())

	If lJob
		ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR005] - Fim Processamento")
		RESET ENVIRONMENT
	Endif

Return()
