#Include 'Protheus.ch'

/*/{Protheus.doc} MA410LEG  
	@description Define novas cores do status do pedido 
	@author Daniel Neumann - CI Result
	@since 14/04/2023
	@version 1.0
*/

User Function MA410LEG()

    Local aLegenda := PARAMIXB

    If !(IsInCallStack("U_WSVTEX46") .Or. "WSVTEX" $ FunName())
	
		AADD(aLegenda,{"BR_CINZA"   ,"Pedido Bloqueado por Estoque"})
		AADD(aLegenda,{"BR_BRANCO"  ,"Pedido Bloqueado por Credito"})

	EndIf

Return(aLegenda)
