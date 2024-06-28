#Include "Protheus.ch"
#Include "FWPrintSetup.ch"
#include "topconn.ch"

#DEFINE	NLINHAINICIAL		0015
#DEFINE	NTAMANHOPAGI		0780
#DEFINE	NQUEBRAOBSERV		0100
#DEFINE	NQUEBRALEGEND		0060

/*/{Protheus.doc} FSWImpOP 

Rotina do Acelerador do Relatório gráfico de Impressão de Ordem de Produção TOTVS IP

@type Function
@author Waldir Baldin
@since 28/07/2015
@version 1.01-20170106

@history 15/10/2015, Julio Lisboa, Rotina de Busca de Empenhos e Roteiros
@history 01/06/2016, João Orsi, Revisão Final do Acelerador
@history 06/01/2017, Carlos Eduardo Niemeyer Rodrigues, Revisão Nome do Fonte para ficar igual ao nome da Função - RelImpOP para FswImpOP + Adição da Versão do Relatório + Revisão ProtheusDoc
@history 12/08/2019, Luiz Emidio, Edição do Gerador de Codigo de Barra (Int25 para Code128c)
/*/
User Function FswImpOP()

	Local cPerg		:= "FSWIPIMPOP"
	
	Private cTitle	:= "Impressão de Ordem de Produção"
	Private cVersion:= "1.01-20170106"
	
	cTitle += " - " + cVersion
	
	If !fPerg(cPerg)
		msgInfo("Cancelado pelo operador.")
	Else
		Processa({|| CursorWait(), ImpRel(), CursorArrow()}, "Imprimindo...")
	Endif
	
Return

/*
	Função que configura as fontes utilizadas e realiza as chamadas das impressões
	Waldir Baldin - 28/07/2015
*/
Static Function ImpRel()
	
	Local lAdjustToLegacy 	:= .F.
	Local lDisableSetup  	:= .F.
	Local nCont				:= 1
	
	Private oPrinter 		:= FWMSPrinter():New("FSWIPIMPOP.OP",, lAdjustToLegacy, "/spool/", lDisableSetup,,,)
	Private nLinha			:= 0
	Private nMargemDir		:= 0
	Private nMargemEsq		:= 0
	Private nTamPag			:= 0
	Private aColImp			:= {}
	Private cNumOP			:= ""
	Private nRegs			:= 0
	
	Private aEmp			:= {}
	Private aRot			:= {}
	Private aCBI			:= {}
	Private aMotivo			:= {}
	
	Private oFont06 		:= TFont():New("Arial", 06, 06,, .F.,,,,, .F., .F.)
	Private oFont06N 		:= TFont():New("Arial", 06, 06,, .T.,,,,, .F., .F.)
	Private oFont08 		:= TFont():New("Arial", 08, 08,, .F.,,,,, .F., .F.)
	Private oFont08N 		:= TFont():New("Arial", 08, 08,, .T.,,,,, .F., .F.)
	Private oFont09 		:= TFont():New("Arial", 09, 09,, .F.,,,,, .F., .F.)
	Private oFont09N 		:= TFont():New("Arial", 09, 09,, .T.,,,,, .F., .F.)
	Private oFont10 		:= TFont():New("Arial", 10, 10,, .F.,,,,, .F., .F.)
	Private oFont10N 		:= TFont():New("Arial", 10, 10,, .T.,,,,, .F., .F.)
	Private oFont11 		:= TFont():New("Arial", 11, 11,, .F.,,,,, .F., .F.)
	Private oFont11N 		:= TFont():New("Arial", 11, 11,, .T.,,,,, .F., .F.)
	Private oFont12 		:= TFont():New("Arial", 12, 12,, .F.,,,,, .F., .F.)
	Private oFont12N 		:= TFont():New("Arial", 12, 12,, .T.,,,,, .F., .F.)
	Private oFont14N 		:= TFont():New("Arial", 14, 14,, .T.,,,,, .F., .F.)
	Private oFont16 		:= TFont():New("Arial", 16, 16,, .F.,,,,, .F., .F.)
	Private oFont16N		:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .f.)
	
	ExecQry()
	
	If nRegs > 0
		ProcRegua(nRegs)
		While QREL->(!Eof())
			cNumOP := AllTrim(QREL->(C2_NUM + C2_ITEM + C2_SEQUEN))
			IncProc("Imprimindo Registro " + StrZero(nCont++,4)  + " de " + StrZero(nRegs,4) + " [OP " + cNumOP + "]")
			
			impCabec(oPrinter)
			
			// Empenhos
			buscaEmp(cNumOP)
			impEmp(oPrinter)
			
			// Roteiros
			If MV_PAR12 == "S"
				buscaRot(QREL->C2_ROTEIRO,QREL->C2_PRODUTO)
				impRot(oPrinter)
			EndIf
			
			If nLinha > (nTamPag - NQUEBRAOBSERV)
				oPrinter:EndPage()
				ImpCabec(oPrinter)
			EndIf
			impObs(oPrinter)
			
			// Impressão das legendas (Transações e Motivos de Parada)
			If MV_PAR13 == "S"
				
				If Len(aMotivo) == 0
					buscaMotivos()
				EndIf
				
				If nLinha > (nTamPag - NQUEBRALEGEND)
					oPrinter:EndPage()
					ImpCabec(oPrinter)
				EndIf
				impAux(oPrinter)
			EndIf
			oPrinter:EndPage()
			
			aEmp	:= {}
			aRot	:= {}
			QREL->(DbSkip())
		EndDo
		oPrinter:Print()
	EndIf
	
