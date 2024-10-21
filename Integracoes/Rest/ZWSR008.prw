#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ ZWSR008.prw บ Autor ณ Allan Rabelo บ Data ณ 17/10/2024     บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Methodo POST para envio para VTEX de notas fiscais         บฑฑ
//ฑฑบ          ณ Fun็ใo de faturamento                                      บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

User Function ZWSR008()
    Local lRet   := .F.
    Local cAlias := Query50()
    Local cXml   := ""
    Local cId    := ""
    Local cChave := ""
    Local oXml  as object
    Local oXmlItens as object
    Local aXmlItens := {}
    Local jBody as JsonObject
    Local cNumPed := ""
    Local nValTot := 0 
    Local nCont := 0

    While (cAlias)->(!EOF())
        cId  := (cAlias)->(IDX)
        cChave := (cAlias)->(CHAVEX)
        if !(Select('ZFR') > 0)
            DbSelectArea("ZFR")
            ZFR->(DBSetOrder(2))
            ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))
	    endif 
        if !(Select('ZFR') > 0)
            DbSelectArea("SC5")
            SC5->(DBSetOrder(1))
            SC5->(DbSeek(xFilial("SC5")+PADR((cAlias)->(PED),TamSX3("ZFR_PEDIDO")[1])))
        endif 
        cXml := ZFR->ZFR_XML
        cNumped := (cAlias)->(XPEDVL)
        if !Empty(cNumPed)
            if (!Empty(cId) .and. !Empty(cXml))
                oXml := QbrXml(cXml,cId)
                oXmlItens := oXml:_NFEPROC:_NFE:_INFNFE:_DET
                nValTot := GetDToVal(oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT:_VORIG:TEXT)
                if (Valtype(oXml:_NFEPROC:_NFE:_INFNFE:_DET) <> "A")
                    aadd(aXmlItens, oXml:_NFEPROC:_NFE:_INFNFE:_DET )
                else
                    for nCont = 1 To Len (oXmlItens)
                        aadd(aXmlItens,oXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont])
                    next
                endif
                jBody := GetJson(cXml,cAlias,oXmlItens,cChave,nValTot,cNumPed)
                if !Empty(jBody)
                    U_ZWSR009(jBody,cNumped,cId)
                endif 
            endif
        endif 
        ZFR->(dbCloseArea())
        (cAlias)->(DBSkip())
    Enddo
Return(lRet)


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ Query50 บ   Autor ณ Allan Rabelo บ Data ณ 28/09/2024       บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Query para encontrar as notas faturadas                    บฑฑ
//ฑฑบ          ณ                                                            บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function Query50()
    Local cQuery := ""
    Local lRet := .F.
    Local cAliasFt := GetNextAlias()

    cQuery := " SELECT ZFR_STATUS as STATUSX, ZFR_ID AS IDX, R_E_C_N_O_ AS RECNO, ZFR_PEDIDO AS PED, ZFR_CHAVE AS CHAVEX,  "
    cQuery += "  ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZFR_XML)),'') AS XMLX, ZFR_XPEDLV AS XPEDVL "
    cQuery += " FROM "+RetSqlName("ZFR")+" AS ZFR "
    cQuery += " WHERE ZFR.D_E_L_E_T_ = ''  "
    cQuery += " AND "
    cQuery += " ZFR_STATUS = '40'  AND ZFR_ID <> '' AND ZFR_XML <> '' "
    cQuery += " ORDER BY ZFR_ID, ZFR_STATUS , ZFR_PEDIDO"

    TcQuery cQuery New Alias (cAliasFt)

    if (cAliasFt)->(!Eof())
        lRet := .T.
    endif

Return(cAliasFt)

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ QbrXml บ   Autor ณ Allan Rabelo บ Data ณ  18/10/2024       บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Funcao para quebrar XML e levar para tratar                บฑฑ
//ฑฑบ          ณ   Param 1 = XML                                            บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function QbrXml(cXml,cId)
    Local cError   := ""
    Local cWarning := ""
    Local oXml     := NIL
    Local lRet     := .F.
    Local cCnpj    := ""
    Local cChave   := ""

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
    //ณ  Quebro XML                                                              ณ
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    oXml := XmlParser( cXml, "_", @cError, @cWarning )
    If (oXml == NIL )
        DbSelectArea("ZFR")
        DbSetOrder(2)
        if ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))
            RecLock("ZFR",.F.)
            ZFR->ZFR_ERROR := ("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
            ZFR->ZFR_STERRO := "50"
            ZFR->(MsUnlock())
        endif
    Endif
Return(oXml)


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ GetJson  บ Autor ณ Allan Rabelo บ Data ณ  18/10/2024       บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Funcao para montar o JSON                                  บฑฑ
//ฑฑบ          ณ   Param 1 = XML                                            บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function GetJson(cXml,cAlias,aXmlItens,cChave,nValTot,cNumPed)
    Local jBody as JsonObject
    Local yX := 0
    Local nLength := 0

    JBody                   := JSONObject():New()
    JBody["type"]           := "Output"
    JBody["issuanceDate"]   := ZFR->ZFR_EMISSA
    JBody["invoiceNumber"]  := alltrim(cNumPed)
    JBody["invoiceValue"]   := nValTot
    JBody["Items"]          := {}
    nLength := 0
    For yX :=1 To Len (aXmlItens)
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

