#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FA080POS
Ponto de entrada para alterar vari�veis na tela de baixa do contas a
pagar.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function FA080POS()

Local lRet 	:= .t.

// Valida��es Universais TOTVS IP
If ExistBlock("TIPAC013",.F.,.T.)
    lRet := ExecBlock("TIPAC013",.F.,.T.,{})
Endif

Return lRet