Return

/*
	Rotina responsável por imprimi o cabecalho da OP
	Waldir Baldin - 28/07/2015
*/
Static Function ImpCabec(oPrinter)
	Local cLogo 		:= GetNewPar("ZZ_LOGOOP","") //Imagem dentro do SYSTEM
	Local cClient		:= ""
	Local nI			:= 0
	local nU			:= 0
	
	nLinha			:= NLINHAINICIAL
	nMargemDir		:= 0500//0590-0030//oPrinter:nVertSize()-0030
	nMargemEsq		:= 0015
	nTamPag			:= NTAMANHOPAGI
	
	nTamCol := nMargemDir/20
	For nI := 1 To 23 
		aAdd(aColImp, nI * nTamCol)
	Next nI
	
	oPrinter:StartPage()
	oPrinter:SayBitmap(nLinha-0020,aColImp[01],cLogo,100,100)
	oPrinter:Say(nLinha,aColImp[09],"ORDEM DE PRODUÇÃO",oFont16N)
	
	oPrinter:Say(nLinha,aColImp[18],"Data:",oFont10N)
	oPrinter:Say(nLinha,aColImp[20],dToC(dDataBase),oFont10)
	nLinha += 0010
	oPrinter:Say(nLinha,aColImp[18],"Hora:",oFont10N)
	oPrinter:Say(nLinha,aColImp[20],time(),oFont10)
	nLinha += 0020
	
	oPrinter:Code128c(nLinha+31,aColImp[02],AllTrim(aRot[nU,01]),30)//oPrinter:Int25(nLinha-0012,aColImp[08],cNumOP,1,30,.T.,.F.)
	oPrinter:Say(nLinha+0030,aColImp[09],cNumOP,oFont16N)
	nLinha += 0070
	
	oPrinter:Say(nLinha,aColImp[01],"Ordem de Produção:",oFont10N)
	oPrinter:Say(nLinha,aColImp[05],cNumOP,oFont10)
	
	oPrinter:Say(nLinha,aColImp[10],"Status:",oFont10N)
	oPrinter:Say(nLinha,aColImp[13],AllTrim(QREL->C2_TPOP),oFont10)
	nLinha += 0010
	oPrinter:Say(nLinha,aColImp[01],"Produto:",oFont10N)
	oPrinter:Say(nLinha,aColImp[05],AllTrim(QREL->C2_PRODUTO),oFont10)
	
	oPrinter:Say(nLinha,aColImp[10],"Descrição:",oFont10N)
	oPrinter:Say(nLinha,aColImp[13],AllTrim(QREL->B1_DESC),oFont10)
	nLinha += 0010
	
	oPrinter:Say(nLinha,aColImp[01],"Quantidade:",oFont10N)
	oPrinter:Say(nLinha,aColImp[05],AllTrim(Transform(QREL->QUANT,PesqPict("SC2","C2_QUANT"))),oFont10)
	
	oPrinter:Say(nLinha,aColImp[10],"U.M.:",oFont10N)
	oPrinter:Say(nLinha,aColImp[13],AllTrim(QREL->C2_UM),oFont10)
	nLinha += 0010
	
	If !Empty(QREL->A1_COD)
		cClient := AllTrim(QREL->A1_COD) + "/" + AllTrim(QREL->A1_LOJA) + " - " + AllTrim(QREL->A1_NOME)
	EndIf
	
	oPrinter:Say(nLinha,aColImp[01],"Cliente:",oFont10N)
	oPrinter:Say(nLinha,aColImp[05],cClient,oFont10)
	
	oPrinter:Say(nLinha,aColImp[10],"Pedido:",oFont10N)
	oPrinter:Say(nLinha,aColImp[13],AllTrim(QREL->C2_PEDIDO),oFont10)
	nLinha += 0010
	
	oPrinter:Say(nLinha,aColImp[01],"Emissão:",oFont10N)
	oPrinter:Say(nLinha,aColImp[05],DTOC(STOD(QREL->C2_EMISSAO)),oFont10)
	nLinha += 0010
	
	oPrinter:Say(nLinha,aColImp[01],"Inicio Previsto:",oFont10N)
	oPrinter:Say(nLinha,aColImp[05],DTOC(STOD(QREL->C2_DATPRI)),oFont10)
	
	oPrinter:Say(nLinha,aColImp[10],"Término Previsto:",oFont10N)
	oPrinter:Say(nLinha,aColImp[13],DTOC(STOD(QREL->C2_DATPRF)),oFont10)
	
	nLinha += 0010
	
	oPrinter:Say(nLinha,aColImp[01],"Local:",oFont10N)
	oPrinter:Say(nLinha,aColImp[05],AllTrim(QREL->C2_LOCAL),oFont10)
	
	oPrinter:Say(nLinha,aColImp[10],"Obs.:",oFont10N)
	oPrinter:Say(nLinha,aColImp[13],AllTrim(QREL->C2_OBS),oFont10)
	
	nLinha += 0030
	
