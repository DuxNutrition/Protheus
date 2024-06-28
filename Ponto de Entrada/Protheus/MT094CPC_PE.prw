#include "protheus.ch"

//------------------------------------------------------------------------
/*/{Protheus.doc} MT094CPC
	@description Exibe informações de outros campos do pedido de compra/autorização de entrega no momento da liberação do documento.
	@author Daniel Neumann
	@since 25.05.2023
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function MT094CPC()
    
    Local cCampos := "|C7_OBS|" //  O retorno deve começar com uma barra vertical ( | ) e ir intercalando o nomes do campos com barras verticais. 

Return (cCampos)
