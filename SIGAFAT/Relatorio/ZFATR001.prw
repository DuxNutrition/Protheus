#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TopConn.ch"

#Define STR_PULA		Chr(13)+Chr(10)

/*{Protheus.doc} 
Relatório de Picking por Pedido de Vendas.
@author Jedielson Rodrigues
@since 29/07/2024
@history 
@version P11,P12
@database MSSQL
*/

User Function ZFATR001()
                  
Local cPerg  		:= "ZFATR001"
Local lTemum        := .F.
Local cQryTmp		:= " "

Private cAlsTMP 	:= GetNextAlias()  
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

Private nEstru		:= 0
Private nFolha      := 0
Private nSalto      := 30
Private nLinha      := 0
Private nMargemEsq  := 25
Private cNFiscal    := " "
Private cSerie      := " "
Private cDtFat   	:= CTOD(" ")
Private cCanal		:= " "
Private cLogo		:= "system\LGMID.png"

//PutSX1( cGrupo, cOrdem, cTexto		, cMVPar	, cVariavel	, cTipoCamp	, nTamanho, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01	, cDef02			, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
U_PutSX1( cPerg	, "01"	, "Do Pedido  :"	, "mv_par01", "mv_ch1"	, "C"		, 09	  , 0			, "G"		,               	, 			, 			, 			,					,			,			,			,		, 			)
U_PutSX1( cPerg	, "02"	, "Até Pedido :"	, "mv_par02", "mv_ch2"	, "C"		, 09	  , 0			, "G"		,               	, 			, 			, 			,					,			,			,			,		, 			)

Pergunte(cPerg,.T.)

fErase(GetTempPath() + "ZFATR001_" + DTOS(DATE()) + ".pdf")
oPrinter:= FWMSPrinter():New("ZFATR001_" + DTOS(DATE()), IMP_PDF, .F.,, .T.) 
oPrinter:cPathPDF := GetTempPath()     
oPrinter:SetPortrait()  
oPrinter:SetResolution(72)  
oPrinter:SetPaperSize(9)   

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
oFont16N   := TFontEx():New(oPrinter,"Arial",15,15,.T.,.T.,.F.)
oFont18N   := TFontEx():New(oPrinter,"Arial",17,17,.T.,.T.,.F.)
	
If Select(cAlsTMP) > 0
	(cAlsTMP)->(dbCloseArea())
EndIf

