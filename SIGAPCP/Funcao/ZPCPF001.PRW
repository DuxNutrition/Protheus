#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} ZPCPF001
Geração automatica do numero de lote
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 05/08/2024
@return cRet
/*/

User Function ZPCPF001(cProdRb,cTpInd)

Local cRet := SPACE(10)

Default cProdRb := 'N'
Default cTpInd  := 'A'

IF cProdRb == 'S'
	cRet :=  "R" + Chr(64+Month(M->C2_EMISSAO))+Right(DToC(M->C2_EMISSAO),1)+Substr(M->C2_NUM,3,4)+If(M->C2_TPPR='E','E','') 
Else
	cRet := Chr(64+Month(M->C2_EMISSAO))+Right(DToC(M->C2_EMISSAO),1)+Substr(M->C2_NUM,3,4)+If(M->C2_TPPR='E','E','')
Endif

Return(cRet)
