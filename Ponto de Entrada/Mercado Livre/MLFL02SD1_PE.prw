#INCLUDE 'TOTVS.CH'

/*
=====================================================================================
Programa.:              MLFL02SD1
Autor....:              Atos
Data.....:              01/02/2023
Descricao / Objetivo:   Mercado Livre | Ponto de Entrada para preechimento de campos 
						dos itens do Documento de Entrada
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function MLFL02SD1()

	Local   aCampos     := {}	

	aAdd(aCampos, {"D1_ITEMCTA"   	, cFilAnt   ,	NIL} )


Return(aCampos)
