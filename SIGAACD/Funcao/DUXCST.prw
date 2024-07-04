#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOTVS.CH'

//Consultas customizadadas para serem utilizadas via Coletor de Dados


user Function DUXCST(nOpc)

	Local lRet := .F.
	Local cQuery		:= ''
	Local cAliasTmp	:= GetNextAlias()
    Local aArea          := GetArea()
	DEFAULT nOpc := 0




	IF nOpc == 1

		cQuery := "SELECT 1 FROM " + RetSqlName("CB9") + " WHERE CB9_ORDSEP = '" + CB7->CB7_ORDSEP + "' AND CB9_XQTDTR = 0 AND D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)


		If (cAliasTmp)->(!Eof())
			lRet := .T.
		EndIf

	ENDIF

    IF nOpc == 2

        cQuery := "SELECT 1 FROM " + RetSqlName("ZD3") + " WHERE ZD3_ORDSEP = '" + CB7->CB7_ORDSEP + "' AND D_E_L_E_T_ = '' AND ZD3_QTDORI <> ZD3_QTDDES "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)


		If (cAliasTmp)->(!Eof())
			lRet := .T.
		EndIf

	ENDIF

    IF nOpc == 4

        cQuery := "SELECT 1 FROM "+ RetSqlName("ZD3") +" WHERE ZD3_DOCMOV = '" + ZD3->ZD3_DOCMOV + "' AND ZD3_QTDORI <> ZD3_QTDDES AND ZD3_DOCMOV <> '' AND ZD3_FLAG = ''"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)


		If (cAliasTmp)->(!Eof())
			lRet := .T.
		EndIf

	ENDIF

	(cAliasTmp)->(dbCloseArea())

RestArea(aArea)    

Return lRet
