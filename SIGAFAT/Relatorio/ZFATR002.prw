#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#define CRLF chr(13) + chr(10)  

/*{Protheus.doc} 
Relatório de Saídas ME.
@author Jedielson Rodrigues
@since 29/07/2024
@history 
@version P11,P12
@database MSSQL
*/

User Function ZFATR002()
    
	Local	aArea 		:= FwGetArea()
	Local	oReport
	Local	aPergs		:= {}
	Local	nNumNF		:= Space(TamSX3('D2_DOC')[1]) 
	Local	nSerieNF	:= Space(TamSX3('D2_SERIE')[1])
	Local	dDtEmiss	:= Ctod(Space(8)) //Data de emissao de NF
    Local   cCod        := Space(TamSX3('B1_COD')[1])
	
	Private cTabela 	:= GetNextAlias()

 	aAdd(aPergs, {1,"De Numero NF"			,nNumNF		,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,50,.F.})            //MV_PAR01
	aAdd(aPergs, {1,"Ate Numero NF"		    ,nNumNF	    ,/*Pict*/,MV_PAR02 > MV_PAR01,/*F3*/,/*When*/,50,.F.})  //MV_PAR02
    aAdd(aPergs, {1,"Serie NF"				,nSerieNF	,/*Pict*/,/*Valid*/	,/*F3*/,/*When*/,50,.F.})           //MV_PAR03
    aAdd(aPergs, {1,"Dt emissao de"			,dDtEmiss	,/*Pict*/,/*Valid*/	,/*F3*/,/*When*/,50,.F.})           //MV_PAR04
	aAdd(aPergs, {1,"Dt emissao ate"		,dDtEmiss	,/*Pict*/,MV_PAR04 > MV_PAR05,/*F3*/,/*When*/,50,.F.})  //MV_PAR05
    aAdd(aPergs, {1,"De Produto"			,cCod	    ,/*Pict*/,/*Valid*/,"SB1",/*When*/,50,.F.})             //MV_PAR06
	aAdd(aPergs, {1,"Ate Produto"		    ,cCod	    ,/*Pict*/,MV_PAR06 > MV_PAR07,"SB1",/*When*/,50,.F.})   //MV_PAR07
	
	If ParamBox(aPergs, "Informe os parametros para Nota Fiscal de saida", , , , , , , , , .F., .F.)
		oReport := fReportDef()
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)
Return

