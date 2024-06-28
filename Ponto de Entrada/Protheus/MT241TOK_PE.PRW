#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT241TOK
Ponto de entrada para efetuar validações no movimento interno de
estoques modelo múltiplo.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MT241TOK()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC011",.F.,.T.)
    lRet := ExecBlock("TIPAC011",.F.,.T.,{})
Endif

Return lRet
