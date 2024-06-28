#include "protheus.ch"

/**
 * Ponto de Entrada apos a Gravacao de registros na tabela SEA
 * FINA060 - Bordero de Titulos a Receber
 *
 * Autor : Victor Hugo - Totvs IP Campinas
 * Data  : 20/06/2012
 */
user function F060SEA2() 	
	
	local oBol := BoletosProtheus():new()
	
	if oBol:isInUse() .and. oBol:temBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		oBol:gravaBordero(SEA->EA_PREFIXO, SEA->EA_NUM, SEA->EA_PARCELA, SEA->EA_TIPO, SEA->EA_NUMBOR)
	endIf	
	
return         