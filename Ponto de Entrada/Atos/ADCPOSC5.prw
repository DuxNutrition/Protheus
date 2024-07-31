#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ADVLDIMP
Ponto de Entrada para Validar se pode importar o pedido ou não, para evitar duplicidade

@author    Douglas Ferreira Martins
@version   1.xx
@since     12/03/2024
/*/
//------------------------------------------------------------------------------------------
User Function ADCPOSC5()
	
	Local 	aCpos 		:= {}
	Local   nVol        := SuperGetMV("VT_VOLPED", , 1)
	Local   cEspecie    := SuperGetMV("VT_ESPECI1", , "CAIXA")



	AAdd(aCpos, {"C5_VOLUME1"	, nVol		        , Nil})
	AAdd(aCpos, {"C5_ESPECI1"	, cEspecie	        , Nil})
	AAdd(aCpos, {"C5_ZZNUMPJ"	, ZTQ->ZTQ_PEDLV	, Nil})
    AAdd(aCpos, {"C5_XSTATUS"	, ""	            , Nil})
    AAdd(aCpos, {"C5_XPEDLV"	, ""	            , Nil})
	
Return aCpos
