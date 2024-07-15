#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TopConn.ch"

#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} ZGENPDF1
	@description Função para Gerar e Gravar em Pdf
	@author Jedielson Rodrigues
	@since 11/07/2024
	@version 1.0
*/

User Function ZGENPDF1(aDescItens,aItemSuces,cSubject,cRotina)

Local cCodProd      := " "
Local nQtd        	:= 0		             
Local cLote	        := " "
Local cLocal 	    := " "                
Local cDtValid      := " "
Local cStatus  		:= " "                
Local cDoc 	 		:= " "
Local cMotBloc 		:= " "
Local nI            := 0
Local nZ			:= 0
Local cCodUsr       := Iif(Empty(RetCodUsr()),"000000",RetCodUsr())
Local cPdfFileName  := ALLTRIM(cRotina)+'_'+cCodUsr+'_'+Substring(Dtoc(Date()),1,2)+Substring(Dtoc(Date()),4,2)+Substring(Dtoc(Date()),9,2)+'_'+Substring(Time(),1,2) +Substring(Time(),4,2) +Substring(Time(),7,2)+'.Pdf'

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
Private oFont13N    := Nil

Private nEstru		:= 0
Private nFolha      := 0
Private nSalto      := 30
Private nLinha      := 0
Private nMargemEsq  := 25
Private cLogo		:= "system\LGMID.png"

Default aMargItens := {}
Default aDescItens := {}
Default aItemSuces := {}
Default cSubject   := " "
Default cRotina    := " "

fErase(GetTempPath() + cPdfFileName)
oPrinter:= FWMSPrinter():New(cPdfFileName, IMP_PDF, .F.,, .T.) 
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
oFont13N   := TFontEx():New(oPrinter,"Arial",12,12,.F.,.T.,.F.)
oFont16N   := TFontEx():New(oPrinter,"Arial",15,15,.T.,.T.,.F.)
oFont18N   := TFontEx():New(oPrinter,"Arial",17,17,.T.,.T.,.F.)

//Array das descrições dos Itens 

	If  nSalto >= 29
			If  nFolha > 0
				oPrinter:EndPage()
			Endif
			FimPag(cSubject,cRotina) 
			nSalto := 0
	Endif

	If Len (aDescItens) > 0
		For nZ := 1  To Len( aDescItens )
		
			oPrinter:Say(nLinha, nMargemEsq	+ aDescItens[nZ][1] , aDescItens[nZ][2]		, oFont10n:oFont)

		Next nZ
			
		nLinha += 20
	Endif

	For nI:= 1 To Len( aItemSuces )

		If  nSalto >= 29
			If  nFolha > 0
				oPrinter:EndPage()
			Endif
			FimPag(cSubject,cRotina) 
			nSalto := 0
		Endif

			oPrinter:Say(nLinha, nMargemEsq + aItemSuces[nI][1] , aItemSuces[nI][2] 	, oFont10:oFont)
		
		 nSalto ++

	Next nI

oPrinter:EndPage()
oPrinter:Preview()   

Return Nil

/*--------------------------------------
	Valida se chegou ao final da página
----------------------------------------*/

Static Function FimPag(cSubject,cRotina)  

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
	Local cData 	:= Transform(dDataBase, "@D 99/99/9999")
	Local cDescFil	:= FwFilialName()
	Local cCompany  := "Dux Company Ltda"
	Local cAssunto  := cSubject
 
	oPrinter:StartPage()										   								

	//dados do cabeçalho 
	oPrinter:SayBitmap(010, 025, cLogo,095, 70)	

	oPrinter:Say(040, 180,	cAssunto														, oFont16N:oFont)

	nFolha ++

	oPrinter:Say(040, 507, "Folha: "+cvaltochar(nFolha)										, oFont10:oFont)

	oPrinter:Box(080, 025, 107, 537	)	
	oPrinter:Say(090, 031, "Empresa/Filial:"  												, oFont10N:oFont)
	oPrinter:Say(100, 031, cEmpAnt+'/'+cFilAnt		       									, oFont10:oFont)

	oPrinter:Say(090, 250, "Razao Social:"  												, oFont10N:oFont)
	oPrinter:Say(100, 250, cCompany		       												, oFont10:oFont)

	oPrinter:Say(090, 450, "Nome da Filial:"  												, oFont10N:oFont)
	oPrinter:Say(100, 450, cDescFil				 											, oFont10:oFont)

	oPrinter:Box(110, 025, 137, 537	)	
	oPrinter:Say(120, 031, "Data:"  														, oFont10N:oFont)
	oPrinter:Say(130, 031, cData		       												, oFont10:oFont)

	oPrinter:Say(120, 250, "Hora:"  														, oFont10N:oFont)
	oPrinter:Say(130, 250, Time()		       												, oFont10:oFont)

	oPrinter:Say(120, 450, "Rotina:"  														, oFont10N:oFont)
	oPrinter:Say(130, 450, cRotina				 											, oFont10:oFont)

	nLinha	:= 50		

	// Imprime Itens Bloqueados

	nLinha += 120

	oPrinter:Box(nLinha-10, 025, nLinha+600, 537)	
	
Return 

 