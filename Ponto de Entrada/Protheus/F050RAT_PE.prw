#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F050RAT
Ponto de entrada para efetuar valida��es na inclus�o de t�tulo do
contas a pagar.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function F050RAT()

Local lRet 	:= .t.

// Valida��es Universais TOTVS IP
If ExistBlock("TIPAC003",.F.,.T.)
    lRet := ExecBlock("TIPAC003",.F.,.T.,{})
Endif

Return lRet
