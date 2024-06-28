#include "Protheus.ch"

/*/{Protheus.doc} MA650BUT
	@type function
	@description    Adiciona botões na rotina de cadastro de OPs
	@author Daniel Neumann
	@since 01/12/2022
	@version 1.0
	
/*/
User Function MA650BUT()

    aAdd(aRotina, {'Impressão da OP',"FWMsgRun(, {|| U_DUXR650() },'Aguarde', 'Gerando arquivo para impressão...')", 0, 6 })

Return aRotina