cQryTmp := " SELECT "+CRLF
cQryTmp += " CASE "+CRLF
cQryTmp += " 	WHEN SA1.A1_ZZESTAB = 'AC'		THEN 'ACADEMIA/CROSSFIT' "+CRLF
cQryTmp += " 	WHEN SA1.A1_ZZESTAB = 'BS'		THEN 'BODY SHOP' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'CE'		THEN 'CLUBE ESPORTIVO' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'CREF'	THEN 'EDUCADOR FISICO' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'CRM'		THEN 'MEDICOS' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'CRN'		THEN 'NUTRICIONISTAS' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'DF'		THEN 'DROGARIA/ FARMACIA' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'DI'		THEN 'DISTRIBUIDORA' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'EC'		THEN 'ECOMMERCE' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'FS'		THEN 'FOOD SERVICE' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'OU'		THEN 'OUTROS' "+CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'PN'		THEN 'LJ PRODUTOS NATURAIS' " +CRLF
cQryTmp += "	WHEN SA1.A1_ZZESTAB = 'SM'		THEN 'SUPERMERCADOS' "+CRLF
cQryTmp += " 	ELSE SA1.A1_ZZESTAB "+CRLF
cQryTmp += " 	END AS 'CANAL_DE_VENDA' "+CRLF
cQryTmp += " 	,SB1.B1_ZENDPIC "+CRLF	
cQryTmp += " 	,SD2.D2_DOC "+CRLF
cQryTmp += " 	,SD2.D2_FILIAL "+CRLF
cQryTmp += " 	,SD2.D2_SERIE "+CRLF
cQryTmp += " 	,SD2.D2_QUANT "+CRLF
cQryTmp += " 	,SD2.D2_COD "+CRLF
cQryTmp += " 	,SD2.D2_NUMSEQ "+CRLF
cQryTmp += " 	,SD2.D2_EMISSAO "+CRLF
cQryTmp += " 	,SD2.D2_CLIENTE "+CRLF
cQryTmp += " 	,SD2.D2_LOJA "+CRLF
cQryTmp += " 	,SD2.D2_LOCAL "+CRLF
cQryTmp += " 	,SD2.D2_GRADE "+CRLF
cQryTmp += " 	,SD2.D2_LOTECTL "+CRLF
cQryTmp += " 	,SD2.D2_POTENCI "+CRLF
cQryTmp += " 	,SD2.D2_ITEM "+CRLF
cQryTmp += " 	,SD2.D2_NUMLOTE "+CRLF
cQryTmp += " 	,SD2.D2_DTVALID "+CRLF
cQryTmp += " 	,SD2.D2_PEDIDO "+CRLF
cQryTmp += " 	,SD2.D2_ITEMPV "+CRLF
cQryTmp += " 	,SF2.F2_ESPECI1 "+CRLF
cQryTmp += " 	,SF2.F2_VOLUME1 "+CRLF
cQryTmp += " 	,SF2.F2_TRANSP "+CRLF
cQryTmp += " 	,SB1.B1_ZENDPIC "+CRLF
cQryTmp += " 	,SB1.B1_DESC "+CRLF
cQryTmp += " 	,SB1.B1_UM "+CRLF
cQryTmp += " FROM " + RetSqlName("SD2") + " SD2 "+CRLF
cQryTmp += " 	INNER JOIN " + RetSqlName("SF2") + " SF2 "+CRLF
cQryTmp += " 		ON SF2.F2_FILIAL = SD2.D2_FILIAL "+CRLF
cQryTmp += " 		AND SF2.F2_DOC = SD2.D2_DOC "+CRLF
cQryTmp += " 		AND SF2.F2_SERIE = SD2.D2_SERIE "+CRLF
cQryTmp += " 		AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "+CRLF 
cQryTmp += " 		AND SF2.F2_LOJA = SD2.D2_LOJA "+CRLF
cQryTmp += " 		AND SF2.D_E_L_E_T_ = ' ' "+CRLF
cQryTmp += "	INNER JOIN " + RetSqlName("SA1") + " SA1 "+CRLF
cQryTmp += " 		ON SF2.F2_CLIENTE = SA1.A1_COD "+CRLF
cQryTmp += "		AND SA1.D_E_L_E_T_ = '' "+CRLF
cQryTmp += " 	INNER JOIN " + RetSqlName("SB1") + " SB1 "+CRLF
cQryTmp += " 		ON SB1.B1_FILIAL = '"+FWxFilial("SB1")+"' "+CRLF
cQryTmp += " 		AND SB1.B1_COD = SD2.D2_COD "+CRLF
cQryTmp += " 		AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQryTmp += " WHERE SD2.D2_FILIAL = '"+FWxFilial("SD2")+"' "+CRLF
cQryTmp += " AND SD2.D2_DOC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF 
If !Empty(MV_PAR03)
	cQryTmp += " AND SD2.D2_SERIE = '"+MV_PAR03+"' "+ CRLF
EndIf
cQryTmp += " AND SD2.D2_QUANT > 0 "+CRLF
cQryTmp += " AND SD2.D_E_L_E_T_ = ' ' "+CRLF
cQryTmp += " ORDER BY SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SB1.B1_ZENDPIC,SD2.D2_COD,SD2.D2_LOTECTL, "+CRLF
cQryTmp += " SD2.D2_NUMLOTE,SD2.D2_DTVALID "+CRLF
		
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTmp),cAlsTMP,.T.,.F.)

Count to nReg 

If  nReg = 0 
	msgstop("Não foram encontradas as notas.")
	Return
Endif

(cAlsTMP)->(dbGoTop())
While !(cAlsTMP)->(Eof())

	cNFiscal := (cAlsTMP)->D2_DOC
	cSerie   := (cAlsTMP)->D2_SERIE
	cDtFat   := SToD((cAlsTMP)->D2_EMISSAO)
	cCanal 	 := FwCutOff(ALLTRIM((cAlsTMP)->CANAL_DE_VENDA), .T.) 

	While !(cAlsTMP)->(Eof()) .and. cNFiscal == (cAlsTMP)->D2_DOC .and. cSerie == (cAlsTMP)->D2_SERIE 

		If  nSalto >= 29
			If  nFolha > 0
				oPrinter:EndPage()
			Endif
			zFimPag() 
			nSalto := 0
		Endif

		nLinha += 20

		oPrinter:Say(nLinha, nMargemEsq + 30	, CValToChar((cAlsTMP)->D2_QUANT)	, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 50	, (cAlsTMP)->D2_COD					, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 100   , Substr((cAlsTMP)->B1_DESC,1,51)	, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 320	, (cAlsTMP)->B1_UM 					, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 350	, (cAlsTMP)->D2_LOCAL				, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 380	, (cAlsTMP)->B1_ZENDPIC				, oFont10:oFont) 
		oPrinter:Say(nLinha, nMargemEsq	+ 420	, (cAlsTMP)->D2_LOTECTL				, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 460	, DToC(SToD((cAlsTMP)->D2_DTVALID))	, oFont10:oFont)
		
		nSalto ++

		(cAlsTMP)->(dbSkip())

		lTemum := .T.
	End
	
	If !lTemum
		(cAlsTMP)->(dbSkip())
	Else
		nSalto := 30
		nFolha := 0
	ENDIF

