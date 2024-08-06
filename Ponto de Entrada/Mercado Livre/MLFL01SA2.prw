#INCLUDE 'TOTVS.CH'

/*
=====================================================================================
Programa.:              MLFL01SA2
Autor....:              Atos
Data.....:              Não Há
Descricao / Objetivo:   Não Há
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function MLFL01SA2()

    Local   aCampos     := {}
    Local   cContaCTB   := SuperGetMV("AD_CONTAA2",.T.,'21101001')

    aAdd(aCampos, {"A2_CALCIRF"  	, "1"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECINSS"  	, "N"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECISS"  	, "N"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECPIS"  	, "2"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECCOFI"  	, "2"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECCSLL"  	, "2"	    ,	NIL} )
    aAdd(aCampos, {"A2_CONTA"  	    , cContaCTB	,	NIL} )
    

Return(aCampos)
