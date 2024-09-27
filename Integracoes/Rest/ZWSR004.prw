#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PRTOPDEF.ch"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ WSR004.prw º Autor ³ Allan Rabelo º Data ³ 25/09/2024      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Schedule para pegar pedidos da INFRACOMMERCE               º±±
//±±º          ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User function ZWSR004()
	local cURL      := GetMV("DX_URL"   ,.F.,"api.stage.ifctech.com.br/")
	local cEnd      := GetMV("DX_ENDP"  ,.F.,"ihub/invoices/list")
	local cApiKey   := GetMV("DX_APIKEY",.F.,"Zqc8nwZxI2v4IoKDpTQxXnwKEjQug8GNwiBEnxSuO2dSkgSpYsJ1lDfKjo5V")
	local cBearer   := GetMv("DX_BEARE" ,.F.,"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdWIiOiIwIiwibmFtZSI6IkR1eCBOdXRyaXRpb24iLCJpc3MiOiJNV2d2ZGp2VHVvbm12WlFZeDBjbUV2RlBmY2lDcDFaciIsIm5iZiI6MTcyNjc2NDQ3MCwiZXhwIjoyMjAwMDYzNjcwLCJpYXQiOjE3MjY3NjQ0NzB9.m3yRVKAPGHhiqCKZCb1LkRSJl8Ypu7namsb-KPaDJZw")
	local cKeynam   := GetMv("DX_KEYNAM",.F.,"Api-Key: ")
	local oRest as object
	Local oOBj
	local cPar  := cKeynam+cApiKey
	local aHeader := {}
	local aJson := {}
	Local cTeste
    Local cHeaderGet as char 

    aadd(aHeader,'Content-Type: application/json')
	aadd(aHeader,'Authorization: Bearer '+cBearer)
    aadd(aHeader,cPar)
	oRest := FWRest():new(cURL)
	oRest:setPath(cEnd)
	oRest:SetGetParams(cPar)
	oRest:GET(aHeader)
	cTeste := oRest:GetResult()
    cTeste := HttpGet(cURL+cEnd,,,aHeader,@cHeaderGet)
	FwJsonDeserialize(oRest:GetResult(),@oOBj)
	aJson := oObj
/*
||||||/////////RETIRAR//////////||||| */
aJson := pegaJson() //--> FUNÇÃO PARA PEGAR JSON TESTE <-- 
/*|||||/////////////////////////||||*/
if !Empty(aJson)
    GetPedZFR(@aJson)
endif 

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ GetPedZFR          ºAutor³ Allan Rabelo            º Data ³ 25/09/2024 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Get trazendo todas as invoice alimentando a tabela ZFR com base no     º±±
±±º         ³ Resultado                                                              º±±
±±º         ³                                                                        º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametr.³ ExpC1= Array com JSON                                                  º±±
±±º         ³ ExpC2=                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³                                                                        º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ DUXNutrition                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                        PROJETO INFRACOMMERCE                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Programador  ³  Data   ³ Motivo da Alteracao                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º              ³         ³                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetPedZFR(aJson)
	Local nCont := 0
	Local aDados := {}
	Local aContd := {}
	Local lRet := .F.

//// Trocar para INVOICE quando liberar a API//////////
	For nCont := 1 to Len(aJson)
		aadd(aDados,aJson[nCont]["_id"])
		aadd(aDados,aJson[nCont]["status"])
		aadd(aDados,aJson[nCont]["invoiceNumber"])
		aadd(aDados,aJson[nCont]["operationType"])
		aadd(aDados,aJson[nCont]["emissionDate"])
		aadd(aDados,aJson[nCont]["isOut"])
		aadd(aDados,aJson[nCont]["sellerCode"])
		aadd(aDados,aJson[nCont]["sellerId"])
		aadd(aDados,aJson[nCont]["updatedAt"])
		//sefaz
		aadd(aDados,aJson[nCont]["Sefaz"]["Key"])
		//documento
		aadd(aDados,aJson[nCont]["receiver"]["document"])
		aadd(aDados,aJson[nCont]["receiver"]["documentType"])
		aadd(aDados,aJson[nCont]["receiver"]["name"])
		//order
		aadd(aDados,aJson[nCont]["order"]["internalNumber"])
		aadd(aDados,aJson[nCont]["order"]["originNumber"])
		aadd(aDados,aJson[nCont]["order"]["platformNumber"])
		aadd(aDados,aJson[nCont]["storeId"])

		aadd(aContd,aDados)
		aDados := {}
	Next
	if !Empty(aContd)
		if GrvContd(aContd)
			lRet := .T.
		endif
	endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ GrvContd           ºAutor³ Allan Rabelo            º Data ³ 25/09/2024 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Recklock na tabela ponte ZFR                                           º±±
