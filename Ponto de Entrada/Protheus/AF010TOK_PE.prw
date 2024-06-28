#Include "Protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} AF010TOK
Ponto de entrada para efetuar validações na inclusão de cadastro de
ativo imobilizado.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------

user function AF010TOK()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC015",.F.,.T.)
    lRet := ExecBlock("TIPAC015",.F.,.T.,{})
Endif

return lRet
