// #########################################################################################
// Projeto: Dux
// Modulo : Integração de Pedidos
// Fonte  : ADCPOSC6
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 12/03/24 | Rafael Yera Barchi| Ponto de entrada para adicionar campos específicos nos 
//          |                   | itens do pedido de venda.
// ---------+-------------------+----------------------------------------------------------- 

#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ADCPOSC6
Ponto de entrada para adicionar campos específicos nos itens do pedido de venda.

@author    Rafael Yera Barchi
@version   1.xx
@since     12/03/2024
/*/
//------------------------------------------------------------------------------------------
User Function ADCPOSC6()
	
	Local 	aCpos 		:= {}
	Local   cTES        := ""
    Local   cOper       := ""
	Local   cOperVend   := SuperGetMV("VT_TINTVND", , "01")
    Local 	cOperBrnd	:= SuperGetMV("VT_TINTBRD", , "04")
    Local 	cItemCta	:= SuperGetMV("VT_ITEMCTA", , "03")
    
    IF ZTS->ZTS_BONIF=='1'
        cOper   := cOperBrnd
    Else
        cOper   := cOperVend
    EndIF

    cTES    := MaTESInt (2, cOper, SA1->A1_COD, SA1->A1_LOJA, "C", SB1->B1_COD, Nil)

	AAdd(aCpos, {"C6_OPER"	    , cOper	        , Nil})
    AAdd(aCpos, {"C6_TES"	    , cTES		    , Nil})
    AAdd(aCpos, {"C6_ITEMCTA"   , cItemCta      , Nil})
	
Return aCpos
