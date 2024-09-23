#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"

// ##############################################################################
// Projeto  : VTEX
// Autor    : Douglas Martins
// FunÃƒï¿½Ã¢â‚¬Å¾o   : VTX46TRANSP
// DescriÃƒï¿½Ã¢â‚¬Å¾o: P.E. para trocar a transportadora de Pedidos VTEX.
// ---------+-------------------+------------------------------------------------
// Data     | Autor             | DescriÃƒï¿½Ã¢â‚¬Å¾o
// ---------+-------------------+------------------------------------------------
// 23/11/20 | Douglas F Martins | Desenvolvimento da rotina.
// ---------+-------------------+------------------------------------------------

User function VTX46TRANSP()

	Local cRet      := ""
	Local cTrpVtx   := "%"+UPPER(Alltrim(NIDTRANSP))+"%"
	Local cQuery    := ""
	Local cAlias1	:= GetNextAlias()
	Local cTrapNO   := SuperGetMV("VT_TRSPNO",,"")


	A1U->(DBSelectArea("A1U"))
	A1U->(DBSetOrder(1))
	If A1U->(MSSeek(FWxFilial("A1U") + Left(cPedLV, 3)))	//cPedLV - Variável de escopo Private da integração VTEX (não deve ser declarada)
		If !Empty(A1U->A1U_XTRANS)
			cRet := A1U->A1U_XTRANS
		EndIf
		//Douglas Martins - 21/04/24
		//Chamado - 15857 - Se for pedido Amazon e não terminar com DBA, tem que passar pelo Processo de Cotação
		//Pedidos DBA são de transporte próprio da Amazon e por isso devem usar a transportadora cadastrada na A1U
		IF Left(cPedLV, 3)=='MZN'
			IF Alltrim(Right(Alltrim(cPedLV), 3))<>'DBA'
				cRet := ""
			EndIF
		EndIF
	EndIf

	If Empty(cRet)

		cRet := SuperGetMV("IP_TRPGEN", , "000000") // Codigo da transportadora generica para cotacao de frete

		cQuery := " SELECT A4_COD FROM "+RetSqlName("SA4")+ " "
		cQuery += " WHERE A4_FILIAL = '"+xFilial("SA4")+"'"
		cQuery += " AND UPPER(A4_XIDVTEX) LIKE '"+cTrpVtx+"'"
		cQuery += " AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		TCQUERY (cQuery) ALIAS &(cAlias1) NEW

		(cAlias1)->(DbGoTop())

		if (cAlias1)->(!eof())
			SA4->(dbSeek(FWxFilial("SA4")+(cAlias1)->A4_COD))
			If SA4->A4_XMODETQ <> "2" .Or. IsInCallStack("U_VTX46SC5")
            	IF (UPPER(Alltrim(NIDTRANSP)) $UPPER(cTrapNO)) .And. !Empty(cTrapNO)
			        cRet := SuperGetMV("IP_TRPGEN", , "000000") // Codigo da transportadora generica para cotacao de frete
                Else
				    cRet := (cAlias1)->A4_COD
                EndIF
			EndIf
		endif

		If Select(cAlias1) > 0
			(cAlias1)->(DbCloseArea())
		EndIf
	EndIf



Return cRet
