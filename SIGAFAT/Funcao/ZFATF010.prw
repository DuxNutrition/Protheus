//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} ZFATF010
Reprocessa ID IC de acordo com o Status
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 22/10/2024
@param cIdIC, character, Id da IC
/*/    
User Function ZFATF010( cIdIC )

    Local aRet          := {}
    Local cQryTMP       := ""
	Local cAlsTMP       := GetNextAlias()
    Private aParamBox   := {}
	 
    Default cIdIC       := ""

    If Empty(cIdIC)

        AAdd(aParamBox,{ 1, "Pedido De:         ", Space(6)                     , "!@"                          , ""    , "SC5"     ,"" , 040      ,.F.})
        AAdd(aParamBox,{ 1, "Pedido Ate:        ", "ZZZZZZ"                     , "!@"                          , ""    , "SC5"     ,"" , 040      ,.T.})
        AAdd(aParamBox,{ 1, "ID IC De:          ", Space(24)                    , ""                            , ""    , ""        ,"" , 100      ,.F.})
        AAdd(aParamBox,{ 1, "ID IC Ate:         ", "ZZZZZZZZZZZZZZZZZZZZZZZZ"   , ""                            , ""    , ""        ,"" , 100      ,.T.})
        AAdd(aParambox,{ 1, "Data Inclusão De:  ", CriaVar('F1_DTDIGIT')        , PesqPict("SF1","F1_DTDIGIT")  , ""    , ""        ,"" , 060      ,.T.}) 
        AAdd(aParambox,{ 1, "Data Inclusão Ate: ", CriaVar('F1_DTDIGIT')        , PesqPict("SF1","F1_DTDIGIT")  , ""    , ""        ,"" , 060      ,.T.}) 

        If ParamBox(aParamBox,"Preencha os Parametros para Processar Integração...",@aRet)

            
          	If Select( (cAlsTMP) ) > 0
		        (cAlsTMP)->(DbCloseArea())
	        EndIf   

            cQryTMP := ""
            cQryTMP := " SELECT ZFR.ZFR_ID FROM "+RetSqlName("ZFR")+" ZFR "                         + CRLF
            cQryTMP += " WHERE ZFR.ZFR_FILIAL = '" + FWxFilial('ZFR') + "'  "                       + CRLF
            cQryTMP += " AND ZFR.ZFR_PEDIDO BETWEEN '"+aRet[01]+"' AND '"+aRet[02]+"' "			    + CRLF
            cQryTMP += " AND ZFR.ZFR_ID BETWEEN '"+aRet[03]+"' AND '"+aRet[04]+"' "			        + CRLF
            cQryTMP += " AND ZFR.ZFR_DATAPD BETWEEN '"+DToS(aRet[05])+"' AND '"+DToS(aRet[06])+"' "	+ CRLF
            cQryTMP += " AND RTRIM(ZFR.ZFR_STATUS) <> '40'  "			                            + CRLF
            cQryTMP += " AND ZFR.ZFR_XML <> ' '  "     					                            + CRLF
            cQryTMP += " AND ZFR.D_E_L_E_T_ <> '*'  "					                            + CRLF
            cQryTMP += " ORDER BY ZFR.ZFR_CHAVE "		                                            + CRLF

            // Executa a consulta.
            DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAlsTMP, .T., .T. )
            
            DbSelectArea((cAlsTMP))
            (cAlsTMP)->(dbGoTop())
            While (cAlsTMP)->(!Eof())
                
                Processa({|| ZF01F010((cAlsTMP)->ZFR_ID) }, "[ZFATF010] - Processando Integração", "Aguarde ...." )
                
                (cAlsTMP)->(DbSkip())    
            EndDo
            (cAlsTMP)->(DbCloseArea())         

        EndIf

    Else

        Processa({|| ZF01F010(cIdIC) }, "[ZFATF010] - Processando Integração", "Aguarde ...." )

    EndIf

    ApMsgInfo("Processo finalizado !!!","[ ZFATF010 ]")

Return()

/*/{Protheus.doc} ZF01F010
Exporta o XML
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 22/10/2024
@param cIdIC, character, Id IC
/*/
Static Function ZF01F010( cIdIC )

    Local lJob := .F.
    
    //Se tiver documento
    If !Empty(cIdIC)

        //Grava o erro na ZFR
        DbSelectArea("ZFR")
        ZFR->( DBSetOrder( 2 ) )
        IF  ZFR->(DbSeek(xFilial("ZFR")+PADR(cIdIC,TamSX3("ZFR_ID")[1])))

            If ( AllTrim(ZFR->ZFR_STATUS) == "01" .Or. AllTrim(ZFR->ZFR_STATUS) == "C1" ) .Or. ( ( AllTrim(ZFR->ZFR_STATUS) == "99" .And. AllTrim(ZFR->ZFR_STERRO) == "20" ) .Or. AllTrim(ZFR->ZFR_STATUS) == "99" .And. AllTrim(ZFR->ZFR_STERRO) == "C2" ) //Nota Disponibilizada ou Cancelamento Disponibilizado

                FWMsgRun(,{|| U_ZWSR005(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob) },,"Enviando a confirmação de Recebimento da Invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")
            
            ElseIf ( AllTrim(ZFR->ZFR_STATUS) == "20" ) .Or. ( AllTrim(ZFR->ZFR_STATUS) == "99" .And. AllTrim(ZFR->ZFR_STERRO) == "30" ) //Confirmação realizada

                FWMsgRun(,{|| U_ZWSR006(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob) },,"Processando a leitura do XML da Invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")

            ElseIf ( AllTrim(ZFR->ZFR_STATUS) == "30" .And. AllTrim(ZFR->ZFR_STATIN) == "authorized" ) .Or. ( AllTrim(ZFR->ZFR_STATUS) == "99" .And. AllTrim(ZFR->ZFR_STERRO) == "40" .And. AllTrim(ZFR->ZFR_STATIN) == "authorized" ) //Xml gravado e nota autorizada

                FWMsgRun(,{|| U_ZFATF007(ZFR->ZFR_ID, ZFR->ZFR_PEDIDO, lJob) },,"Processando a escrituracao da invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")
            EndIf

        EndIf
                    
    EndIf
    
Return()