Return

/*
	Realiza a impressão dos empenhos
	Waldir Baldin - 28/07/2015
*/
Static Function impEmp(oPrinter)

	Local nU := 0
	
	If len(aEmp) > 0
		nLinha += 0010
		oPrinter:Say(nLinha,aColImp[10],"EMPENHOS",oFont16N)
		nLinha += 0010
		
		oPrinter:Say(nLinha,aColImp[01],"CÓDIGO",oFont10N)
		oPrinter:Say(nLinha,aColImp[04],"DESCRIÇÃO",oFont10N)
		oPrinter:Say(nLinha,aColImp[11],"QTDE.",oFont10N)
		oPrinter:Say(nLinha,aColImp[15],"U.M.",oFont10N)
		oPrinter:Say(nLinha,aColImp[16],"LOCAL",oFont10N)
		oPrinter:Say(nLinha,aColImp[18],"END.",oFont10N)
		oPrinter:Say(nLinha,aColImp[21],"LOTE",oFont10N)
		nLinha += 0005
		oPrinter:Line(nLinha,aColImp[01],nLinha,aColImp[23])
		nLinha += 0020
	EndIf
	
	For nU := 1 to len(aEmp)
		If nLinha >= nTamPag
			oPrinter:EndPage()
			ImpCabec(oPrinter)
			
			nLinha += 0010
			oPrinter:Say(nLinha,aColImp[10],"EMPENHOS",oFont16N)
			nLinha += 0010
			
		oPrinter:Say(nLinha,aColImp[01],"CÓDIGO",oFont10N)
		oPrinter:Say(nLinha,aColImp[04],"DESCRIÇÃO",oFont10N)
		oPrinter:Say(nLinha,aColImp[11],"QTDE.",oFont10N)
		oPrinter:Say(nLinha,aColImp[15],"U.M.",oFont10N)
		oPrinter:Say(nLinha,aColImp[16],"LOCAL",oFont10N)
		oPrinter:Say(nLinha,aColImp[18],"END.",oFont10N)
		oPrinter:Say(nLinha,aColImp[21],"LOTE",oFont10N)
			nLinha += 0005
			
			oPrinter:Line(nLinha,aColImp[01],nLinha,aColImp[23])
			nLinha += 0020
		EndIf
		oPrinter:Say(nLinha,aColImp[01],AllTrim(aEmp[nU,01]),oFont10) //Codigo produto
		oPrinter:Say(nLinha,aColImp[04],AllTrim(aEmp[nU,02]),oFont10) //Descricao produto
		oPrinter:Say(nLinha,aColImp[11],AllTrim(Transform(aEmp[nU,03],PesqPict("SD4","D4_QUANT"))),oFont10) //Quantidade empenho
		oPrinter:Say(nLinha,aColImp[15],AllTrim(aEmp[nU,04]),oFont10) //Unidade de medida
		oPrinter:Say(nLinha,aColImp[16],AllTrim(aEmp[nU,05]),oFont10) //Armazém
		oPrinter:Say(nLinha,aColImp[18],AllTrim(aEmp[nU,06]),oFont10) //Endereco
		oPrinter:Say(nLinha,aColImp[21],AllTrim(aEmp[nU,07]),oFont10) //Lote
		nLinha += 0020
	Next nU
	
