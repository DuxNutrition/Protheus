#include "protheus.ch"

/**
 * Ponto de Entrada apos o processamento do Retorno da Comunicacao Bancaria - FINA200
 *
 * Autor : Victor Hugo - Totvs IP Campinas
 * Data  : 20/06/2012
 */
user function F200TIT() 	
	
	local lShowMsg	:= .F.
	local oBol 		:= BoletosProtheus():new()
	
	if oBol:isInUse() .and. oBol:temBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		oBol:restBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, lShowMsg)
	endIf	
	
return         