#include "protheus.ch"

//------------------------------------------------------------------------
/*/{Protheus.doc} MT094CCR
	@description Exibe informações de outros campos da alçada (SCR) no momento da liberação do documento
	@author Daniel Neumann
	@since 25.05.2023
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function MT094CCR()
    
    Local cCampos := "|CR_XCODPG|CR_XDESPG|CR_XCODFOR|CR_XLJFOR|CR_XNOMFOR|" //  O retorno deve começar com uma barra vertical ( | ) e ir intercalando o nomes do campos com barras verticais. 

Return (cCampos)
