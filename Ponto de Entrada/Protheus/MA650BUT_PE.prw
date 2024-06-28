#include "Protheus.ch"

/*/{Protheus.doc} MA650BUT
	@type function
	@description    Adiciona bot�es na rotina de cadastro de OPs
	@author Daniel Neumann
	@since 01/12/2022
	@version 1.0
	
/*/
User Function MA650BUT()

    aAdd(aRotina, {'Impress�o da OP',"FWMsgRun(, {|| U_DUXR650() },'Aguarde', 'Gerando arquivo para impress�o...')", 0, 6 })

Return aRotina
