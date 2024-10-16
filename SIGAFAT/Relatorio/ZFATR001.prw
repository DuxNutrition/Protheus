#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TopConn.ch"

#Define STR_PULA		Chr(13)+Chr(10)

/*{Protheus.doc} 
Relat�rio de Picking por Pedido de Vendas.
@author Jedielson Rodrigues
@since 29/07/2024
@history 
@version P11,P12
@database MSSQL
*/

User Function ZFATR001()
                  
Local cPerg  		:= "ZFATR001"
Local aArea 		:= FwGetArea()

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
Private cNumPed     := " "
Private cLoja       := " "
Private cEmissao   	:= CTOD(" ")
Private cLogo		:= "system\LGMID.png"

//PutSX1( cGrupo, cOrdem, cTexto		, cMVPar	, cVariavel	, cTipoCamp	, nTamanho, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01	, cDef02			, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
U_PutSX1( cPerg	, "01"	, "Do Pedido  :"	, "mv_par01", "mv_ch1"	, "C"		, 06	  , 0			, "G"		,               	, 			, 			, 			,					,			,			,			,		, 			)
U_PutSX1( cPerg	, "02"	, "Ate Pedido :"	, "mv_par02", "mv_ch2"	, "C"		, 06	  , 0			, "G"		,               	, 			, 			, 			,					,			,			,			,		, 			)

If Pergunte(cPerg,.T.) 
	Processa({|| RelProc()}, "Filtrando...")
Else 
	FWRestArea(aArea)
	Return (.F.)
Endif

FWRestArea(aArea)

Return

Static Function RelProc()

Local lTemum  := .F.
Local cQryTmp := " "
Local nAtual  := 0

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
cQryTmp += " 	SC5.C5_NUM, "+CRLF
cQryTmp += "	SC5.C5_FILIAL, "+CRLF
cQryTmp += "	SC5.C5_EMISSAO, "+CRLF
cQryTmp += "	SC5.C5_CLIENT, "+CRLF
cQryTmp += "	SC5.C5_LOJACLI, "+CRLF
cQryTmp += "	SA1.A1_END, "+CRLF
cQryTmp += "	SA1.A1_BAIRRO, "+CRLF
cQryTmp += "	SA1.A1_MUN, "+CRLF
cQryTmp += "	SA1.A1_EST, "+CRLF
cQryTmp += "	SA1.A1_CEP, "+CRLF
cQryTmp += "	SA1.A1_NOME, "+CRLF
cQryTmp += "	SC5.C5_ZZNTRAN, "+CRLF
cQryTmp += "	SC5.C5_VOLUME1, "+CRLF
cQryTmp += "	SC5.C5_ESPECI1, "+CRLF
cQryTmp += "	SC6.C6_QTDVEN, "+CRLF
cQryTmp += "	SC6.C6_PRODUTO, "+CRLF
cQryTmp += "	SB1.B1_DESC, "+CRLF
cQryTmp += "	SB1.B1_UM, "+CRLF
cQryTmp += "	SC6.C6_LOCAL, "+CRLF
cQryTmp += "	SB1.B1_ZENDPIC, "+CRLF
cQryTmp += "	IsNull(SC9.C9_LOTECTL,'') AS C9_LOTECTL, "+CRLF
cQryTmp += "	IsNull(SC9.C9_DTVALID,'') AS C9_DTVALID "+CRLF
cQryTmp += " FROM " + RetSqlName("SC6") + " SC6 WITH(NOLOCK) "+CRLF
cQryTmp += " 	INNER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) "+CRLF
cQryTmp += " 		ON SC5.C5_FILIAL = SC6.C6_FILIAL "+CRLF
cQryTmp += " 		AND SC5.C5_NUM = SC6.C6_NUM "+CRLF
cQryTmp += "		AND SC5.C5_CLIENTE = SC6.C6_CLI "+CRLF
cQryTmp += "		AND SC5.C5_LOJACLI = SC6.C6_LOJA "+CRLF
cQryTmp += "		AND SC5.C5_XSTATUS = 'FRTOK' "+CRLF
cQryTmp += "		AND SC5.D_E_L_E_T_ = '' "+CRLF
cQryTmp += "	INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) "+CRLF
cQryTmp += "		ON SB1.B1_FILIAL = '"+FWxFilial("SB1")+"' "+CRLF
cQryTmp += "		AND SB1.B1_COD = SC6.C6_PRODUTO "+CRLF
cQryTmp += "		AND SB1.D_E_L_E_T_ = '' "+CRLF
cQryTmp += "	INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK) "+CRLF 
cQryTmp += "		ON SA1.A1_FILIAL = '"+FWxFilial("SA1")+"' "+CRLF
cQryTmp += "		AND SA1.A1_COD = SC6.C6_CLI "+CRLF
cQryTmp += "		AND SA1.A1_LOJA = SC6.C6_LOJA "+CRLF
cQryTmp += "		AND SA1.D_E_L_E_T_ = ' ' "+CRLF
cQryTmp += "	LEFT JOIN " + RetSqlName("SC9") + " SC9 WITH(NOLOCK) "+CRLF 
cQryTmp += "		ON SC9.C9_FILIAL = SC6.C6_FILIAL "+CRLF
cQryTmp += "		AND SC9.C9_PEDIDO = SC6.C6_NUM "+CRLF
cQryTmp += "		AND SC9.C9_ITEM = SC6.C6_ITEM "+CRLF
cQryTmp += "		AND SC9.C9_CLIENTE = SC5.C5_CLIENT "+CRLF
cQryTmp += "		AND SC9.C9_LOJA = SC5.C5_LOJACLI "+CRLF
cQryTmp += "		AND SC9.C9_NFISCAL = ' ' "+CRLF
cQryTmp += "		AND SC9.D_E_L_E_T_ = ' ' "+CRLF
cQryTmp += " WHERE SC6.C6_FILIAL = '"+FWxFilial("SC6")+"' "+CRLF 
cQryTmp += " AND SC6.C6_NOTA = ' ' "+CRLF
cQryTmp += " AND SC6.C6_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQryTmp += " AND SC6.C6_QTDVEN > 0 "+CRLF
cQryTmp += " AND SC6.C6_BLQ <> 'R' "+CRLF
cQryTmp += " AND SC6.D_E_L_E_T_ = ' ' "+CRLF
cQryTmp += " ORDER BY SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_CLI,SB1.B1_ZENDPIC,SC6.C6_PRODUTO,SC6.C6_ITEM,SC9.C9_LOTECTL,SC9.C9_DTVALID "+CRLF
		
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTmp),cAlsTMP,.T.,.F.)