End

oPrinter:EndPage()
oPrinter:Preview()   

Return Nil

/*--------------------------------------
	Valida se chegou ao final da página
----------------------------------------*/

Static Function zFimPag()  

    Local cCode     := cNFiscal
	Local nLinC		:= 3.60		//Linha que será impresso o Código de Barra
	Local nColC		:= 23.0		//Coluna que será impresso o Código de Barra
	Local nWidth	:= 0.0164	//Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta é 0.0164
	Local nHeigth   := 0.6		//Numero da Altura da barra. Default 1.5 --- limite de altura é 0.3
	//Local lBanner	:= .T.		//Se imprime a linha com o código embaixo da barra. Default .T.
	Local nPFWidth	:= 0.8		//Número do índice de ajuste da largura da fonte. Default 1
	Local nPFHeigth	:= 0.9		//Número do índice de ajuste da altura da fonte. Default 1
	Local lCmtr2Pix	:= .T.		//Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.
 
	oPrinter:StartPage()										   								

	//dados do cabeçalho 
	oPrinter:SayBitmap(010, 025, cLogo,095, 70)	

	oPrinter:Say(040, 180, "PICK-LIST NOTA FISCAL"											, oFont12:oFont)

	oPrinter:Say(060, 200, cNFiscal															, oFont18N:oFont)

	oPrinter:FWMSBAR("CODE128" , nLinC , nColC, cCode, oPrinter,/*lCheck*/,/*Color*/,/*lHorz*/, nWidth, nHeigth,.F.,/*cFont*/,/*cMode*/,.F./*lPrint*/,nPFWidth,nPFHeigth,lCmtr2Pix)
	
	oPrinter:Say(040, 420, "Data Faturamento:"												, oFont10n:oFont)
	oPrinter:Say(060, 420, cvaltochar(cDtFat)			        							, oFont16:oFont)

	oPrinter:Say(075, 420, cCanal			        										, oFont12N:oFont)

	nFolha ++

	oPrinter:Say(040, 507, "Folha: "+cvaltochar(nFolha)										, oFont10:oFont)
		
	oPrinter:Box(080, 025, 120, 200	)	
	oPrinter:Say(090, 027, "Endereço de Entrega" 											, oFont10N:oFont)
	
	dbSelectArea("SA1")
	If  dbSeek(xFilial("SA1") + (cAlsTMP)->D2_CLIENTE +(cAlsTMP)->D2_LOJA)
		oPrinter:Say(100, 027, SA1->A1_END		       										, oFont10:oFont)
		oPrinter:Say(107, 027, SA1->A1_BAIRRO												, oFont10:oFont)
		oPrinter:Say(115, 027, "CEP " + SA1->A1_CEP+"-"+AllTrim(A1_MUN)+"-"+A1_EST			, oFont10:oFont)
	Endif
	
	oPrinter:Box(080, 200, 120, 537	)	
	oPrinter:Say(090, 207, "Nome"  															, oFont10N:oFont)
	oPrinter:Say(103, 207, Substr(SA1->A1_NOME,1,45)										, oFont16:oFont)
	oPrinter:Say(113, 207, Substr(SA1->A1_NOME,46,90)										, oFont16:oFont)

	oPrinter:Box(122, 025, 145, 537	)	
	oPrinter:Say(130, 027, "Separador:"  													, oFont10N:oFont)
	oPrinter:Say(130, 106, "Conferente:"  													, oFont10N:oFont)
	oPrinter:Say(130, 206, "Transportadora:"  												, oFont10N:oFont)
		
	dbSelectArea("SA4")
	If  dbSeek(xFilial("SA4") + (cAlsTMP)->F2_TRANSP)
		oPrinter:Say(140, 206, SA4->A4_NOME				 									, oFont10:oFont)
	Endif
	
	oPrinter:Say(130, 456, "Volumes:"  														, oFont10N:oFont)
	oPrinter:Say(140, 456, cvaltochar((cAlsTMP)->F2_VOLUME1)+" "+(cAlsTMP)->F2_ESPECI1  	, oFont10:oFont)

	nLinha	:= 50		

	// Imprime dados da nota

	nLinha += 120

	oPrinter:Box(nLinha-10, 025, nLinha+600, 537)	
	oPrinter:Say(nLinha, nMargemEsq	+ 2		, "Quantidade"		, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 50	, "Código"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 100	, "Nome"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 320	, "Unid" 			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 350	, "Local"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 380	, "Endereço"		, oFont10n:oFont) 
	oPrinter:Say(nLinha, nMargemEsq	+ 420	, "Lote"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 460	, "Validade"		, oFont10n:oFont)

Return 
