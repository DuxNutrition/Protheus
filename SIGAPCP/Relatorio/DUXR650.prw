#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TopConn.ch"

#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} DUXR650
	@description Impressão de OPs
	@author Daniel Neumann - CI Result
	@since 05//03/2023
	@version 1.0
*/

User Function DUXR650()

	Local cPerg 		:= "DUXR650"
	Local cAliasSC2		:= GetNextAlias()

	Private oPrinter 	:= Nil
	Private oFont10N   	:= Nil
	Private oFont07N   	:= Nil
	Private oFont07    	:= Nil
	Private oFont08    	:= Nil
	Private oFont08N   	:= Nil
	Private oFont09N   	:= Nil
	Private oFont09    	:= Nil
	Private oFont10    	:= Nil
	Private oFont11    	:= Nil
	Private oFont12    	:= Nil
	Private oFont22    	:= Nil
	Private oFont11N   	:= Nil
	Private oFont18N   	:= Nil
	Private oFont12n  	:= Nil
	Private nPgAtu		:= 0
	Private nTamCab 	:= 115
	Private nLinha		:= 0
	Private nMargemEsq	:= 15
	Private nSaltoFT11	:= 12
	Private nEstru		:= 0
	Private cOrdOper	:= ""
	
	If Pergunte( cPerg, .T. , "OPs para impressão")
		
		fErase(GetTempPath() + "DUXR650_" + DTOS(DATE()) + ".pdf")
		oPrinter:= FWMSPrinter():New("DUXR650_" + DTOS(DATE()), IMP_PDF, .F.,, .T.) 
		oPrinter:cPathPDF := GetTempPath()     
		oPrinter:SetPortrait()  
		oPrinter:SetResolution(72)  
		oPrinter:SetPaperSize(9)   
		
		BeginSQL Alias cAliasSC2 

			SEELCT R_E_C_N_O_ AS RECNO
				 FROM %TABLE:SC2% SC2
				 WHERE 	SC2.%NOTDEL%
				 		AND C2_FILIAL = %EXP:xFilial("SC2")%
				 		AND C2_NUM || C2_ITEM || C2_SEQUEN BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%

		EndSQL 

		If (cAliasSC2)->(!EOF())
			While (cAliasSC2)->(!EOF())

				SC2->(DbGoTo((cAliasSC2)->RECNO))

				Impressao()

				(cAliasSC2)->(DbSkip())
			EndDo 
		EndIf 

		oPrinter:Preview()  
	EndIf 

Return 

