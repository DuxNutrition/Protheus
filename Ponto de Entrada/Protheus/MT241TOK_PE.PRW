#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT241TOK
Ponto de entrada para efetuar valida��es no movimento interno de
estoques modelo m�ltiplo.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MT241TOK()

Local lRet 	:= .t.

// Valida��es Universais TOTVS IP
If ExistBlock("TIPAC011",.F.,.T.)
    lRet := ExecBlock("TIPAC011",.F.,.T.,{})
Endif

Return lRet
