//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} ZFATF009
Exporta o XML escriturado
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 22/10/2024
@param cIdIC, character, Id da IC
/*/    
User Function ZFATF009( cIdIC, cTipo )

    Local aRet          := {}
    Local cQryTMP       := ""
	Local cAlsTMP       := GetNextAlias()
    Private aParamBox   := {}
	 
    Default cIdIC       := ""
    Default cTipo       := "1"

    If Empty(cIdIC)

        AAdd(aParamBox,{ 1, "Pedido De:         ", Space(6)                     , "!@"                          , ""    , "SC5"     ,"" , 040      ,.F.})
        AAdd(aParamBox,{ 1, "Pedido Ate:        ", "ZZZZZZ"                     , "!@"                          , ""    , "SC5"     ,"" , 040      ,.T.})
        AAdd(aParamBox,{ 1, "ID IC De:          ", Space(24)                    , ""                            , ""    , ""        ,"" , 100      ,.F.})
        AAdd(aParamBox,{ 1, "ID IC Ate:         ", "ZZZZZZZZZZZZZZZZZZZZZZZZ"   , ""                            , ""    , ""        ,"" , 100      ,.T.})
        AAdd(aParambox,{ 1, "Data Inclus�o De:  ", CriaVar('F1_DTDIGIT')        , PesqPict("SF1","F1_DTDIGIT")  , ""    , ""        ,"" , 060      ,.T.}) 
        AAdd(aParambox,{ 1, "Data Inclus�o Ate: ", CriaVar('F1_DTDIGIT')        , PesqPict("SF1","F1_DTDIGIT")  , ""    , ""        ,"" , 060      ,.T.}) 
        aAdd(aParamBox,{ 2 ,"Exportar:          ", 1 ,{"1 - XML","2 - ERRO","3 - AMBOS"}    ,40,"",.F.})

        If ParamBox(aParamBox,"Preencha os Parametros para Exportar os XML(s)...",@aRet)

            cTipo   := aRet[07]
            
          	If Select( (cAlsTMP) ) > 0
		        (cAlsTMP)->(DbCloseArea())
	        EndIf   

            cQryTMP := ""
            cQryTMP := " SELECT ZFR.ZFR_ID FROM "+RetSqlName("ZFR")+" ZFR "                         + CRLF
            cQryTMP += " WHERE ZFR.ZFR_FILIAL = '" + FWxFilial('ZFR') + "'  "                       + CRLF
            cQryTMP += " AND ZFR.ZFR_PEDIDO BETWEEN '"+aRet[01]+"' AND '"+aRet[02]+"' "			    + CRLF
            cQryTMP += " AND ZFR.ZFR_ID BETWEEN '"+aRet[03]+"' AND '"+aRet[04]+"' "			        + CRLF
            cQryTMP += " AND ZFR.ZFR_DATAPD BETWEEN '"+DToS(aRet[05])+"' AND '"+DToS(aRet[06])+"' "	+ CRLF
            cQryTMP += " AND ZFR.ZFR_XML <> ' '  "     					                            + CRLF
            cQryTMP += " AND ZFR.ZFR_STATUS IN ('30','40','99' )  " 	                            + CRLF
            cQryTMP += " AND ZFR.D_E_L_E_T_ <> '*'  "					                            + CRLF
            cQryTMP += " ORDER BY ZFR.ZFR_CHAVE "		                                            + CRLF

            // Executa a consulta.
            DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAlsTMP, .T., .T. )
            
            DbSelectArea((cAlsTMP))
            (cAlsTMP)->(dbGoTop())
            While (cAlsTMP)->(!Eof())
                
                Processa({|| ZF01F009((cAlsTMP)->ZFR_ID, cTipo) }, "[ZFATF009] - Exportando XML(s)", "Aguarde ...." )
                
                (cAlsTMP)->(DbSkip())    
            EndDo
            (cAlsTMP)->(DbCloseArea())         

        EndIf

    Else

        Processa({|| ZF01F009(cIdIC ,cTipo) }, "[ZFATF009] - Exportando XML(s)", "Aguarde ...." )

    EndIf

    ApMsgInfo("Processo finalizado !!!","[ ZFATF009 ]")

Return()

/*/{Protheus.doc} ZF01F009
Exporta o XML
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 22/10/2024
@param cIdIC, character, Id IC
/*/
Static Function ZF01F009( cIdIC, cTipo )
    
    Local cTextoXML     := ""
    Local cTextoTXT     := ""
    Local cPastaXML     := "C:\Xml_Infracommerce\"
    Local cPastaTXT     := "C:\Xml_Infracommerce\"

    If !ExistDir( cPastaXML )
		MakeDir( cPastaXML )
		ApMsgInfo("Pasta para salvar o(s) Xml(s) criada com sucesso."+CRLF+"Caminho: "+cPastaXML,"[ ZFATF009 ]")
	Endif
    If !ExistDir( cPastaTXT )
		MakeDir( cPastaTXT )
		ApMsgInfo("Pasta para salvar o(s) Txt(s) criada com sucesso."+CRLF+"Caminho: "+cPastaTXT,"[ ZFATF009 ]")
	Endif
    //Se tiver documento
    If !Empty(cIdIC)

        //Grava o erro na ZFR
        DbSelectArea("ZFR")
        ZFR->( DBSetOrder( 2 ) )
        IF  ZFR->(DbSeek(xFilial("ZFR")+PADR(cIdIC,TamSX3("ZFR_ID")[1])))

            If AllTrim(ZFR->ZFR_STATUS) $ "30|40|99"

                If AllTrim(cTipo) == "1 - XML" //Exporta XML

                    cPastaXML := cPastaXML + "XML_" + AllTrim(ZFR->ZFR_ID) +"_" + AllTrim(ZFR->ZFR_CHAVE) + ".xml"
                    cTextoXML := ZFR->ZFR_XML

                    If !Empty(cTextoXML) 
                        
                        //Gera o arquivo
                        oFileXML := FWFileWriter():New(cPastaXML, .T.)
                        oFileXML:SetEncodeUTF8(.T.)
                        oFileXML:Create()
                        oFileXML:Write(cTextoXML)
                        oFileXML:Close()

                    Else
                        ApMsgInfo("Xml n�o encontrado, verifique as parametriza��es","[ ZFATF009 ]")
                    EndIf

                ElseIf AllTrim(cTipo) == "2 - ERRO" //Exporta Erro

                    cPastaTXT := cPastaTXT + "ERRO_" + AllTrim(ZFR->ZFR_ID) + ".txt"
                    cTextoTXT := ZFR->ZFR_ERROR

                    If !Empty(cTextoTXT) 
                        
                        //Gera o arquivo
                        oFileXML := FWFileWriter():New(cPastaTXT, .T.)
                        oFileXML:SetEncodeUTF8(.T.)
                        oFileXML:Create()
                        oFileXML:Write(cTextoTXT)
                        oFileXML:Close()

                    Else
                        ApMsgInfo("Erro n�o encontrado, verifique as parametriza��es","[ ZFATF009 ]")
                    EndIf

                ElseIf AllTrim(cTipo) == "3 - AMBOS" //Exporta Erro

                    cPastaXML := cPastaXML + "XML_" + AllTrim(ZFR->ZFR_ID) +"_" + AllTrim(ZFR->ZFR_CHAVE) + ".xml"
                    cTextoXML := ZFR->ZFR_XML

                    If !Empty(cTextoXML) 
                        
                        //Gera o arquivo
                        oFileXML := FWFileWriter():New(cPastaXML, .T.)
                        oFileXML:SetEncodeUTF8(.T.)
                        oFileXML:Create()
                        oFileXML:Write(cTextoXML)
                        oFileXML:Close()

                    Else
                        ApMsgInfo("Xml n�o encontrado, verifique as parametriza��es","[ ZFATF009 ]")
                    EndIf

                    cPastaTXT := cPastaTXT + "ERRO_" + AllTrim(ZFR->ZFR_ID) + ".txt"
                    cTextoTXT := ZFR->ZFR_ERROR

                    If !Empty(cTextoTXT) 
                        
                        //Gera o arquivo
                        oFileXML := FWFileWriter():New(cPastaTXT, .T.)
                        oFileXML:SetEncodeUTF8(.T.)
                        oFileXML:Create()
                        oFileXML:Write(cTextoTXT)
                        oFileXML:Close()

                    Else
                        ApMsgInfo("Erro n�o encontrado, verifique as parametriza��es","[ ZFATF009 ]")
                    EndIf

                EndIf

            EndIf

        EndIf
                    
    EndIf
    
Return()
