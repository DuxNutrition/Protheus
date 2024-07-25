#INCLUDE  'TOTVS.CH'


User Function ADFATSQL()


	Local 	cSQL 		:= ""
	Local 	cLogDir		:= SuperGetMV("VT_LOGDIR", , "\log\")
	Local 	nNumReg		:= SuperGetMV("VT_NUMREGF", , 30)
	Local 	lFatServ	:= SuperGetMV("VT_FATSERV", , .F.)
	Local 	lCotFrete	:= SuperGetmv("VT_COTFRET", ,.F.)
	Local   cStatusFOK 	:= SuperGetMV("VT_STFRTOK", , "FRTOK")
	Local 	cLogArq		:= "ADFATAUT.sql"

	Private cStatusOK   := SuperGetMV("VT_STSEPOK", , "SEPOK")	// Separação OK

	DEFAULT _lLogs := .F.

	cSQL := "     SELECT "+ CRLF
	If Upper(AllTrim(TCGetDB())) == "MSSQL"
		cSQL += "     TOP (" + CValToChar(nNumReg) + ")
	EndIF

	cSQL += " C5_XDATA, C5_XHORA, C5_NUM " + CRLF

	If lMultLoj
		cSQL += " ,C5_XITEMCC, C5_XPEDLV " + CRLF
	EndIF

    cSQL += "  ,  (SELECT COUNT(*) FROM SC9010 SC9 WHERE C9_FILIAL = C5_FILIAL    AND SC9.C9_PEDIDO = C5_NUM         AND SC9.D_E_L_E_T_= ' '  AND C9_BLEST <> ' ' ) " + CRLF

	cSQL += "       FROM " + RetSQLName("SC5") + " SC5 "
	If Upper(AllTrim(TCGetDB())) == "MSSQL"
		cSQL += "(NOLOCK) " + CRLF
	Else
		cSQL += CRLF
	EndIf

	If lMultLoj
		cSQL += " INNER JOIN " + RetSQLName("ZAA") + " ZAA "
		If "MSSQL" $ Upper(AllTrim(TCGetDB()))
			cSQL += " (NOLOCK) " + CRLF
		Else
			cSQL += CRLF
		EndIf
		cSQL += "         ON ZAA_FILIAL = '" + xFilial("ZAA") + "' " + CRLF
		cSQL += "        AND ZAA.ZAA_ITEMCC = C5_XITEMCC " + CRLF
		cSQL += "        AND ZAA.ZAA_FILPED = C5_FILIAL " + CRLF
		cSQL += "        AND ZAA_CANAL = '01' " + CRLF
		cSQL += "        AND ZAA.D_E_L_E_T_= ' ' " + CRLF
	EndIf

	

	cSQL += "      WHERE C5_FILIAL = '" + xFilial("SC5") + "' " + CRLF
	If !(IsInCallStack("U_WSVTEX46") .Or. "WSVTEX46" $ FunName())
		cSQL += "        AND C5_NUM BETWEEN '" + AllTrim(MV_PAR01) + "' AND '" + AllTrim(MV_PAR02) + "' " + CRLF
		If lMultLoj
			cSQL += "        AND C5_XITEMCC BETWEEN '" + AllTrim(MV_PAR03) + "' AND '" + AllTrim(MV_PAR04) + "' " + CRLF
		EndIF
		cSQL += "        AND C5_EMISSAO BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' " + CRLF
	Else
		cSQL += "        AND C5_NUM BETWEEN '" + SC5->C5_NUM + "' AND '" + SC5->C5_NUM + "' " + CRLF
	EndIf
	cSQL += "        AND C5_NOTA = '" + Space(TamSX3("C5_NOTA")[1]) + "' " + CRLF
	//Define se fatura apenas pedidos do E-commerce ou todos os pedidos disponíveis

	cSQL += " AND  ( "

	IF lCotFrete
		cSQL += "         C5_XSTATUS = '" + AllTrim(cStatusFOK)+ "'  " + CRLF
	Else
		cSQL += "         C5_XSTATUS = '" + AllTrim(cStatusOK)+ "' " + CRLF
	EndIF

	IF lFatServ
		cSQL += "        OR C5_XSTATUS = '" + AllTrim(cStatusNvS)+ "'  " + CRLF
	EndIF

	cSQL += " ) " + CRLF

	cSQL += "        AND C5_XPEDLV <> '" + Space(TamSX3("C5_XPEDLV")[1]) + "' " + CRLF

	cSQL += "        AND SC5.D_E_L_E_T_ = ' ' " + CRLF

    //cSQL += "  GROUP BY " + CRLF
    //cSQL += "  C5_XDATA, C5_XHORA, C5_NUM ,C5_XITEMCC, C5_XPEDLV " + CRLF
    //cSQL += "  HAVING COUNT(DISTINCT C9_BLEST) = 1 " + CRLF
	cSQL  += " AND (SELECT COUNT(*) FROM SC9010 SC9 WHERE C9_FILIAL = C5_FILIAL     AND SC9.C9_PEDIDO = C5_NUM         AND SC9.D_E_L_E_T_= ' '  AND C9_BLEST <> ' ' )  = 0 "

	cSQL += "        ORDER BY C5_XDATA ASC, C5_XHORA,C5_NUM  ASC " + CRLF


	
	MemoWrite(cLogDir + cLogArq, cSQL)
	
Return(cSQL)