Static Function fReportDef() //Definições do relatório

	Local oReport
	Local oSection := Nil
	
	oReport:= TReport():New("ZFATR002",;				// --Nome da impressão
                            "Relatorio de Saidas ME",;  // --Título da tela de parâmetros
                            ,;      		// --Grupo de perguntas na SX1, ao invés das pereguntas estou usando Parambox
                            {|oReport|  ReportPrint(oReport),};
                            ) // --Descrição do relatório
	
	oReport:SetLandScape(.T.)			//--Orientação do relatório como paisagem.
	oReport:HideParamPage()    	        //--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()        		//--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()        		//--Define que não será impresso o rodapé padrão da página
	oReport:SetPreview(.T.)   			//--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2)   		//--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	//oReport:oPage:SetPaperSize(9)		//--Define impressão no papel A4

	oReport:lParamPage := .T. //Página de parâmetros?
	
	//Impressão por planilhas
	oReport:SetDevice(4)        		//--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
	//oReport:SetTpPlanilha({.T., .T., .T., .T.}) //Formato Tabela {Normal, Suprimir linhas brancas e totais, Formato de Tabela, Formato de Tabela xlsx}
 
	//Definições de fonte:
	//oReport:SetLineHeight(50) 			//--Espaçamento entre linhas
	//oReport:cFontBody := 'Arial' 			//--Tipo da fonte
	//oReport:nFontBody := 10				//--Tamanho da fonte
	//oReport:SetEdit(.T.) 
	//Pergunte(oReport:GetParam(),.F.) 	//--Adicionar as perguntas na SX1

	oSection := TRSection():New(oReport,; 	//--Criando a seção de dados
		OEMToAnsi("Relatorio de Saidas ME"),;
		{cTabela})
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
		
	//TRCell():New(oSection2,"CR_DATALIB"	,"SCR"	,'Data Aprov SC'	,/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)
	//--Colunas do relatório
	TRCell():New( oSection  ,"D2_FILIAL"  	,cTabela ,"Filial"			,PesqPict("SD2","D2_FILIAL")	,TamSx3("D2_FILIAL")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"D2_EMISSAO"  	,cTabela ,"Emissao"			,PesqPict("SD2","D2_EMISSAO")	,TamSx3("D2_EMISSAO")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "CENTER"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"D2_PEDIDO"    ,cTabela ,"Pedido"	        ,PesqPict("SD2","D2_PEDIDO")	,TamSx3("D2_PEDIDO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"B1_COD"       ,cTabela ,"Produto"			,PesqPict("SB1","B1_COD")		,TamSx3("B1_COD")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DESCRI"     	,cTabela ,"Descricao"	    ,								,TamSx3("B1_DESC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_QUANT"     ,cTabela ,"Quantidade"		,PesqPict("SD2","D2_QUANT")    	,TamSx3("D2_QUANT")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_TOTAL"     ,cTabela ,"Vlr.Total"		,PesqPict("SD2","D2_TOTAL")    	,TamSx3("D2_TOTAL")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F2_VALBRUT"   ,cTabela ,"Vlr.Bruto"		,PesqPict("SF2","F2_VALBRUT")   ,TamSx3("F2_VALBRUT")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_DOC"       ,cTabela ,"Num. Docto."		,PesqPict("SD2","D2_DOC")		,TamSx3("D2_DOC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_SERIE"     ,cTabela ,"Série"	        ,PesqPict("SD2","D2_SERIE")		,TamSx3("D2_SERIE")[1]	    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_CLIENTE"   ,cTabela ,"Cliente"			,PesqPict("SD2","D2_CLIENTE")	,TamSx3("D2_CLIENTE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_NOME"      ,cTabela ,"Desc.Cliente"	,PesqPict("SA1","A1_NOME")		,55	    					, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_CEP"  	    ,cTabela ,"CEP"		        ,PesqPict("SA1","A1_CEP")		,TamSx3("A1_CEP")[1]	    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"A1_EST"       ,cTabela ,"UF"	            ,PesqPict("SA1","A1_EST")		,TamSx3("A1_EST")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"C5_VOLUME1"   ,cTabela ,"Volume"	        ,PesqPict("SC5","C5_VOLUME1")	,TamSx3("C5_VOLUME1")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"C5_PBRUTO"    ,cTabela ,"Peso Bruto"		,PesqPict("SC5","C5_PBRUTO")	,TamSx3("C5_PBRUTO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"C5_XITEMCC"   ,cTabela ,"Canal"  		    ,PesqPict("SC5","C5_XITEMCC")	,TamSx3("C5_XITEMCC")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "LEFT"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    
Return oReport

Static Function ReportPrint(oReport)

	Local aArea 	:= FWGetArea()
	Local cQry		:= ""
	Local oSectDad  := Nil
	Local nAtual	:= 0
	Local nTotal	:= 0
	
	//Pegando as secoes do relatório
	oSectDad := oReport:Section(1) //Primeira seção disponível

	If Select( cTabela ) > 0
		(cTabela)->(DbCloseArea())
	EndIf

    cQry := " SELECT "                                                  	+ CRLF
    cQry += "   D2_FILIAL "                                             	+ CRLF
    cQry += "   ,D2_EMISSAO "                                				+ CRLF
	cQry += "   ,D2_PEDIDO "                                            	+ CRLF
    cQry += "   ,B1_COD "                                               	+ CRLF
	cQry += "   ,B1_DESC AS DESCRI "                                        + CRLF
    cQry += "   ,D2_QUANT "                                             	+ CRLF
	cQry += "   ,D2_TOTAL "                                             	+ CRLF
	cQry += "   ,F2_VALBRUT "                                             	+ CRLF
	cQry += "   ,D2_DOC "                                               	+ CRLF
    cQry += "   ,D2_SERIE "                                             	+ CRLF
	cQry += "	,D2_CLIENTE "                                           	+ CRLF
	cQry += "	,A1_NOME "                                              	+ CRLF
	cQry += "	,A1_CEP "                                               	+ CRLF
	cQry += "	,A1_EST "                                               	+ CRLF
	cQry += "	,C5_VOLUME1 "                                           	+ CRLF
	cQry += "	,C5_PBRUTO "                                            	+ CRLF
	cQry += "	,C5_XITEMCC "                                          		+ CRLF
    cQry += " FROM " + RetSqlName("SD2") + " AS SD2 WITH(NOLOCK) "          + CRLF
	cQry += "   INNER JOIN " + RetSqlName("SF2") + " SF2 WITH(NOLOCK) "     + CRLF
	cQry += "       ON SF2.F2_FILIAL = '" + FWxFilial("SF2") + "' "         + CRLF
	cQry += "       AND SF2.F2_DOC = SD2.D2_DOC "        					+ CRLF
	cQry += "       AND SF2.F2_SERIE = SD2.D2_SERIE "                       + CRLF
	cQry += "       AND SF2.D_E_L_E_T_ = ' ' "                              + CRLF
	cQry += "   INNER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) "     + CRLF
	cQry += "       ON SC5.C5_FILIAL = '" + FWxFilial("SC5") + "' "         + CRLF
	cQry += "       AND SC5.C5_NUM = SD2.D2_PEDIDO "        				+ CRLF
	cQry += "       AND SC5.D_E_L_E_T_ = ' ' "                              + CRLF
	cQry += "   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) "     + CRLF
	cQry += "       ON SB1.B1_FILIAL = '" + FWxFilial("SB1") + "' "         + CRLF
	cQry += "       AND SB1.B1_COD = SD2.D2_COD "                           + CRLF
	cQry += "       AND SB1.D_E_L_E_T_ = ' ' "                              + CRLF
	cQry += "   INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) "     + CRLF
	cQry += "       ON SA1.A1_FILIAL = '" + FWxFilial("SA1") + "' "         + CRLF
    cQry += "       AND SA1.A1_COD = SC5.C5_CLIENTE "       				+ CRLF
	cQry += "       AND SA1.D_E_L_E_T_ = ' ' "                              + CRLF
    cQry += " WHERE 1=1 "                                                   + CRLF
    cQry += " AND SD2.D2_FILIAL = '" + FWxFilial("SD2") + "' "              + CRLF
    
	If !Empty(MV_PAR02) //Parametro por Nf
		cQry += " AND SD2.D2_DOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
	EndIf

    If !Empty(MV_PAR03) // Parametro por Serie
	    cQry += " AND SD2.D2_SERIE = '" + MV_PAR03 + "' " + CRLF
    EndIf

	If !(Empty(MV_PAR04) .AND. Empty(MV_PAR05)) // Parametro por Data
		cQry += " AND SD2.D2_EMISSAO BETWEEN '" + DtoS(MV_PAR04) + "' AND '" + DtoS(MV_PAR05) + "'" + CRLF
	EndIf

	If !Empty(MV_PAR07) // Parametro por Produto
		cQry += " AND SD2.D2_COD BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'" + CRLF
	EndIf

    cQry += " AND SD2.D_E_L_E_T_ = ' ' "                                     + CRLF
    cQry += " ORDER BY SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_EMISSAO,SD2.D2_COD "  + CRLF
		
	//Executando a conulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )

	//Setando o total da régua.
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init() 
	
	DbSelectArea(cTabela)
		(cTabela)->(DbGotop())
		While (cTabela)->(!EoF())
			
			//Incrementando a regua
			nAtual++

			oReport:SetMsgPrint("Imprimindo registo " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " ...")
			oReport:IncMeter()

			oSectDad:Cell("D2_FILIAL"):SetValue((cTabela)->D2_FILIAL)
			oSectDad:Cell("D2_EMISSAO"):SetValue(StoD((cTabela)->D2_EMISSAO))
			oSectDad:Cell("D2_PEDIDO"):SetValue((cTabela)->D2_PEDIDO)
			oSectDad:Cell("B1_COD"):SetValue((cTabela)->B1_COD)
			oSectDad:Cell("DESCRI"):SetValue(ALLTRIM(FwCutOff((cTabela)->DESCRI, .T.)))
			oSectDad:Cell("D2_QUANT"):SetValue((cTabela)->D2_QUANT)
			oSectDad:Cell("D2_TOTAL"):SetValue((cTabela)->D2_TOTAL)
			oSectDad:Cell("F2_VALBRUT"):SetValue((cTabela)->F2_VALBRUT)
			oSectDad:Cell("D2_DOC"):SetValue((cTabela)->D2_DOC)
			oSectDad:Cell("D2_SERIE"):SetValue((cTabela)->D2_SERIE)
			oSectDad:Cell("D2_CLIENTE"):SetValue((cTabela)->D2_CLIENTE)
			oSectDad:Cell("A1_NOME"):SetValue((cTabela)->A1_NOME)
			oSectDad:Cell("A1_CEP"):SetValue((cTabela)->A1_CEP)
			oSectDad:Cell("A1_EST"):SetValue((cTabela)->A1_EST)
			oSectDad:Cell("C5_VOLUME1"):SetValue((cTabela)->C5_VOLUME1)
			oSectDad:Cell("C5_PBRUTO"):SetValue((cTabela)->C5_PBRUTO)
			oSectDad:Cell("C5_XITEMCC"):SetValue((cTabela)->C5_XITEMCC)

			//Imprimindo a linha atual
			oSectDad:PrintLine()

			(cTabela)->(DbSkip())
		EndDo
	oSectDad:Finish()
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)
Return