Static Function Impressao()

	Local cLogo			:= "system\LGMID.png"
	Local CDATVLD		:= ""

	SB1->(DbsetOrder(1))
	SB1->(dBsEEK(xFilial("SB1") + SC2->C2_PRODUTO))

	cDatVld 	:= SubStr(DTOC(MonthSum(SC2->C2_DATPRI , ROUND(SB1->B1_PRVALID / 30, 0))), 4, 8)
	cOrdOper	:= PADR(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN, 14)

	oFont07    := TFontEx():New(oPrinter,"Arial",06,06,.F.,.T.,.F.)
	oFont08    := TFontEx():New(oPrinter,"Arial",07,07,.F.,.T.,.F.)
	oFont09    := TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)
	oFont10    := TFontEx():New(oPrinter,"Arial",09,09,.F.,.T.,.F.)
	oFont11    := TFontEx():New(oPrinter,"Arial",10,10,.F.,.T.,.F.)
	oFont12    := TFontEx():New(oPrinter,"Arial",11,11,.F.,.T.,.F.)
	oFont14    := TFontEx():New(oPrinter,"Arial",13,13,.F.,.T.,.F.)
	oFont16    := TFontEx():New(oPrinter,"Arial",15,15,.F.,.T.,.F.)
	oFont22    := TFontEx():New(oPrinter,"Arial",23,23,.F.,.T.,.F.)

	oFont07N   := TFontEx():New(oPrinter,"Arial",06,06,.T.,.T.,.F.)
	oFont08N   := TFontEx():New(oPrinter,"Arial",06,06,.T.,.T.,.F.)
	oFont09N   := TFontEx():New(oPrinter,"Arial",08,08,.T.,.T.,.F.)	
	oFont10N   := TFontEx():New(oPrinter,"Arial",08,08,.T.,.T.,.F.)	
	oFont11N   := TFontEx():New(oPrinter,"Arial",10,10,.T.,.T.,.F.)	
	oFont12N   := TFontEx():New(oPrinter,"Arial",11,11,.T.,.T.,.F.) 
	oFont18N   := TFontEx():New(oPrinter,"Arial",17,17,.T.,.T.,.F.)
	
	oPrinter:StartPage()    

	oPrinter:Box(048,  014	, 064	, 285	)	
	oPrinter:Box(048,  285	, 064	, 570	)	
	oPrinter:Box(064,  014	, 080	, 285	)	
	oPrinter:Box(064,  285	, 080	, 570	)	
	oPrinter:Box(080,  100	, 096	, 285	)	
	oPrinter:Box(080,  285	, 096	, 570	)	
	
	oPrinter:Box(096,  100	, 112	, 285	)	
	oPrinter:Box(096,  285	, 112	, 427	)	
	oPrinter:Box(096,  427	, 112	, 570	)	
	
	oPrinter:Box(112,  100	, 128	, 285	)	
	oPrinter:Box(112,  285	, 128	, 427	)	
	oPrinter:Box(112,  427	, 128	, 570	)	

	//dados do cabeçalho 
	oPrinter:Box(020,  014	, 051	, 570	) 	
	oPrinter:SayBitmap(005, 019, cLogo, 080, 055)	
	oPrinter:Say(040, 180, "ORDEM DE PRODUÇÃO"												, oFont18N:oFont)
	//--- Codigo de Barras
	oPrinter:Code128C(048,350,Alltrim(SC2->C2_NUM) + Alltrim(SC2->C2_ITEM) + Alltrim(SC2->C2_SEQUEN),28)
	
	oPrinter:Box(020, 450	, 051	, 570	) 	
	oPrinter:Say(030, 455, "Fabricação da OP"												, oFont10:oFont)
	oPrinter:Say(045, 455, "____ / ____ / _____    ____ : ____"								, oFont10N:oFont)
	
	oPrinter:Say(060, 019, "Produto" 														, oFont10:oFont)
	oPrinter:Say(060, 050, ": "+Capital(AllTrim(POSICIONE("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_DESC") ))					, oFont10N:oFont)
	oPrinter:Say(060, 290, "Protocolo de produção"	 										, oFont10:oFont)
	oPrinter:Say(060, 365, ": "																, oFont10N:oFont)

	oPrinter:Say(076, 019, "Código" 														, oFont10:oFont)
	oPrinter:Say(076, 050, ": "+SC2->C2_PRODUTO												, oFont10N:oFont)
	oPrinter:Say(076, 290, "Quantidade" 													, oFont10:oFont)
	oPrinter:Say(076, 365, ": "+STR(SC2->C2_QUANT, 14, 2)									, oFont10N:oFont)

	oPrinter:Say(092, 110, "N° Ordem de produção" 											, oFont10:oFont)
	oPrinter:Say(092, 190, ": "+PADR(SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN, 14)		, oFont10N:oFont)
	oPrinter:Say(092, 290, "Unidade de medida" 												, oFont10:oFont)
	oPrinter:Say(092, 365, ": "+POSICIONE("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_UM") 	, oFont10N:oFont)

	oPrinter:Say(108, 110, "Lote" 															, oFont10:oFont)
	oPrinter:Say(108, 140, ": "+SC2->C2_LOTECTL 											, oFont10N:oFont)
	oPrinter:Say(108, 290, "Hora inicial" 													, oFont10:oFont)
	oPrinter:Say(108, 330, " ______ : ______" 												, oFont10N:oFont)
	oPrinter:Say(108, 432, "Data inicial" 													, oFont10:oFont)
	oPrinter:Say(108, 480, "_____ / _____ / _______"										, oFont10N:oFont)

	oPrinter:Say(124, 110, "Validade" 														, oFont10:oFont)
	oPrinter:Say(124, 140, ": "+AllTrim(Str(ROUND(SB1->B1_PRVALID / 30, 0))) + " meses" + IIF(eMPTY(cDatVld), "", " - ") + cDatVld 	, oFont10N:oFont)
	oPrinter:Say(124, 290, "Hora final" 													, oFont10:oFont)
	oPrinter:Say(124, 330, " ______ : ______" 												, oFont10N:oFont)	
	oPrinter:Say(124, 432, "Data final" 													, oFont10:oFont)
	oPrinter:Say(124, 480, "_____ / _____ / _______" 										, oFont10N:oFont)

	oPrinter:QRCode(150,025,Alltrim(SC2->C2_NUM) + Alltrim(SC2->C2_ITEM) + Alltrim(SC2->C2_SEQUEN),70) 

	nLinha := 150
	
	FimPag() 

	IMPPRDEMP()

	nLinha += nSaltoFT11 * 2

	ALTEADIC()

	nLinha += nSaltoFT11 * 2

	LIMPEZA()

	nLinha += nSaltoFT11 * 2

	OBSERVA()
	

	oPrinter:EndPage()
 
	

