#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FA040INC
Ponto de entrada para efetuar validações na inclusão de título do
contas a receber.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function FA040INC()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If ExistBlock("TIPAC002",.F.,.T.)
    lRet := ExecBlock("TIPAC002",.F.,.T.,{})
Endif

Return lRet
