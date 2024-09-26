#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#define CRLF chr(13) + chr(10)  

/*{Protheus.doc} ZESTR001
Relatório Conferencia de Inventario 
@type function
@author Jedielson Rodrigues
@since 29/07/2024
@version 12.1.2310
@database MSSQL
*/

User Function ZESTR001()
    
Local	aArea 		:= FwGetArea()
Local	oReport
Local	aPergs		:= {}
Local	dDtInv		:= Ctod(Space(8))
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
Local 	nListPrd	:= 1

Private cTabela 	:= GetNextAlias()
Private cModInv 	:= SuperGetMv('MV_CBINVMD',.F.,"2")

aAdd(aPergs, {1,"De Produto"			  ,cCod		,/*Pict*/,/*Valid*/,"SB1",/*When*/,60,.F.})             //MV_PAR01
aAdd(aPergs, {1,"Ate Produto"		      ,cCod	    ,/*Pict*/,MV_PAR02 > MV_PAR01,"SB1",/*When*/,60,.F.})   //MV_PAR02
aAdd(aPergs, {1,"De Endereco"  			  ,cEnder	,/*Pict*/,/*Valid*/	,"SBE",/*When*/,60,.F.})            //MV_PAR03
aAdd(aPergs, {1,"Ate Endereco"            ,cEnder	,/*Pict*/,MV_PAR03 > MV_PAR04,"SBE",/*When*/,60,.F.})   //MV_PAR04
aAdd(aPergs, {1,"Data de Invetario"   	  ,dDtInv	,/*Pict*/,/*Valid*/	,/*F3*/,/*When*/,50,.T.})           //MV_PAR05
aAdd(aPergs, {1,"De Local"  			  ,cLocal	,/*Pict*/,/*Valid*/	,"NNR",/*When*/,50,.F.})            //MV_PAR06
aAdd(aPergs, {1,"Ate Local" 			  ,cLocal	,/*Pict*/,MV_PAR07 > MV_PAR06,"NNR",/*When*/,50,.F.})   //MV_PAR07
aAdd(aPergs, {1,"De Tipo Prod"  		  ,cTipo	,/*Pict*/,/*Valid*/	,"02",/*When*/,50,.F.})       		//MV_PAR08
aAdd(aPergs, {1,"Ate Tipo Prod" 		  ,cTipo	,/*Pict*/,MV_PAR09 > MV_PAR08,"02",/*When*/,50,.F.})    //MV_PAR09
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
	If cModInv == "1"
		oReport := fRepMod1()
		oReport:PrintDialog()
	Else
		oReport := fRepMod2()
		oReport:PrintDialog()
	Endif
EndIf

FWRestArea(aArea)

Return

Static Function fRepMod1() //Definições do relatório

Local oReport
Local oSection 		:= Nil
Local  cPictQFim 	:= PesqPict("SB2",'B2_QFIM',20)
Local  cPictQtd  	:= PesqPict("SB7",'B7_QUANT',20)
Local  cPictVFim 	:= PesqPict("SB2",'B2_VFIM1',20)
Local  cTamQFim  	:= 20
Local  cTamQtd   	:= 20
Local  cTamVFim  	:= 20
Local  cDescrel     := ""

