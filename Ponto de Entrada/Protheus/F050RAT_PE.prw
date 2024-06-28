#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F050RAT
Ponto de entrada para efetuar validações na inclusão de título do
contas a pagar.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function F050RAT()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC003",.F.,.T.)
    lRet := ExecBlock("TIPAC003",.F.,.T.,{})
Endif

Return lRet
