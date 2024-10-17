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

User function ZWSR005(cId)
	local cURL      := GetMV("DX_URL",.F.,"https://api.stage.ifctech.com.br/ihub/")
	local cEnd      := GetMV("DX_ENDPT",.F.,"invoices/")
	local cApiKey   := GetMV("DX_APIKEY",.F.,"67JvuGlf3PvuNueA14fsSD3B7GgH6E1u")
	local cBearer   := GetMv("DX_BEARE",.F.,"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdWIiOiIwIiwibmFtZSI6IkR1eCBOdXRyaXRpb24iLCJpc3MiOiJNV2d2ZGp2VHVvbm12WlFZeDBjbUV2RlBmY2lDcDFaciIsIm5iZiI6MTcyNjc2NDQ3MCwiZXhwIjoyMjAwMDYzNjcwLCJpYXQiOjE3MjY3NjQ0NzB9.m3yRVKAPGHhiqCKZCb1LkRSJl8Ypu7namsb-KPaDJZw")
	local cKeynam   := GetMv("DX_KEYNAM",.F.,"Api-Key: ")
	local cPar  := cKeynam+cApiKey
	local aHeader := {}
	Local cResponse
	Local cHeaderRet as char
	Local cAtual := "."
	Local nTamanho := 13
	Local nLinha := 0
	Local cRet := ""
	Local lRet := .F.

	Default nRecno := 0
    If IsBlind()
		Conout("JOB ZWSR005 (ENVIO PROCESSADAS) INICIADO NA DATA: "+Dtos(Date())+" NO HORÁRIO: "+TIME()+" ")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT" 
	Endif

	aadd(aHeader,'Authorization: Bearer '+cBearer)
	aadd(aHeader,'Content-Type: application/json;charset=UTF-8')
	aadd(aHeader,cPar)

	if !(Select('ZFR') > 0)
		DbSelectArea("ZFR")
		ZFR->(DBSetOrder(2))
		ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))
	endif 
	
	cResponse := HTTPQuote(cURL+cEnd+cId+"/ack", "PATCH",,,120,aHeader,@cHeaderRet)
	if !Empty(cResponse)
		While !Empty(cAtual) //--> Verifico se existe a palavra STATUS na linha, caso sim ele leve para condição 'ok'
			nLinha++
			cAtual := MemoLine(cResponse,nTamanho,nLinha)
			if !Empty(cAtual)
				if (cAtual $ "status")
					cRet   := cAtual
					cAtual := ""
				endif
			endif
		Enddo	
		cRet  := cResponse
		if ("200"$cRet)
			RecLock("ZFR",.F.)
			ZFR->ZFR_STATUS := "20"
			ZFR->ZFR_DATACR := Date()
			ZFR->ZFR_HORACR := Time()
			ZFR->(MsUnlock())
			lRet := .T.
		else
			RecLock("ZFR",.F.)
			ZFR->ZFR_ERROR := "Erro no envio de PATH para INFRACOMMERCE "
			ZFR->ZFR_STERRO := "20"
			ZFR->(MsUnlock())
			lRet := .F.
		endif
	endif
	ZFR->(dbCloseArea())
If IsBlind()
    Conout("JOB ZWSR005 (ENVIO PROCESSADAS) FINALIZADO NA DATA: "+Dtos(Date())+" NO HORÁRIO: "+TIME()+" ")
    RESET ENVIRONMENT
endif 
Return(lRet)
