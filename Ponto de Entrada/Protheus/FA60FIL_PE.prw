#include "protheus.ch"

/**
 * Ponto de Entrada para filtro de Seleção de Títulos na rotina
 * FINA060 - Bordero de Titulos a Receber
 *
 * Autor : Victor Hugo - Totvs IP Campinas
 * Data  : 20/06/2012
 */
user function FA60FIL() 
	
	local cFiltro 	:= ""
	local cBanco  	:= Paramixb[1]
	local cAgencia  := Paramixb[2]
	local cConta 	:= Paramixb[3]
	local oBol		:= BoletosProtheus():new()
	
	if oBol:isInUse()
		cFiltro += oBol:getFilBordero(cBanco, cAgencia, cConta)
	endIf	
	
return cFiltro         