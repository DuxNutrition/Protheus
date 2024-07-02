#INCLUDE 'TOTVS.CH'
/*
=====================================================================================
Programa.:              AMZF02SD1
Autor....:              Atos
Data.....:              Não Há
Descricao / Objetivo:   Amazon Full | Atos
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

User Function AMZF02SD1()

Local   aCampos     := {}

aAdd(aCampos, {"D1_ITEMCTA" , XFILIAL("SD1"),	NIL} )

Return(aCampos)
