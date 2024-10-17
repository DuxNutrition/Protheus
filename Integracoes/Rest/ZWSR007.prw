#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ ZWSR007.prw บ Autor ณ Allan Rabelo บ Data ณ 28/09/2024     บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Schedule para pegar todas as notas com XML e enviar para   บฑฑ
//ฑฑบ          ณ Fun็ใo de faturamento                                      บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

User function ZWSR007(cId)
	Local cNumId := ""
	Local cXml := ""
	Local cNumPed := ""
	Local cRecno := ""
    Local cAliasFT 

	Default cId := ""

	If IsBlind()
		Conout("JOB ZWSR007 (FATURAMENTO) INICIADO NA DATA: "+Dtos(Date())+" NO HORมRIO: "+TIME()+" ")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT"
	Endif

	if Empty(cId)
		cAliasFT := QueryFat()
        if !Empty(cAliasFT)
			While (cAliasFt)->(!eof())
				cNumId := (cAliasFt)->(IDX)
				cNumPed := (cAliasFt)->(PED)
				DbSelectArea("ZFR")
				DbSetOrder(2)
				if (ZFR->(DbSeek(xFilial("ZFR")+PADR(cNumId,TamSX3("ZFR_ID")[1]))))
					cXml := ZFR->ZFR_XML
					if !Empty(cXml)
						U_DuxFatA(cXml,cNumPed,cNumId,cRecno)
					endif
				endif
				(cAliasFt)->(DbSkip())
			Enddo
		endif
	else
		DbSelectArea("ZFR")
		DbSetOrder(2)
		if (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
			if (alltrim(ZFR->ZFR_STATUS)) == "30"
				cNumId := ZFR->ZFR_ID
				cNumPed:= ZFR->ZFR_PEDIDO
				cXml := ZFR->ZFR_XML
				if !Empty(cXml)
					U_DuxFatA(cXml,cNumPed,cNumId,cRecno)
				endif
			endif
		endif
	endif
	If IsBlind()
		Conout("JOB ZWSR007 (FATURAMENTO) FINALIZADO NA DATA: "+Dtos(Date())+" NO HORมRIO: "+TIME()+" ")
		RESET ENVIRONMENT
	endif

Return()


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ ValidSTAT บ Autor ณ Allan Rabelo บ Data ณ 28/09/2024       บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Query para encontrar os results prontos                    บฑฑ
//ฑฑบ          ณ                                                            บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function QueryFat()
	Local cQuery := ""
	Local lRet := .F.
	Local cAliasFt := GetNextAlias()

	cQuery := " SELECT ZFR_STATUS as STATUSX, ZFR_ID AS IDX, R_E_C_N_O_ AS RECNO, ZFR_PEDIDO AS PED, ZFR_XML AS XMLX "
	cQuery += " FROM "+RetSqlName("ZFR")+" AS ZFR "
	cQuery += " WHERE ZFR.D_E_L_E_T_ = ''  "
	cQuery += " AND "
	cQuery += " ZFR_STATUS = '30'  AND ZFR_ID <> '' "
	cQuery += " ORDER BY ZFR_ID, ZFR_STATUS , ZFR_PEDIDO"

	TcQuery cQuery New Alias (cAliasFt)

	if (cAliasFt)->(!Eof())
		lRet := .T.
	endif

Return(cAliasFt)
