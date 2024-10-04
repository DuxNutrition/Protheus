#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PRTOPDEF.ch"

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  � WSR004.prw � Autor � Allan Rabelo � Data � 25/09/2024      ���
//�������������������������������������������������������������������������͹��
//���Descricao � Schedule para pegar pedidos da INFRACOMMERCE               ���
//���          �                                                            ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

User function ZWSR004()
	local cURL      := GetMV("DX_URL"   ,.F.,"localhost:3000/")
	local cEnd      := GetMV("DX_ENDP"  ,.F.,"invoices")
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

	If IsBlind()
		Conout("JOB ZWSR004 (BUSCA PEDIDOS) INICIADO NA DATA: "+Dtos(Date())+" NO HOR�RIO: "+TIME()+" ")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT"
	Endif

	aadd(aHeader,'Authorization: Bearer '+cBearer)
	aadd(aHeader,'Content-Type: application/json;charset=UTF-8')

	oRest := FWRest():new(cURL)
	oRest:setPath(cEnd)
	oRest:SetGetParams(cPar)
	oRest:GET(aHeader)
	cTeste := oRest:GetResult()
	FwJsonDeserialize(oRest:GetResult(),@oOBj)
	aJson := oObj
/*
||||||/////////RETIRAR//////////||||| */
aJson := pegaJson() //--> FUN��O PARA PEGAR JSON TESTE <-- 
/*|||||/////////////////////////||||*/
//���������������������������������������������������������������������������Ŀ
//�  Chamada fun��o para pegar todos os dados do GET                         �
//�����������������������������������������������������������������������������
if !Empty(aJson)
    GetPedZFR(@aJson)
endif 
Conout("JOB ZWSR004 (BUSCA PEDIDOS) FINALIZADO NA DATA: "+Dtos(Date())+" NO HOR�RIO: "+TIME()+" ")
RESET ENVIRONMENT
Return()
/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa � GetPedZFR          �Autor� Allan Rabelo            � Data � 25/09/2024 ���
������������������������������������������������������������������������������������͹��
���Desc.    � Get trazendo todas as invoice alimentando a tabela ZFR com base no     ���
���         � Resultado                                                              ���
���         �                                                                        ���
���         �                                                                        ���
������������������������������������������������������������������������������������͹��
���Parametr.� ExpC1= Array com JSON                                                  ���
���         � ExpC2=                                                                 ���
������������������������������������������������������������������������������������͹��
���Retorno  �                                                                        ���
���         �                                                                        ���
������������������������������������������������������������������������������������͹��
���Uso      � DUXNutrition                                                           ���
������������������������������������������������������������������������������������͹��
���                        PROJETO INFRACOMMERCE                                     ���
������������������������������������������������������������������������������������͹��
���  Programador  �  Data   � Motivo da Alteracao                                    ���
������������������������������������������������������������������������������������͹��
���              �         �                                                        ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/

Static Function GetPedZFR(aJson)
	Local nCont := 0
	Local aDados := {}
	Local aContd := {}
	Local lRet := .F.
	//���������������������������������������������������������������������������Ŀ
    //�  Monto array com base no que estou RECEBENDO JSON                         �
    //�����������������������������������������������������������������������������

