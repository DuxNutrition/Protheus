#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F100TOK
Ponto de entrada para efetuar valida��es na inclus�o de movimento
banc�rio.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function F100TOK()

Local lRet 	:= .t.


IF !('ACCTG002' $FUNNAME())
// Valida��es Universais TOTVS IP
    If ExistBlock("TIPAC004",.F.,.T.)
        lRet := ExecBlock("TIPAC004",.F.,.T.,{})
    Endif
EndIF

Return lRet