Return

/*
	Executa a Impressão
	Waldir Baldin - 28/07/2015
*/
Static Function impRot(oPrinter)
	
	Local nU			:= 0
	Local cDataVazia	:= "__ / __ / ____"
	Local cHoraVazia	:= "___ : ___"
	Local lBscCargMaq	:= .T.
	Local lOKSH8		:= .F.
	
	If Len(aRot) > 0
		nLinha += 0010
		oPrinter:Say(nLinha,aColImp[10],"ROTEIRO",oFont16N)
		nLinha += 0010
		
		oPrinter:Say(nLinha,aColImp[01],"COD",oFont08N)
		oPrinter:Say(nLinha,aColImp[02],"OPERAÇÃO",oFont08N)
		oPrinter:Say(nLinha,aColImp[06],"RECURSO",oFont08N)
		oPrinter:Say(nLinha,aColImp[09],"FERR.",oFont08N)
		If MV_PAR14 == "2"
			oPrinter:Say(nLinha,aColImp[11],"INI PREV.",oFont08N)
			oPrinter:Say(nLinha,aColImp[14],"HR. INI",oFont08N)
			oPrinter:Say(nLinha,aColImp[17],"FIM PREV.",oFont08N)
			oPrinter:Say(nLinha,aColImp[20],"HR. FIM",oFont08N)
		Else
			oPrinter:Say(nLinha,aColImp[11],"INI REAL",oFont08N)
			oPrinter:Say(nLinha,aColImp[14],"HR. INI",oFont08N)
			oPrinter:Say(nLinha,aColImp[17],"FIM REAL",oFont08N)
			oPrinter:Say(nLinha,aColImp[20],"HR. FIM",oFont08N)
		EndIf
		nLinha += 0005
		
		oPrinter:Line(nLinha,aColImp[01],nLinha,aColImp[23])
		nLinha += 0020
		
		For nU := 1 to Len(aRot)
			If nLinha >= nTamPag
				oPrinter:EndPage()
				ImpCabec(oPrinter)
				
				nLinha += 0010
				oPrinter:Say(nLinha,aColImp[10],"ROTEIRO",oFont16N)
				nLinha += 0010
				
				oPrinter:Say(nLinha,aColImp[01],"COD",oFont08N)
				oPrinter:Say(nLinha,aColImp[02],"OPERAÇÃO",oFont08N)
				oPrinter:Say(nLinha,aColImp[06],"RECURSO",oFont08N)
				oPrinter:Say(nLinha,aColImp[09],"FERR.",oFont08N)
				If MV_PAR14 == "2"
					oPrinter:Say(nLinha,aColImp[11],"INI PREV.",oFont08N)
					oPrinter:Say(nLinha,aColImp[14],"HR. INI",oFont08N)
					oPrinter:Say(nLinha,aColImp[17],"FIM PREV.",oFont08N)
					oPrinter:Say(nLinha,aColImp[20],"HR. FIM",oFont08N)
				Else
					oPrinter:Say(nLinha,aColImp[11],"INI REAL",oFont08N)
					oPrinter:Say(nLinha,aColImp[14],"HR. INI",oFont08N)
					oPrinter:Say(nLinha,aColImp[17],"FIM REAL",oFont08N)
					oPrinter:Say(nLinha,aColImp[20],"HR. FIM",oFont08N)
				EndIf

				nLinha += 0005
				
				oPrinter:Line(nLinha,aColImp[01],nLinha,aColImp[23])
				nLinha += 0020
			EndIf
			
			If MV_PAR14 == "2" .AND. lBscCargMaq
				SH8->(DbSetOrder(1)) //H8_FILIAL+H8_OP+H8_OPER+H8_DESDOBR
				If Len(cNumOP) <> TamSx3("H8_OP")[1]
					cNumOp := cNumOP + "  "
				EndIf
				If SH8->(DbSeek(xFilial("SH8") + cNumOP + aRot[nU,01]))
					lBscCargMaq	:= .T.
					lOKSH8		:= .T.
				Else
					lBscCargMaq := .F.
					nLinha += 0020
				EndIf
			EndIf
			
			oPrinter:Say(nLinha,aColImp[01],AllTrim(aRot[nU,01]),oFont08)
			If MV_PAR15 == "S"
					oPrinter:Code128c(nLinha+31,aColImp[02],AllTrim(aRot[nU,01]),30)//oPrinter:Int25(nLinha,aColImp[02],AllTrim(aRot[nU,01]),1,20,.F.,.F.)
			EndIf
			oPrinter:Say(nLinha,aColImp[02],AllTrim(aRot[nU,02]),oFont08)
			oPrinter:Say(nLinha,aColImp[06],AllTrim(aRot[nU,03]),oFont08)
			oPrinter:Say(nLinha,aColImp[09],AllTrim(aRot[nU,04]),oFont08)
			
			If MV_PAR14 == "2" .And. !lOKSH8 .And. !lBscCargMaq
				oPrinter:Say(nLinha,aColImp[11],"Não Foram Encontrados os Dados Gerados Pelo Carga Máquina.",oFont08N)
				nLinha += 0020
				oPrinter:Say(nLinha,aColImp[11],"INI REAL: ___/___/_____ HR. INI: ___:____ FIM REAL: ___/___/_____ HR. FIM: ___:____",oFont08N)
				oPrinter:Say(nLinha,aColImp[11],"OPERADOR: _______________________________________________________________",oFont08N)
			ElseIf MV_PAR14 == "2"
				oPrinter:Say(nLinha,aColImp[11],Iif(!Empty(SH8->H8_DTINI),DTOC(SH8->H8_DTINI),"Não Foram Encontrados os Dados Gerados Pelo Carga Máquina."),oFont08) // DATA INICIO
				oPrinter:Say(nLinha,aColImp[14],Iif(!Empty(SH8->H8_HRINI),SH8->H8_HRINI,""),oFont08) // HORA INICIO
				oPrinter:Say(nLinha,aColImp[17],Iif(!Empty(SH8->H8_DTFIM),DTOC(SH8->H8_DTFIM),""),oFont08) // DATA FIM
				oPrinter:Say(nLinha,aColImp[20],Iif(!Empty(SH8->H8_HRFIM),SH8->H8_HRFIM,""),oFont08) // HORA FIM
				nLinha += 0020
				oPrinter:Say(nLinha,aColImp[11],"OPERADOR: _______________________________________________________________",oFont08)
				nLinha += 0020
			ElseIf MV_PAR14 == "1"
				oPrinter:Say(nLinha,aColImp[11],cDataVazia,oFont08)
				oPrinter:Say(nLinha,aColImp[14],cHoraVazia,oFont08)
				oPrinter:Say(nLinha,aColImp[17],cDataVazia,oFont08)
				oPrinter:Say(nLinha,aColImp[20],cHoraVazia,oFont08)
				nLinha += 0020
				oPrinter:Say(nLinha,aColImp[11],"OPERADOR: _______________________________________________________________",oFont08N)
				nLinha += 0020
			EndIf
		Next
	EndIf
	