cDescrel  += "Emite uma relacao que mostra o saldo em estoque e todas as contagens efetuadas "
cDescrel  += "no inventario. Baseado nestas duas informacoes ele calcula a diferenca encontrada."

	oReport:= TReport():New("ZESTR001","Listagem dos itens inventariados",/*cPerg*/,{|oReport|ReportMod1(oReport)},cDescrel)
	oReport:SetLandScape(.T.)			//--Orientação do relatório como paisagem.
	oReport:SetEnvironment(2)   		//--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	oReport:SetDevice(4)				//--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF

	//Seção 1 
	oSection := TRSection():New(oReport,"Lancamento de Inventario",{cTabela})

	TRCell():New( oSection  ,"B1_COD"       ,cTabela ,"Produto"						,PesqPict("SB1","B1_COD")		,TamSx3("B1_COD")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DESCRI"     	,cTabela ,"Descricao"	    			,								,TamSx3("B1_DESC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_LOTECTL"   ,cTabela ,"Lote"						,PesqPict("SB7","B7_LOTECTL")   ,TamSx3("B7_LOTECTL")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_NUMLOTE"   ,cTabela ,"Sub Lote"					,PesqPict("SB7","B7_NUMLOTE")   ,TamSx3("B7_NUMLOTE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_DTVALID"   ,cTabela ,"Validade" 					,PesqPict("SB7","B7_DTVALID")   ,TamSx3("B7_DTVALID")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_LOCALIZ"   ,cTabela ,"Localizacao"					,PesqPict("SB7","B7_LOCALIZ")   ,TamSx3("B7_LOCALIZ")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_NUMSERI"   ,cTabela ,"Num Serie"					,PesqPict("SB7","B7_NUMSERI")   ,TamSx3("B7_NUMSERI")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B1_TIPO"   	,cTabela ,"TP"							,PesqPict("SB1","B1_TIPO")   	,TamSx3("B1_TIPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B1_GRUPO"   	,cTabela ,"Grupo"						,PesqPict("SB1","B1_GRUPO") 	,TamSx3("B1_GRUPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B1_UM"   		,cTabela ,"UM"							,PesqPict("SB1","B1_UM")   		,TamSx3("B1_UM")[1]			, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_LOCAL" 	,cTabela ,"Amz"							,PesqPict("SB7","B7_LOCAL")   	,TamSx3("B7_LOCAL")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_DOC"   	,cTabela ,"Docto"						,PesqPict("SB7","B7_DOC")   	,TamSx3("B7_DOC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"B7_QUANT"   	,cTabela ,"Quantidade Inventariada" 	,PesqPict("SB7","B7_QUANT")   	,TamSx3("B7_QUANT")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"QUANTDATA"   	,cTabela ,"Qtd na data do Inventario" 	,cPictQFim   					,cTamQFim					, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DIFQUANT"   	,cTabela ,"Diferenca Quantidade" 		,cPictQtd   					,cTamQtd					, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DIFVALOR"   	,cTabela ,"Diferenca Valor" 			,cPictVFim   					,cTamVFim					, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"STATUS"   	,cTabela ,"Status" 						,"@!"	                        ,15							, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

Return oReport

Static Function ReportMod1(oReport)

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
	cQry += " SUM(SB7.B7_QUANT) AS B7_QUANT, SB7.B7_STATUS, "+ CRLF
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
	cQry += " AND SB7.B7_DATA = '"+DTOS(MV_PAR05)+"' "+ CRLF // Parametro por Data
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
				nTotal     := A285Tot(cTabela,lContagem,@lEmAberto,@lSB7Cnt,cModInv)
			
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
				nTotal  := A285Tot(cTabela,lContagem,@lEmAberto,@lSB7Cnt,cModInv)
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

Static Function fRepMod2() //Definições do relatório

Local oReport
Local oSection := Nil
Local cTamVFim := 20
Local cDescrel := ""

cDescrel  += "Emite uma relacao que mostra o saldo em estoque e todas as contagens efetuadas "
cDescrel  += "no inventario. Baseado nestas duas informacoes ele calcula a diferenca encontrada."

	oReport:= TReport():New("ZESTR001","Listagem dos itens inventariados",/*cPerg*/,{|oReport|ReportMod2(oReport)},cDescrel)
	oReport:SetLandScape(.T.)			//--Orientação do relatório como paisagem.
	oReport:SetEnvironment(2)   		//--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	oReport:SetDevice(4)				//--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF

	//Seção 1 
	oSection := TRSection():New(oReport,"Lancamento de Inventario",{cTabela})

		TRCell():New( oSection  ,"CBC_COD"       ,cTabela ,"Produto"					,PesqPict("CBC","CBC_COD")		,TamSx3("CBC_COD")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"DESCRI"     	,cTabela ,"Descricao"	    			,								,TamSx3("B1_DESC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"CBC_LOTECT"   ,cTabela ,"Lote"						,PesqPict("CBC","CBC_LOTECT")   ,TamSx3("CBC_LOTECT")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"CBC_NUMLOTE"  ,cTabela ,"Sub Lote"					,PesqPict("CBC","B7_NUMLOTE")   ,TamSx3("CBC_NUMLOTE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"B8_DTVALID"   ,cTabela ,"Validade" 					,PesqPict("SB8","B8_DTVALID")   ,TamSx3("B7_DTVALID")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"CBC_LOCALI"   ,cTabela ,"Localizacao"					,PesqPict("CBC","CBC_LOCALI")   ,TamSx3("CBC_LOCALI")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"CBC_NUMSER"   ,cTabela ,"Num Serie"					,PesqPict("CBC","CBC_NUMSER")   ,TamSx3("CBC_NUMSER")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"B1_TIPO"   	,cTabela ,"TP"							,PesqPict("SB1","B1_TIPO")   	,TamSx3("B1_TIPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"B1_GRUPO"   	,cTabela ,"Grupo"						,PesqPict("SB1","B1_GRUPO") 	,TamSx3("B1_GRUPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"B1_UM"   		,cTabela ,"UM"							,PesqPict("SB1","B1_UM")   		,TamSx3("B1_UM")[1]			, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"CBC_LOCAL" 	,cTabela ,"Amz"							,PesqPict("CBC","CBC_LOCAL")   	,TamSx3("CBC_LOCAL")[1]	    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"CBA_CODINV"   ,cTabela ,"Docto"						,PesqPict("CBA","CBA_CODINV")   ,TamSx3("CBA_CODINV")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"ULT_CONTAGEM" ,cTabela ,"Quantidade Inventariada" 	,PesqPict("CBC","CBC_QUANT")   	,TamSx3("CBC_QUANT")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"QUANTDATA"   	,cTabela ,"Qtd na data do Inventario" 	,PesqPict("CBC","CBC_QUANT")   	,TamSx3("CBC_QUANT")[1]	    , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"DIFQUANT"   	,cTabela ,"Diferenca Quantidade" 		,PesqPict("CBC","CBC_QUANT")   	,TamSx3("CBC_QUANT")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"DIFVALOR"   	,cTabela ,"Diferenca Valor" 			,"@E 9,999,999.999"             ,cTamVFim					, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"CBA_CONTR"   	,cTabela ,"Cont.Realiz" 			    ,"99"                           ,TamSx3("CBA_CONTR")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT"	, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
		TRCell():New( oSection  ,"STATUS"   	,cTabela ,"Status" 						,"@!"	                        ,12							, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT"		, /*lLineBreak*/, "CENTER"	, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

Return oReport

Static Function ReportMod2(oReport)

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
	Local cStatus   := ""
	Local lSB7Cnt   := .T.
	Local lFirst    := .F.
	Local lEmAberto := .F.
	
	//Pegando as secoes do relatório
	oSectDad := oReport:Section(1) //Primeira seção disponível

	If Select( cTabela ) > 0
		(cTabela)->(DbCloseArea())
	EndIf

	cQry := " SELECT CBC.CBC_FILIAL "+ CRLF
    cQry += " ,CBA.CBA_CODINV "+ CRLF
	cQry += " ,CBC.CBC_COD "+ CRLF
	cQry += " ,SB1.B1_DESC AS DESCRI "+ CRLF
	 cQry +=" ,SB1.B1_TIPO "+ CRLF
    cQry += " ,SB1.B1_GRUPO "+ CRLF
	cQry += " ,SB1.B1_UM "+ CRLF
	cQry += " ,CBC.CBC_LOCAL "+ CRLF
	cQry += " ,CBC.CBC_NUMLOT "+ CRLF
    cQry += " ,CBC.CBC_LOCALI "+ CRLF
    cQry += " ,CBC.CBC_NUMSER "+ CRLF
    cQry += " ,CBC.CBC_LOTECT "+ CRLF
	cQry += " ,IsNull(CBA.CBA_DATA ,' ') AS CBA_DATA "+ CRLF
    cQry += " ,IsNull(SB8.B8_DTVALID,' ') AS B8_DTVALID "+ CRLF
    cQry += " ,(    SELECT TOP 1 CBCONT.CBC_QUANT FROM CBC010 CBCONT WITH(NOLOCK) "+ CRLF 
    cQry += "            WHERE CBCONT.CBC_FILIAL = CBC.CBC_FILIAL "+ CRLF 
    cQry += "            AND CBCONT.CBC_CODINV = CBA.CBA_CODINV "+ CRLF
    cQry += "            AND CBCONT.CBC_COD = CBC.CBC_COD "+ CRLF
    cQry += "            AND CBCONT.CBC_LOCAL = CBC.CBC_LOCAL "+ CRLF
    cQry += "            AND CBCONT.CBC_NUMLOT = CBC.CBC_NUMLOT "+ CRLF
    cQry += "            AND CBCONT.CBC_LOCALI = CBC.CBC_LOCALI "+ CRLF
    cQry += "            AND CBCONT.CBC_NUMSER = CBC.CBC_NUMSER "+ CRLF
    cQry += "            AND CBCONT.CBC_LOTECT = CBC.CBC_LOTECT "+ CRLF
    cQry += "            AND CBCONT.D_E_L_E_T_ = ' ' "+ CRLF
    cQry += "            ORDER BY CBCONT.R_E_C_N_O_ DESC "+ CRLF
    cQry += " ) AS ULT_CONTAGEM "+ CRLF
	cQry += " ,CBA.CBA_CONTR
	cQry += " ,CBA.CBA_STATUS  "+ CRLF
	cQry += " FROM " + RetSqlName("CBA") + " AS CBA WITH(NOLOCK) "+ CRLF 
	cQry += " LEFT JOIN " + RetSqlName("CBC") + " AS CBC WITH(NOLOCK) "+ CRLF
	cQry += " 	ON CBC.CBC_FILIAL = CBA.CBA_FILIAL "+ CRLF
    cQry += "	AND CBC.CBC_CODINV = CBA.CBA_CODINV "+ CRLF
	If !Empty(MV_PAR02) // Parametro por Produto
		cQry += " AND CBC.CBC_COD >= '"+MV_PAR01+"' AND CBC.CBC_COD <= '"+MV_PAR02+"' "+ CRLF 
	EndIf
	If !Empty(MV_PAR04) // Parametro por Endereco
		cQry += " AND CBC.CBC_LOCALI BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+ CRLF
	EndIf
	If !Empty(MV_PAR07) // Parametro por Local
		cQry += " AND CBC.CBC_LOCAL BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "+ CRLF
	EndIf
	If !Empty(MV_PAR15) // Parametro por Lote
		cQry += " AND CBC.CBC_LOTECT BETWEEN '"+MV_PAR14+"' AND '"+MV_PAR15+"' "+ CRLF
	EndIf
    cQry += "	AND CBC.D_E_L_E_T_ = ' ' "+ CRLF
	cQry += " LEFT JOIN " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) "+ CRLF 
    cQry += "	ON SB8.B8_FILIAL = CBA.CBA_FILIAL "+ CRLF
    cQry += "	AND SB8.B8_PRODUTO = CBC.CBC_COD "+ CRLF
    cQry += "	AND SB8.B8_LOCAL = CBC.CBC_LOCAL "+ CRLF
    cQry += "	AND SB8.B8_LOTECTL = CBC.CBC_LOTECT "+ CRLF 
    cQry += "	AND SB8.B8_NUMLOTE = CBC.CBC_NUMLOT "+ CRLF
    cQry += "	AND SB8.D_E_L_E_T_ = ' ' "+ CRLF
	cQry += " LEFT JOIN " + RetSqlName("SB1") + " AS SB1 WITH(NOLOCK) "+ CRLF
    cQry += "	ON SB1.B1_FILIAL = '" + FWxFilial("SB1") + "' "+ CRLF
    cQry += "	AND SB1.B1_COD = CBC.CBC_COD "+ CRLF 
	If !Empty(MV_PAR09) // Parametro por Tipo
		cQry += " AND SB1.B1_TIPO BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' "+ CRLF
	EndIf
	If !Empty(MV_PAR11) // Parametro por Grupo
		cQry += " AND SB1.B1_GRUPO BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' "+ CRLF
	EndIf
    cQry += "	AND SB1.D_E_L_E_T_ = ' ' "+ CRLF 
	cQry += " WHERE CBA.CBA_FILIAL = '" + FWxFilial("CBA") + "' "+ CRLF
	cQry += " AND CBA.CBA_DATA = '"+DTOS(MV_PAR05)+"' "+ CRLF // Parametro por Data
	If !Empty(MV_PAR13) // Parametro por Docto
		cQry += " AND CBA.CBA_CODINV BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' "+ CRLF
	EndIf 
	cQry += " AND CBA.CBA_STATUS IN ('4','5') "+ CRLF
	cQry += " AND CBA.D_E_L_E_T_ = ' ' "+ CRLF 
	cQry += " GROUP BY  CBC.CBC_FILIAL, CBA.CBA_CODINV, CBC.CBC_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_UM, CBC.CBC_LOCAL, CBC.CBC_NUMLOT, CBC.CBC_LOCALI, CBC.CBC_NUMSER, CBC.CBC_LOTECT, CBA_DATA, SB8.B8_DTVALID, CBA.CBA_CONTR, CBA_STATUS "+ CRLF

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

			//Incrementando a regua
			nAtual++

			nTotal     := 0
			lSB7Cnt    := .T.
			lImprime   := .T.
			nSaldo	   := 0
			cProduto   := (cTabela)->CBC_COD
			cLocal     := (cTabela)->CBC_LOCAL
			cLocaliz   := (cTabela)->CBC_LOCALI
			cNumSeri   := (cTabela)->CBC_NUMSER
			cLotectl   := (cTabela)->CBC_LOTECT
			cNumLote   := (cTabela)->CBC_NUMLOTE
			cStatus    := Iif((cTabela)->CBA_STATUS == "4","Finalizado","Processado")
			lFirst     := .T.
			lEmAberto  := .F.
			nTotal     := A285Tot(cTabela,lContagem,@lEmAberto,@lSB7Cnt,cModInv)

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

			If lSB7Cnt .AND.(lImprime .Or. MV_PAR18 == 3)

				If lFirst
					nSaldo := aSaldo[1]
				Else
					nSaldo := 0
				EndIf 	

				oReport:SetMsgPrint("Imprimindo registo " + cValToChar(nAtual) + " de " + cValToChar(nPastot) + " ...")
				oReport:IncMeter()

				oSectDad:Cell("CBC_COD"):SetValue((cTabela)->CBC_COD)
				oSectDad:Cell("DESCRI"):SetValue(ALLTRIM(FwCutOff((cTabela)->DESCRI, .T.)))			
				oSectDad:Cell("CBC_LOTECT"):SetValue((cTabela)->CBC_LOTECT)
				oSectDad:Cell("CBC_NUMLOTE"):SetValue((cTabela)->CBC_NUMLOTE)
				oSectDad:Cell("B8_DTVALID"):SetValue(Stod((cTabela)->B8_DTVALID))
				oSectDad:Cell("CBC_LOCALI"):SetValue((cTabela)->CBC_LOCALI)
				oSectDad:Cell("CBC_NUMSER"):SetValue((cTabela)->CBC_NUMSER)
				oSectDad:Cell("B1_TIPO"):SetValue((cTabela)->B1_TIPO)
				oSectDad:Cell("B1_GRUPO"):SetValue((cTabela)->B1_GRUPO)
				oSectDad:Cell("B1_UM"):SetValue((cTabela)->B1_UM)
				oSectDad:Cell("CBC_LOCAL"):SetValue((cTabela)->CBC_LOCAL)
				oSectDad:Cell("CBA_CODINV"):SetValue((cTabela)->CBA_CODINV)
				oSectDad:Cell("ULT_CONTAGEM"):SetValue((cTabela)->ULT_CONTAGEM)
				oSectDad:Cell("QUANTDATA"):SetValue(nSaldo)
				oSectDad:Cell("DIFQUANT"):SetValue(nTotal - nSaldo )
				oSectDad:Cell("DIFVALOR"):SetValue((nTotal - nSaldo)*aCM[MV_PAR16])
				oSectDad:Cell("CBA_CONTR"):SetValue((cTabela)->CBA_CONTR)
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
@type function
@author Jedielson Rodrigues
@param cTabela - Alias temporário com registros da tabela SB7.
@param lContagem - Informa se o inventário por contagem está habilitado 
@param lEmAberto - Variável responsável por informar se existe lançamentos
				  de inventário em aberto para o produto.
@param lSB7Cnt -Informa se a linha do produto deve ou não ser impressa.
@since 02/09/2024
@version 12.1.2310
*/

Static Function A285Tot(cTabela,lContagem,lEmAberto,lSB7Cnt,cModInv)

Local 	nTotal  := 0
Default nModInv := .F.

If cModInv == "1"
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
Else 
	If lContagem
		nTotal += (cTabela)->ULT_CONTAGEM
	Else
		If !(cTabela)->CBA_STATUS $ "4,5"
			nTotal 	   := (cTabela)->ULT_CONTAGEM
			lEmAberto  := .T.
		Else
			If !lEmAberto
				nTotal += (cTabela)->ULT_CONTAGEM
			Else
				lSB7Cnt := .F.
			EndIf
		EndIf
	EndIf
Endif

Return nTotal
 


