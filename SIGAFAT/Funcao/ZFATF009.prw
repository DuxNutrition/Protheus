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
User Function ZFATF009( cIdIC )

    Local aRet          := {}
    Local cQryTMP       := ""
	Local cAlsTMP       := GetNextAlias()
    Private aParamBox   := {}
	 
    Default cIdIC       := ""

    If Empty(cIdIC)

        AAdd(aParamBox,{ 1, "Pedido De:         ", Space(6)                 , "!@"                          , ""    , "SC5"  ,"" , 040      ,.F.})
        AAdd(aParamBox,{ 1, "Pedido Ate:        ", "ZZZZZZ"                 , "!@"                          , ""    , "SC5"  ,"" , 040      ,.T.})
        AAdd(aParambox,{ 1, "Data Inclusão De:  ", CriaVar('F1_DTDIGIT')    , PesqPict("SF1","F1_DTDIGIT")  , ""    , ""    , "" , 060      ,.T.}) 
        AAdd(aParambox,{ 1, "Data Inclusão Ate: ", CriaVar('F1_DTDIGIT')    , PesqPict("SF1","F1_DTDIGIT")  , ""    , ""    , "" , 060      ,.T.}) 

        If ParamBox(aParamBox,"Preencha os Parametros para Exportar os XML(s)...",@aRet)

            
          	If Select( (cAlsTMP) ) > 0
		        (cAlsTMP)->(DbCloseArea())
	        EndIf   

            cQryTMP := ""
            cQryTMP := " SELECT ZFR.ZFR_ID FROM "+RetSqlName("ZFR")+" ZFR "                         + CRLF
            cQryTMP += " WHERE ZFR.ZFR_FILIAL = '" + FWxFilial('ZFR') + "'  "                       + CRLF
            cQryTMP += " AND ZFR.ZFR_PEDIDO BETWEEN '"+aRet[01]+"' AND '"+aRet[02]+"' "			    + CRLF
            cQryTMP += " AND ZFR.ZFR_DATAPD BETWEEN '"+DToS(aRet[03])+"' AND '"+DToS(aRet[04])+"' "	+ CRLF
            cQryTMP += " AND ZFR.ZFR_XML <> ' '  "     					                            + CRLF
            cQryTMP += " AND ZFR.ZFR_STATUS IN ('30','40','99' )  " 	                            + CRLF
            cQryTMP += " AND ZFR.D_E_L_E_T_ <> '*'  "					                            + CRLF
            cQryTMP += " ORDER BY ZFR.ZFR_CHAVE "		                                            + CRLF

            // Executa a consulta.
            DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryTMP), cAlsTMP, .T., .T. )
            
            DbSelectArea((cAlsTMP))
            (cAlsTMP)->(dbGoTop())
            While (cAlsTMP)->(!Eof())
                
                Processa({|| ZF01F009((cAlsTMP)->ZFR_ID) }, "[ZFATF009] - Exportando XML(s)", "Aguarde ...." )
                
                (cAlsTMP)->(DbSkip())    
            EndDo
            (cAlsTMP)->(DbCloseArea())         

        EndIf

    Else

        Processa({|| ZF01F009(cIdIC) }, "[ZFATF009] - Exportando XML(s)", "Aguarde ...." )

    EndIf

    ApMsgInfo("Processo finalizado !!!","[ ZFATF009 ]")

/*/{Protheus.doc} ZF01F009
Exporta o XML
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 22/10/2024
@param cIdIC, character, Id IC
/*/Return()
Static Function ZF01F009( cIdIC )
    
    Local cTextoXML     := ""
    Local cArqXML       := "C:\Xml_Infracommerce\"

    If !ExistDir( cArqXML )
		MakeDir( cArqXML )
		ApMsgInfo("Pasta para salvar o(s) boleto(s) criada com sucesso."+CRLF+"Caminho: "+cArqXML,"[ ZFATF009 ]")
	Endif
    //Se tiver documento
    If !Empty(cIdIC)

        //Grava o erro na ZFR
        DbSelectArea("ZFR")
        ZFR->( DBSetOrder( 2 ) )
        IF  ZFR->(DbSeek(xFilial("ZFR")+PADR(cIdIC,TamSX3("ZFR_ID")[1])))

            If AllTrim(ZFR->ZFR_STATUS) $ "30|40|99"

                cArqXML   := cArqXML + ZFR->ZFR_CHAVE + ".xml"

                cTextoXML := ZFR->ZFR_XML

                If !Empty(cTextoXML)
                    
                    //Gera o arquivo
                    oFileXML := FWFileWriter():New(cArqXML, .T.)
                    oFileXML:SetEncodeUTF8(.T.)
                    oFileXML:Create()
                    oFileXML:Write(cTextoXML)
                    oFileXML:Close()

                Else
                    ApMsgInfo("Xml não encontrado, verifique as parametrizações","[ ZFATF009 ]")
                EndIf

            EndIf

        EndIf
                    
    EndIf
    
Return()
