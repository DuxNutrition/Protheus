#INCLUDE "SPEDNFE.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} CCeLote
Remessa em lote de notas CCe
@type function
@version  
@author vnucc
@since 2/20/2024
@param cAlias, character, 
@param nReg, numeric, 
@param nOpc, numeric, 
@return variant, return_description
/*/
User Function CCeLote(cAlias,nReg,nOpc)

	local aCfgCCe		:= {}
	Local cNfeDoc		:= IIf ((cAlias == "SF2"),Alltrim((cAlias)->F2_DOC) + " / " + SubStr((cAlias)->F2_SERIE,1,3), Alltrim((cAlias)->F1_DOC) + " / " + SubStr((cAlias)->F1_SERIE,1,3))
	Local nLimite		:= IIf ((cAlias == "SF2"),Val(Right(RTrim((cAlias)->F2_IDCCE),2)),Val(Right(RTrim((cAlias)->F1_IDCCE),2)))		//Limite do numero de eventos
	Local aNfe			:= {}
	Local cAmbiente		:= ""
	Local cVerLayout	:= "1.00"
	Local cVerLayEven	:= "1.00"
	Local cVerEven		:= "1.00"
	Local cVerCCe		:= "1.00"
	Local cHoraVeraoCCe	:= "2"	// Horario de verao: 1-Sim ### 2-Nao
	Local cHorarioCCe	:= "2"	// Horario: 1-Fernando de Noronha ### 2-Brasilia ### 3-Manaus
	Local aTexto		:= {}
	Local lOk			:= .T.
	Local cIdEnt		:= ""
	Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	local cError		:=  ""
	Local cTexto		:= ""//Space(1000)
	Local cRetorno    	:= ""
	Local oWs
	Local oWizard
	Local lUsaColab := UsaColaboracao("1")

	Private aNfeLote	:= {}
	Private cNfeOri		:= Space(TamSX3("D2_DOC")[1])
	Private cNfeDest	:= Space(TamSX3("D2_DOC")[1])
	Private dDtIni 		:= ddatabase
	Private dDtFim		:= ddatabase
	Private cSerie		:= IIf ((cAlias == "SF2"),SubStr((cAlias)->F2_SERIE,1,3),  SubStr((cAlias)->F1_SERIE,1,3))
	Private nEnvio		:= 0

// Verifica se a entidade foi configurada e o limite por eventos
	If IsReady(,,,lUsaColab) .And. nLimite < 20

		// Dados da Nfe
		If cAlias == "SF2"
			aNfe := {	(cAlias)->F2_CHVNFE		,; //01 - Chave da Nfe
			(cAlias)->(Recno())		,; //02 - Recno
			(cAlias)->F2_SERIE		,; //03 - Serie
			(cAlias)->F2_DOC}		      //04 - Numero
		Else
			aNfe := {	(cAlias)->F1_CHVNFE		,;	//01-Chave da Nfe
			(cAlias)->(Recno())		,; //02 - Recno
			(cAlias)->F1_SERIE		,; //03 - Serie
			(cAlias)->F1_DOC}		      //04 - Numero
		EndIf

		DEFINE FONT oBold BOLD

		// Obtem o codigo da entidade
		cIdEnt := GetIdEnt(lUsaColab)

		If !Empty(cIdEnt)

			if lUsaColab
				cAmbiente		:= ColGetPar("MV_AMBIENT","")
				cVerLayout		:= ColGetPar("MV_CCEVLAY","1.00")
				cVerLayEven	:= ColGetPar("MV_EVENTOV","1.00")
				cVerEven		:= ColGetPar("MV_LAYOUTV","1.00")
				cVerCCe 		:= ColGetPar("MV_CCEVER","1.00")
				cHoraVeraoCCe := ColGetPar("MV_HRVERAO","")
				cHorarioCCe 	:= 	ColGetPar("MV_HORARIO","")

				lOk				:= .t.
			else
				// Obtem o ambiente da carta de correcao
				oWS:=WsSpedCfgNfe():New()
				oWS:cUSERTOKEN 	  	:= "TOTVS"
				oWS:cID_ENT    		:= cIdEnt
				oWS:nAMBIENTECCE	:= 0
				oWS:cVERCCELAYOUT	:= "1.00"
				oWS:cVERCCELAYEVEN	:= "1.00"
				oWS:cVERCCEEVEN		:= "1.00"
				oWS:cVERCCE			:= "1.00"
				oWS:cHORAVERAOCCE	:= "2"
				oWS:cHORARIOCCE		:= "2"
				oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"
				aCfgCCe := getCfgCCe(@cError, cIdEnt)
				lOk:= empty(cError)

			endif
			If lOk
				if !lUsaColab
					// Ambiente
					If Valtype(aCfgCCe[1]) <> "U"
						cAmbiente := aCfgCCe[1]
					Else
						cAmbiente := STR0349	//"2-Homologacao"
					EndIf
					// Versao do leiaute
					If ValType(aCfgCCe[8]) <> "U"
						cVerLayout := aCfgCCe[8]
					Else
						cVerLayout := "1.00"
					EndIF
					// Versao do leiaute do evento
					If ValType(aCfgCCe[7]) <> "U"
						cVerLayEven := aCfgCCe[7]
					Else
						cVerLayEven := "1.00"
					EndIF
					// Versao do evento
					If ValType(aCfgCCe[6]) <> "U"
						cVerEven := aCfgCCe[6]
					Else
						cVerEven := "1.00"
					EndIF
					// Versao da carta de correcao
					If ValType(aCfgCCe[5]) <> "U"
						cVerCCe := aCfgCCe[5]
					Else
						cVerCCe := "1.00"
					EndIF
					// Horario de verao
					If ValType(aCfgCCe[3]) <> "U"
						cHoraVeraoCCe := aCfgCCe[3]
					Else
						cHoraVeraoCCe := "2"
					EndIF
					// Horario
					If ValType(aCfgCCe[2]) <> "U"
						cHorarioCCe := aCfgCCe[2]
					Else
						cHorarioCCe := "2"
					EndIF
				endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da Interface                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aTexto,{})
				aTexto[1] := STR0357+" " 						//"Esta rotina tem como objetivo auxilia-lo na transmissão da Carta de Correção Eletrônica para o serviço Totvs Services SPED."
				aTexto[1] += STR0358+CRLF+CRLF 					//"O registro de uma nova Carta de Correção substitui a anterior, sendo assim a nova Carta de Correção deverá conter todas as correções a serem consideradas. "
				aTexto[1] += STR0374+CRLF+CRLF 					//"Totvs Services SPED está operando com a seguinte configuração: "
				aTexto[1] += STR0015+cAmbiente+CRLF 			//"Ambiente: "
				aTexto[1] += STR0350+": "+cVerLayout+CRLF		//"Versao do layout"
				aTexto[1] += STR0351+": "+cVerLayEven+CRLF		//"Versao do layout do evento"
				aTexto[1] += STR0352+": "+cVerEven+CRLF			//"Versao do evento"
				aTexto[1] += STR0361+": "+cVerCCe+CRLF	 		//"Versao da carta de correcao"
				aTexto[1] += STR0369+": "+cHoraVeraoCCe+CRLF	//"Horario de verao"
				aTexto[1] += STR0370+": "+cHorarioCCe+CRLF		//"Horario"
				aadd(aTexto,{})

				DEFINE WIZARD oWizard ;
					TITLE STR0355;		//"Assistente de transmissão da Carta de Correcao Eletronica"
				HEADER STR0019;		//"Atencao"
				MESSAGE STR0356;	//"Siga atentamente os passos para a configuracao da Carta de Correcao Eletronica."
				TEXT aTexto[1] ;
				NEXT {|| .T.} ;
				FINISH {||.T.}

			CREATE PANEL oWizard  ;
				HEADER STR0355;		//"Assistente de transmissão da Carta de Correcao Eletronica"
			MESSAGE "";
				BACK {|| .T.} ;
			NEXT {|| IIF(RetNotas(),.T.,.F. )} ;
			PANEL

		@ 003,005 SAY "Nota Fiscal De: " FONT oBold OF oWizard:oMPanel[2] PIXEL
		@ 003,070 MSGET oVar VAR cNfeOri Picture "@!" SIZE 060,10 PIXEL OF oWizard:oMPanel[2]  F3 cAlias
		//@ 010,040 MSGET oVar   VAR cProduto Picture "@!"        SIZE 060,10 PIXEL OF oDlgMain F3 "SB1" VALID(GetDescProd())
		@ 025,005 SAY "Nota Fiscal Até: " FONT oBold OF oWizard:oMPanel[2] PIXEL
		@ 025,070 MSGET oVar VAR cNfeDest Picture "@!" SIZE 060,10 PIXEL OF oWizard:oMPanel[2]  F3 cAlias
//
		@ 047,005 SAY "Data Emissão De: " FONT oBold OF oWizard:oMPanel[2] PIXEL
		@ 047,070 MSGET oVar VAR dDtIni Picture "99/99/99" SIZE 040,10 OF oWizard:oMPanel[2] PIXEL
		//@ 045,040 MSGET oVar   VAR dDtProces Picture "99/99/99" SIZE 040,10 PIXEL OF oDlgMain VALID(GetDatas())

		@ 059,005 SAY "Data Emissão Até: " FONT oBold OF oWizard:oMPanel[2] PIXEL
		@ 059,070 MSGET oVar VAR dDtFim Picture "99/99/99" SIZE 040,10 OF oWizard:oMPanel[2] PIXEL

		CREATE PANEL oWizard  ;
			HEADER STR0355 ;	//"Assistente de transmissão da Carta de Correcao Eletronica"
		MESSAGE ""	;
			BACK {|| .T.} ;
		NEXT {|| IIf(SpedCCeTexto(@cTexto,1000,.T.),(Processa({|lEnd| cRetorno := SpedLote(cTexto,cAlias)}),.T.),.F.)} ;
		PANEL

	// Nota Fiscal/Serie
	@ 003,005 SAY cValToChar(len(aNfeLote)) + " Documentos selecionados / Serie : " FONT oBold OF oWizard:oMPanel[3] PIXEL
	@ 003,110 SAY cSerie FONT oBold OF oWizard:oMPanel[3] PIXEL

	@ 015,005 SAY STR0368 SIZE 250,10 PIXEL  FONT oBold OF oWizard:oMPanel[3]	//"Descreva a correção a ser considerada (sem acentuação)"
	@ 025,005 GET cTexto MEMO SIZE 275,100 PIXEL OF oWizard:oMPanel[3]

	CREATE PANEL oWizard  ;
		HEADER STR0355;		//"Assistente de transmissão da Carta de Correcao Eletronica"
	MESSAGE "";
		BACK {|| .T.} ;
		FINISH {|| .T.} ;
		PANEL

	@ 010,010 GET cRetorno MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[4]

	ACTIVATE WIZARD oWizard CENTERED
EndIf

EndIf

Else

	If nLimite >= 20

		Aviso("SPED",STR0372,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!", STR0647 = "SPED"

	Else

		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!", STR0647 = "SPED"

	Endif

EndIf

Return


Static Function IsReady(cURL,nTipo,lHelp,lUsaColab)

	Local cHelp    := ""
	local cError	:= ""
	Local lRetorno := .F.
	DEFAULT nTipo := 1
	DEFAULT lHelp := .F.
	DEFAULT lUsaColab := .F.
	if !lUsaColab
		If FunName() <> "LOJA701"
			If !Empty(cURL)
				PutMV("MV_SPEDURL",cURL)
			EndIf
			SuperGetMv() //Limpa o cache de parametros - nao retirar
			DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		Else
			If !Empty(cURL)
				PutMV("MV_NFCEURL",cURL)
			EndIf
			SuperGetMv() //Limpa o cache de parametros - nao retirar
			DEFAULT cURL      := PadR(GetNewPar("MV_NFCEURL","http://"),250)
		EndIf
		//Verifica se o servidor da Totvs esta no ar
		if(isConnTSS(@cError))
			lRetorno := .T.
		Else
			If lHelp
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3) // STR0647 = "SPED"
			EndIf
			lRetorno := .F.
		EndIf


		//Verifica se Há Certificado configurado
		If nTipo <> 1 .And. lRetorno

			if( isCfgReady(, @cError) )
				lRetorno := .T.
			else
				If nTipo == 3
					cHelp := cError

					If lHelp .And. !"003" $ cHelp
						Aviso("SPED",cHelp,{STR0114},3) // STR0647 = "SPED"
						lRetorno := .F.

					EndIf

				Else
					lRetorno := .F.

				EndIf
			endif

		EndIf

		//Verifica Validade do Certificado
		If nTipo == 2 .And. lRetorno
			isValidCert(, @cError)
		EndIf
	else
		lRetorno := ColCheckUpd()
		if lHelp .And. !lRetorno .And. !lAuto
			MsgInfo("UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0") // STR0810
		endif
	endif

Return(lRetorno)



Static Function GetIdEnt(lUsaColab)

	local cIdEnt := ""
	local cError := ""

	Default lUsaColab := .F.

	If !lUsaColab

		cIdEnt := getCfgEntidade(@cError)

		if(empty(cIdEnt))
			Aviso("SPED", cError, {STR0114}, 3) // STR0647 = "SPED"

		endif

	else
		if !( ColCheckUpd() )
			Aviso("SPED", "UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{STR0114},3) //STR0647 = "SPED", // STR0810 =  "UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0"
		else
			cIdEnt := "000000"
		endif
	endIf

Return(cIdEnt)

Static Function SpedCCeTrf(aNfe,cTexto,cAlias)

	Local cXml      := ""
	Local cIdEven	:= ""
	Local cRetorno  := ""
	Local lRetorno	:= .F.
	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local dDataIni	:= Date()
	Local cHoraIni	:= Time()
	Local cErro		:= ""
	Local cIdEnt	:= ""
	
	Local nRegSF2	:= aNfe[2]
	Local lUsaColab := UsaColaboracao("1")

// Verifica se a entidade foi configurada e o limite por eventos
	If IsReady(,,,lUsaColab)

		// Obtem o codigo da entidade
		cIdEnt := GetIdEnt(lUsaColab)

		// Monta o Xml
		cXml := SpedCCeXml(aNfe,cTexto)

		if lUsaColab
			if ColEnvEvento("CCE",aNfe,cXml,@cIdEven,@cErro)
				SpedAtuEvento(1,nRegSF2,cIdEven,cAlias)
				nEnvio++
				lRetorno:= .T.
			endif
		else
			// Chamado do metodo e envio
			oWs:= WsNFeSBra():New()
			oWs:cUserToken	:= "TOTVS"
			oWs:cID_ENT		:= cIdEnt
			oWs:cXML_LOTE	:= cXml
			oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

			If oWs:NfeRemessaEvento()
				If Type("oWS:oWsNfeRemessaEventoResult:cString[1]") <> "U"
					cIdEven := oWS:oWsNfeRemessaEventoResult:cString[1]
					If !Empty(cIdEven)
						SpedAtuEvento(1,nRegSF2,cIdEven,cAlias)
						nEnvio++
						lRetorno:= .T.
					Endif
				Endif
			Else
				lRetorno:= .F.
				cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			Endif
		endif

		If lRetorno
			cRetorno := IIF(lUsaColab,STR0491,STR0026)+CRLF //"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."#"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
			cRetorno += STR0359+CRLF+CRLF //"Verifique se o evento foi vinculado a NF-e na SEFAZ, utilizando a rotina 'Monitor'."
			cRetorno += Left(STR0360,16)+cValToChar(nEnvio)+Substr(STR0360,16)+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foi transmitido 0/1 evento em "
		Else
			cRetorno := iif(lUsaColab,STR0490,STR0030)+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."#"Houve erro durante a transmissão para o Totvs Services SPED."
			cRetorno += cErro
		EndIf

	Else

		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!", STR0647 = "SPED"

	Endif

Return(cRetorno)

Static Function SpedAtuEvento(nOpc,nRecno,cIdEven,cAlias,cEvento,lDesmarca)

	Default nOpc 	:= 1
	Default cIdEven	:= IIF (cAlias == "SF2",SF2->F2_IDCCE,SF1->F1_IDCCE)
	Default cEvento	:= "110110"
	Default lDesmarca := .F.

	If cAlias == "SF2"

		SF2->(dbGoTo(nRecno))
		SF2->(RecLock("SF2",.F.))

		If cEvento == "110110"
			If nOpc == 1				// Grava o ID da CCe
				SF2->F2_IDCCE := cIdEven
			Else
				SF2->F2_EVENFLG	:= "1"	// Grava o flag de vinculo
			Endif

		ElseIf cEvento == "110999"
			If nOpc = 1
				SF2->F2_CODRGS	:= 'T'	// Transmitido
				SF2->F2_IDRGS	:= cIdEven
			ElseIf nOpc == 2
				SF2->F2_CODRGS	:= 'S'	// Autorizado(NF vinculada)
			ElseIf nOpc == 3
				SF2->F2_CODRGS	:= 'N'	// Rejeitado
			ElseIf nOpc == 4
				SF2->F2_CODRGS := 'M'	// Cancelamento transmitido
			ElseIF 	nOpc == 5
				SF2->F2_CODRGS := 'R'	// Cancelamento rejeitado
			ElseIF 	nOpc == 6
				SF2->F2_CODRGS := 'C'	// Cancelamento autorizado
			EndIf
			If lDesmarca
				SF2->F2_FLAGRGS := ''		// Limpa a Marca
			EndIf
		EndIf
		SF2->(MsUnlock())
	Else

		SF1->(dbGoTo(nRecno))
		SF1->(RecLock("SF1",.F.))

		If cEvento == "110110"
			If nOpc == 1				// Grava o ID da CCe
				SF1->F1_IDCCE := cIdEven
			Else
				SF1->F1_EVENFLG	:= "1"	// Grava o flag de vinculo
			Endif

		ElseIf cEvento == "110999"
			If nOpc = 1
				SF1->F1_CODRGS	:= 'T'
				SF1->F1_IDRGS	:= cIdEven
			ElseIf nOpc == 2
				SF1->F1_CODRGS	:= 'S'
			ElseIf nOpc == 3
				SF1->F1_CODRGS	:= 'N'
			ElseIf nOpc == 4
				SF1->F1_CODRGS := 'M'
			ElseIF 	nOpc == 5
				SF1->F1_CODRGS := 'R'
			ElseIF 	nOpc == 6
				SF1->F1_CODRGS := 'C'
			EndIF
			If lDesmarca
				SF1->F1_FLAGRGS := '' // Limpa a Marca
			EndIf
		EndIf
		SF1->(MsUnlock())
	EndIf

Return


Static Function RetNotas()

	Local aAreaAnt  := GetArea()
	Local lRet      := .T.
	Local cAliasTmp := GetNextAlias()
	Local cQuery    := ""
	
	aNfeLote := {}

	cQuery := "SELECT F2_CHVNFE,R_E_C_N_O_ AS RECNO,F2_SERIE,F2_DOC "
	cQuery += "FROM "+RetSqlName("SF2")+" WHERE "
	cQuery += "F2_EMISSAO BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"' AND "
	cQuery += "F2_DOC BETWEEN '"+cNfeOri+"' AND '"+cNfeDest+"' AND "
	cQuery += "F2_SERIE = '"+cSerie+"' AND D_E_L_E_T_ = '' "


	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	While (cAliasTmp)->(!EOF())

		AAdd(aNfeLote, { (cAliasTmp)->F2_CHVNFE, (cAliasTmp)->RECNO,(cAliasTmp)->F2_SERIE,(cAliasTmp)->F2_DOC} )

		(cAliasTmp)->(dbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())

	RestArea(aAreaAnt)


	if empty(aNfeLote)
		MsgInfo("Nenhuma nota encontrada !")
		lRet:=.F.
	else
		lRet:=.T.
	endif

Return lRet



Static Function SpedLote(cTexto,cAlias) 

	Local cRetorno := ""
	Local nx 
	
	Default cTexto := ''
	Default cAlias := 'SF2'

	for nx := 1 to len(aNfeLote)

	cRetorno := SpedCCeTrf(aNfeLote[nx],cTexto,cAlias)

	next nx 

Return cRetorno