Return

/*
	Realiza a impressão do box de observações
	Waldir Baldin - 28/07/2015
*/
Static Function impObs(oPrinter)
	
	nLinha += 0020
	oPrinter:Say(nLinha,aColImp[09],"OBSERVAÇÕES",oFont16N)
	nLinha += 0010
	oPrinter:Box(nLinha,aColImp[01],nLinha+0070,aColImp[23])
	nLinha += 0080
	
Return

/*
	Realiza a impressão do box de legendas auxiliares
	Waldir Baldin - 28/07/2015
*/
Static Function impAux(oPrinter)
	
	Local nI			:= 0
	Local nQtdIt		:= 10
	Local nLinTMP		:= 0
	Local nColAux		:= 0
	
	oPrinter:Box(nLinha,aColImp[01],nLinha+0070,aColImp[23])
	nLinha 	+= 0015
	nLinTMP	:= nLinha
	
	If MV_PAR13 == "S" .and. Len(aMotivo) > 0
		nLinha := nLinTMP
		oPrinter:Say(nLinha,aColImp[06],"TRANSAÇÕES DA PRODUÇÃO E MOTIVOS DE PARADA",oFont12N)
		nLinha		+= 0010
		nLinTMP	:= nLinha
		nColAux	:= aColImp[01] + 0005
		For nI := 1 to nQtdIt
			If nI <= Len(aMotivo)
				oPrinter:Say(nLinha,nColAux,AllTrim(aMotivo[nI,1]) + " - " + AllTrim(aMotivo[nI,2]),oFont06)
			EndIf
			nLinha += 0010
			
			// Quebra das colunas do BOX
			If nI == (nQtdIt / 2)
				nLinha 	:= nLinTMP
				nColAux	:= aColImp[07] + 0005
			EndIf
		Next
	EndIf
	
