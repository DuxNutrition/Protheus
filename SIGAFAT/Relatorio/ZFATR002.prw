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
	
	If ParamBox(aPergs, "Informe os parâmetros para Nota Fiscal de saída", , , , , , , , , .F., .F.)
		oReport := fReportDef()
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)
Return

Static Function fReportDef() //Definições do relatório

	Local oReport
	Local oSection	:= Nil
	
	oReport:= TReport():New("ZFATR002",;				// --Nome da impressão
                            "Relatório de Saídas ME",;  // --Título da tela de parâmetros
                            ,;      		// --Grupo de perguntas na SX1, ao invés das pereguntas estou usando Parambox
                            {|oReport|  ReportPrint(oReport),};
                            ) // --Descrição do relatório
	
	oReport:SetLandScape(.T.)			//--Orientação do relatório como paisagem.
	//oReport:HideParamPage(.T.)    	//--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()        		//--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()        		//--Define que não será impresso o rodapé padrão da página
	oReport:SetPreview(.T.)   			//--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2)   		//--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	oReport:oPage:SetPaperSize(9)		//--Define impressão no papel A4

	oReport:lParamPage := .T. //Página de parâmetros?
	
	//Impressão por planilhas
	oReport:SetDevice(4)        		//--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
	oReport:SetTpPlanilha({.T., .T., .T., .T.}) //Formato Tabela {Normal, Suprimir linhas brancas e totais, Formato de Tabela, Formato de Tabela xlsx}
 
	//Definições de fonte:
	oReport:SetLineHeight(50) 			//--Espaçamento entre linhas
	oReport:cFontBody := 'Courier New' 	//--Tipo da fonte
	oReport:nFontBody := 12				//--Tamanho da fonte
	//oReport:SetEdit(.T.) 
	//Pergunte(oReport:GetParam(),.F.) 	//--Adicionar as perguntas na SX1

	oSection := TRSection():New(oReport,; 	//--Criando a seção de dados
		OEMToAnsi("Relatório de Saídas ME"),;
		{cTabela})
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
		
	
	//TRCell():New(oSection2,"CR_DATALIB"	,"SCR"	,'Data Aprov SC'	,/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)
	//--Colunas do relatório
	TRCell():New( oSection  ,"D2_FILIAL"  	,cTabela ,"Filial"			,/*cPicture*/,TamSx3("D2_FILIAL")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"DT_EMIS"  	,cTabela ,"Data de Emissão"	,/*cPicture*/,08 	                    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"D2_PEDIDO"    ,cTabela ,"Pedido"	        ,/*cPicture*/,TamSx3("D2_PEDIDO")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"B1_COD"       ,cTabela ,"Produto"			,/*cPicture*/,TamSx3("B1_COD")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"B1_DESC"      ,cTabela ,"Descricao"	    ,/*cPicture*/,TamSx3("B1_DESC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_QUANT"     ,cTabela ,"Quantidade"		,/*cPicture*/,TamSx3("D2_QUANT")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_DOC"       ,cTabela ,"Documento"		,/*cPicture*/,TamSx3("D2_DOC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_SERIE"     ,cTabela ,"Série"	        ,/*cPicture*/,TamSx3("D2_SERIE")[1]	    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"D2_CLIENTE"   ,cTabela ,"Cliente"			,/*cPicture*/,TamSx3("D2_CLIENTE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_NOME"      ,cTabela ,"Desc. Cliente"	,/*cPicture*/,TamSx3("A1_NOME")[1]	    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_CEP"  	    ,cTabela ,"CEP"		        ,/*cPicture*/,TamSx3("A1_CEP")[1]	    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"A1_EST"       ,cTabela ,"UF"	            ,/*cPicture*/,TamSx3("A1_EST")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"C5_VOLUME1"   ,cTabela ,"Volume"	        ,/*cPicture*/,TamSx3("C5_VOLUME1")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"C5_PBRUTO"    ,cTabela ,"Peso Bruto"		,/*cPicture*/,TamSx3("C5_PBRUTO")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"C5_XITEMCC"  ,cTabela ,"Canal de Vendas"  ,/*cPicture*/,TamSx3("C5_XITEMCC")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    

Return oReport

Static Function ReportPrint(oReport)

	Local aArea 	:= FWGetArea()
	Local cQry		:= ""
	Local oSectDad  := Nil
	Local nAtual	:= 0
	Local nTotal	:= 0
	
	//Pegando as secoes do relatório
	oSectDad := oReport:Section(1) //Primeira seção disponível

    cQry := " SELECT "                                                      + CRLF
    cQry += "   D2_FILIAL "                                                 + CRLF
    cQry += "   ,D2_EMISSAO AS DT_EMIS "                                    + CRLF
	cQry += "   ,D2_PEDIDO "                                                + CRLF
    cQry += "   ,B1_COD "                                                   + CRLF
	cQry += "   ,B1_DESC "                                                  + CRLF
    cQry += "   ,D2_QUANT "                                                 + CRLF
	cQry += "   ,D2_DOC "                                                   + CRLF
    cQry += "   ,D2_SERIE "                                                 + CRLF
	cQry += "	,D2_CLIENTE "                                               + CRLF
	cQry += "	,A1_NOME "                                                  + CRLF
	cQry += "	,A1_CEP "                                                   + CRLF
	cQry += "	,A1_EST "                                                   + CRLF
	cQry += "	,C5_VOLUME1 "                                               + CRLF
	cQry += "	,C5_PBRUTO "                                                + CRLF
	cQry += "	,C5_XITEMCC "                                               + CRLF
    cQry += " FROM " + RetSqlName("SD2") + " AS SD2 WITH(NOLOCK) "          + CRLF
	cQry += "   INNER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) "     + CRLF
	cQry += "       ON SC5.C5_NUM = SD2.D2_PEDIDO "                         + CRLF
	cQry += "       AND SC5.C5_FILIAL = '" + FWxFilial("SC5") + "' "        + CRLF
	cQry += "       AND SC5.D_E_L_E_T_ = ' ' "                              + CRLF
	cQry += "   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) "     + CRLF
	cQry += "       ON SB1.B1_COD = SD2.D2_COD "                            + CRLF
	cQry += "       AND SB1.B1_FILIAL = '  ' "                              + CRLF
	cQry += "       AND SB1.D_E_L_E_T_ = ' ' "                              + CRLF
	cQry += "   INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) "     + CRLF
	cQry += "       ON SA1.A1_COD = SC5.C5_CLIENTE "                        + CRLF
    cQry += "       AND SA1.A1_FILIAL = '" + FWxFilial("SA1") + "' "        + CRLF
	cQry += "       AND SA1.D_E_L_E_T_ = ' ' "                              + CRLF
    cQry += " WHERE 1=1 "                                                   + CRLF
    cQry += " AND SD2.D2_FILIAL = '" + FWxFilial("SD2") + "' "              + CRLF
    
	If !Empty(MV_PAR02) //DT INVOICE ATE
		cQry += " AND SD2.D2_DOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
	EndIf

    If !Empty(MV_PAR03)
	    cQry += " AND SD2.D2_SERIE = '" + MV_PAR03 + "' " + CRLF
    EndIf

	If !Empty(MV_PAR05) // NUM DOCUMENTO NF
		cQry += " AND SD2.D2_COD BETWEEN '" + DtoS(MV_PAR04) + "' AND '" + DtoS(MV_PAR05) + "'" + CRLF
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

			oSectDad:Cell("DT_EMIS"):SetValue(StoD((cTabela)->DT_EMIS))
	
			//Imprimindo a linha atual
			oSectDad:PrintLine()

			(cTabela)->(DbSkip())
		EndDo
	oSectDad:Finish()
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)
Return


