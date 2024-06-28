#include 'totvs.ch'

/*/{Protheus.doc} MA410MNU
	
	Ponto de entrada para inclusao de opcoes no menu aRotina rotina pedido de venda 
	
	@type  Function
	@author Daniel Neumann CI RESULT
	@since 22/06/2023
	@version P12
/*/
User Function MA410MNU()
	
	If !(IsInCallStack("U_WSVTEX46") .Or. "WSVTEX" $ FunName())
		aAdd(aRotina,	{ "Ajusta Volumetria",	"u_AJUSTVOL()",	0,	2,	0,	Nil	})
	EndIf

Return