Return

/*
	Executa a query das Ordens de Produção
	Waldir Baldin - 28/07/2015
*/
Static Function ExecQry()
	
	local cQuery	:= ""
	local cIsNull 	:= iif(TcGetDb() = "ORACLE", "NVL", iif(TcGetDb() $ "DB2", "COALESCE", "ISNULL"))
	
	cQuery		+=	"SELECT "																								+ CRLF
	cQuery		+=	"    C2_NUM, C2_ITEM, C2_SEQUEN, "																		+ CRLF
	cQuery		+=	"    CASE "																								+ CRLF
	cQuery		+=	"        WHEN C2_TPOP = 'F' THEN 'F - Firme' "															+ CRLF
	cQuery		+=	"        WHEN C2_TPOP = 'P' THEN 'P - Prevista' "														+ CRLF
	cQuery		+=	"    END C2_TPOP, "																						+ CRLF
	cQuery		+=	"    C2_PRODUTO, B1_DESC, C2_UM, C2_LOCAL, C2_PEDIDO, "													+ CRLF
	cQuery		+=	"    (C2_QUANT - C2_QUJE) QUANT, C2_QUANT, C2_ROTEIRO, "												+ CRLF
	cQuery		+=	"    C2_EMISSAO, C2_DATPRI, C2_DATPRF, C2_OBS, "														+ CRLF
	cQuery		+=	"    " + cIsNull + "(A1_COD, '') A1_COD, " + cIsNull + "(A1_LOJA, '') A1_LOJA, "						+ CRLF
	cQuery		+=	"	 " + cIsNull + "(A1_NOME, '') A1_NOME "																+ CRLF
	cQuery		+=	"FROM "																									+ CRLF																																																																																																																																																		+ CRLF
	cQuery		+=	"    "+retSqlName("SC2")+" SC2 "																		+ CRLF
	cQuery		+=	"    INNER JOIN "			+ retSqlName("SB1")	+ " SB1 ON "											+ CRLF
	cQuery		+=	"        B1_FILIAL = '"		+ xFilial("SB1")	+ "' AND B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "	+ CRLF
	cQuery		+=	"    LEFT JOIN "			+ retSqlName("SC5")	+ " SC5 ON "											+ CRLF
	cQuery		+=	"        C5_FILIAL = '"		+ xFilial("SC5")	+ "' AND C5_NUM = C2_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "	+ CRLF
	cQuery		+=	"    LEFT JOIN "			+ retSqlName("SA1")	+ " SA1 ON "											+ CRLF
	cQuery		+=	"        A1_FILIAL = '"		+ xFilial("SA1")	+ "' AND A1_COD = C5_CLIENTE AND "						+ CRLF
	cQuery		+=	"        A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' "												+ CRLF
	cQuery		+=	"WHERE "																								+ CRLF
	cQuery		+=	"    C2_FILIAL = '"	+ xFilial("SC2") + "' AND "															+ CRLF
	cQuery		+=	"    C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '" + MV_PAR01 + "' AND '"	+ MV_PAR02			+ "' AND "			+ CRLF
	cQuery		+=	"    C2_PRODUTO	BETWEEN '"	+ MV_PAR03				+ "' AND '"	+ MV_PAR04			+ "' AND "			+ CRLF
	cQuery		+=	"    C2_EMISSAO	BETWEEN '"	+ dToS(MV_PAR05)		+ "' AND '"	+ dToS(MV_PAR06)	+ "' AND "			+ CRLF
	cQuery		+=	"    C2_DATPRI	BETWEEN '"	+ dToS(MV_PAR07)		+ "' AND '"	+ dToS(MV_PAR08)	+ "' AND "			+ CRLF
	cQuery		+=	"    C2_DATPRF	BETWEEN '"	+ dToS(MV_PAR09)		+ "' AND '"	+ dToS(MV_PAR10)	+ "' AND "			+ CRLF
	if MV_PAR11 != "A"
		cQuery	+=	"    C2_TPOP = '"			+ MV_PAR11				+ "' AND "											+ CRLF
	endIf
	cQuery		+=	"    SC2.D_E_L_E_T_ = ' ' "																				+ CRLF
	cQuery		+=	"ORDER BY "																								+ CRLF
	cQuery		+=	"	C2_NUM, C2_ITEM, C2_SEQUEN"																			+ CRLF
	
	if select("QREL") > 0
		QREL->(dbCloseArea())
	endIf
	
	TcQuery cQuery New Alias "QREL"
	count to nRegs
	QREL->(dbGoTop())
	