Count to nReg 

ProcRegua(nReg)

If  nReg = 0 
	FWAlertError("N�o foram encontrados Pedidos de Vendas.","Aviso")
	Return
Endif

(cAlsTMP)->(dbGoTop())
While !(cAlsTMP)->(Eof())

	cNumPed  := ALLTRIM((cAlsTMP)->C5_NUM)
	cLoja    := (cAlsTMP)->C5_LOJACLI
	cEmissao := SToD((cAlsTMP)->C5_EMISSAO)
	 
	While !(cAlsTMP)->(Eof()) .AND. cNumPed == (cAlsTMP)->C5_NUM 

		If  nSalto >= 29
			If  nFolha > 0
				oPrinter:EndPage()
			Endif
			zCabPed() 
			nSalto := 0
		Endif

		nLinha += 20

		oPrinter:Say(nLinha, nMargemEsq + 30	, CValToChar((cAlsTMP)->C6_QTDVEN)	, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 50	, (cAlsTMP)->C6_PRODUTO				, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 100   , Substr((cAlsTMP)->B1_DESC,1,51)	, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq + 320	, (cAlsTMP)->B1_UM 					, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 350	, (cAlsTMP)->C6_LOCAL				, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 380	, (cAlsTMP)->B1_ZENDPIC				, oFont10:oFont) 
		oPrinter:Say(nLinha, nMargemEsq	+ 420	, (cAlsTMP)->C9_LOTECTL				, oFont10:oFont)
		oPrinter:Say(nLinha, nMargemEsq	+ 460	, DToC(SToD((cAlsTMP)->C9_DTVALID))	, oFont10:oFont)
		
		nSalto ++

		nAtual++
        IncProc("Processando registros " + cValToChar(nAtual) + " de " + cValToChar(nReg) + "...")

		(cAlsTMP)->(dbSkip())

		lTemum := .T.
	EndDo
	
	If !lTemum
		(cAlsTMP)->(dbSkip())
	Else
		nSalto := 30
		nFolha := 0
	Endif

EndDo

oPrinter:EndPage()
oPrinter:Preview()   

Return Nil

/*--------------------------------------
	Valida se chegou ao final da p�gina
----------------------------------------*/

