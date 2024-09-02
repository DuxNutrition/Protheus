#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#define CRLF chr(13) + chr(10)  

/*{Protheus.doc} 
Relatório Conferencia de Inventario 
@author Jedielson Rodrigues
@since 29/07/2024
@history 
@version P11,P12
@database MSSQL
*/

User Function ZESTR001()
    
Local	aArea 		:= FwGetArea()
Local	oReport
Local	aPergs		:= {}
Local	dDtInv		:= Ctod(Space(8)) //Data de emissao de NF
Local   cCod        := Space(TamSX3('B1_COD')[1])
Local   cEnder		:= Space(TamSX3('B7_LOCALIZ')[1])
Local   cLocal      := Space(TamSX3('B7_LOCAL')[1])
Local   cTipo       := Space(TamSX3('B1_TIPO')[1])
Local   cGrupo      := Space(TamSX3('B1_GRUPO')[1])
Local   cDoc        := Space(TamSX3('B7_DOC')[1])
Local   cLote       := Space(TamSX3('B7_LOTECTL')[1])
Local 	aMoeda		:= {"1a Moeda","2a Moeda","3a Moeda","4a Moeda","5a Moeda"}
Local 	aCusmed		:= {"Atual","Ult.Fechamento"}
Local 	aListPrd	:= {"Com Diferenças","Sem Diferenças","Todos"}
Local 	nMoeda		:= 1
Local 	nCusmed		:= 1
Local 	nListPrd	:= 3

Private cTabela 	:= GetNextAlias()

aAdd(aPergs, {1,"De Produto"			  ,cCod		,/*Pict*/,/*Valid*/,"SB1",/*When*/,60,.F.})            //MV_PAR01
aAdd(aPergs, {1,"Ate Produto"		      ,cCod	    ,/*Pict*/,MV_PAR02 > MV_PAR01,"SB1",/*When*/,60,.F.})  //MV_PAR02
aAdd(aPergs, {1,"De Endereco"  			  ,cEnder	,/*Pict*/,/*Valid*/	,"SBE",/*When*/,60,.F.})           //MV_PAR03
aAdd(aPergs, {1,"Ate Endereco"            ,cEnder	,/*Pict*/,MV_PAR03 > MV_PAR04,"SBE",/*When*/,60,.F.})  //MV_PAR04
aAdd(aPergs, {1,"Data de Selecao"   	  ,dDtInv	,/*Pict*/,/*Valid*/	,/*F3*/,/*When*/,50,.T.})           //MV_PAR05
aAdd(aPergs, {1,"De Local"  			  ,cLocal	,/*Pict*/,/*Valid*/	,"NNR",/*When*/,50,.F.})            //MV_PAR06
aAdd(aPergs, {1,"Ate Local" 			  ,cLocal	,/*Pict*/,MV_PAR07 > MV_PAR06,"NNR",/*When*/,50,.F.})   //MV_PAR07
aAdd(aPergs, {1,"De Tipo"  			  	  ,cTipo	,/*Pict*/,/*Valid*/	,"02",/*When*/,50,.F.})       		//MV_PAR08
aAdd(aPergs, {1,"Ate Tipo" 			  	  ,cTipo	,/*Pict*/,MV_PAR09 > MV_PAR08,"02",/*When*/,50,.F.})    //MV_PAR09
aAdd(aPergs, {1,"De Grupo"  			  ,cGrupo	,/*Pict*/,/*Valid*/	,"SBM",/*When*/,50,.F.})       	    //MV_PAR10
aAdd(aPergs, {1,"Ate Grupo" 			  ,cGrupo	,/*Pict*/,MV_PAR11 > MV_PAR10,"SBM",/*When*/,50,.F.})   //MV_PAR11
aAdd(aPergs, {1,"De Docto"				  ,cDoc		,/*Pict*/,/*Valid*/	,/*F3*/,/*When*/,50,.F.})           //MV_PAR12
aAdd(aPergs, {1,"Ate Docto"				  ,cDoc		,/*Pict*/,MV_PAR13 > MV_PAR12,/*F3*/,/*When*/,50,.F.})  //MV_PAR13
aAdd(aPergs, {1,"De Lote"				  ,cLote	,/*Pict*/,/*Valid*/	,/*F3*/,/*When*/,50,.F.})           //MV_PAR14
aAdd(aPergs, {1,"Ate Lote"				  ,cLote	,/*Pict*/,,/*F3*/,/*When*/,50,.F.})  					//MV_PAR15
aAdd(aPergs, {3,"Qual moeda" 		 	  ,nMoeda  	,aMoeda   ,50 ,"" ,.F.})								//MV_PAR16
aAdd(aPergs, {3,"Usar o Custo Medio" 	  ,nCusmed  ,aCusmed  ,60 ,"" ,.F.})								//MV_PAR17
aAdd(aPergs, {3,"Listar Produtos" 	 	  ,nListPrd ,aListPrd ,60 ,"" ,.F.})								//MV_PAR18