//// Trocar para INVOICE quando liberar a API//////////
	For nCont := 1 to Len(aJson["invoices"])
		aadd(aDados,aJson["invoices"][nCont]["_id"])
		aadd(aDados,aJson["invoices"][nCont]["status"])
		aadd(aDados,aJson["invoices"][nCont]["invoiceNumber"])
		aadd(aDados,aJson["invoices"][nCont]["operationType"])
		aadd(aDados,aJson["invoices"][nCont]["emissionDate"])
		aadd(aDados,aJson["invoices"][nCont]["isOut"])
		aadd(aDados,aJson["invoices"][nCont]["sellerCode"])
		aadd(aDados,aJson["invoices"][nCont]["sellerId"])
		aadd(aDados,aJson["invoices"][nCont]["updatedAt"])
		//sefaz
		aadd(aDados,aJson["invoices"][nCont]["Sefaz"]["Key"])
		//documento
		aadd(aDados,aJson["invoices"][nCont]["receiver"]["document"])
		aadd(aDados,aJson["invoices"][nCont]["receiver"]["documentType"])
		aadd(aDados,aJson["invoices"][nCont]["receiver"]["name"])
		//order
		aadd(aDados,aJson["invoices"][nCont]["order"]["internalNumber"])
		aadd(aDados,aJson["invoices"][nCont]["order"]["originNumber"])
		aadd(aDados,aJson["invoices"][nCont]["order"]["platformNumber"])
		aadd(aDados,aJson["invoices"][nCont]["storeId"])

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
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa � GrvContd           �Autor� Allan Rabelo            � Data � 25/09/2024 ���
������������������������������������������������������������������������������������͹��
���Desc.    � Recklock na tabela ponte ZFR                                           ���
���         �                                                                        ���
���         �                                                                        ���
���         �                                                                        ���
������������������������������������������������������������������������������������͹��
���Parametr.� ExpC1= Array com JSON                                                  ���
���         � ExpC2=                                                                 ���
������������������������������������������������������������������������������������͹��
���Retorno  �                                                                        ���
���         �                                                                        ���
������������������������������������������������������������������������������������͹��
���Uso      � DUXNutrition                                                           ���
������������������������������������������������������������������������������������͹��
���                        PROJETO INFRACOMMERCE                                     ���
������������������������������������������������������������������������������������͹��
���  Programador  �  Data   � Motivo da Alteracao                                    ���
������������������������������������������������������������������������������������͹��
���              �         �                                                        ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
Static Function GrvContd(aContd)

	Local nCont := 0
	Local lRet := .T.

	//���������������������������������������������������������������������������Ŀ
    //�  Gravo Conteudo na tabela PONTE                                           �
    //�����������������������������������������������������������������������������

	For nCont := 1 to Len(aContd)
		DbSelectArea("ZFR")
		ZFR->(DBSetOrder(1))
		ZFR->(DbGoTop())
		if !(ZFR->(DbSeek(xFilial("ZFR")+PADR(aContd[nCont][15],TamSX3("ZFR_PEDIDO")[1]))))
			RecLock("ZFR",.T.)
			ZFR->ZFR_FILIAL := cFilAnt
			ZFR->ZFR_ID     := aContd[nCont][1]
			ZFR->ZFR_STATIN := aContd[nCont][2]
			ZFR->ZFR_INVOIC := aContd[nCont][3]
			ZFR->ZFR_OPER   := aContd[nCont][4]
			ZFR->ZFR_EMISSA := aContd[nCont][5]
			ZFR->ZFR_ITOUTS  := aContd[nCont][6]
			ZFR->ZFR_CODSEL := aContd[nCont][7]
			ZFR->ZFR_IDSELL := aContd[nCont][8]
			ZFR->ZFR_UPDAT  := aContd[nCont][9]
			ZFR->ZFR_CHAVE  := aContd[nCont][10]
			ZFR->ZFR_DOC    := Upper(aContd[nCont][11])
			ZFR->ZFR_DOCTIP := aContd[nCont][12]
			ZFR->ZFR_NOME   := aContd[nCont][13]
			//ZFR->ZFR_PDINT  := aContd[nCont][14]
			ZFR->ZFR_PEDIDO := aContd[nCont][15]
			ZFR->ZFR_PLATNU := aContd[nCont][16]
			ZFR->ZFR_STOREI := aContd[nCont][17]
			ZFR->ZFR_STATUS := "1"
			ZFR->ZFR_DATAPD := Date()
			ZFR->ZFR_HORAPD := Time()
			ZFR->(MsUnlock())

        /* -->Execu��o parte dois -> Envio de aviso de recebimento <--*/
			if !Empty(ZFR->ZFR_ID)
				lRet :=  U_ZWSR005(ZFR->ZFR_ID)
			endif
		endif
	Next
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
