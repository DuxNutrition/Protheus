#include "totvs.ch"
#include "FWPrintSetup.ch"
#include "RPTDEF.ch"

/*{Protheus.doc} NOTAS

Rotina responsável pela consulta de notas para impressao
Geeker
*/
User Function ZNotas()

	Local aSizeDlg   := FwGetDialogSize(oMainWnd)
	Local nHeight    := aSizeDlg[3]
	Local nWidth     := aSizeDlg[4]
	Local nLargBtn   := 50
	Private oFwLayer
	Private oPanTitulo
	Private oPanGrid
	Private oPanHeader
	Private oSayModulo, cSayModulo := ''
	Private oSaySubTit, cSaySubTit := 'IMPRESSÃO DANFE'
	Private oSayTitulo, cSayTitulo := ''
	Private cFontUti    := "Tahoma"
	Private oFontMod    := TFont():New(cFontUti, , -38)
	Private oFontSub    := TFont():New(cFontUti, , -20)
	Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
	Private oFontBtn    := TFont():New(cFontUti, , -14)
	Private oFontSay    := TFont():New(cFontUti, , -12)
	Private lMarker  := .T.
	Private aNotas   := {}
	Private cChaveNfe:= ""

	//Alimenta o array
	Filtronota()

	DEFINE MsDIALOG o3Dlg FROM 0,0 TO nHeight, nWidth TITLE "Impressão de Notas" PIXEL of oMainWnd

	oPnMaster := tPanel():New(0,0,,o3Dlg,,,,,,0,0)
	oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT
	//Criando a barra de botões
	oButtonBar := FWButtonBar():new()
	oButtonBar:Init( o3Dlg, 015, 015, CONTROL_ALIGN_LEFT, .T. )
	oButtonBar:AddBtnImage( "SALVAR.PNG", "GERA PDF", {|| Verifinota(aNotas)}, , ,  )
	//oButtonBar:addBtnText( "PESQUISA.PNG",	"GERA PDF", bNotas,,, CONTROL_ALIGN_LEFT, .T.)
	//Criando a camada
	oFwLayer := FwLayer():New()
	oFwLayer:init(o3Dlg,.F.)


	//Adicionando 3 linhas, a de título, a superior e a do calendário
	oFWLayer:addLine("TIT", 10, .F.)
	oFWLayer:addLine("COR", 90, .F.)

	//Adicionando as colunas das linhas
	oFWLayer:addCollumn("HEADERTEXT",   050, .T., "TIT")
	oFWLayer:addCollumn("BLANKBTN",     040, .T., "TIT")
	oFWLayer:addCollumn("BTNSAIR",      010, .T., "TIT")
	oFWLayer:addCollumn("COLGRID",      120, .T., "COR")
	//Criando os paineis
	oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TIT")
	oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TIT")
	oPanGrid   := oFWLayer:GetColPanel("COLGRID",    "COR")
	oSayModulo := TSay():New(004, 003, {|| cSayModulo}, oPanHeader, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
	oSayTitulo := TSay():New(004, 045, {|| cSayTitulo}, oPanHeader, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
	oSaySubTit := TSay():New(001, 035, {|| cSaySubTit}, oPanHeader, "", oFontSubN, , , , .T., RGB(021, 083, 125), , 300, 30, , , , , , .F., , )
	oBtnSair := TButton():New(006, 001, "Cancelar",             oPanSair, {|| o3Dlg:End()}, nLargBtn, 018, , oFontBtn, , .T., , , , , , )

	oDespesBrw := fwBrowse():New()
	oDespesBrw:setOwner( oPanGrid )

	oDespesBrw:setDataArray()
	oDespesBrw:setArray( aNotas )
	oDespesBrw:disableConfig()
	oDespesBrw:disableReport()

	oDespesBrw:SetLocate() // Habilita a Localização de registros

	oDespesBrw:AddMarkColumns({|| IIf(aNotas[oDespesBrw:nAt,01], "LBOK", "LBNO")},; //Code-Block image
		{|| SelectOne(oDespesBrw, aNotas)},; //Code-Block Double Click
		{|| SelectAll(oDespesBrw, 01, aNotas) }) //Code-Block Header Click

	oDespesBrw:addColumn({"Filial"            , {||aNotas[oDespesBrw:nAt,02]}, "C", "@!"    , 1,  07    ,                            , .T. , , .F.,, "aNotas[oDespesBrw:nAt,02]",, .F., .T.,                                    , "ETDESPES1"    })
	oDespesBrw:addColumn({"Nota"              , {||aNotas[oDespesBrw:nAt,03]}, "C", "@!"    , 1, 10   ,                            , .T. , , .F.,, "aNotas[oDespesBrw:nAt,02]",, .F., .T.,                                    , "ETDESPES1"    })
	oDespesBrw:addColumn({"Serie"             , {||aNotas[oDespesBrw:nAt,04]}, "C", "@!"    , 1, 05   ,                            , .T. , , .F.,, "aNotas[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })
	oDespesBrw:addColumn({"Cod. Cliente"      , {||aNotas[oDespesBrw:nAt,07]}, "C", "@!"    , 1, 10    ,                            , .T. , , .F.,, "aNotas[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })
	oDespesBrw:addColumn({"Loja"              , {||aNotas[oDespesBrw:nAt,08]}, "C", "@!"    , 1, 10    ,                            , .T. , , .F.,, "aNotas[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })
	oDespesBrw:addColumn({"Nome"              , {||aNotas[oDespesBrw:nAt,09]}, "C", "@!"    , 1, 50   ,                            , .T. , , .F.,, "aNotas[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })
	oDespesBrw:addColumn({"Data"              , {||aNotas[oDespesBrw:nAt,05]}, "C", "@!"    , 1, 15    ,                            , .T. , , .F.,, "aNotas[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })

	oDespesBrw:setEditCell( .T. , { || .T. } ) //activa edit and code block for validation
	oDespesBrw:Activate(.T.)
	//AADD(aButtons, {"Imprime NF", {|| Verifinota(aNotas)},"Gera PDF"})

	Activate MsDialog o3Dlg CENTERED
	//EnchoiceBar( o3Dlg,{||o3Dlg:End()},{||o3Dlg:End()},,aButtons)

return .t.
// SELECAO DE ITENS
Static Function SelectOne(oBrowse, aArquivo)
	aArquivo[oDespesBrw:nAt,1] := !aArquivo[oDespesBrw:nAt,1]
	//oBrowse:Refresh()
Return .T.
//FUNÇÃO PARA SELECIONAR TODOS OS REGISTROS
Static Function SelectAll(oBrowse, nCol, aArquivo)
	Local _ni := 1
	For _ni := 1 to len(aArquivo)
		aArquivo[_ni,1] := lMarker
	Next
	oBrowse:Refresh()
	lMarker:=!lMarker
Return .T.
/*{Protheus.doc} filtronota
*/
Static Function filtronota()
	Local aPergs   := {}
	Private cNumDocDe   := ''
	Private cNumDocAte  := ''
	Private cTranspDe   := ''
    Private cTranspAte  := ''
	Private cSerieDe    := ''
	Private cSerieAte   := ''
	Private cDataEmiDe  := ''
	Private cDataEmiAte := ''
	Private cRegistros  := ''


	if Perg()
		cNumDocDe   := MV_PAR01
		cNumDocAte  := MV_PAR02
		cSerieDe    := MV_PAR03
		cSerieAte   := MV_PAR04
		cTranspDe   := MV_PAR05
		cTranspAte  := MV_PAR06
		cDataEmiDe  := MV_PAR07
		cDataEmiAte := MV_PAR08
		if Empty(cNumDocAte)
			Help(NIL, NIL, "ATENÇAO!!", NIL, "Os Parametros (N.da Nota De) e/ou (N.da Nota Até) Nao Foram preenchidos." , 1, 0, NIL, NIL, NIL, NIL, NIL, {"Preencha corretamente os Par?metros"})
		else
			Processa({|| buscanota()}, 'Processando...', '', .F.)
		endif
	endif
Return
/* ----------------------------------------------------------------
  Function: Perg
  Descri??o: Fun??o para os par?metros
----------------------------------------------------------------
*/
Static Function Perg()

	Local aParamBox := {}
	Local dDataDe   := FirstDate(Date())
	Local dDataAte  := LastDate(Date())
	Local cTitle    := 'Parametros Nota'

	aAdd(aParamBox, {1, "N.da Nota De   "  , Space(TamSx3("F2_DOC")[1]), "", ".T.", "SF2", ".T.", 50, .F.})
	aAdd(aParamBox, {1, "N.da Nota Até  "  , Space(TamSx3("F2_DOC")[1]), "", ".T.", "SF2", ".T.", 50, .F.})
	aAdd(aParamBox, {1, "Serie De "        , Space(TamSx3("F2_SERIE")[1]), "", ".T.", "SF2", ".T.", 50, .F.})
	aAdd(aParamBox, {1, "Serie Até "       , Space(TamSx3("F2_SERIE")[1]), "", ".T.", "SF2", ".T.", 50, .F.})
	aAdd(aParamBox, {1, "Transportadora De   " , Space(TamSx3("A4_COD")[1]), "", ".T.", "SA4", ".T.", 50, .F.})
    aAdd(aParamBox, {1, "Transportadora Ate  " , Space(TamSx3("A4_COD")[1]), "", ".T.", "SA4", ".T.", 50, .F.})
	aAdd(aParamBox, {1, "Data de Emissão De " , dDataDe,  "", "", "", "", 50, .F.})
	aAdd(aParamBox, {1, "Data de Emissão Ate ", dDataAte, "", "", "", "", 50, .F.})

return ParamBox(aParambox,"Parametros",,,,,,,,cTitle,.T.,.T.)
/*
 Busca nota no banco de dados

*/
Static Function buscanota()

	Local cQuery := ""
	Local cQryF2 := Getnextalias()

	cQuery:=" SELECT F2_FILIAL," + CRLF
	cQuery+=" F2_DOC, F2_SERIE, F2_EMISSAO, F2_CHVNFE,"+ CRLF
	cQuery+=" SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_NREDUZ, SA1.A1_END, SA1.A1_EST, SA1.A1_CEP, SA1.A1_MUN" + CRLF
	cQuery+=" FROM " + RetSqlName('SF2') + " AS SF2"+ CRLF
	cQuery+=" INNER JOIN " + RetSqlName('SA1') + " AS SA1 ON SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.D_E_L_E_T_ = ' '" + CRLF
	cQuery+=" WHERE SF2.D_E_L_E_T_=''"
	cQuery+=" AND F2_DOC BETWEEN '" + cNumDocDe + "' AND '" + cNumDocAte + "' "
	cQuery+=" AND F2_SERIE BETWEEN '" + cSerieDe + "' AND '" + cSerieAte + "' "
	cQuery+=" AND F2_EMISSAO BETWEEN '" + DTOS(cDataEmiDe) + "' AND '" + DTOS(cDataEmiAte) + "'" + CRLF 
	cQuery+=" AND F2_TRANSP BETWEEN '" + cTranspDe + "' AND '" + cTranspAte + "'" + CRLF
	cQuery+=" ORDER BY F2_DOC " + CRLF

	cQuery:=ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryF2, .T., .F. )

	(cQryF2)->(DbGoTop())
	While (cQryF2)->(!EOF())

		aadd(aNotas,{.f.,alltrim((cQryF2)->F2_FILIAL),alltrim((cQryF2)->F2_DOC),AllTrim((cQryF2)->F2_SERIE),STOD((cQryF2)->F2_EMISSAO),(cQryF2)->F2_CHVNFE,(cQryF2)->A1_COD,(cQryF2)->A1_LOJA,(cQryF2)->A1_NOME} )

		(cQryF2)->(dbSkip())
	EndDo
	(cQryF2)->(dbCloseArea())
	DbSelectArea('SF2')

Return aNotas
/*{Protheus.doc} Verifca flag

*/
Static Function Verifinota(aNotas)
	Local lExistNFe:=.F.
	Private i:= 0

	For i:=1 to len(aNotas)
		If aNotas[i][1] == .T.
			ImpriNF(aNotas[i])
			lExistNFe:=.T.
		EndIf
	next
	IF !lExistNFe
		Aviso("Não há notas", "Selecione uma nota para impressão", {"Ok"}, 1)
		BREAK
	ENDIF
Return
/*{Protheus.doc} Getchave
*/
User Function Getchave()

Return cChaveNfe
/*{Protheus.doc} Impressão da nota

*/
Static Function ImpriNF(aNotas)

	local oDanfe        := nil as object
	local oSetup        := nil as object
	local cSession  	:= GetPrinterSession() as character
	local cDevice     	:= if(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),;
		"PDF",;
		fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)) as character
	local cBarra		:= iif(IsSrvUnix(),"/","\") as character
	local cDir			:= "" as character
	local cFilePrint	:= "DANFE_"+aNotas[3]+Dtos(MSDate())+StrTran(Time(),":","") as character
	local nRet 			:= 0 as numeric
	local nX 			:= 0 as numeric
	local nTipo		    := 0 as numeric
	local nPar		    := 0 as numeric
	local nFlags        := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + ;
		PD_DISABLEPREVIEW + PD_DISABLEMARGIN as numeric
	local nLocal       	:= if(fwGetProfString(cSession,"local","SERVER",.T.)==;
		"SERVER",1,2) as numeric
	local nOrientation 	:= if(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)==;
		"PORTRAIT",1,2) as numeric
	local cIdEnt 		:= getCfgEntidade() as character
	local lJob			:= isBlind() as logical
	local lDanfeII		:= tssHasRdm("PrtNfeSef") as logical
	local lDanfeIII		:= tssHasRdm("DANFE_P1") as logical
	local lMsgVld		:= .f. as logical
	local aDevice  		:= {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"} as array
	local nPrintType    := aScan(aDevice,{|x| x == cDevice }) as numeric
	local lAdjustToLegacy := .f. as logical

	if(tssHasRdm("DANFE_V") .and. if(lJob, nPar == 1, .t.))
		nRet := tssExecRdm("Danfe_v", .F.)
	elseif tssHasRdm("DANFE_VI") .and. if(lJob, nPar == 2, .t.)
		nRet := tssExecRdm("Danfe_vi", .F.)
	endif

	Pergunte("NFSIGW",.F.)

	mv_par01 := aNotas[3]
	mv_par02 := aNotas[3]
	mv_par03 := aNotas[4]
	mv_par04 := 2
	mv_par05 := 2
	mv_par06 := 2
	mv_par07 := aNotas[5]
	mv_par08 := aNotas[5]
	cChaveNfe:= aNotas[6]

	if(nRet >= 20100824)
		cDir := SuperGetMV('MV_RELT',,"\SPOOL\")

		if(!empty(cDir) .and. !ExistDir(cDir))
			aDir := StrTokArr(cDir, cBarra)
			cDir := ""
			for nX := 1 to len(aDir)
				cDir += aDir[nX] + cBarra
				if !ExistDir(cDir)
					MakeDir(cDir)
				endif
			next
		endif

		if(nTipo != 1)
			oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, cDir, .T. )

			if(lJob)
				oDanfe:SetViewPDF(.F.)
				oDanfe:lInJob := .T.
			endif

			if(!oDanfe:lInJob)
				oSetup := FWPrintSetup():New(nFlags, "DANFE")
				oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
				oSetup:SetPropert(PD_ORIENTATION , nOrientation)
				oSetup:SetPropert(PD_DESTINATION , nLocal)
				oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
				oSetup:SetPropert(PD_PAPERSIZE   , 2)

				if(ExistBlock( "SPNFESETUP" ))
					Execblock( "SPNFESETUP" , .F. , .F. , {oDanfe, oSetup} )
				endif
			endif

			if(lJob .or. oSetup:activate() == PD_OK)

				fwWriteProfString( cSession, "local"      , iif( lJob, "SERVER",;
					iif(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER","CLIENT")),.t.)

				fwWriteProfString( cSession, "PRINTTYPE"  , iif(lJob, "PDF"		  ,;
					iif(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       )), .t.)

				fwWriteProfString( cSession, "ORIENTATION", iif(lJob, "LANDSCAPE" ,;
					iif(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" )), .t.)

				oDanfe:setCopies(val(iif(lJob,"1",oSetup:cQtdCopia)))

				if(lJob .and. (nPar == 1)) .or. (!lJob .and. oSetup:GetProperty(PD_ORIENTATION) == 1)
					iif(lDanfeII, tssExecRdm("PrtNfeSef", .F., cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint ,/*lIsLoja*/, /*nTipo*/), lMsgVld := .t.)
				elseif((lJob .and. (nPar == 2) ) .or. !lJob)
					iif(lDanfeIII, tssExecRdm("DANFE_P1", .F., cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/ ), lMsgVld := .t.)
				Endif
			endif
		endif

		if(!lJob)
			if (lMsgVld)
				Help(NIL, NIL,"Fonte de impressão do DANFE não compilado.", NIL,;
					"Acesse o portal do cliente baixe, os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente",;
					1, 0, NIL, NIL, NIL, NIL, NIL, {"Fonte não compilado"})
			endif
		endif
	endif

	FreeObj(oDanfe)
	FreeObj(oSetup)

Return
