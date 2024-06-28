#include "protheus.ch"

//------------------------------------------------------------------------
/*/{Protheus.doc} MT094CCR
	@description Exibe informa��es de outros campos da al�ada (SCR) no momento da libera��o do documento
	@author Daniel Neumann
	@since 25.05.2023
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function MT094CCR()
    
    Local cCampos := "|CR_XCODPG|CR_XDESPG|CR_XCODFOR|CR_XLJFOR|CR_XNOMFOR|" //  O retorno deve come�ar com uma barra vertical ( | ) e ir intercalando o nomes do campos com barras verticais. 

Return (cCampos)