If ParamBox(aPergs, "Informe os parametros do Lançamento de Inventario", , , , , , , , , .F., .F.)	
	oReport := fReportDef()
	oReport:PrintDialog()
EndIf

FWRestArea(aArea)

Return

Static Function fReportDef() //Definições do relatório

Local oReport
Local oSection := Nil
Local  cPictQFim 	:= PesqPict("SB2",'B2_QFIM',20)
Local  cPictQtd  	:= PesqPict("SB7",'B7_QUANT',20)
Local  cPictVFim 	:= PesqPict("SB2",'B2_VFIM1',20)
Local  cTamQFim  	:= 20
Local  cTamQtd   	:= 20
Local  cTamVFim  	:= 20

	oReport:= TReport():New("ZESTR001",;				// --Nome da impressão
							"Lancamento de Inventario",;  // --Título da tela de parâmetros
							,;      		// --Grupo de perguntas na SX1, ao invés das pereguntas estou usando Parambox
							{|oReport|  ReportPrint(oReport),};
							) // --Descrição do relatório

	oReport:SetLandScape(.T.)			//--Orientação do relatório como paisagem.
	oReport:HideParamPage(.F.)    	    //--Desabilita a impressao da pagina de parametros.
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
		OEMToAnsi("Lancamento de Inventario"),;
		{cTabela})
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
		
	TRCell():New( oSection  ,"B1_COD"       ,cTabela ,"Produto"						,PesqPict("SB1","B1_COD")		,TamSx3("B1_COD")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DESCRI"     	,cTabela ,"Descricao"	    			,								,TamSx3("B1_DESC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_LOTECTL"   ,cTabela ,"Lote"						,PesqPict("SB7","B7_LOTECTL")   ,TamSx3("B7_LOTECTL")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_NUMLOTE"   ,cTabela ,"Sub Lote"					,PesqPict("SB7","B7_NUMLOTE")   ,TamSx3("B7_NUMLOTE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_DTVALID"   ,cTabela ,"Validade" 					,PesqPict("SB7","B7_DTVALID")   ,TamSx3("B7_DTVALID")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_LOCALIZ"   ,cTabela ,"Localizacao"					,PesqPict("SB7","B7_LOCALIZ")   ,TamSx3("B7_LOCALIZ")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_NUMSERI"   ,cTabela ,"Num Serie"					,PesqPict("SB7","B7_NUMSERI")   ,TamSx3("B7_NUMSERI")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B1_TIPO"   	,cTabela ,"TP"							,PesqPict("SB7","B1_TIPO")   	,TamSx3("B1_TIPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B1_GRUPO"   	,cTabela ,"Grupo"						,PesqPict("SB7","B1_GRUPO") 	,TamSx3("B1_GRUPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B1_UM"   		,cTabela ,"UM"							,PesqPict("SB7","B1_UM")   		,TamSx3("B1_UM")[1]			, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_LOCAL" 	,cTabela ,"Amz"							,PesqPict("SB7","B7_LOCAL")   	,TamSx3("B7_LOCAL")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_DOC"   	,cTabela ,"Docto"						,PesqPict("SB7","B7_DOC")   	,TamSx3("B7_DOC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_QUANT"   	,cTabela ,"Quantidade Inventariada" 	,PesqPict("SB7","B7_QUANT")   	,TamSx3("B7_QUANT")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"QUANTDATA"   	,cTabela ,"Qtd na data do Inventario" 	,cPictQFim   					,cTamQFim					, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DIFQUANT"   	,cTabela ,"Diferenca Quantidade" 		,cPictQtd   					,cTamQtd					, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DIFVALOR"   	,cTabela ,"Diferenca Valor" 			,cPictVFim   					,cTamVFim					, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"STATUS"   	,cTabela ,"Status" 						,"@!"	                        ,15							, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

Return oReport

Static Function ReportPrint(oReport)

	Local aArea 	:= FWGetArea()
	local oSaldoWMS := Nil
	Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
	Local lContagem := SuperGetMv('MV_CONTINV',.F.,.F.)
	Local lImprime  := .T.
	Local _aAreaSB2 := SB2->(GetArea())
	Local cQry		:= ""
	Local cProduto  := ""
	Local cLocal 	:= ""
	Local oSectDad  := Nil
	Local nAtual	:= 0
	Local nTotal	:= 0
	Local nPastot	:= 0
	Local nSaldo	:= 0
	Local aSaldo	:= {}
	Local aSalQtd   := {}
	Local aCM		:= {}
	Local nX        := 0
	Local cSeek     := ''
	Local cCompara  := ''
	Local cStatus   := ''
	Local lSB7Cnt   := .T.
	Local lFirst    := .F.
	Local lEmAberto := .F.
	
	//Pegando as secoes do relatório
	oSectDad := oReport:Section(1) //Primeira seção disponível

	If Select( cTabela ) > 0
		(cTabela)->(DbCloseArea())
	EndIf

	cQry := " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_DESC AS DESCRI, SB1.B1_UM, SB1.B1_CODITE, "+ CRLF
	cQry += " SB7.B7_FILIAL, SB7.B7_COD, SB7.B7_LOCAL, SB7.B7_LOCALIZ, SB7.B7_DATA, "+ CRLF
	cQry += " SB7.B7_NUMSERI, SB7.B7_LOTECTL, SB7.B7_NUMLOTE, SB7.B7_DOC, SB7.B7_ESCOLHA, "+ CRLF
	cQry += " SUM(SB7.B7_QUANT) B7_QUANT, SB7.B7_STATUS, "+ CRLF
	cQry += " IsNull(SB7.B7_DTVALID,' ') AS B7_DTVALID, SB7.B7_STATUS "+ CRLF
	cQry += " FROM " + RetSqlName("SB7") + " AS SB7 WITH(NOLOCK) "+ CRLF
	cQry += " LEFT JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) "+ CRLF
	cQry += " 	ON SB1.B1_FILIAL = '" + FWxFilial("SB1") + "' "+ CRLF
	cQry += "	AND SB1.B1_COD = SB7.B7_COD "+ CRLF

	If !Empty(MV_PAR09) // Parametro por Tipo
		cQry += " AND SB1.B1_TIPO BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' "+ CRLF
	EndIf

	If !Empty(MV_PAR11) // Parametro por Grupo
		cQry += " AND SB1.B1_GRUPO BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "+ CRLF
	EndIf

	cQry += "	AND SB1.D_E_L_E_T_ = ' ' "+ CRLF
	cQry += " WHERE SB7.B7_FILIAL =  '" + FWxFilial("SB7") + "' "+ CRLF

	If !Empty(MV_PAR02) // Parametro por Produto
		cQry += " AND SB7.B7_COD >= '"+MV_PAR01+"' AND SB7.B7_COD <= '"+MV_PAR02+"' "+ CRLF 
	EndIf

	If !Empty(MV_PAR04) // Parametro por Endereco
		cQry += " AND SB7.B7_LOCALIZ BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ CRLF
	EndIf

	cQry += " AND SB7.B7_DATA = '"+DTOS(MV_PAR05)+"' "+ CRLF
	

	If !Empty(MV_PAR07) // Parametro por Local
		cQry += " AND SB7.B7_LOCAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "+ CRLF
	EndIf

	If !Empty(MV_PAR13) // Parametro por Docto
		cQry += " AND SB7.B7_DOC BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' "+ CRLF
	EndIf

	If !Empty(MV_PAR15) // Parametro por Lote
		cQry += " AND SB7.B7_LOTECTL BETWEEN '"+MV_PAR14+"' AND '"+MV_PAR15+"' "+ CRLF
	EndIf

	If lContagem
		cQry += " AND SB7.B7_ESCOLHA = 'S' "
	EndIf

	cQry += "	AND SB7.D_E_L_E_T_ = ' ' "+ CRLF
	cQry += " GROUP BY SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_TIPO, "+ CRLF
	cQry += "	SB1.B1_GRUPO, SB1.B1_DESC, SB1.B1_UM, SB1.B1_CODITE, "+ CRLF
	cQry += "	SB7.B7_FILIAL, SB7.B7_COD, SB7.B7_LOCAL, SB7.B7_LOCALIZ, SB7.B7_DATA, "+ CRLF
	cQry += "	SB7.B7_NUMSERI, SB7.B7_LOTECTL, SB7.B7_NUMLOTE, SB7.B7_DOC, "+ CRLF
	cQry += "	SB7.B7_ESCOLHA, SB7.B7_STATUS, SB7.B7_DTVALID,SB7.B7_STATUS "+ CRLF
	cQry += " ORDER BY SB1.B1_FILIAL, SB1.B1_COD, SB7.B7_DOC, SB7.B7_STATUS, SB7.B7_LOTECTL, SB7.B7_NUMLOTE, SB7.B7_LOCALIZ "+ CRLF
		
	//Executando a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )

	//Setando o total da régua.
	Count to nPastot
	oReport:SetMeter(nPastot)
	
	//Enquanto houver dados
	oSectDad:Init() 
	
	DbSelectArea(cTabela)
		(cTabela)->(DbGotop())
		While !oReport:Cancel() .And. (cTabela)->(!EoF())

		oReport:IncMeter()

		If cSeek <> (cTabela)->&(cCompara)
			
			//Incrementando a regua
			nAtual++

			nTotal     := 0
			lSB7Cnt    := .T.
			lImprime   := .T.
			cSeek      := xFilial('SB7')+DTOS(MV_PAR05)+(cTabela)->B7_COD+(cTabela)->B7_LOCAL+(cTabela)->B7_LOCALIZ+(cTabela)->B7_NUMSERI+(cTabela)->B7_LOTECTL+(cTabela)->B7_NUMLOTE
			cCompara   := "B7_FILIAL+B7_DATA+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE"
			nSaldo	   := 0
			cProduto   := (cTabela)->B7_COD
			cLocal     := (cTabela)->B7_LOCAL
			cLocaliz   := (cTabela)->B7_LOCALIZ
			cNumSeri   := (cTabela)->B7_NUMSERI
			cLotectl   := (cTabela)->B7_LOTECTL
			cNumLote   := (cTabela)->B7_NUMLOTE
			cStatus    := Iif((cTabela)->B7_STATUS == "1","Nao processado","Processado")
			lFirst     := .T.
			lEmAberto  := .F.
			nTotal     := A285Tot(cTabela,lContagem,@lEmAberto,@lSB7Cnt)
		
			dbSelectArea('SB2')
			dbSetOrder(1)
			If SB2->(DbSeek(xFilial("SB2")+cProduto+cLocal))
				If (Localiza(cProduto,.T.) .And. !Empty(cLocaliz+cNumSeri)) .Or. (Rastro(cProduto) .And. !Empty(cLotectl+cNumLote))
					If IntDl(cProduto) .and. lWmsNew
						oSaldoWMS	:= WMSDTCEstoqueEndereco():New()
						aSalQtd		:= oSaldoWMS:SldPrdData(cProduto,cLocal,MV_PAR05,cLoteCtl,cNumLote,cLocaliz,cNumSeri)
					Else
						aSalQtd   := CalcEstL(cProduto,cLocal,MV_PAR05+1,cLoteCtl,cNumLote,cLocaliz,cNumSeri)
					EndIf
					aSaldo    := CalcEst(cProduto,cLocal,MV_PAR05+1)
					aSaldo[2] := (aSaldo[2] / aSaldo[1]) * aSalQtd[1]
					aSaldo[3] := (aSaldo[3] / aSaldo[1]) * aSalQtd[1]
					aSaldo[4] := (aSaldo[4] / aSaldo[1]) * aSalQtd[1]
					aSaldo[5] := (aSaldo[5] / aSaldo[1]) * aSalQtd[1]
					aSaldo[6] := (aSaldo[6] / aSaldo[1]) * aSalQtd[1]
					aSaldo[7] := aSalQtd[7]
					aSaldo[1] := aSalQtd[1]
				Else
					aSaldo := CalcEst(cProduto,cLocal,MV_PAR05+1)
				EndIf
				If MV_PAR17 == 1
					aCM:={}
					If QtdComp(aSaldo[1]) > QtdComp(0)
						For nX:=2 to Len(aSaldo)
							aAdd(aCM,aSaldo[nX]/aSaldo[1])
						Next nX
					Else
						aCM := PegaCmAtu(cProduto,cLocal)
					EndIf
				Else
					aCM := PegaCMFim(cProduto,cLocal)
				EndIf
			Else
				aSaldo := {0,0}
				aCM    := {0,0,0,0,0}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ lImprime - Variavel utilizada para verificar se o usuario deseja |
			//| Listar Produto: 1-Com Diferencas / 2-Sem Diferencas / 3-Todos    |      
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTotal-aSaldo[1] == 0
				If MV_PAR18 == 1
					lImprime := .F.
				EndIf
			Else
				If MV_PAR18 == 2
					lImprime := .F.
				EndIf
			EndIf
		Else
			nTotal  := A285Tot(cTabela,lContagem,@lEmAberto,@lSB7Cnt)
			lFirst  := .F.
		EndIF

		If lSB7Cnt .AND.(lImprime .Or. MV_PAR18 == 3)

			If lFirst
				nSaldo := aSaldo[1]
			Else
				nSaldo := 0
			EndIf 	

			oReport:SetMsgPrint("Imprimindo registo " + cValToChar(nAtual) + " de " + cValToChar(nPastot) + " ...")
			oReport:IncMeter()

			oSectDad:Cell("B1_COD"):SetValue((cTabela)->B1_COD)
			oSectDad:Cell("DESCRI"):SetValue(ALLTRIM(FwCutOff((cTabela)->DESCRI, .T.)))			
			oSectDad:Cell("B7_LOTECTL"):SetValue((cTabela)->B7_LOTECTL)
			oSectDad:Cell("B7_NUMLOTE"):SetValue((cTabela)->B7_NUMLOTE)
			oSectDad:Cell("B7_DTVALID"):SetValue(Stod((cTabela)->B7_DTVALID))
			oSectDad:Cell("B7_LOCALIZ"):SetValue((cTabela)->B7_LOCALIZ)
			oSectDad:Cell("B7_NUMSERI"):SetValue((cTabela)->B7_NUMSERI)
			oSectDad:Cell("B1_TIPO"):SetValue((cTabela)->B1_TIPO)
			oSectDad:Cell("B1_GRUPO"):SetValue((cTabela)->B1_GRUPO)
			oSectDad:Cell("B1_UM"):SetValue((cTabela)->B1_UM)
			oSectDad:Cell("B1_GRUPO"):SetValue((cTabela)->B1_GRUPO)
			oSectDad:Cell("B7_LOCAL"):SetValue((cTabela)->B7_LOCAL)
			oSectDad:Cell("B7_DOC"):SetValue((cTabela)->B7_DOC)
			oSectDad:Cell("B7_QUANT"):SetValue((cTabela)->B7_QUANT)
			oSectDad:Cell("QUANTDATA"):SetValue(nSaldo)
			oSectDad:Cell("DIFQUANT"):SetValue(nTotal - nSaldo )
			oSectDad:Cell("DIFVALOR"):SetValue((nTotal - nSaldo)*aCM[MV_PAR16])
			oSectDad:Cell("STATUS"):SetValue(cStatus)
			
			//Imprimindo a linha atual
			oSectDad:PrintLine()

		Endif

			(cTabela)->(DbSkip())
		EndDo
	oSectDad:Finish()
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)
	RestArea(_aAreaSB2)
Return


/*{Protheus.doc} A285Tot
Função responsável por calcular a quantidade inventariada, identificando
lançamentos processados e não processados
@author Jedielson Rodrigues
@param cTabela - Alias temporário com registros da tabela SB7.
@param lContagem - Informa se o inventário por contagem está habilitado 
@param lEmAberto - Variável responsável por informar se existe lançamentos
				  de inventário em aberto para o produto.
@param lSB7Cnt -Informa se a linha do produto deve ou não ser impressa.
@since 02/09/2024
@version P12
*/

Static Function A285Tot(cTabela,lContagem,lEmAberto,lSB7Cnt)
Local nTotal := 0

If lContagem
	nTotal += (cTabela)->B7_QUANT
Else
	If (cTabela)->B7_STATUS == "1"
		nTotal 	   := (cTabela)->B7_QUANT
		lEmAberto  := .T.
	Else
		If !lEmAberto
			nTotal += (cTabela)->B7_QUANT
		Else
			lSB7Cnt := .F.
		EndIf
	EndIf
EndIf

Return nTotal
