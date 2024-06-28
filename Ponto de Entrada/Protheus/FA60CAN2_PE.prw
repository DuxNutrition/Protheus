#include "protheus.ch"

/**
 * Ponto de Entrada apos o Cancelamento de Borderos de Titulos a Receber
 *
 * Autor : Victor Hugo - Totvs IP Campinas
 * Data  : 20/06/2012
 */
user function FA60CAN2() 	
	
	local lShowMsg	:= .F.
	local oBol 		:= BoletosProtheus():new()
	
	if oBol:isInUse() .and. oBol:temBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		oBol:restBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, lShowMsg)
	endIf	
	
return         