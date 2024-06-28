#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TopConn.ch"

#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} DUXR775
	@description Pick-List Nota Fiscal
	@author Marlovani - CI Result
	@since 20/03/2023
	@version 1.0
*/

User Function DUXR775()

Local cQuery        := ""
Local cCodProd      := ""
Local nQtdIt        := 0
Local cDescProd     := ""
Local cUnidade      := ""		             
Local cLote	        := ""
Local cLocal 	    := ""                
Local cDtValid      := ""
LOCAL cPerg  		:= "DUXPIC"
Local lTemum        := .F.

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
Private cNFiscal    := 0
Private cSerie      := 0
Private cDtFat      := 0
Private cLogo		:= "system\LGMID.png"

//PutSX1( cGrupo, cOrdem, cTexto		, cMVPar	, cVariavel	, cTipoCamp	, nTamanho, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01	, cDef02			, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
//u_PutSX1( cPerg	, "01"	, "Da  Nota :"	, "mv_par01", "mv_ch1"	, "C"		, 09	  , 0			, "G"		,               	, 			, 			, 			,					,			,			,			,		, 			)
//u_PutSX1( cPerg	, "02"	, "Até Nota :"	, "mv_par02", "mv_ch2"	, "C"		, 09	  , 0			, "G"		,               	, 			, 			, 			,					,			,			,			,		, 			)
//u_PutSX1( cPerg	, "03"	, "Série    :"	, "mv_par03", "mv_ch3"	, "C"		, 03	  , 0			, "G"		,               	, 			, 			, 			,					,			,			,			,		, 			)

Pergunte(cPerg,.T.)

fErase(GetTempPath() + "DUXR775_" + DTOS(DATE()) + ".pdf")
oPrinter:= FWMSPrinter():New("DUXR775_" + DTOS(DATE()), IMP_PDF, .F.,, .T.) 
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
	
//----------------------------------------------------------- Seleção de registros
cAliasSD2 := "C775Imp"

cQuery := "SELECT SD2.R_E_C_N_O_ SD2REC,"
cQuery += "SD2.D2_DOC,SD2.D2_FILIAL,SD2.D2_SERIE,SD2.D2_QUANT,SD2.D2_COD, SD2.D2_NUMSEQ, SD2.D2_EMISSAO, SD2.D2_CLIENTE,"
cQuery += "SD2.D2_LOJA, SD2.D2_LOCAL,SD2.D2_GRADE,SD2.D2_LOTECTL,SD2.D2_POTENCI, SD2.D2_ITEM, "
cQuery += "SD2.D2_NUMLOTE,SD2.D2_DTVALID,SD2.D2_PEDIDO,SD2.D2_ITEMPV,"
cQuery += "SF2.F2_ESPECI1,SF2.F2_VOLUME1,SF2.F2_TRANSP "
cQuery += " FROM "
cQuery += RetSqlName("SD2") + " SD2, " + RetSqlName("SF2") + " SF2 "
cQuery += "WHERE "                   
cQuery += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
cQuery += IIf(!Empty(mv_par03),"SD2.D2_SERIE = '"+mv_par03+"' AND ", "" )
cQuery += "SD2.D2_DOC between '"+mv_par01+"' AND '"+mv_par02+"' AND " 
cQuery += "SD2.D2_QUANT > 0 AND "
cQuery += "SD2.D_E_L_E_T_ = ' ' AND "
cQuery += "SD2.D2_FILIAL= SF2.F2_FILIAL   AND " 
cQuery += "SD2.D2_DOC   = SF2.F2_DOC   AND " 
cQuery += "SD2.D2_SERIE = SF2.F2_SERIE AND " 
cQuery += "SF2.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_COD,SD2.D2_LOTECTL,"
cQuery += "SD2.D2_NUMLOTE,SD2.D2_DTVALID"
		
cQuery := ChangeQuery(cQuery)
//Memowrite("C:\TMP\QryPickListNotas.txt",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)

Count to nReg 

If  nReg = 0 
	msgstop("Não foram encontradas as notas.")
	Return
Endif

(cAliasSD2)->(dbGoTop())

