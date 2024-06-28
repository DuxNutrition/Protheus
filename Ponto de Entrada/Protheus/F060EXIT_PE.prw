#include "TOTVS.CH"

/*/{Protheus.doc} F060EXIT

Ponto de Entrada apos a Transferencia de Titulos a Receber

@type function
@author Victor Hugo - Totvs Campinas
@since 20/06/2012

@history 02/12/2016, Carlos Eduardo Niemeyer Rodrigues, Ajustes para Tabela Dinâmica e Ajustes ProtheusDoc e CleanCode
/*/ 
User Function F060EXIT() 	
		
	Local oBol 		:= BoletosProtheus():new()
	Local lShowMsg	:= .F.
	
	if oBol:isInUse() .and. oBol:temBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		oBol:restBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, lShowMsg)
	endIf	
	
Return
