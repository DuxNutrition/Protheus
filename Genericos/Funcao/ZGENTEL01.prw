#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'FWLIBVERSION.CH' 

/*/{Protheus.doc} 
Tela que consulta os status das Aprovacoes dos Documentos do ipo (Z1)
@author Jedielson Rodrigues
@since 28/09/2024
@history 
@version P11,P12
@database MSSQL
@See 
/*/

User Function ZGENTEL01(cAlias,nReg,nOpcx,cTipoDoc,lStatus,lResid,aRotina)

Local aArea			:= GetArea()
Local aSavCols		:= {}
Local aSavHead		:= {}
Local cHelpApv		:= "Este documento nao possui controle de aprovacao ou deve ser aprovado pelo controle de alçadas." //OemToAnsi(STR0052) 
Local cAliasSCR		:= GetNextAlias()
Local cComprador	:= ""
Local cSituaca  	:= ""
Local cNumDoc		:= ""
Local cStatus		:= "Documento aprovado" //STR0087 // "Documento aprovado"
Local cTitle		:= ""
Local cTitDoc		:= ""
Local cAddHeader	:= ""
Local cAprovador	:= ""
Local nSavN			:= 0
Local nX   			:= 0
Local oDlg			:= NIL
Local oGet			:= NIL
Local oBold			:= NIL
Local lExAprov		:= SuperGetMV("MV_EXAPROV",.F.,.F.)
Local lAprPCEC		:= SuperGetMV("MV_APRPCEC",.F.,.F.)
Local lAprSAEC		:= SuperGetMV("MV_APRSAEC",.F.,.F.)
Local lAprSCEC		:= SuperGetMV("MV_APRSCEC",.F.,.F.)
Local lAprCTEC		:= SuperGetMV("MV_APRCTEC",.F.,0) <> 0
Local lAprMDEC		:= .T.
Local cAprIPPC		:= SuperGetMv("MV_APRIPPC",.F.,'2')
Local lCtCorp		:= .F.
Local lMdCorp		:= .F.
Local cQuery   		:= ""
Local aStruSCR 		:= SCR->(dbStruct())
Local cFilSCR 		:= ""
Local cFilDBM		:= ""
Local lFluig		:= SuperGetMV("MV_APWFECM",.F.,"1") == "1" .And. !Empty(AllTrim(GetNewPar("MV_ECMURL",""))) .And. FWWFFluig()
Local nTotal 		:= 0
Local aCposPe 		:= {}
Local nP 			:= 0

DEFAULT cTipoDoc := "PC"
DEFAULT lStatus  := .T.
DEFAULT lResid   := .F.
DEFAULT nOpcx    := 2
DEFAULT aRotina  := {}

cFilSCR := IIf(cTipoDoc $ 'IC|CT|IR|RV',CnFilCtr(CN9->CN9_NUMERO),xFilial("SCR"))
cFilDBM := xFilial("DBM")

If lStatus
	aSavCols := aClone(aCols)
	aSavHead := aClone(aHeader)
	nSavN := N
Else
	Private aCols := {}
	Private aHeader := {}
	Private N := 1
EndIf

dbSelectArea(cAlias)
MsGoto(nReg)

IF cTipoDoc $ "PC|AE|IP"
	If !Empty(SC7->C7_APROV) .Or. cTipoDoc == "IP"
		cTitle  	:= "Aprovacao do Pedido de Compra"// OemToAnsi(STR0029) // "Aprovacao do Pedido de Compra"
		cTitDoc 	:= "Pedido" //OemToAnsi(STR0012) // "Pedido"
		cHelpApv	:= "Este pedido nao possui controle de aprovacao." //OemToAnsi(STR0033) // "Este pedido nao possui controle de aprovacao."
		cNumDoc 	:= SC7->C7_NUM
		cComprador	:= UsrRetName(SC7->C7_USER)
	EndIf
ElseIf cTipoDoc == "CP"
	If !Empty(SC3->C3_APROV)
    	cTitle 		:= "Aprovacao do Contrato de Parceria" //OemToAnsi(STR0040) // "Aprovacao do Contrato de Parceria"
		cTitDoc 	:= "Contrato"// OemToAnsi(STR0039) // "Contrato"
		cHelpApv	:= "Este Contrato nao possui controle de aprovacao."// OemToAnsi(STR0038) // "Este Contrato nao possui controle de aprovacao."
		cNumDoc		:= SC3->C3_NUM
		cComprador	:= UsrRetName(SC3->C3_USER)
	EndIf
ElseIf cTipoDoc == "NF"
	If !Empty(SF1->F1_APROV)
	    cTitle		:= "Aprovacao da Nota Fiscal de Entrada"// OemToAnsi(STR0047) // "Aprovacao da Nota Fiscal de Entrada"
	    cTitDoc		:= "Nota Fiscal" // OemToAnsi(STR0048) // "Nota Fiscal"
	    cHelpApv	:= "Esta Nota Fiscal nao possui controle de aprovacao." //OemToAnsi(STR0049) // "Esta Nota Fiscal nao possui controle de aprovacao."
		cNumDoc		:= SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	EndIf
