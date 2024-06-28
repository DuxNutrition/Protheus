#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT100LOK
Ponto de entrada para efetuar validações no item da NF de entrada

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MT100LOK()

Local lRet 	:= .t.

// Validações Universais TOTVS IP
If !(aCols[n,Len(aHeader)+1]) .And. ExistBlock("TIPAC006",.F.,.T.)
    lRet := ExecBlock("TIPAC006",.F.,.T.,{})
Endif

Return lRet
