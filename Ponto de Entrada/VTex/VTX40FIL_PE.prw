#INCLUDE 'TOTVS.CH'

/*
=====================================================================================
Programa.:              VTX40FIL
Autor....:              Atos
Data.....:              27/05/24
Descricao / Objetivo:   VTex | Ponto de Entrada para Selecionar Vendas com Código de 
						Rastreio Preenchhidos para enviar para a VTEX
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

User Function VTX40FIL()

	Local cSQL := " AND (C5_RASTR <> '" + Space(TamSX3("C5_RASTR")[1]) + "' OR  F2_XTRACKI <> '" + Space(TamSX3("F2_XTRACKI")[1]) + "' ) " + CRLF

Return(cSQL)
