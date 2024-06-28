#Include 'Protheus.ch'

/*/{Protheus.doc} MT103EXC

Valida a exclus�o de uma pr�-nota
	
@author TOTVS IP
@since 05/11/2019
@type function

@return L�gico Permite ou n�o a exclus�o
/*/
User Function A140EXC()
	
	local lRet	:= .T.

	If ExistBlock("IPEstornaIntegracaoGestor",.F.,.T.)
		lRet	:= ExecBlock("IPEstornaIntegracaoGestor",.F.,.T.,{SF1->F1_CHVNFE})
	Endif
	
Return lRet

