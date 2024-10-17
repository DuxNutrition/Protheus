#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ ZWSR006.prw º Autor ³ Allan Rabelo º Data ³ 28/09/2024      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Schedule para pegar os XML e gravar do INTERCOMMERCE       º±±
//±±º          ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User function ZWSR006(cId)
	local cURL      := GetMV("DX_URL",.F.,"https://api.stage.ifctech.com.br/ihub/")
	local cEnd      := GetMV("DX_ENDX",.F.,"invoices/")
	local cApiKey   := GetMV("DX_APIKEY",.F.,"67JvuGlf3PvuNueA14fsSD3B7GgH6E1u")
	local cBearer   := GetMv("DX_BEARE",.F.,"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdWIiOiIwIiwibmFtZSI6IkR1eCBOdXRyaXRpb24iLCJpc3MiOiJNV2d2ZGp2VHVvbm12WlFZeDBjbUV2RlBmY2lDcDFaciIsIm5iZiI6MTcyNjc2NDQ3MCwiZXhwIjoyMjAwMDYzNjcwLCJpYXQiOjE3MjY3NjQ0NzB9.m3yRVKAPGHhiqCKZCb1LkRSJl8Ypu7namsb-KPaDJZw")
	local cKeynam   := GetMv("DX_KEYNAM",.F.,"Api-Key:")
	local oRest as object
	Local oOBj
	local cPar  := cKeynam+cApiKey
	local aHeader := {}
	local aJson := {}
	Local cTeste
	Local cXmlD := ""
	Local cIntCom := ""
	Local cResponse
	Local cHeaderRet as char
	Local oXml := NIL
	Local cAlias2

	If IsBlind()
		Conout("JOB ZWSR006 (BUSCA XML) INICIADO NA DATA: "+Dtos(Date())+" NO HORÁRIO: "+TIME()+" ")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT"
	Endif

	aadd(aHeader,'Authorization: Bearer '+cBearer)
	aadd(aHeader,'Content-Type: application/json;charset=UTF-8')
	aadd(aHeader,cPar)

	if Empty(cId)
		cAlias2 := ValidSTAT("XML")
	else 
		cAlias2 := ValidSTAT("XML",cId)
	endif 
	
	While (cAlias2)->(!eof())
		cResponse := HTTPQuote(cURL+cEnd+alltrim((cAlias2)->(IDX))+"/xml", "GET",,,120,aHeader,@cHeaderRet)
		if !Empty(cResponse) 
			FwJsonDeserialize(cResponse,@oOBj)
		endif 

	aJson := oObj

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega o JSON e decode64 nele para gravar na ZFR                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    if !Empty(aJson)
        cXmlD := aJson:CONTENT
        cXmlD := Decode64(cXmlD)
        DbSelectArea("ZFR")
		ZFR->(DbGoTo((cAlias2)->(RECNO)))
        if !Empty(cXmlD)
        	    RecLock("ZFR",.F.)
				ZFR->ZFR_STATUS := "30"
				ZFR->ZFR_DATAX := Date()
				ZFR->ZFR_HORAX := Time()
                ZFR->ZFR_XML   := cXmlD
				ZFR->(MsUnlock())
				lRet := .T.
		else
				ZFR->ZFR_ERROR := "Erro no recebimento de XML da INFRACOMMERCE "
                ZFR->ZFR_STERRO := "20"
				ZFR->(MsUnlock())
				lRet := .F.
        endif 
    endif 
    (cAlias2)->(DbSkip())
    
	Enddo
(cAlias2)->(dbCloseArea())

If IsBlind()
	Conout("JOB ZWSR006 (BUSCA XML) FINALIZADO NA DATA: "+Dtos(Date())+" NO HORÁRIO: "+TIME()+" ")
	RESET ENVIRONMENT
endif 
Return()


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ ValidSTAT º Autor ³ Allan Rabelo º Data ³ 28/09/2024       º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Query para encontrar os results prontos                    º±±
//±±º          ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function ValidSTAT(cOper,cId)
Local cQuery := ""
Local lRet := .F.
Local cAlias2 := GetNextAlias()

cQuery := " SELECT ZFR_STATUS as STATUSX, ZFR_ID AS IDX, R_E_C_N_O_ AS RECNO  FROM "+RetSqlName("ZFR")+" AS ZFR "
cQuery += " WHERE ZFR.D_E_L_E_T_ = ''  "
cQuery += " AND "
if     (cOper == "PATCH")
    cQuery += " ZFR_STATUS = '1'  "
elseif (cOper == "XML")
    cQuery += " ZFR_STATUS = '20' "
elseif (cOper == "OK")
    cQuery += " ZFR_STATUS = '30' "
elseif (cOper == "ERRO")
    cQuery += " ZFR_STATUS = '99' "
endif 
if !Empty(cId)
	 cQuery += " AND ZFR_ID = '"+cId+"' "
endif 

TcQuery cQuery New Alias (cAlias2)

if (cAlias2)->(!Eof())
    lRet := .T. 
endif 

Return(cAlias2) 


Static Function pegaJson()
	local cFile := 'C:\temp\db1.json'
	local cJsonStr,oJson
	Local cCount
    Local aJson
    Local oJsonB

	cJsonStr := readfile(cFile)
	oJson := JsonObject():New()
	cErr := oJson:fromJson(cJsonStr)
    aJson := FWJsonDeserialize(cJsonStr,@oJsonB)
    aJson := @oJsonB
	If !empty(cErr)
		MsgStop(cErr,"JSON PARSE ERROR")
		Return
	Endif
    //FreeObj(oJsonB)


Return(@aJson)


STATIC Function ReadFile(cFile)
	Local cBuffer := ''
	Local nH , nTam
	nH := Fopen(cFile)
	IF nH != -1
		nTam := fSeek(nH,0,2)
		fSeek(nH,0)
		cBuffer := space(nTam)
		fRead(nH,@cBuffer,nTam)
		fClose(nH)
	Else
		MsgStop("Falha na abertura do arquivo ["+cFile+"]","FERROR "+cValToChar(Ferror()))
	Endif

Return cBuffer

