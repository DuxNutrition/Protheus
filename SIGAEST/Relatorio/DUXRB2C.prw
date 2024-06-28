//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} DUXRB2C
	@description Relatório - Estoque e Reservas B2C        
	@author Administrador
	@since 05/04/2023
	@version 1.0
/*/
	
User Function DUXRB2C()
	Local aArea   := GetArea()
	Local oReport
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "DUXRB2C   "
	
	If Pergunte(cPerg,.T.)
	
		oReport := DUXRB2CA()
	
		oReport:PrintDialog()
	
	EndIf
	
	RestArea(aArea)
Return
	
	
	
/*/{Protheus.doc} DUXRB2CA
	@description - Função que monta a definição do relatório
	@author Administrador
	@since 05/04/2023
	@version 1.0
/*/
	
Static Function DUXRB2CA()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil

    Private QtdPedVen   := 0
    Private SaldoDispo  := 0
	Private nQtdResB2C	:= 0
	Private nSldDiB2C	:= 0
	
	//Criação do componente de impressão
	oReport := TReport():New(	"DUXRB2C",;		//Nome do Relatório
								"Estoque e Reservas B2C",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| DUXRB2CB(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .T.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "B2_FILIAL"		, "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B2_COD"			, "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_DESC"		, "QRY_AUX", "Descricao", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_UM"			, "QRY_AUX", "UM", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B2_LOCAL"		, "QRY_AUX", "Armazém", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	TRCell():New(oSectDad, "B2_QATU"		, "QRY_AUX", "Saldo Atual", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDEMPE"		, "QRY_AUX", "Qtd Empenhada", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B2_QPEDVEN"		, "QRY_AUX", "Qtd Ped Ven Blq", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B2_RESERVA"		, "QRY_AUX", "Qtd Reserv/Ped Ven Lib", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ZBC_QUANTI"		, "QRY_AUX", "Qtd Res B2C", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, ""				, "QRY_AUX", "Qtd Consumida B2C", "@E 9,999,999.9999999", 15, /*lPixel*/,{|| QtdPedVen },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, ""				, "QRY_AUX", "Sld Reserv B2C", "@E 9,999,999.9999999", 15, /*lPixel*/,{|| nQtdResB2C },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, ""				, "QRY_AUX", "Sld Disp B2C", "@E 9,999,999.9999999", 15, /*lPixel*/,{|| nSldDiB2C },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, ""				, "QRY_AUX", "Sld Disp B2B", "@E 9,999,999.9999999", 15, /*lPixel*/,{|| nSldDiB2B },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)


	
Return oReport
	
/*/{Protheus.doc} DUXRB2CB
	@description - Função que imprime o relatório
	@author Administrador
	@since 05/04/2023
	@version 1.0
/*/
	
Static Function DUXRB2CB(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT B2_FILIAL,"		+ STR_PULA
	cQryAux += "B2_COD,"		+ STR_PULA
	cQryAux += "B1_DESC,"		+ STR_PULA
	cQryAux += "B1_UM,"		+ STR_PULA
	cQryAux += "B2_LOCAL,"		+ STR_PULA
	cQryAux += "B2_QATU,"		+ STR_PULA
	cQryAux += "B2_QEMP + B2_QEMPSA + B2_QEMPPRJ AS QTDEMPE, " + STR_PULA
	cQryAux += "B2_QPEDVEN,"		+ STR_PULA
	cQryAux += "B2_QACLASS,"		+ STR_PULA
	cQryAux += "B2_QTNP,"		+ STR_PULA
	cQryAux += "B2_QNPT,"		+ STR_PULA
	cQryAux += "'QTD_PED_VEN' AS QUANT_PED_VEN,"		+ STR_PULA
	cQryAux += "B2_RESERVA,"		+ STR_PULA
	cQryAux += "ZBC_QUANTI,"		+ STR_PULA
	cQryAux += "ZBC_DTINI,"		+ STR_PULA
	cQryAux += "ZBC_DTFIM,"		+ STR_PULA
	cQryAux += "'SALDO' AS SALDO_DISPONIVEL"		+ STR_PULA
	cQryAux += "FROM SB2010 SB2"		+ STR_PULA
	cQryAux += "JOIN SB1010 SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "LEFT JOIN ZBC010 ZBC ON ZBC_FILIAL = B2_FILIAL AND ZBC_CODPRO = B2_COD AND ZBC.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "WHERE B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"		+ STR_PULA
	cQryAux += "AND B2_LOCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"		+ STR_PULA
	cQryAux += "AND B2_FILIAL = '" + xFilial("SB2") + "'"		+ STR_PULA
	cQryAux += "AND SB2.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "AND '" + DTOS(DATE()) + "' BETWEEN ZBC_DTINI AND ZBC_DTFIM"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())

	SB1->(DbSetOrder(1))

	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

        If !Empty(QRY_AUX->(ZBC_DTINI))
            QtdPedVen   := U_SLDVDB2C(xFilial("SC6"), QRY_AUX->(B2_COD), STOD(QRY_AUX->(ZBC_DTINI)), STOD(QRY_AUX->(ZBC_DTFIM)), QRY_AUX->(B2_LOCAL))
        Else 
            QtdPedVen   := 0
        EndIf 

		
		If SB1->(DbSeek(xFilial("SB1") + QRY_AUX->(B2_COD))) .And. SB1->B1_LOCPAD == QRY_AUX->(B2_LOCAL)

			nQtdResB2C 	:= MAX((QRY_AUX->(ZBC_QUANTI) - QtdPedVen), 0)		
		Else 
			nQtdResB2C	:= Nil
		EndIf 

		nSldDiB2C 	:= MAX(QRY_AUX->(B2_QATU) - QRY_AUX->(QTDEMPE) - QRY_AUX->(B2_RESERVA), 0)
		nSldDiB2B 	:= MAX(QRY_AUX->(B2_QATU) - QRY_AUX->(QTDEMPE) - QRY_AUX->(B2_RESERVA) - IIF(nQtdResB2C == Nil, 0, nQtdResB2C), 0)

		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