While (cAliasSD2)->(!Eof())
	cNFiscal := (cAliasSD2)->D2_DOC
	cSerie   := (cAliasSD2)->D2_SERIE
	cDtFat   := STOD((cAliasSD2)->D2_EMISSAO)

	While (cAliasSD2)->(!Eof()) .and. cNFiscal = (cAliasSD2)->D2_DOC .and. cSerie = (cAliasSD2)->D2_SERIE 

		If  nSalto >= 29
			If  nFolha > 0
				oPrinter:EndPage()
			Endif
			FimPag() 
			nSalto := 0
		Endif

		// Imprime dados dos itens
	
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1") + (cAliasSD2)->D2_COD)

		cCodProd := (cAliasSD2)->D2_COD
		nQtdIt   := (cAliasSD2)->D2_QUANT
		cDescProd:= Subs(SB1->B1_DESC,1,50)
		cUnidade := SB1->B1_UM		             
		cLote	 := (cAliasSD2)->D2_LOTECTL
		cLocal 	 := (cAliasSD2)->D2_LOCAL                
		cDtValid := DTOC(STOD((cAliasSD2)->D2_DTVALID))

		nLinha += 20

		oPrinter:Say(nLinha, nMargemEsq + 30	, cvaltochar(nQtdIt)		, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 80	, cCodProd					, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 120   , cDescProd					, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 340	, cUnidade 					, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 380	, cLocal					, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 420	, cLote						, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 460	, cDtValid					, oFont10:oFont)

		nSalto ++

		(cAliasSD2)->(dbSkip())

		lTemum := .T.
	End
	
	If !lTemum
		(cAliasSD2)->(dbSkip())
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

Static Function FimPag()  

    Local cCode     := cNFiscal
//	Local nLinC		:= 4.95		//Linha que será impresso o Código de Barra
//	Local nColC		:= 1.6		//Coluna que será impresso o Código de Barra
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

	oPrinter:Say(060, 200, cvaltochar(cNFiscal)												, oFont18N:oFont)

	oPrinter:FWMSBAR("CODE128" , nLinC , nColC, cCode, oPrinter,/*lCheck*/,/*Color*/,/*lHorz*/, nWidth, nHeigth,.F.,/*cFont*/,/*cMode*/,.F./*lPrint*/,nPFWidth,nPFHeigth,lCmtr2Pix)
	
	oPrinter:Say(040, 420, "Data Faturamento:"												, oFont10n:oFont)
	oPrinter:Say(060, 420, cvaltochar(cDtFat)			        							, oFont16:oFont)

	nFolha ++

	oPrinter:Say(040, 507, "Folha: "+cvaltochar(nFolha)										, oFont10:oFont)
		
	oPrinter:Box(080, 025, 120, 200	)	
	oPrinter:Say(090, 027, "Endereço de Entrega" 											, oFont10N:oFont)
	
	dbSelectArea("SA1")
	If  dbSeek(xFilial("SA1") + (cAliasSD2)->D2_CLIENTE +(cAliasSD2)->D2_LOJA)
		oPrinter:Say(100, 027, SA1->A1_END		       										, oFont10:oFont)
		oPrinter:Say(107, 027, SA1->A1_BAIRRO												, oFont10:oFont)
		oPrinter:Say(115, 027, "CEP " + SA1->A1_CEP+"-"+AllTrim(A1_MUN)+"-"+A1_EST					, oFont10:oFont)
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
	If  dbSeek(xFilial("SA4") + (cAliasSD2)->F2_TRANSP)
		oPrinter:Say(140, 206, SA4->A4_NOME				 									, oFont10:oFont)
	Endif
	
	oPrinter:Say(130, 456, "Volumes:"  														, oFont10N:oFont)
	oPrinter:Say(140, 456, cvaltochar((cAliasSD2)->F2_VOLUME1)+" "+(cAliasSD2)->F2_ESPECI1  , oFont10:oFont)

	nLinha	:= 50		

	// Imprime dados da nota

	nLinha += 120

	oPrinter:Box(nLinha-10, 025, nLinha+600, 537)	
	oPrinter:Say(nLinha, nMargemEsq	+ 2		, "Quantidade(em UN)"		, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 80	, "Código"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 120	, "Nome"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 340	, "Unid" 					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 380	, "Local"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 420	, "Lote"					, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 460	, "Validade"				, oFont10n:oFont)

Return 

//	oPrinter:FWMSBAR("CODE128" , nLinC , nColC, alltrim(QRYTMP-&gt;CODBAR), oPrinter,/*lCheck*/,/*Color*/,/*lHorz*/, nWidth, nHeigth,.F.,/*cFont*/,/*cMode*/,.F./*lPrint*/,nPFWidth,nPFHeigth,lCmtr2Pix)
 