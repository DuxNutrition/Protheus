#include "totvs.ch"
#include "FWPrintSetup.ch"
#include "RPTDEF.ch"

#define IMP_DANFE    1
#define IMP_ETIQUETA 2

/*/{Protheus.doc} ZFATF002
Reliza a impressão customizada da nota fiscal 
e etiqueta (danfinho)de acordo com o range de 
transportadoras.
@type  Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
User Function ZFATF002(nTipoImpr)

	Local lRet              := .T.
	Private cAlsTmp         := GetNextAlias()
	Private cChaveNfe       := ""
	Private cTransDe        := ""
	Private cTransAte       := ""
	Private cNotaDe         := ""
	Private cNotaAte        := ""
	Private cSerie          := ""
	Private cMsg            := ""
	Private cSolucao        := ""
	Private cImpressora     := ""
	Private nImpressora     := 0
	Private nTipoOperacao   := 0
	Private dDataDe         := CToD("//")
	Private dDataAte        := CToD("//")
	Default nTipoImpr       := 1

	If(GetPergunta(nTipoImpr))
		
        SetPergunta(nTipoImpr)

		FwMsgRun( ,{|| lRet := ZChaveNfe() }, FwFilialName(), "Aguarde...Buscando informaçõe..." )

		If(lRet)
			ZSetChave()
			If !(Empty(cChaveNfe))
				If(nTipoImpr == IMP_DANFE)
					PrintDanfe()
				ElseIf(nTipoImpr == IMP_ETIQUETA)
					PrintEtiq()
				EndIf
			Else
				lRet := .f.
			EndIf
		EndIf

		If(!lRet)
			cMsg     := "Não foi possível obter informações das notas fiscais."
			cSolucao := "Verifique os parâmetros digitados."
			ShowMessage()
		EndIf
	EndIf
Return

/*/{Protheus.doc} PrintDanfe
Realiza a impressão do DANFE.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
Static Function PrintDanfe()
	Local oDanfe            := Nil
	Local oSetup            := Nil
	Local cSession  	    := GetPrinterSession()
	Local cDevice     	    := If(Empty(FwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",FwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	Local cBarra		    := IIf(IsSrvUnix(),"/","\")
	Local cDir			    := ""
	Local cFilePrint	    := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
	Local nRet 			    := 0
	Local nX 			    := 0
	Local nTipo		        := 0
	Local nPar		        := 0
	Local nFlags            := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	Local nLocal       	    := if(FwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2)
	Local nOrientation 	    := if(FwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	Local cIdEnt 		    := GetCfgEntidade()
	Local lJob			    := isBlind()
	Local lDanfeII		    := TssHasRdm("PrtNfeSef")
	Local lDanfeIII		    := TssHasRdm("DANFE_P1")
	Local lMsgVld		    := .T.
	Local aDevice  		    := {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
	Local nPrintType        := aScan(aDevice,{|x| x == cDevice })
	Local lAdjustToLegacy   := .F.

	If(TssHasRdm("DANFE_V") .and. if(lJob, nPar == 1, .t.))
		nRet := TssExecRdm("Danfe_v", .F.)
	ElseIf TssHasRdm("DANFE_VI") .and. if(lJob, nPar == 2, .t.)
		nRet := TssExecRdm("Danfe_vi", .F.)
	EndIf

	Pergunte("NFSIGW",.F.)

	mv_par01 := cNotaDe
	mv_par02 := cNotaAte
	mv_par03 := cSerie
	mv_par04 := 2
	mv_par05 := 2
	mv_par06 := 2
	mv_par07 := dDataDe
	mv_par08 := dDataAte

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

					iif(lDanfeII, TssExecRdm("PrtNfeSef", .F., cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint ,/*lIsLoja*/, /*nTipo*/), lMsgVld := .t.)

				elseif((lJob .and. (nPar == 2) ) .or. !lJob)
					iif(lDanfeIII, TssExecRdm("DANFE_P1", .F., cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/ ), lMsgVld := .t.)
				Endif
			endif
		endif
	Endif

	FreeObj(oDanfe)
	FreeObj(oSetup)
return

/*/{Protheus.doc} ZSetChave
Carrega as chaves NFE á serem 
filtradas na impressão.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
Static Function ZSetChave()

	DbSelectArea(cAlsTmp)
	(cAlsTmp)->(dbGoTop())
    While((cAlsTmp)->(!eof()))

		If(empty(cChaveNfe))
			cChaveNfe := AllTrim((cAlsTmp)->CHAVE_NFE)
		Else
			cChaveNfe += "|"+ AllTrim((cAlsTmp)->CHAVE_NFE)
		EndIf

		(cAlsTmp)->(dbSkip())
	EndDo

	(cAlsTmp)->(dbCloseArea())

Return()

/*/{Protheus.doc} ZChaveNfe
Busca as chaves NFE á serem 
filtradas na impressão.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
Static Function ZChaveNfe()
	
    Local cSql := ""
	Local lRet := .T.

    If Select( (cAlsTmp) ) > 0
        (cAlsTmp)->(DbCloseArea())
    EndIf

	cSql += " SELECT SF2.F2_CHVNFE AS CHAVE_NFE " + CRLF
	cSql += " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK) " + CRLF
	cSql += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"' " + CRLF
	cSql += " AND SF2.F2_TRANSP BETWEEN '"+cTransDe+"' AND '"+cTransAte+"' " + CRLF
	cSql += " AND SF2.F2_DOC BETWEEN '"+cNotaDe+"' AND '"+cNotaAte+"'   " + CRLF

	If !(Empty(cSerie))
		cSql += " AND SF2.F2_SERIE = '"+cSerie+"' " + CRLF
	EndIf

	cSql += "  AND SF2.F2_EMISSAO BETWEEN '"+DToS(dDataDe)+"' AND '"+DToS(dDataAte)+"' " + CRLF
	cSql += "  AND   SF2.D_E_L_E_T_ = '' " + CRLF
	cSql += " ORDER BY 1 " + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), cAlsTmp, .T., .T. )

    DbSelectArea(cAlsTmp)
	(cAlsTmp)->(dbGoTop())

	If (Empty((cAlsTmp)->CHAVE_NFE))
		lRet := .f.
		(cAlsTmp)->(dbCloseArea())
	EndIf

Return(lRet)

/*/{Protheus.doc} PrintEtiq
Realiza a impressão da etiqueta.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
Static Function PrintEtiq()
	local cIdEnt	 := GetCfgEntidade()
	local cUrl		 := "" 
	local lRet		 := .T.
	local lUsaColab	 := .F.

	If !(Empty(cIdEnt))
		lUsaColab := UsaColaboracao("1")
		if(!lUsaColab)
			cUrl := Padr( GetNewPar("MV_SPEDURL",""), 250 )
		endif

		if(tssHasRdm("ImpDfEtq"))

			Pergunte("NFDANFETIQ",.f.)

			mv_par01 := cNotaDe
			mv_par02 := cNotaAte
			mv_par03 := cSerie
			mv_par04 := dDataDe
			mv_par05 := dDataAte
			mv_par06 := nTipoOperacao
			mv_par07 := nImpressora
			mv_par08 := cImpressora

			TssExecRdm("ImpDfEtq", .T., {cUrl, cIdEnt, lUsaColab} )
		else
			Help(NIL, NIL,"Fonte não compilado.", NIL,;
				"Fonte de geração do DANFE simplificado etiqueta não compilado.",;
				1, 0, NIL, NIL, NIL, NIL, NIL,;
				{"Acesse o portal do cliente, baixe o DanfeEtiqueta.PRW e compile em seu ambiente."})
			lRet := .F.
		endif
	endif

return

/*/{Protheus.doc} SetPergunta
Realiza o carregamento das 
perguntas.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
Static Function SetPergunta(nTipoImpr)
	
    cTransDe    := AllTrim(Mv_Par01)
	cTransAte   := AllTrim(Mv_Par02)
	cNotaDe     := Mv_Par03
	cNotaAte    := Mv_Par04
	cSerie      := Mv_Par05
	dDataDe     := Mv_Par06
	dDataAte    := Mv_Par07

	If(nTipoImpr == IMP_ETIQUETA)
		nTipoOperacao := Val(Mv_Par08)
		nImpressora   := Val(Mv_Par09)
		cImpressora   := Mv_Par10
	EndIf

Return

/*/{Protheus.doc} getPergunta
Carrega os parâmetros para o 
usuário.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
Static Function GetPergunta(nTipoImpr)
	
    Local aParBox 	  := {}
	Local aImpressora := {"1=Termica","2=Normal"}
	Local aTpDoc      := {"1=Entrada","2=Saída"}
	Local lRet	  	  := .T.

	Aadd( aParBox,{1, "Transportadora de"	,Space(TamSx3("F2_TRANSP")[1])	,"", "", "SA4"  ,"",  80,.F.})
	Aadd( aParBox,{1, "Transportadora até"	,Space(TamSx3("F2_TRANSP")[1])	,"", "", "SA4"  ,"",  80,.F.})
	Aadd( aParBox,{1, "Nota Fiscal de"	    ,Space(TamSx3("F2_DOC")[1])	    ,"", "", "SF2"  ,"",  80,.F.})
	Aadd( aParBox,{1, "Nota Fiscal até"	    ,Space(TamSx3("F2_DOC")[1])	    ,"", "", "SF2"	,"",  80,.F.})
	Aadd( aParBox,{1, "Serie"	            ,Space(TamSx3("F2_SERIE")[1])	,"", "", ""     ,"",  80,.F.})
	Aadd( aParBox,{1, "Data de"             ,Criavar("F2_EMISSAO")	        ,"", "", ""	    ,"",  80,.F.})
	Aadd( aParBox,{1, "Data até"            ,Criavar("F2_EMISSAO")	        ,"", "", ""	    ,"",  80,.F.})

	If(nTipoImpr == IMP_ETIQUETA)
		Aadd( aParBox,{2, "Tipo Operação"   ,aTpDoc[02],aTpDoc,80,".t.", .f.})
		Aadd( aParBox,{2, "Tipo Impressora" ,aImpressora[02],aImpressora,80,".t.", .f.})
		Aadd( aParBox,{1, "Impressora" ,space(6),"", "","CB5IMP","",80,.f.})
	EndIf

	If(!ParamBox(aParBox,"Impressão DANFE",nil,,,,,,,"IMPDANFE",.t.,.t.))
		lRet := .F.
	EndIf

Return(lRet)

/*/{Protheus.doc} showMessage
Mosta a mensagem de erro e solução.
@type function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function showMessage()
	help(nil, nil, FwFilialName(), nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {cSolucao})
return