Return

/*
	Rotina responsável por montar o grupo de perguntas personalizado baseado na função ParamBox.
	Waldir Baldin - 28/07/2015
*/
Static Function fPerg(cPerg)
	
	local aParambox	:= {}
	local aTipo		:= {"F=Firme", "P=Prevista", "A=Ambas"}
	local aSimNao		:= {"S=Sim", "N=Não"}
	//local aOrigem		:= {"1=B1_COD", "2=B1_CODBAR"}
	Local aRoteiros	:= {"1=A Preencher","2=Carga Máquina"}
	local lRet		:= .f.
	Local aRet 		:= {}
	
	aAdd(aParambox, {1, "OP de:"					,space(TamSx3("C2_NUM")[1] + TamSx3("C2_ITEM")[1] + TamSx3("C2_SEQUEN")[1])	,"@!"		,"" ,"SC2"				,"", 060,	.f.})	// MV_PAR01 
	aAdd(aParambox, {1, "OP até:"					,space(TamSx3("C2_NUM")[1] + TamSx3("C2_ITEM")[1] + TamSx3("C2_SEQUEN")[1])	,"@!"		,"" ,"SC2"				,"", 060,	.f.})	// MV_PAR02
	aAdd(aParambox, {1, "Produto de:"				,space(TamSx3("C2_PRODUTO")[1])											,"@!"		,"" ,"SB1"				,"", 060,	.f.})	// MV_PAR03
	aAdd(aParambox, {1, "Produto até:"				,space(TamSx3("C2_PRODUTO")[1])											,"@!"		,"" ,"SB1"				,"", 060,	.t.})	// MV_PAR04
	aAdd(aParambox, {1, "Emissão de:"				,cToD("")																,""			,"" ,""					,"", 050,	.t.})	// MV_PAR05
	aAdd(aParambox, {1, "Emissão até:"				,cToD("")																,""			,"" ,""					,"", 050,	.t.})	// MV_PAR06
	aAdd(aParambox, {1, "Início de:"				,cToD("")																,""			,"" ,""					,"", 050,	.t.})	// MV_PAR07
	aAdd(aParambox, {1, "Início até:"				,cToD("")																,""			,"" ,""					,"", 050,	.t.})	// MV_PAR08
	aAdd(aParambox, {1, "Entrega de:"				,cToD("")																,""			,"" ,""					,"", 050,	.t.})	// MV_PAR09
	aAdd(aParambox, {1, "Entrega até:"				,cToD("")																,""			,"" ,""					,"", 050,	.t.})	// MV_PAR10
	aAdd(aParambox, {2, "Tipo OP:"					,"1"																	,aTipo		,100,"Pertence('AFP')"	,			.f.})	// MV_PAR11
	aAdd(aParambox, {2, "Imprime Roteiro:"			,"1"																	,aSimNao		,100,"Pertence('SN')"	,			.f.})	// MV_PAR12
	aAdd(aParambox, {2, "Imprime Motivo Paradas:"		,"1"																	,aSimNao		,100,"Pertence('SN')"	,			.f.})	// MV_PAR13
	aAdd(aParambox, {2, "Roteiros:"					,"1"																	,aRoteiros	,100,"Pertence('12')"	,			.f.})	// MV_PAR14
	aAdd(aParambox, {2, "Código Barras Roteiro:"		,"1"																	,aSimNao		,100,"Pertence('SN')"	,			.f.})	// MV_PAR15
	
	lRet := ParamBox(aParambox, cTitle, @aRet,,,,,,, cPerg, .T., .T.)
	
Return lRet

