#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FA050INC
Ponto de entrada para efetuar validações na inclusão de título do
contas a pagar.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function FA050INC()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC001",.F.,.T.)
    lRet := ExecBlock("TIPAC001",.F.,.T.,{})
Endif

Return lRet
