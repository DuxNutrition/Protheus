#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"

/*********************************************************************************************
* Rotina	:	FA430FIG
* Autor		:	Marcos Wey da Mata
* Data		:	04/03/2022
* Descricao	:	Permitir modificar CNPJ do retorno DDA

* Apoio		: 	
*********************************************************************************************/
User Function FA430FIG()
           
Local cCNPJ 		:= ParamIxb[1]
Local cQuery		:= ""
Local cNameQuery	:= ""
Local aArea			:= GetArea()
Private cAlsTMP 	:= GetNextAlias()  

If Select(cAlsTMP) > 0
	(cAlsTMP)->(dbCloseArea())
EndIf

cQuery := " "
cQuery := " SELECT * FROM " + RetSqlName("SE2") + " SE2 " 													+ CRLF
cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 " 														+ CRLF
cQuery += "		ON SA2.A2_FILIAL = '  ' "  																	+ CRLF
cQuery += "		AND SA2.A2_COD = SE2.E2_FORNECE "  															+ CRLF
cQuery += "		AND SA2.A2_LOJA = SE2.E2_LOJA " 															+ CRLF
cQuery += "   	AND (SA2.A2_CGC LIKE '" + SubStr(cCNPJ,1,8) + "%' OR SA2.A2_CGC = '" + cCNPJ + "' ) " 		+ CRLF
cQuery += "		AND SA2.D_E_L_E_T_ = ' ' " 																	+ CRLF
cQuery += " WHERE SE2.E2_FILIAL = '"+FwxFilial("SE2")+"' " 													+ CRLF
cQuery += " AND SE2.E2_VALOR =  " + str(nValPgto) + " " 													+ CRLF
cQuery += " AND SE2.D_E_L_E_T_ = ' ' " 																		+ CRLF
cQuery += " ORDER BY SE2.E2_VENCREA DESC " 																	+ CRLF


cNameQuery		:= "FA430FIG_" + zRetDtHr() + ".sql"
if file( "\Tmp_Sql\" + cNameQuery )
	ferase( "\Tmp_Sql\" + cNameQuery )
endif
MemoWrite( "\Tmp_Sql\" + cNameQuery , cQuery )

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlsTMP,.T.,.F.)                             
(cAlsTMP)->(DbGoTop())
	
If Select(cAlsTMP) > 0	
	While (cAlsTMP)->(!Eof())
		If (cAlsTMP)->A2_CGC = cCNPJ
			(cAlsTMP)->(dbCloseArea())
			Return cCNPJ
		EndIf
		(cAlsTMP)->(dbSkip())
	EndDo
	(cAlsTMP)->(dbGoTop())         
	While (cAlsTMP)->(!Eof())
		If SubStr((cAlsTMP)->A2_CGC,1,8) = SubStr(cCNPJ,1,8)
			cCNPJ := (cAlsTMP)->A2_CGC
			(cAlsTMP)->(dbCloseArea())
			Return cCNPJ
		EndIf
		(cAlsTMP)->(dbSkip())
	EndDo
EndIf

(cAlsTMP)->(dbCloseArea())

Restarea(aArea)

Return(cCNPJ)

//-----------------------------------------------------------------
Static Function zRetDtHr()

	Local cRet		:= ""
	Local aDatas	:= {}
	
	aDatas	:= GetAPOInfo("FA430FIG_PE.prw")
	cRet	:= DTOS(aDatas[4]) + "_" + StrTran(aDatas[5],":","")
	cRet	+= "_" + alltrim(cUserName)
	cRet	+= "_" + alltrim(GetEnvServer())

Return(cRet)
