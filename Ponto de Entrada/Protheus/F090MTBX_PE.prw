#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F090MTBX
Ponto de entrada para alterar variáveis na tela de baixa automática
do contas a pagar.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function F090MTBX()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC014",.F.,.T.)
    lRet := ExecBlock("TIPAC014",.F.,.T.,{})
Endif

Return lRet