Return Nil

/*
	@description Valida se chegou ao final da página
	@author Daniel Neumann - CI Result
	@since 12/01/2023
	@version 1.0
*/
Static Function FimPag()  

	If nLinha >= 820
		
		oPrinter:EndPage()
		oPrinter:StartPage()										   								
		
		nLinha	:= 30
		
	EndIf

Return 


/*
	@description Realiza a impressão dos produtos empenhados
	@author Daniel Neumann - CI Result
	@since 15/02/2023
	@version 1.0
*/
Static Function IMPPRDEMP()

	Local nI 		:= 0
	Local cAliasSD4 := GetNextAlias()
	Local nQtd		:= 0
	Local cLotes	:= ""
	Local aEmpenhos	:= {}
	Local nLinbkp	:= 0
	Local nLinha2	:= 0
	Local lLinhLot	:= .F.
	

	oPrinter:Say(nLinha, nMargemEsq	+ 200		, "Componentes do Produto"	, oFont12N:oFont)

	nLinha += nSaltoFT11

	oPrinter:Say(nLinha, nMargemEsq			, "Código"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 40	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 45	, "Descrição do Item"		, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 215	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 220	, "UN"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 240	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 245	, "Qtd Necessária"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 325	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 330	, "Lotes"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 400	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 405	, "Qdt Fracionada"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 475	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 480	, "Qtd Macro (Sacaria)"		, oFont10n:oFont)

	oPrinter:Line (nLinha += 5,  nMargemEsq, nLinha, 570)

	nLinha += nSaltoFT11

	//Buscar MP relacionadas a OP
	BeginSQL Alias cAliasSD4 
	
		SELECT 	D4_COD,
				B1_DESC,
				D4_QTDEORI,
				B1_UM,
				D4_LOTECTL
			FROM %TABLE:SD4% SD4 
			JOIN %TABLE:SB1% SB1 ON SB1.%NOTDEL% AND B1_COD = D4_COD
			WHERE 	SD4.%NOTDEL%
					AND D4_FILIAL 	= %EXP:xFilial("SD4")%
					AND D4_OP		= %EXP:cOrdOper%

				ORDER BY D4_COD

	EndSQL

	//GROUP BY D4_COD, B1_DESC, B1_UM, D4_LOTECTL   Agrupamento para impressão. 

	If (cAliasSD4)->(!EOF())

		While (cAliasSD4)->(!EOF())
			AADD(aEmpenhos, { (cAliasSD4)->D4_COD, (cAliasSD4)->B1_DESC, (cAliasSD4)->D4_QTDEORI, (cAliasSD4)->B1_UM, (cAliasSD4)->D4_LOTECTL })
			(cAliasSD4)->(DbSkip()) 
		EndDo

		(cAliasSD4)->(DbCloseArea())

		For nI := 1 To Len(aEmpenhos)
			
			nQtd 		+= aEmpenhos[nI][3]
			cLotes		:= aEmpenhos[nI][5]
			lLinhLot	:= .F.

			If nI == Len(aEmpenhos) .Or. aEmpenhos[nI][1] != aEmpenhos[nI + 1][1]
				
				//Verifica se chegou a fim da página para gerar outra.
				FimPag()  

				If nLinbkp > 0 

					nLinha += nSaltoFT11
					
					oPrinter:Say(nLinha , nMargemEsq + 325	, "|"																						, oFont10:oFont)
					oPrinter:Say(nLinha , nMargemEsq + 330	, cLotes																					, oFont10:oFont)
					oPrinter:Say(nLinha , nMargemEsq + 400	, "|"																						, oFont10:oFont)
					oPrinter:Say(nLinha , nMargemEsq + 405	, aEmpenhos[nI][4] + " - " + AllTrim(Strtran(Str(aEmpenhos[nI][3], 14, 3), ".", ","))		, oFont10:oFont)
					oPrinter:Say(nLinha , nMargemEsq + 475	, "|"																						, oFont10:oFont)

					cLotes		:= ""
					nLinha2 	:= nLinha
					nLinha 		:= nLinbkp
				EndIf 
				oPrinter:Say(nLinha, nMargemEsq			, AllTrim(aEmpenhos[nI][1])									, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq	+ 40	, "|"														, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq + 45	, SubStr(Capital(AllTrim(aEmpenhos[nI][2])), 0, 45)			, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq + 215	, "|"														, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq + 220	,  aEmpenhos[nI][4]											, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq + 240	, "|"														, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq	+ 245	, AllTrim(Strtran(Str(nQtd, 14, 3), ".", ","))				, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq + 325	, "|"														, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq	+ 330	, cLotes													, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq + 400	, "|"														, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq	+ 405	, ""														, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq + 475	, "|"														, oFont10:oFont)
				oPrinter:Say(nLinha, nMargemEsq	+ 480	, ""														, oFont10:oFont)

				nQtd	:= 0
				cLotes	:= ""
				nLinbkp	:= 0

				If nLinha2 > 0 
					nLinha 	:= nLinha2
					nLinha2	:= 0
				EndIf 
						
				oPrinter:Line (nLinha += 4,  nMargemEsq, nLinha, 570)

				nLinha += nSaltoFT11
			Else 
				If nLinbkp == 0 
					nLinbkp 	:= nLinha
					lLinhLot	:= .T.
				EndIf 	
				
				/*
				If lLinhLot 
					FimPag()
					oPrinter:Say(nLinha + 4 , nMargemEsq + 215	, "___________________________________________________________________", oFont10:oFont)
				EndIf 
				*/
				nLinha += nSaltoFT11

				FimPag() 

				//oPrinter:Say(nLinha , nMargemEsq + 215	, "|"																					, oFont10:oFont)
				//oPrinter:Say(nLinha , nMargemEsq + 220	,  aEmpenhos[nI][4]																		, oFont10:oFont)
				//oPrinter:Say(nLinha , nMargemEsq + 240	, "|"																					, oFont10:oFont)
				//oPrinter:Say(nLinha , nMargemEsq + 245	, AllTrim(Strtran(Str(aEmpenhos[nI][3], 14, 3), ".", ","))								, oFont10:oFont)
				oPrinter:Say(nLinha , nMargemEsq + 325	, "|"																						, oFont10:oFont)
				oPrinter:Say(nLinha , nMargemEsq + 330	, cLotes																					, oFont10:oFont)
				oPrinter:Say(nLinha , nMargemEsq + 400	, "|"																						, oFont10:oFont)
				oPrinter:Say(nLinha , nMargemEsq + 405	, aEmpenhos[nI][4] + " - " + AllTrim(Strtran(Str(aEmpenhos[nI][3], 14, 3), ".", ","))		, oFont10:oFont)
				oPrinter:Say(nLinha , nMargemEsq + 475	, "|"																						, oFont10:oFont)
				//cLotes += " - "
			EndIf 
		Next nI
	Else 
		//Verifica se chegou a fim da página para gerar outra.
		FimPag()  

		oPrinter:Say(nLinha, nMargemEsq			, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 40	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 45	, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 215	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 220	,  ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 240	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 245	, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 325	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 330	, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 400	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 405	, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 475	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 480	, ""			, oFont10:oFont)
		
		oPrinter:Line (nLinha += 4,  nMargemEsq, nLinha, 570)

		nLinha += nSaltoFT11

	EndIf 
	
