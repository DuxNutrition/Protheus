#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} ZPCPF001
Geração automatica do numero de lote
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 05/08/2024
@return cRet
/*/

User Function ZPCPF001(cNum,cProduto,cEmissao,cProdRb,cTpInd)

Local cRet    := SPACE(10)
Local lRastro := .F.

Default cNum     := M->C2_NUM
Default cProduto := M->C2_PRODUTO
Default cEmissao := M->C2_EMISSAO
Default cProdRb  := M->C2_XRBD
Default cTpInd   := M->C2_XTPIND 

lRastro := Rastro(cProduto)

If lRastro == .T.
	IF cProdRb == 'S'
		cRet := "R"+Chr(64+Month(M->C2_EMISSAO))+Right(DToC(M->C2_EMISSAO),1)+Substr(M->C2_NUM,3,4)+cTpInd
	Else
		cRet := Chr(64+Month(M->C2_EMISSAO))+Right(DToC(M->C2_EMISSAO),1)+Substr(M->C2_NUM,3,4)+cTpInd
	Endif
Endif

Return(cRet)
