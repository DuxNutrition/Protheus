#include "Totvs.ch"

/*/{Protheus.doc} MTSELEOP
PE para não chamar a tela de opcionais quando abrir um pedido de venda.
@author Regis Ferreira
@since 30/12/2019
/*/

User Function MTSELEOP()

	Local cRet  := ParamIxb[1]	// Retorno da rotina
	Local cProd := ParamIxb[2]  // Produto do pedido
	Local cProg := ParamIxb[3]  // Nome do programa que esta executando a funcao SELOPC
	Local lRet  := .T.

	if cProg == "MATA410"
		lRet := .F.
	endif

	If (IsInCallStack("U_WSVTEX46") .Or. "WSVTEX" $ FunName())
		lRet := .F.
	EndIf

Return(lRet)
