#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT240TOK
Ponto de entrada para efetuar validações no movimento interno de
estoques modelo simples.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MT240TOK()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC010",.F.,.T.)
    lRet := ExecBlock("TIPAC010",.F.,.T.,{})
Endif

Return lRet