±±º         ³                                                                        º±±
±±º         ³                                                                        º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametr.³ ExpC1= Array com JSON                                                  º±±
±±º         ³ ExpC2=                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³                                                                        º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ DUXNutrition                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                        PROJETO INFRACOMMERCE                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Programador  ³  Data   ³ Motivo da Alteracao                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º              ³         ³                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvContd(aContd)

	Local nCont := 0
	Local lRet := .T.

	For nCont := 1 to Len(aContd)
		DbSelectArea("ZFR")
		ZFR->(DBSetOrder(1))
		ZFR->(DbGoTop())
		if !(ZFR->(DbSeek(xFilial("ZFR")+PADR(cValTochar(aContd[nCont]["15"]),TamSX3("ZFR_PEDIDO")[1]))))
			RecLock("ZFR",.T.)
			ZFR->ZFR_FILIAL := cFilAnt
			ZFR->ZFR_ID     := aContd[nCont][1]
			ZFR->ZFR_STATIN := aContd[nCont][2]
			ZFR->ZFR_INVOIC := aContd[nCont][3]
			ZFR->ZFR_OPER   := aContd[nCont][4]
			ZFR->ZFR_EMISSA := aContd[nCont][5]
			ZFR->ZFR_ITOUT  := aContd[nCont][6]
			ZFR->ZFR_CODSEL := aContd[nCont][7]
			ZFR->ZFR_IDSELL := aContd[nCont][8]
			ZFR->ZFR_UPDAT  := aContd[nCont][9]
			ZFR->ZFR_CHAVE  := aContd[nCont][10]
			ZFR->ZFR_DOC    := aContd[nCont][11]
			ZFR->ZFR_DOCTIP := aContd[nCont][12]
			ZFR->ZFR_NOME   := aContd[nCont][13]
			ZFR->ZFR_PDINT  := aContd[nCont][14]
			ZFR->ZFR_PEDIDO := aContd[nCont][15]
			ZFR->ZFR_PLATNU := aContd[nCont][16]
			ZFR->ZFR_STOREI := aContd[nCont][17]
			ZFR->ZFR_STATUS := 1
			ZFR->ZFR_DATAPD := Stod(Date())
			ZFR->ZFR_HORAPD := Time()
			ZFR->(MsUnlock())

        /* -->Execução parte dois -> Envio de aviso de recebimento <--*/
			if !Empty(ZFR->ZFR_ID)
				lRet :=  U_ZWSR4ER(ZFR->ZFR_ID)
			endif
		endif
	Next
Return(lRet)

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

User function ZWSR4ER(cId)
	local cURL      := GetMV("DX_URL",.F.,"localhost:3000/")
	local cEnd      := GetMV("DX_ENDPT",.F.,"count")
	local cApiKey   := GetMV("DX_APIKEY",.F.,"Zqc8nwZxI2v4IoKDpTQxXnwKEjQug8GNwiBEnxSuO2dSkgSpYsJ1lDfKjo5V")
	local cBearer   := GetMv("DX_BEARE",.F.,"Zqc8nwZxI2v4IoKDpTQxXnwKEjQug8GNwiBEnxSuO2dSkgSpYsJ1lDfKjo5V")
	local cKeynam   := GetMv("DX_KEYNAM",.F.,"Api-Key=")
	local cPar  := cKeynam+cApiKey
	local aHeader := {}
	Local cResponse
	Local cHeaderRet as char
	Local cOper     := "PATCH"
	Local cAtual := "."
	Local nTamanho := 13
	Local nLinha := 0
	Local cRet := ""
	Local lRet := .F.

	aadd(aHeader,'Authorization: Bearer '+cBearer)
	aadd(aHeader,'Content-Type: application/json;charset=UTF-8')
	aadd(aHeader,cPar)


	DbSelectArea("ZFR")
	cResponse := HTTPQuote(cURL+cEnd, "PATCH",,cId,120,aHeader,@cHeaderRet)
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
		ZFR->(DBSetOrder(2))
		if (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
			if (cRet$"200")
				RecLock("ZFR",.F.)
				ZFR->ZFR_STATUS := 20
				ZFR->ZFR_DATACR := Stod(Date())
				ZFR->ZFR_HORACR := Time()
				ZFR->(MsUnlock())
				lRet := .T.
			else
				ZFR->ZFR_ERROR := "Erro no envio de PATH para INFRACOMMERCE "
				lRet := .F.
			endif
		endif
	endif
	ZFR->(dbCloseArea())

Return(lRet)



/*/{Protheus.doc} PEGAJSON
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function pegaJson()
	local cFile := 'C:\temp\db1.json'
	local cJsonStr,oJson
	Local cCount

	cJsonStr := readfile(cFile)
	oJson := JsonObject():New()
	cErr := oJson:fromJson(cJsonStr)


Return
