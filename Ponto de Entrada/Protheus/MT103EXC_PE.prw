#Include 'Protheus.ch'

/*/{Protheus.doc} MT103EXC

Valida exclusão do documento de entrada.
	
@author TOTVS IP
@since 05/11/2019
@type function

@return Lógico Permite ou não a exclusão
/*/
User Function MT103EXC()
	
	local lRet	:= .T.

	If ExistBlock("IPEstornaIntegracaoGestor",.F.,.T.)
		lRet	:= ExecBlock("IPEstornaIntegracaoGestor",.F.,.T.,{SF1->F1_CHVNFE})
	Endif
	
Return lRet