Return



/*
	@author Daniel Neumann - CI Result
	@since 06/03/2023
	@version 1.0
*/
Static Function ALTEADIC()

	Local nI 		:= 0

				
	//Verifica se chegou a fim da página para gerar outra.
	FimPag()  
	
	oPrinter:Say(nLinha, nMargemEsq	+ 80		, "Alterações e Adições"	, oFont12N:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 400		, "Devolução"				, oFont12N:oFont)

	nLinha += nSaltoFT11

				
	//Verifica se chegou a fim da página para gerar outra.
	FimPag()  

	oPrinter:Say(nLinha, nMargemEsq			, "Descrição"				, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 150	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 155	, "Lote"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 215	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 220	, "Quantidade"				, oFont10n:oFont)

	oPrinter:Say(nLinha, 300				, "Descrição"				, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 440	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 445	, "Lote"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 500	, "|"						, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 505	, "Quantidade"				, oFont10n:oFont)

	oPrinter:Line (nLinha += 5	,  nMargemEsq	, nLinha, 285)
	oPrinter:Line (nLinha 		,  300			, nLinha, 570)

	nLinha += nSaltoFT11

	For nI := 1 To 7
	
		//Verifica se chegou a fim da página para gerar outra.
		FimPag()  

		oPrinter:Say(nLinha, nMargemEsq			, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 150	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 155	, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 215	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 220	, ""			, oFont10:oFont)
		
		oPrinter:Say(nLinha, 300				, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 440	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 445	, ""			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 500	, "|"			, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 505	, ""			, oFont10:oFont)
		
		//Verifica se chegou a fim da página para gerar outra.
		FimPag()  
		oPrinter:Line (nLinha += 4	,  nMargemEsq	, nLinha, 285)
		oPrinter:Line (nLinha 		,  300			, nLinha, 570)

		nLinha += nSaltoFT11

	Next nI
	
	