Static Function zCabPed()  

    Local cCode     := cNumped
	Local nLinC		:= 3.60		//Linha que ser� impresso o C�digo de Barra
	Local nColC		:= 23.0		//Coluna que ser� impresso o C�digo de Barra
	Local nWidth	:= 0.0164	//Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta � 0.0164
	Local nHeigth   := 0.6		//Numero da Altura da barra. Default 1.5 --- limite de altura � 0.3
	//Local lBanner	:= .T.		//Se imprime a linha com o c�digo embaixo da barra. Default .T.
	Local nPFWidth	:= 0.8		//N�mero do �ndice de ajuste da largura da fonte. Default 1
	Local nPFHeigth	:= 0.9		//N�mero do �ndice de ajuste da altura da fonte. Default 1
	Local lCmtr2Pix	:= .T.		//Utiliza o m�todo Cmtr2Pix() do objeto Printer.Default .T.
 
	oPrinter:StartPage()										   								

	//dados do cabe�alho 
	oPrinter:SayBitmap(010, 025, cLogo,095, 70)	

	oPrinter:Say(040, 180, "PICK-LIST PEDIDO DE VENDAS"												, oFont12:oFont)

	oPrinter:Say(060, 223, cNumped																	, oFont18N:oFont)

	oPrinter:FWMSBAR("CODE128" , nLinC , nColC, cCode, oPrinter,/*lCheck*/,/*Color*/,/*lHorz*/, nWidth, nHeigth,.F.,/*cFont*/,/*cMode*/,.F./*lPrint*/,nPFWidth,nPFHeigth,lCmtr2Pix)
	
	oPrinter:Say(040, 420, "Emissao do Pedido:"														, oFont10n:oFont)
	oPrinter:Say(060, 420, cvaltochar(cEmissao)			        									, oFont16:oFont)

	//oPrinter:Say(075, 420, cCanal			        												, oFont12N:oFont)

	nFolha ++

	oPrinter:Say(040, 507, "Folha: "+cvaltochar(nFolha)												, oFont10:oFont)
		
	oPrinter:Box(080, 025, 120, 200	)	
	oPrinter:Say(090, 027, "Endere�o de Entrega" 													, oFont10N:oFont)
	
	dbSelectArea("SA1")
	If  dbSeek(xFilial("SA1") + (cAlsTMP)->C5_CLIENT + (cAlsTMP)->C5_LOJACLI)
		oPrinter:Say(100, 027, SA1->A1_END		       												, oFont10:oFont)
		oPrinter:Say(107, 027, SA1->A1_BAIRRO														, oFont10:oFont)
		oPrinter:Say(115, 027, "CEP " + SA1->A1_CEP+"-"+AllTrim(A1_MUN)+"-"+A1_EST					, oFont10:oFont)
	Endif
	
	oPrinter:Box(080, 200, 120, 537	)	
	oPrinter:Say(090, 207, "Nome"  																	, oFont10N:oFont)
	oPrinter:Say(103, 207, Substr(SA1->A1_NOME,1,45)												, oFont16:oFont)
	oPrinter:Say(113, 207, Substr(SA1->A1_NOME,46,90)												, oFont16:oFont)

	oPrinter:Box(122, 025, 145, 537	)	
	oPrinter:Say(130, 027, "Separador:"  															, oFont10N:oFont)
	oPrinter:Say(130, 106, "Conferente:"  															, oFont10N:oFont)
	oPrinter:Say(130, 206, "Transportadora:"  														, oFont10N:oFont)
	oPrinter:Say(140, 206, ALLTRIM((cAlsTMP)->C5_ZZNTRAN)				 			   				, oFont10:oFont)
	
	
	oPrinter:Say(130, 456, "Volumes:"  																, oFont10N:oFont)
	oPrinter:Say(140, 456, cvaltochar((cAlsTMP)->C5_VOLUME1)+" "+(cAlsTMP)->C5_ESPECI1				, oFont10:oFont)

	nLinha	:= 50		

	// Imprime dados do Pedido

	nLinha += 120

	oPrinter:Box(nLinha-10, 025, nLinha+600, 537)	
	oPrinter:Say(nLinha, nMargemEsq	+ 2		, "Quantidade"		, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 50	, "C�digo"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 100	, "Nome"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq + 320	, "U.M" 			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 350	, "Local"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 380	, "Endere�o"		, oFont10n:oFont) 
	oPrinter:Say(nLinha, nMargemEsq	+ 420	, "Lote"			, oFont10n:oFont)
	oPrinter:Say(nLinha, nMargemEsq	+ 460	, "Validade"		, oFont10n:oFont)

Return 