ElseIf cTipoDoc $ "MD|IM"
	cTitle   	:= "Aprovação da  Medição de Contrato" //OemToAnsi(STR0053)//"Aprovação da  Medição de Contrato"
	cTitDoc   	:= "Medição" //OemToAnsi(STR0054)//"Medição"
	cHelpApv  	:= "Esta medição não possui controle de aprovação" //OemToAnsi(STR0055)//"Esta medição não possui controle de aprovação"
	cAprovador	:= "Aprovadores" //OemToAnsi(STR0062)//"Aprovadores"
	lMdCorp	:= Empty(CND->CND_FILIAL)
	cNumDoc   	:= CND->CND_NUMMED
	cComprador	:= CND->CND_APROV + " - " + Posicione("SAL",1,xFilial("SAL")+CND->CND_APROV, "AL_DESC")
ElseIf cTipoDoc $ "CT|IC|Z1"
	cTitle    	:= "Aprovação de Contrato" // OemToAnsi(STR0076)//"Aprovação de Contrato"
	cTitDoc   	:= "Contratos" //OemToAnsi(STR0077)//"Contratos"
	cHelpApv  	:= "Este contrato não possui controle de aprovação" //OemToAnsi(STR0078)//"Este contrato não possui controle de aprovação"
	cAprovador	:= "Solicitante" //OemToAnsi(STR0079)//"Aprovadores"
	lCtCorp	:= Empty(CN9->CN9_FILIAL)
	cDocRevis   := ZAD->ZAD_CONTRA + " - " + ZAD->ZAD_REVISA
	cNumDoc     := ZAD->ZAD_CONTRA
	cComprador	:= "000745 - Jedielson.Rodrigues"
ElseIf cTipoDoc == "SC"
	cTitle   	:= "Aprovacao da Solicitação de Compra" //OemToAnsi(STR0064) // "Aprovacao da Solicitação de Compra"
	cTitDoc  	:= "Solicitação" //OemToAnsi(STR0065) // "Solicitação"
	cHelpApv  	:= "Esta solicitação nao possui controle de aprovacao." //OemToAnsi(STR0066) // "Esta solicitação nao possui controle de aprovacao."
	cNumDoc   	:= SC1->C1_NUM
	cComprador	:= UsrRetName(SC1->C1_USER)
ElseIf cTipoDoc == "SA"
	cTitle    	:= "Aprovação da Solicitação de Armazém" //OemToAnsi(STR0069) // "Aprovação da Solicitação de Armazém"
	cTitDoc   	:= "Solicitação" //OemToAnsi(STR0065) // "Solicitação"
	cHelpApv  	:= "Esta solicitação nao possui controle de aprovação." //OemToAnsi(STR0066) // "Esta solicitação nao possui controle de aprovação."
	cNumDoc   	:= SCP->CP_NUM
	cComprador:= UsrRetName(SCP->CP_SOLICIT)
ElseIf cTipoDoc $ "RV|IR"
	cTitle		:= "Aprovação de Contrato" //OemToAnsi(STR0076)//"Aprovação de Contrato"
	cTitDoc   	:= "Contrato" //OemToAnsi(STR0077)//"Contrato"
	cHelpApv  	:= "Este contrato não possui controle de aprovação" //OemToAnsi(STR0078)//"Este contrato não possui controle de aprovação"
	cAprovador	:= "Aprovadores" //OemToAnsi(STR0079)//"Aprovadores"
	lCtCorp	:= Empty(CN9->CN9_FILIAL)
	cNumDoc   	:= CN9->CN9_NUMERO + " - " + CN9->CN9_REVISA
	cComprador	:= CN9->CN9_APROV + " - " + Posicione("SAL",1,xFilial("SAL")+CN9->CN9_APROV, "AL_DESC")
EndIf