/*

	Rotina que busca os Empenhos da OP em questão
	Julio Lisboa - 15/10/2015
*/
Static Function buscaEmp(cOP)
	
	Local cQuery		:= ""
	Default cOP		:= ""
	
	If !Empty(cOP)
		cQuery := "SELECT DISTINCT D4_COD, B1_DESC, D4_QUANT, DC_QUANT, B1_UM, D4_LOCAL, DC_LOCALIZ, D4_LOTECTL, D4_OP, DC_OP "+CRLF
		cQuery += "FROM " +CRLF
		cQuery +=		RetSqlName("SD4") + " SD4 "+CRLF
		cQuery += "INNER JOIN "+CRLF
		cQuery +=    RetSqlName("SB1") + " AS SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND D4_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "LEFT JOIN "+CRLF
		cQuery +=    RetSqlName("SDC") + " AS SDC ON DC_FILIAL = D4_FILIAL AND DC_PRODUTO = D4_COD AND DC_OP = D4_OP  AND DC_LOTECTL = D4_LOTECTL AND SDC.D_E_L_E_T_ = ' ' "+CRLF
		cQuery += "WHERE "+CRLF
		cQuery += "	D4_FILIAL = '" + xFilial("SD4") + "' "+CRLF
		cQuery += "	AND D4_OP = '" + cOP + "' "+CRLF
		cQuery += "	AND SD4.D_E_L_E_T_ = ' ' "+CRLF
		
		If Select("QRYSDC") > 0
			QRYSDC->(DbCloseArea())
		EndIf
		
		TCQUERY cQuery NEW ALIAS "QRYSDC"
		
		While QRYSDC->(!Eof())
			Aadd(aEmp,{;
				QRYSDC->D4_COD,;			// Codigo
				QRYSDC->B1_DESC,;			// Descrição
				Iif(QRYSDC->DC_QUANT = 0,QRYSDC->D4_QUANT,QRYSDC->DC_QUANT),; // Quantidade //Iif(ValType(QRYSDC->DC_QUANT) == "U",QRYSDC->D4_QUANT,QRYSDC->DC_QUANT),; // Quantidade
				QRYSDC->B1_UM,;			// Unidade de Medida
				QRYSDC->D4_LOCAL,;			// Armazem
				QRYSDC->DC_LOCALIZ,;		// Endereço
				QRYSDC->D4_LOTECTL;		// Lote
				})
			QRYSDC->(DbSkip())
		EndDo
		QRYSDC->(dbCloseArea())
		
	EndIf
	
Return

/*
	Rotina que busca os Roteiros da OP em questão
	Julio Lisboa - 15/10/2015
*/
Static Function buscaRot(cRoteiro,cProduto)
	
	Local cQuery		:= ""
	Default cRoteiro	:= ""
	
	If !Empty(cRoteiro)
		cQuery += "SELECT " + CRLF
		cQuery += "	*	" + CRLF
		cQuery += "FROM " + CRLF
		cQuery += "	" + RetSqlName("SG2") + " AS SG2 " + CRLF
		cQuery += "INNER JOIN " + CRLF
		cQuery += "	" + RetSqlName("SB1") + " AS SB1 " + CRLF
		cQuery += "ON " + CRLF
		cQuery += "	B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = G2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "	G2_FILIAL = '" + xFilial("SG2") + "' AND " + CRLF
		cQuery += "	G2_CODIGO = '" + cRoteiro + "' AND " + CRLF
		cQuery += "	G2_PRODUTO = '" + cProduto + "' AND " + CRLF
		cQuery += "	SG2.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY " + CRLF
		cQuery += " G2_PRODUTO,	G2_OPERAC " + CRLF
		
		If Select("QRYROT") > 0
			QRYROT->(DbCloseArea())
		EndIf
		
		TcQuery cQuery New Alias "QRYROT"
		
		While QRYROT->(!Eof())
			Aadd(aRot,{;
			QRYROT->G2_OPERAC,;	// 01 - Operação
			QRYROT->G2_DESCRI,;	// 02 - Descrição
			QRYROT->G2_RECURSO,;	// 03 - Recurso
			QRYROT->G2_FERRAM;		// 04 - Ferramenta
			})
			QRYROT->(DbSkip())
		EndDo
		QRYROT->(DbCloseArea())
	EndIf
	
Return

/*
	Busca os motivos de parada
	28/07/2015
*/
Static Function buscaMotivos()
	
	Local cQuery		:= ""
	
	cQuery := "SELECT " + CRLF
	cQuery += "	X5_CHAVE, X5_DESCRI " + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "	" + RetSqlName("SX5") + " AS SX5 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	X5_FILIAL = '" + xFilial("SX5") + "' AND " + CRLF
	cQuery += "	X5_TABELA = '44' AND " + CRLF
	cQuery += "	SX5.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY " + CRLF
	cQuery += "	X5_CHAVE" + CRLF
	
	If Select("QRYMOTIVO") > 0
		QRYMOTIVO->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "QRYMOTIVO"
	
	While QRYMOTIVO->(!Eof())
		Aadd(aMotivo,{QRYMOTIVO->X5_CHAVE,QRYMOTIVO->X5_DESCRI})
		QRYMOTIVO->(DbSkip())
	EndDo
	
	QRYMOTIVO->(DbCloseArea())

Return
