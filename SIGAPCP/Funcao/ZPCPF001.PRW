#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} ZPCPF001
Geração automatica do numero de lote
@type function
@version 1.0
@author Dux | Allan Rabelo
@history Dux | Jedielson Rodrigues
@since 05/08/2024
@return cRet
/*/

User Function ZPCPF001(cNum,cProduto,cEmissao,cProdRb,cTpInd)

Local cRet    := Space(TamSX3('C2_LOTECTL')[1])
Local lRastro := .F.
Local cLetra  := " "

Default cNum     := M->C2_NUM
Default cProduto := M->C2_PRODUTO
Default cEmissao := M->C2_EMISSAO
Default cProdRb  := M->C2_XRBD
Default cTpInd   := M->C2_XTPIND 

lRastro := Rastro(cProduto)

If lRastro == .T.
	cLetra := Chr(64+Month(M->C2_EMISSAO))
	If cLetra $ "I|O"
		cLetra := Chr(Asc(cLetra) + 1)
	Endif
	IF cProdRb == 'S'
		cRet := "R"+cLetra+Right(DToC(cEmissao),1)+Substr(cNum,3,4)+cTpInd
	Else
		cRet := cLetra+Right(DToC(cEmissao),1)+Substr(cNum,3,4)+cTpInd
	Endif
Endif

Return(cRet)
