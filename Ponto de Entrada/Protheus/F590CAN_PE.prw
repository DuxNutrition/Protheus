#include "protheus.ch"

/**
 * Ponto de Entrada apos o Cancelamento de Borderos de Titulos a Receber
 * atraves da rotina de Manutencao de Borderos - FINA590
 *
 * Autor : Victor Hugo - Totvs IP Campinas
 * Data  : 20/06/2012
 */
user function F590CAN() 	
	
	local lShowMsg	:= .F.     
	local cCarteira := Paramixb[1]
	local cNumBor	:= Paramixb[2]
	local oBol 		:= BoletosProtheus():new()
	
	if cCarteira == "R" .and. oBol:isInUse() .and. oBol:temBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		oBol:restBoleto(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, lShowMsg)
	endIf	
	
return         