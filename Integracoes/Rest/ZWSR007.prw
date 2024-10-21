#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} ZWSR007
Methodo POST para envio para VTEX de notas fiscais
@type function
@version 12.1.2310
@author Dux | Allan Rabel
@since 21/10/2024
@param cIdSeek, character, Id Infra
@param cPedSeek, character, Pedido Protheus
@param lJob, logical, Executa por job
/*/
User Function ZWSR007(cIdSeek, cPedSeek, lJob)
    
    Local cAlias        := GetNextAlias()
	Local cXml          := ""
    Local oXml          as object
    Local oXmlItens     as object
    Local aXmlItens     := {}
    Local jBody         as JsonObject
    Local nValTot       := 0 
    Local nCont         := 0
    Local cQuery        := ""
    Local cIdIc         := ""
    Local cChvNfe       := ""
    Local cPedLv        := ""
    Local _cFil         := FWCodFil()

    Default lJob        := .F.
    Default cIdSeek     := ""
    Default cPedSeek    := ""

    If lJob
		ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR008] - Inicio Processamento")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT"
	Endif

    If AllTrim(_cFil) == "04" //Executa somente na filial 04

        If Select( (cAlias) ) > 0
            (cAlias)->(DbCloseArea())
        EndIf

        cQuery := ""
        cQuery += " SELECT  ZFR_ID              AS IDX "                        + CRLF
        cQuery += "         ,ZFR_CHAVE          AS CHAVEX "                     + CRLF
        cQuery += "         ,ZFR_XPEDLV         AS XPEDLV "                     + CRLF
        cQuery += "         ,ZFR_STATUS         AS STATUS "                     + CRLF
        cQuery += " FROM "+RetSqlName("ZFR")+" AS ZFR "                         + CRLF
        cQuery += " WHERE ZFR.ZFR_FILIAL = '" + FWxFilial('ZFR') + "' "         + CRLF    
        cQuery += " AND ZFR_STATUS = '40'  "                                    + CRLF
        If !Empty(cIdSeek)
            cQuery += " AND ZFR_ID = '"+cIdSeek+"' "                            + CRLF
        Else
            cQuery += " AND ZFR_ID <> ' ' "                                     + CRLF
        EndIf
         If !Empty(cPedSeek)
            cQuery += " AND ZFR_PEDIDO = '"+cPedSeek+"' "                       + CRLF
        EndIf
        cQuery += " AND ZFR_XML <> ' ' "                                        + CRLF    
        //cQuery += " AND ZFR_PEDIDO = '002002'  "                                + CRLF
        cQuery += " AND ZFR.D_E_L_E_T_ <> '*'  "                                + CRLF
        cQuery += " ORDER BY ZFR_ID, ZFR_STATUS , ZFR_PEDIDO "                  + CRLF    

        // Executa a consulta.
        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

        DbSelectArea((cAlias))
        (cAlias)->(dbGoTop())
        While (cAlias)->(!EOF())

            If AllTrim((cAlias)->STATUS) == '40' //Executa somente se a nota foi escriturada

                cIdIc   := (cAlias)->IDX
                cChvNfe := (cAlias)->CHAVEX
                cPedLv  := (cAlias)->XPEDLV
            
                DbSelectArea("ZFR")
                ZFR->(DBSetOrder(2))
                If ZFR->(DbSeek(xFilial("ZFR")+PADR(cIdIc,TamSX3("ZFR_ID")[1])))
            
                    cXml := ZFR->ZFR_XML

                    If !Empty(cPedLv)
                        
                        If !( Empty(cIdIc) .And. Empty(cXml) )
                        
                            oXml        := QbrXml(cXml,cIdIc)
                            oXmlItens   := oXml:_NFEPROC:_NFE:_INFNFE:_DET
                            nValTot     := GetDToVal(oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT:_VORIG:TEXT)
                        
                            If (Valtype(oXml:_NFEPROC:_NFE:_INFNFE:_DET) <> "A")
                                aadd(aXmlItens, oXml:_NFEPROC:_NFE:_INFNFE:_DET )
                            Else
                                For nCont = 1 To Len(oXmlItens)
                                    Aadd(aXmlItens,oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont])
                                Next
                            EndIf
                            
                            jBody := GetJson(cXml ,cAlias ,oXmlItens ,cChvNfe ,nValTot ,cPedLv )

                            If !Empty(jBody)
                                If lJob
				                    zEnvPost(jBody ,cPedLv ,cIdIc)
			                    Else
				                    Processa({|| zEnvPost(jBody ,cPedLv ,cIdIc) }, "[ZWSR008] - Buscando notas faturadas na InfraCommerce", "Aguarde ...." )
			                    EndIf                               
                            EndIf 
                        EndIf
                    EndIf 
                EndIf
            EndIf
            (cAlias)->(DBSkip())
        Enddo
        (cAlias)->(DbCloseArea())
    Else
        If lJob
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR008] - Permitido executar a rotina somente na Filial 04")
		Else
			ApMsgInfo( 'Permitido executar a rotina somente na Filial 04', '[ZWSR008]' )
		Endif
    EndIf

    If lJob
	    ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR008] - Fim Processamento")
		RESET ENVIRONMENT
	Else
	    ApMsgInfo( 'Processamento Concluido com Sucesso.', '[ZWSR008]' )
	Endif

Return()


/*/{Protheus.doc} QbrXml
Funcao para quebrar XML e levar para tratar
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param cXml, character, Xml Memo
@param cIdIc, character, IdIC
@return variant, xml
/*/
Static Function QbrXml(cXml,cIdIc)

    Local cError   := ""
    Local cWarning := ""
    Local oXml     := NIL

    //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    //�  Quebro XML                                                              �
    //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    oXml := XmlParser( cXml, "_", @cError, @cWarning )

    If (oXml == NIL )

        DbSelectArea("ZFR")
        DbSetOrder(2)
        If ZFR->(DbSeek(xFilial("ZFR")+PADR(cIdIc,TamSX3("ZFR_ID")[1])))
            RecLock("ZFR",.F.)
            ZFR->ZFR_ERROR := ("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
            ZFR->ZFR_STERRO := "50"
            ZFR->(MsUnlock())
        EndIf

    Endif

Return(oXml)


/*/{Protheus.doc} GetJson
Funcao para montar o JSON  
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param cXml, character, xml
@param cAlias, character, alias
@param aXmlItens, array, itens XML
@param cChave, character, Chave
@param nValTot, numeric, total nota
@param cPedLv, character, pedido Vtex
@return variant, Body
/*/
Static Function GetJson(cXml,cAlias,aXmlItens,cChave,nValTot,cPedLv)

    Local jBody as JsonObject
    Local yX := 0
    Local nLength := 0

    JBody                   := JSONObject():New()
    JBody["type"]           := "Output"
    JBody["issuanceDate"]   := ZFR->ZFR_EMISSA
    JBody["invoiceNumber"]  := alltrim(cPedLv)
    JBody["invoiceValue"]   := nValTot
    JBody["Items"]          := {}
    nLength := 0
    For yX :=1 To Len(aXmlItens)
        nLength++
        aAdd(jBody["Items"], JSONObject():New() )
        jBody["Items"][nLength]["id"]             := aXmlItens[nLength]:_Prod:_cProd:Text
        jBody["Items"][nLength]["price"]          := GetDToVal(aXmlItens[nLength]:_Prod:_vProd:Text)
        jBody["Items"][nLength]["quantity"]       := GetDToVal(aXmlItens[nLength]:_Prod:_QCOM:Text)
        jBody["Items"][nLength]["description"]    := aXmlItens[nLength]:_Prod:_xProd:Text
    next yX
    JBody["invoiceKey"]      := cChave
    JBody["invoiceUrl"]      := ""
    JBody["embeddedInvoice"] := cXml
    JBody["courier"]         := ""
    JBody["trackingNumber"]  := ""
    JBody["trackingUrl"]     := ""
    JBody["dispatchedDate"]  := ""

    jBody := FwJsonSerialize(jBody,.f.,.f.,.T.)

Return(jBody)

/*/{Protheus.doc} zEnvPost
Envia o post para a VTex
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param jBody, json, Body
@param cPedLv, character, Pedido Vtex
@param cIdIc, character, Id IC
/*/
Static Function zEnvPost(jBody,cPedLv,cIdIc)

	Local cURL      := SuperGetMV("DUX_API013"  ,.F.,"https://duxnutrition.vtexcommercestable.com.br/api/oms/pvt/orders/")
	Local cEnd      := SuperGetMV("DUX_API014"  ,.F.,"/invoice")
	Local cApiKey   := "X-VTEX-API-AppKey: "    + AllTrim(SuperGetMV("DUX_API015"  ,.F.,"vtexappkey-duxnutrition-ANSENB"))
	Local cToken    := "X-VTEX-API-AppToken: "  + AllTrim(SuperGetMv("DUX_API016"  ,.F.,"NWMCEYASEVOEVRBYGCVTNQOZMBPWIPAGVLOFMVYZNUHHXCODMDTZQUBEABTKTLDLVPKUJZGYXUWNRTDMJTHZTJEOLPINEAWURSEWWEQCUORHHBRLSAKDAKJFDSNTBLLL"))
	Local oOBj
	Local aHeader   := {}
	Local cResponse
	Local cHeaderRet as char

     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Monto cabe�alho para envio a POST da VETEX                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� 
	aAdd(aHeader    ,"Accept: application/json;charset=UTF-8")
	aadd(aHeader    ,'Content-Type: application/json;charset=UTF-8')
	aadd(aHeader    ,cApiKey)
    aadd(aHeader    ,cToken)

	cResponse := HttpPost(cURL+AllTrim(cPedLv)+cEnd ,"" ,jBody ,120 ,aHeader ,@cHeaderRet)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Pega o JSON e decode64 nele para gravar na ZFR                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� 
	If !Empty(cResponse)
	
        FWJSONDESERIALIZE(cResponse,@oObj)
      
        DbSelectArea("ZFR")
        ZFR->(DBSetOrder(2))
        If ZFR->(DbSeek(xFilial("ZFR")+PADR(cIdIc,TamSX3("ZFR_ID")[1])))

            If !("Error"$cResponse)
                RecLock("ZFR",.F.)
                    ZFR->ZFR_STATUS := "50"
                    ZFR->ZFR_DTENVX := Date()
                    ZFR->ZFR_HRENVX := Time()
                    ZFR->ZFR_XPEDLV := cPedLv
                    ZFR->ZFR_DTRETV := oObj:Date 
                    ZFR->ZFR_OIRETV := oObj:Orderid 
                    ZFR->ZFR_PRRETV := oObj:Receipt 
                ZFR->(MsUnlock())
            Else
                RecLock("ZFR",.F.)
                    ZFR->ZFR_ERROR := oObj:message 
                    ZFR->ZFR_STERRO := "50"
                    ZFR->ZFR_STATUS := "99"
                ZFR->(MsUnlock())
            EndIf 
        EndIf
    EndIf 

Return()

