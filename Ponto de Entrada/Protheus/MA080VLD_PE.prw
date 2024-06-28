#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MA080VLD
Ponto de entrada para efetuar validações na inclusão de cadastro de
TES.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MA080VLD()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC009",.F.,.T.)
    lRet := ExecBlock("TIPAC009",.F.,.T.,{})
Endif

Return lRet
