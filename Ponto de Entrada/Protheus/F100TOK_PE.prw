#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F100TOK
Ponto de entrada para efetuar validações na inclusão de movimento
bancário.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function F100TOK()

Local lRet 	:= .t.


IF !('ACCTG002' $FUNNAME())
// Validações Universais TOTVS IP
    If ExistBlock("TIPAC004",.F.,.T.)
        lRet := ExecBlock("TIPAC004",.F.,.T.,{})
    Endif
EndIF

Return lRet
