#Include 'Protheus.ch'

/*/{Protheus.doc} MT103EXC

Valida a exclusão de uma pré-nota
	
@author TOTVS IP
@since 05/11/2019
@type function

@return Lógico Permite ou não a exclusão
/*/
User Function A140EXC()
	
	local lRet	:= .T.

	If ExistBlock("IPEstornaIntegracaoGestor",.F.,.T.)
		lRet	:= ExecBlock("IPEstornaIntegracaoGestor",.F.,.T.,{SF1->F1_CHVNFE})
	Endif
	
Return lRet