Return



/*
	@author Daniel Neumann - CI Result
	@since 06/03/2023
	@version 1.0
*/
Static Function LIMPEZA()

				
	//Verifica se chegou a fim da página para gerar outra.
	FimPag()  
	
	oPrinter:Say(nLinha						, nMargemEsq	+ 80		, "Registro de limpeza"					, oFont12N:oFont)
	oPrinter:Say(nLinha						, nMargemEsq	+ 345		, "Quantidade real produzida"			, oFont12N:oFont)
	oPrinter:Say(nLinha + nSaltoFT11 * 5	, nMargemEsq	+ 345		, "Tempo total de produção"				, oFont12N:oFont)

	nLinha += nSaltoFT11 

	//Verifica se chegou a fim da página para gerar outra.
	FimPag()  

	oPrinter:Say(nLinha, nMargemEsq			, "Pesagem"			, oFont10:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 100	, "|"					, oFont10:oFont)
	oPrinter:Line (nLinha += 4	,  nMargemEsq	, nLinha, 285)

	oPrinter:Line (nLinha	,  nMargemEsq + 345	, nLinha, 540)
	
	nLinha += nSaltoFT11

	//Verifica se chegou a fim da página para gerar outra.
	FimPag() 

	oPrinter:Say(nLinha, nMargemEsq			, "Abastecimento Bins"			, oFont10:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 100	, "|"					, oFont10:oFont)
	oPrinter:Line (nLinha += 4	,  nMargemEsq	, nLinha, 285)
	
	nLinha += nSaltoFT11

	//Verifica se chegou a fim da página para gerar outra.
	FimPag() 

	oPrinter:Say(nLinha, nMargemEsq			, "Cápsula"			, oFont10:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 100	, "|"					, oFont10:oFont)
	oPrinter:Line (nLinha += 4	,  nMargemEsq	, nLinha, 285)
	
	nLinha += nSaltoFT11

	//Verifica se chegou a fim da página para gerar outra.
	FimPag() 

	oPrinter:Say(nLinha, nMargemEsq			, "Envase"			, oFont10:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 100	, "|"					, oFont10:oFont)
	oPrinter:Line (nLinha += 4	,  nMargemEsq	, nLinha, 285)
	
	nLinha += nSaltoFT11

	//Verifica se chegou a fim da página para gerar outra.
	FimPag() 

	oPrinter:Say(nLinha, nMargemEsq			, "Sacheteira"			, oFont10:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 100	, "|"					, oFont10:oFont)
	oPrinter:Line (nLinha += 4	,  nMargemEsq	, nLinha, 285)

	oPrinter:Line (nLinha	,  nMargemEsq + 345	, nLinha, 540)
	
	nLinha += nSaltoFT11

	
Return



/*
	@author Daniel Neumann - CI Result
	@since 06/03/2023
	@version 1.0
*/
Static Function OBSERVA()

	Local nI := 0

	//Verifica se chegou a fim da página para gerar outra.
	FimPag()  
	
	oPrinter:Say(nLinha						, nMargemEsq		, "Observações"	, oFont12N:oFont)

	nLinha += nSaltoFT11 

	For nI := 1 To 7
	
		//Verifica se chegou a fim da página para gerar outra.
		FimPag()  

		oPrinter:Line (nLinha 		,  nMargemEsq			, nLinha, 570)

		nLinha += nSaltoFT11 + 4

	Next nI
	
	nLinha += nSaltoFT11

	
Return
