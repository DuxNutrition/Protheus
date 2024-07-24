#include 'totvs.ch'

/*
=====================================================================================
Programa.:              MA410MNU
Autor....:              Daniel Neumann CI RESULT
Data.....:              22/06/2023
Descricao / Objetivo:   Ponto de entrada para inclusao de opcoes no menu aRotina rotina pedido de venda 
Doc. Origem:            GAP022
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function MA410MNU()
	
	If !(IsInCallStack("U_WSVTEX46") .Or. "WSVTEX" $ FunName())
		aAdd(aRotina,	{ "Ajusta Volumetria",	"u_ZFATF001()",	0,	2,	0,	Nil	})
	EndIf

Return()