If !Empty(cNumDoc)
	aHeader:= {}
	aCols  := {}

	/*
	If ExistBlock("A120PSCR")
		cAddHeader := ExecBlock("A120PSCR", .F., .F. )
		aCposPe := StrTokArr2(cAddHeader,"/",.F.) //Tratamento para adcionar campos na query
		If ValType(cAddHeader) <> "C"
			cAddHeader := ""
		Endif
	Endif*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem do aHeader com os campos fixos.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX3->(dbSetOrder(1))
	SX3->(MsSeek("SCR"))
	If (cTipoDoc $ "PC|IP" .And. lAprPCEC) .Or.;
			(cTipoDoc == "SA" .And. lAprSAEC) .Or.;
			(cTipoDoc == "SC" .And. lAprSCEC) .Or.;
			(cTipoDoc $ "CT|IC|Z1" .And. lAprCTEC) .Or.;
			(cTipoDoc $ "MD|IM" .And. lAprMDEC) .Or.;
			(cTipoDoc $ "SC|IP|PC" .and. MtExistDBM(cTipoDoc,cNumDoc))
		AADD(aHeader,{"Item","bCR_ITEM","",8,0,"","","C","",""} )	// Item
	Endif

	While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == "SCR")
		IF AllTrim(SX3->X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB/CR_TIPO/CR_ITGRP" + Iif(lFluig,"/CR_FLUIG","") + cAddHeader
			AADD(aHeader,{	TRIM(X3Titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT } )

			If AllTrim(SX3->X3_CAMPO) == "CR_NIVEL"
				AADD(aHeader,{ "Aprovador Responsável","bCR_NOME",   "",15,0,"","","C","",""} )	//"Aprovador Responsável"
				AADD(aHeader,{ "Situação","bCR_SITUACA","",20,0,"","","C","",""} )	//"Situação"
				AADD(aHeader,{ "Avaliado por","bCR_NOMELIB","",15,0,"","","C","",""} )	//"Avaliado por"
			EndIf
			
			If AllTrim(SX3->X3_CAMPO) == "CR_DATALIB"
				AADD(aHeader,{ "Grupo","bCR_GRUPO","",6,0,"","","C","",""} )	//"Grupo"
			EndIf

		Endif

		SX3->(dbSkip())
	EndDo

	ADHeadRec("SCR",aHeader)

	If cTipoDoc == "PC"

		cQuery    := "SELECT "
		cQuery    += "COALESCE(
		cQuery    += "(SELECT DISTINCT C7_NUM FROM " +RetSqlName("SC7")"
		cQuery    += " WHERE C7_FILIAL = '" + fwxFilial('SC7') + "' 
		cQuery    += " AND C7_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM)) + "' AND C7_RESIDUO = 'S'), ' ' ) C7_RESIDUO, "
		cQuery    += "   SCR.CR_USER, "
		cQuery    += "   SCR.CR_TIPO, "
		cQuery    += "   SCR.CR_GRUPO, "
		cQuery    += "   SCR.CR_STATUS, "
		cQuery    += "   SCR.CR_USERLIB, "
		cQuery    += "   SCR.CR_NIVEL, "
		cQuery    += "   SCR.CR_DATALIB, "
		cQuery    += "   SCR.CR_FLUIG, "
		If Len(aCposPe) > 0
			For nP := 1 To Len(aCposPe)
				cQuery += aCposPe[nP]+","
			Next
		EndIf 		
		cQuery    += "   SCR.R_E_C_N_O_ SCRRECNO, "		    
		cQuery    += "   SCR.CR_OBS "
		cQuery    += "FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
		cQuery    += "SCR.CR_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM)) + "'" 

		If cAprIPPC == "1"//Verificação do parâmetro MV_APRIPPC para mostrar no log de aprovação (IP+PC)
			cQuery    += " AND SCR.CR_TIPO IN ('PC','IP') "
		Else
			cQuery    += " AND SCR.CR_TIPO = 'PC' "
		EndIf 
		cQuery    += " AND SCR.D_E_L_E_T_=' ' "

	ElseIf cTipoDoc == "AE"
		cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
		cQuery    += "SCR.CR_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM))+"' AND "
		cQuery    += "SCR.CR_TIPO = 'AE' "
		If lExAprov .And. lResid
			cQuery    += " "
		Else
			cQuery    += "AND SCR.D_E_L_E_T_=' ' "
		EndIf
	ElseIf cTipoDoc == "CP"
		cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
		cQuery    += "SCR.CR_NUM = '"+Padr(SC3->C3_NUM,Len(SCR->CR_NUM))+"' AND "
		cQuery    += "SCR.CR_TIPO = 'CP' "
		If !lExAprov .Or. SC3->C3_RESIDUO != "S"
			cQuery    += "AND SCR.D_E_L_E_T_=' ' "
		EndIf
	ElseIf cTipoDoc == "NF"
		cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
		cQuery    += "SCR.CR_NUM = '"+Padr(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,Len(SCR->CR_NUM))+"' AND "
		cQuery    += "SCR.CR_TIPO = 'NF' "
		cQuery    += "AND SCR.D_E_L_E_T_=' ' "
	ElseIf cTipoDoc == "MD"
		cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE "
		If !lMdCorp
			cQuery		+= "SCR.CR_FILIAL='"+cFilSCR+"' AND "
		EndIf
		cQuery    += "SCR.CR_NUM = '"+Padr(CND->CND_NUMMED,Len(SCR->CR_NUM))+"' AND "
		cQuery    += "SCR.CR_TIPO = 'MD' "
		cQuery    += "AND SCR.D_E_L_E_T_=' ' "
	ElseIf cTipoDoc == "SC"
		cAliasSCR  := GetNextAlias()
		cQuery     := "SELECT SCR.*,DBM.DBM_ITEM,DBM.DBM_ITEMRA,DBM.DBM_APROV,SCR.R_E_C_N_O_ SCRRECNO "
		cQuery	   += "FROM "+RetSqlName("SCR")+" SCR LEFT JOIN "
		cQuery	   += RetSqlName("DBM")+" DBM ON "
		cQuery	   += "SCR.CR_TIPO=DBM.DBM_TIPO AND "
		cQuery	   += "SCR.CR_NUM=DBM.DBM_NUM AND "
		cQuery	   += "SCR.CR_GRUPO=DBM.DBM_GRUPO AND "
		cQuery	   += "SCR.CR_ITGRP=DBM.DBM_ITGRP AND "
		If MtVerTipcom(SC1->C1_NUM,cTipoDoc)
			cQuery	   += "SCR.CR_TIPCOM = DBM.DBM_TIPCOM AND "
		Endif
		cQuery	   += "SCR.CR_USER=DBM.DBM_USER AND "
		cQuery	   += "SCR.CR_USERORI=DBM.DBM_USEROR AND "
		cQuery	   += "SCR.CR_APROV=DBM.DBM_USAPRO AND "
		cQuery	   += "SCR.CR_APRORI=DBM.DBM_USAPOR AND "
		cQuery	   += "SCR.D_E_L_E_T_ = DBM.D_E_L_E_T_ "
		cQuery     += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
		cQuery     += "DBM.DBM_FILIAL='"+cFilDBM+"' AND "
		cQuery     += "SCR.CR_NUM = '"+Padr(SC1->C1_NUM,Len(SCR->CR_NUM))+"' AND "
		cQuery     += "SCR.CR_TIPO = 'SC' "
		
		If (lExAprov .AND. !lResid) .OR. !lExAprov
			cQuery    += "AND SCR.D_E_L_E_T_=' ' "
		Else
			//Realiza Filtro dos Deletados Apenas para os Registros Sem C1_RESIDUO = 'S'
			cQrySC1 := "JOIN " + RetSqlName("SC1") + " SC1 "
			cQrySC1 += "	ON SC1.C1_NUM = SCR.CR_NUM "
			cQrySC1 += "	AND SC1.C1_ITEM = DBM.DBM_ITEM "
			cQrySC1 += "	AND SC1.D_E_L_E_T_ = ' ' "
			cQrySC1 += "	AND (CASE WHEN SC1.C1_RESIDUO = ' ' THEN SCR.D_E_L_E_T_ ELSE ' ' END) = ' ' "
			cQuery := StrTran(cQuery,"WHERE",cQrySC1+"WHERE")
			
			//Adiciona coluna C1_RESIDUO 
			cQuery := StrTran(cQuery,"SCR.*","SC1.C1_RESIDUO,SCR.*") 
			
			//Apresenta somente o último registro da SCR distinto para cada item (não lista registros desnecessários)
			cQuery	  += "AND SCR.R_E_C_N_O_ IN (SELECT DISTINCT MAX(SCR_.R_E_C_N_O_) "
			cQuery    += "FROM "+RetSqlName("SCR") + " SCR_ LEFT JOIN "
			cQuery	   += RetSqlName("DBM")+" DBM_ ON "
			cQuery	   += "SCR_.CR_TIPO=DBM_.DBM_TIPO AND "
			cQuery	   += "SCR_.CR_NUM=DBM_.DBM_NUM AND "
			cQuery	   += "SCR_.CR_GRUPO=DBM_.DBM_GRUPO AND "
			cQuery	   += "SCR_.CR_ITGRP=DBM_.DBM_ITGRP AND "
			cQuery	   += "SCR_.CR_USER=DBM_.DBM_USER AND "
			cQuery	   += "SCR_.CR_USERORI=DBM_.DBM_USEROR AND "
			cQuery	   += "SCR_.CR_APROV=DBM_.DBM_USAPRO AND "
			cQuery	   += "SCR_.CR_APRORI=DBM_.DBM_USAPOR AND "
			cQuery	   += "SCR_.D_E_L_E_T_ = DBM_.D_E_L_E_T_ "	
			cQuery    += "GROUP BY CR_NUM, CR_USER, CR_APROV, CR_ITGRP, CR_DATALIB, CR_USERLIB, CR_LIBAPRO, CR_GRUPO, DBM_.DBM_ITEM)"
		EndIf
	ElseIf cTipoDoc == "SA"
		cQuery    := "SELECT SCR.*,DBM.DBM_ITEM,DBM.DBM_ITEMRA,SCR.R_E_C_N_O_ SCRRECNO "
		cQuery	   += "FROM "+RetSqlName("SCR")+" SCR LEFT JOIN "
		cQuery	   += RetSqlName("DBM")+" DBM ON "
		cQuery	   += "CR_TIPO=DBM_TIPO AND "
		cQuery	   += "CR_NUM=DBM_NUM AND "
		cQuery	   += "CR_GRUPO=DBM_GRUPO AND "
		cQuery	   += "CR_ITGRP=DBM_ITGRP AND "
		cQuery	   += "CR_USER=DBM_USER AND "
		cQuery	   += "CR_USERORI=DBM_USEROR AND "
		cQuery	   += "CR_APROV=DBM_USAPRO AND "
		cQuery	   += "CR_APRORI=DBM_USAPOR "
		cQuery    += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
		cQuery    += "SCR.CR_NUM = '"+Padr(SCP->CP_NUM,Len(SCR->CR_NUM))+"' AND "
		cQuery    += "SCR.CR_TIPO = 'SA' "
		If !lExAprov
			cQuery    += "AND DBM.D_E_L_E_T_=' ' "
			cQuery    += "AND SCR.D_E_L_E_T_=' ' "
		EndIf
	ElseIf cTipoDoc == "IP"
		cQuery    := "SELECT SCR.*,DBM.DBM_ITEM,DBM.DBM_APROV,DBM.DBM_ITEMRA,SCR.R_E_C_N_O_ SCRRECNO "
		cQuery	  += "FROM "+RetSqlName("SCR")+" SCR LEFT JOIN "
		cQuery	  += RetSqlName("DBM")+" DBM ON "
		cQuery    += "	 DBM.DBM_FILIAL='"+cFilDBM+"' AND "
		cQuery	  += "	 SCR.CR_TIPO=DBM.DBM_TIPO AND "
		cQuery	  += "	 SCR.CR_NUM=DBM.DBM_NUM AND "
		cQuery	  += "	 SCR.CR_GRUPO=DBM.DBM_GRUPO AND "
		cQuery	  += "	 SCR.CR_ITGRP=DBM.DBM_ITGRP AND "
		If MtVerTipcom(SC7->C7_NUM,cTipoDoc)
			cQuery	  += "	 SCR.CR_TIPCOM =DBM.DBM_TIPCOM AND "
		Endif
		cQuery	  += "	 SCR.CR_USER=DBM.DBM_USER AND "
		cQuery	  += "	 SCR.CR_USERORI=DBM.DBM_USEROR AND "
		cQuery	  += "	 SCR.CR_APROV=DBM.DBM_USAPRO AND "
		cQuery	  += "	 SCR.CR_APRORI=DBM.DBM_USAPOR AND "
		cQuery	  += "   SCR.D_E_L_E_T_ = DBM.D_E_L_E_T_ "
		If (lExAprov .AND. !lResid) .OR. !lExAprov
			cQuery	  += " AND DBM.D_E_L_E_T_ = ' ' "
		Endif
		cQuery    += " WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "		
		cQuery    += " SCR.CR_NUM = '"+Padr(SC7->C7_NUM,Len(SCR->CR_NUM))+"' AND "
		cQuery    += " SCR.CR_TIPO IN('IP','PC')"
		If (lExAprov .AND. !lResid) .OR. !lExAprov
			cQuery    += " AND SCR.D_E_L_E_T_=' ' "
		Else
			//Realiza Filtro dos Deletados Apenas para os Registros Sem C1_RESIDUO = 'S'
			cQrySC7 := " LEFT JOIN " + RetSqlName("SC7") + " SC7 "
			cQrySC7 += "	ON SC7.C7_NUM = SCR.CR_NUM "
			cQrySC7 += "	AND SC7.C7_ITEM = DBM.DBM_ITEM "
			cQrySC7 += "	AND SC7.D_E_L_E_T_ = ' ' "
			cQrySC7 += "	AND (CASE WHEN SC7.C7_RESIDUO = ' ' THEN SCR.D_E_L_E_T_ ELSE ' ' END) = ' ' "
			cQuery := StrTran(cQuery,"WHERE",cQrySC7+"WHERE")
			
			//Adiciona coluna C7_RESIDUO 
			cQuery := StrTran(cQuery,"SCR.*","SC7.C7_RESIDUO,SCR.*") 
			
			//Apresenta somente o último registro da SCR distinto para cada item (não lista registros desnecessários)
			cQuery	  += "AND SCR.R_E_C_N_O_ IN (SELECT DISTINCT MAX(SCR_.R_E_C_N_O_) "
			cQuery    += "FROM "+RetSqlName("SCR") + " SCR_ LEFT JOIN "
			cQuery	   += RetSqlName("DBM")+" DBM_ ON "
			cQuery	   += "SCR_.CR_TIPO=DBM_.DBM_TIPO AND "
			cQuery	   += "SCR_.CR_NUM=DBM_.DBM_NUM AND "
			cQuery	   += "SCR_.CR_GRUPO=DBM_.DBM_GRUPO AND "
			cQuery	   += "SCR_.CR_ITGRP=DBM_.DBM_ITGRP AND "
			cQuery	   += "SCR_.CR_USER=DBM_.DBM_USER AND "
			cQuery	   += "SCR_.CR_USERORI=DBM_.DBM_USEROR AND "
			cQuery	   += "SCR_.CR_APROV=DBM_.DBM_USAPRO AND "
			cQuery	   += "SCR_.CR_APRORI=DBM_.DBM_USAPOR "
			If (lExAprov .AND. !lResid) .OR. !lExAprov
				cQuery	   += " AND SCR_.D_E_L_E_T_ = DBM_.D_E_L_E_T_ "	
			Endif
			cQuery	   += "AND SCR_.CR_FILIAL  = SCR.CR_FILIAL "
			cQuery	   += "AND SCR_.CR_NUM =   SCR.CR_NUM "

			cQuery    += "GROUP BY CR_NUM, CR_USER, CR_APROV, CR_ITGRP, CR_DATALIB, CR_USERLIB, CR_LIBAPRO, CR_GRUPO)"
		EndIf
	ElseIf cTipoDoc $ "CT|Z1"
		cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
		cQuery    += "WHERE "
		If !lCtCorp
			cQuery		+= "SCR.CR_FILIAL='"+cFilSCR+"' AND "
		EndIf
		cQuery    += "SCR.CR_NUM = '"+cNumDoc+"' AND "
		cQuery    += "SCR.CR_TIPO IN ('CT','RV','Z1') "
		cQuery    += "AND SCR.D_E_L_E_T_=' ' "
	ElseIf cTipoDoc == "IC"
		cQuery    := "SELECT SCR.*,DBM.DBM_ITEM,DBM.DBM_ITEMRA,SCR.R_E_C_N_O_ SCRRECNO "
		cQuery	   += "FROM "+RetSqlName("SCR")+" SCR LEFT JOIN "
		cQuery	   += RetSqlName("DBM")+" DBM ON "
		cQuery	   += "CR_TIPO=DBM_TIPO AND "
		cQuery	   += "CR_NUM=DBM_NUM AND "
		cQuery	   += "CR_GRUPO=DBM_GRUPO AND "
		cQuery	   += "CR_ITGRP=DBM_ITGRP AND "
		cQuery	   += "CR_USER=DBM_USER AND "
		cQuery	   += "CR_USERORI=DBM_USEROR AND "
		cQuery	   += "CR_APROV=DBM_USAPRO AND "
		cQuery	   += "CR_APRORI=DBM_USAPOR AND "
		cQuery    += "DBM.D_E_L_E_T_= ' ' "
		cQuery    += "WHERE "
		If !lCtCorp
			cQuery		+= "SCR.CR_FILIAL='"+cFilSCR+"' AND "
		EndIf
		cQuery    += "SCR.CR_NUM LIKE '"+Alltrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"%' AND "
		cQuery    += "(SCR.CR_TIPO = 'IC' OR SCR.CR_TIPO = 'CT' )"
		cQuery    += "AND SCR.D_E_L_E_T_=' ' "
	ElseIf cTipoDoc == "IM"
		cQuery    := "SELECT SCR.*,DBM.DBM_ITEM,DBM.DBM_ITEMRA,SCR.R_E_C_N_O_ SCRRECNO "
		cQuery	   += "FROM "+RetSqlName("SCR")+" SCR LEFT JOIN "
		cQuery	   += RetSqlName("DBM")+" DBM ON "
		cQuery	   += "CR_TIPO=DBM_TIPO AND "
		cQuery	   += "CR_NUM=DBM_NUM AND "
		cQuery	   += "CR_GRUPO=DBM_GRUPO AND "
		cQuery	   += "CR_ITGRP=DBM_ITGRP AND "
		cQuery	   += "CR_USER=DBM_USER AND "
		cQuery	   += "CR_USERORI=DBM_USEROR AND "
		cQuery	   += "CR_APROV=DBM_USAPRO AND "
		cQuery	   += "CR_APRORI=DBM_USAPOR AND "
		cQuery    += "DBM.D_E_L_E_T_= ' ' "
		cQuery    += "WHERE "
		If !lMdCorp
			cQuery		+= "SCR.CR_FILIAL='"+cFilSCR+"' AND "
		EndIf
		cQuery    += "SCR.CR_NUM LIKE '"+Alltrim(CND->CND_NUMMED)+"%' AND "
		cQuery    += "(SCR.CR_TIPO = 'IM' OR SCR.CR_TIPO = 'MD' )"
		cQuery    += "AND SCR.D_E_L_E_T_=' ' "
	ElseIf cTipoDoc == "IR"
		cQuery    := "SELECT SCR.*,DBM.DBM_ITEM,DBM.DBM_ITEMRA,SCR.R_E_C_N_O_ SCRRECNO "
		cQuery	   += "FROM "+RetSqlName("SCR")+" SCR LEFT JOIN "
		cQuery	   += RetSqlName("DBM")+" DBM ON "
		cQuery	   += "CR_TIPO=DBM_TIPO AND "
		cQuery	   += "CR_NUM=DBM_NUM AND "
		cQuery	   += "CR_GRUPO=DBM_GRUPO AND "
		cQuery	   += "CR_ITGRP=DBM_ITGRP AND "
		cQuery	   += "CR_USER=DBM_USER AND "
		cQuery	   += "CR_USERORI=DBM_USEROR AND "
		cQuery	   += "CR_APROV=DBM_USAPRO AND "
		cQuery	   += "CR_APRORI=DBM_USAPOR AND "
		cQuery    += "DBM.D_E_L_E_T_= ' ' "
		cQuery    += "WHERE "
		If !lCtCorp
			cQuery		+= "SCR.CR_FILIAL='"+xFilial("SCR")+"' AND "
		EndIf
		cQuery    += "SCR.CR_NUM LIKE '"+Alltrim(CN9->CN9_NUMERO+CN9->CN9_REVISA)+"%' AND "
		cQuery    += "(SCR.CR_TIPO = 'IR' OR SCR.CR_TIPO = 'RV' )"
		cQuery    += "AND SCR.D_E_L_E_T_=' ' "
	EndIf
	cQuery += "ORDER BY "+SqlOrder(SCR->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

	//Verifica se for pedido de compra e se parâmetro MV_EXAPROV para mostrar histórico de SRC deletada está ativo.
	//Caso não encontre registros ativos (SCR recriada quando eliminado resíduo de PC atendido parcialmente)
	//procura os registros de histórico deletado (pq SCR é deletada e não é recriada se pedido não foi atendido parcialmente)
	If cTipoDoc == "PC" .AND. !((lExAprov .AND. !lResid) .OR. !lExAprov)
		Count To nTotal
		If nTotal == 0

			(cAliasSCR)->(DbCloseArea())
			cQuery := StrTran(cQuery,"SCR.D_E_L_E_T_=' '","SCR.D_E_L_E_T_='*'")

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
		Else
			(cAliasSCR)->(DbGoTop())
		EndIf
	EndIf

	For nX := 1 To Len(aStruSCR)
		If aStruSCR[nX][2]<>"C"
			TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
		EndIf
	Next nX

	While !(cAliasSCR)->(Eof())
		aAdd(aCols,Array(Len(aHeader)+1))

		For nX := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nX][2])
				aTail(aCols)[nX] := (cAliasSCR)->SCRRECNO
			ElseIf IsHeadAlias(aHeader[nX][2])
				aTail(aCols)[nX] := "SCR"
			ElseIf aHeader[nX][02] == "bCR_NOME"
				aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USER)
			ElseIf aHeader[nX][02] == "bCR_ITEM"
				If lAprPCEC .Or. lAprSAEC .Or. lAprSCEC .Or. lAprCTEC .Or. lAprMDEC
					If (cAliasSCR)->CR_TIPO $ "SC|SA|IP|IC|IM"
						aTail(aCols)[nX] := AllTrim((cAliasSCR)->DBM_ITEM) + IIF(!Empty((cAliasSCR)->DBM_ITEMRA),"-"+(cAliasSCR)->DBM_ITEMRA,"")
					Else
						aTail(aCols)[nX] := Replicate("-",8)
					Endif
				Endif
			ElseIf aHeader[nX][02] == "bCR_GRUPO"
				aTail(aCols)[nX] := (cAliasSCR)->CR_GRUPO
			ElseIf aHeader[nX][02] == "bCR_SITUACA"
				Do Case
					Case ((cAliasSCR)->CR_TIPO = "SC" .OR. (cAliasSCR)->CR_TIPO = "IP") .And. (cAliasSCR)->CR_STATUS == "01" .And. (cAliasSCR)->DBM_APROV == "1"
						cSituaca := "Aprovado" //"Aprovado"
					Case (cAliasSCR)->CR_STATUS == "01"
						cSituaca := "Pendente em níveis anteriores" //"Pendente em níveis anteriores"
						If cStatus == "Documento aprovado" //"Documento aprovado"
							cStatus := "Aguardando liberação(ões)" //"Aguardando liberação(ões)"
						EndIf
					Case ((cAliasSCR)->CR_TIPO = "SC" .OR. (cAliasSCR)->CR_TIPO = "IP") .And. (cAliasSCR)->CR_STATUS == "02" .And. (cAliasSCR)->DBM_APROV == "1"
						cSituaca := "Aprovado" //"Aprovado"
					Case (cAliasSCR)->CR_STATUS == "02"
						cSituaca := "Pendente" //"Pendente"
						If cStatus == "Documento aprovado" //"Documento aprovado"
							cStatus := "Aguardando liberação(ões)" //"Aguardando liberação(ões)"
						EndIf
					Case (cAliasSCR)->CR_STATUS == "03"
						cSituaca := "Aprovado" //"Aprovado"
					Case (cAliasSCR)->CR_STATUS == "04"
						cSituaca := "Bloqueado" //"Bloqueado"
						If cStatus # "Documento aprovado" //"Documento aprovado"
							cStatus := "Documento bloqueado" //"Documento bloqueado"
						EndIf
					Case (cAliasSCR)->CR_STATUS == "05"
						cSituaca := "Aprovado/rejeitado pelo nível" //"Aprovado/rejeitado pelo nível"
					Case (cAliasSCR)->CR_STATUS == "06"
						cSituaca := "Rejeitado"	//"Rejeitado"
						If cStatus # "Documento rejeitado"   //"Documento rejeitado"
							cStatus := "Documento rejeitado" //"Documento rejeitado"
						EndIf
					Case (cAliasSCR)->CR_STATUS == "07"
						cSituaca := "Rejeitado/bloqueado por outro usuário"	//"Rejeitado/bloqueado por outro usuário"
						If cStatus # "Documento rejeitado"   //"Documento rejeitado"
							cStatus := "Documento rejeitado" //"Documento rejeitado"
						EndIf						
				EndCase
				
				If cTipoDoc == "SC" .AND. !((lExAprov .AND. !lResid) .OR. !lExAprov)
					If (cAliasSCR)->(FieldPos("C1_RESIDUO"))>0 .AND. !Empty((cAliasSCR)->C1_RESIDUO)
						If !("Elim.Resíduo/" $ cStatus)
							cStatus	:= "Elim.Resíduo/" + cStatus //"Elim.Resíduo/" + Status
						Endif
						cSituaca 	:= "Elim.Resíduo/" + cSituaca //"Elim.Resíduo/" + Situação
					EndIf
				ElseIf cTipoDoc $ "IP|PC" .AND. (cAliasSCR)->(FieldPos("C7_RESIDUO"))>0 .AND. !Empty((cAliasSCR)->C7_RESIDUO)
						If !("Elim.Resíduo/" $ cStatus)
							cStatus	:= "Elim.Resíduo/" + cStatus //"Elim.Resíduo/" + Status
						Endif
						cSituaca 	:= "Elim.Resíduo/" + cSituaca //"Elim.Resíduo/" + Situação 
				EndIf
				
				aTail(aCols)[nX] := cSituaca
			ElseIf aHeader[nX][02] == "bCR_NOMELIB"
				aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
			ElseIf Alltrim(aHeader[nX][02]) == "CR_OBS"//Posicionar para ler
				SCR->(dbGoto((cAliasSCR)->SCRRECNO))
				aTail(aCols)[nX] := SCR->CR_OBS
			ElseIf ( aHeader[nX][10] != "V")
				aTail(aCols)[nX] := FieldGet(FieldPos(aHeader[nX][2]))
			EndIf
		Next nX
		aTail(aCols)[Len(aHeader)+1] := .F.

		(cAliasSCR)->(dbSkip())
	EndDo

	If !Empty(aCols)
		n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds).
		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra // Contrato"
		@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
		If !(cTipoDoc $ "MD|RV|CT|IC|IM|Z1")
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Pedido" / "Contrato" / "Nota Fiscal"
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 150,009 OF oDlg FONT oBold
	        If cTipoDoc <> "NF"
				@ 015,095 SAY Iif(cTipoDoc=="SC","Solicitante ","Comprador") OF oDlg PIXEL SIZE 045,009 FONT oBold //105 -> "Solicitante " 013->"Comprador"
				@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
	        EndIF
	   	Else
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Medicao"
			@ 014,035 MSGET cDocRevis PICTURE "" WHEN .F. PIXEL SIZE 50,009 OF oDlg FONT oBold

			@ 015,095 SAY cAprovador OF oDlg PIXEL SIZE 045,009 FONT oBold //"Aprovador"
			@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
	   	EndIf

		@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009 //'Situacao :'
		@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
		@ 132,205 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //'Fechar'
		oGet:= MSGetDados():New(038,003,120,250,nOpcx,,,"")
		oGet:Refresh()
		@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		Aviso("[ZGENTEL01] - Atencao",cHelpApv + CHR(13),{"Voltar"})
	EndIf

	(cAliasSCR)->(dbCloseArea())

	If lStatus
		aHeader := aClone(aSavHead)
		aCols := aClone(aSavCols)
		N := nSavN
	EndIf
Else
	Aviso("[ZGENTEL01] - Atencao",cHelpApv + CHR(13),{"Voltar"})
EndIf

dbSelectArea(cAlias)
RestArea(aArea)

Return NIL
