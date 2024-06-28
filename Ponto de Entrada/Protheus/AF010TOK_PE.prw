#Include "Protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} AF010TOK
Ponto de entrada para efetuar valida��es na inclus�o de cadastro de
ativo imobilizado.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------

user function AF010TOK()

Local lRet 	:= .t.

// Valida��es Universais TOTVS IP
If ExistBlock("TIPAC015",.F.,.T.)
    lRet := ExecBlock("TIPAC015",.F.,.T.,{})
Endif

return lRet
