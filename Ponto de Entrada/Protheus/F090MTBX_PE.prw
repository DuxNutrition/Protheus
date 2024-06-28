#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} F090MTBX
Ponto de entrada para alterar vari�veis na tela de baixa autom�tica
do contas a pagar.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function F090MTBX()

Local lRet 	:= .t.

// Valida��es Universais TOTVS IP
If ExistBlock("TIPAC014",.F.,.T.)
    lRet := ExecBlock("TIPAC014",.F.,.T.,{})
Endif

Return lRet
