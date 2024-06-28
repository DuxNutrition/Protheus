#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MA080VLD
Ponto de entrada para efetuar valida��es na inclus�o de cadastro de
TES.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MA080VLD()

Local lRet 	:= .t.

// Valida��es Universais TOTVS IP
If ExistBlock("TIPAC009",.F.,.T.)
    lRet := ExecBlock("TIPAC009",.F.,.T.,{})
Endif

Return lRet
