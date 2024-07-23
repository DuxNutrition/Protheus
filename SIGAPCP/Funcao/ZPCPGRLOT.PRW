#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/ Geralote
Geração automatica do numero de lote


@version P23.10
@ return lRet
/*/
//-------------------------------------------------------------------
User Function gera_lote()

Local c_lRet := SPACE(10)

IF M->C2_XRBD == 'S'

	c_lRet := Chr(64+Month(M->C2_EMISSAO))+Right(DToC(M->C2_EMISSAO),1)+Substr(M->C2_NUM,3,4)+If(M->C2_TPPR='E','E','') + "R"

Else
	
	c_lRet := Chr(64+Month(M->C2_EMISSAO))+Right(DToC(M->C2_EMISSAO),1)+Substr(M->C2_NUM,3,4)+If(M->C2_TPPR='E','E','')
	
Endif

Return c_lRet
