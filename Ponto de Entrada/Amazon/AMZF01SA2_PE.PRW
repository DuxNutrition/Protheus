#INCLUDE 'TOTVS.CH'

/*
=====================================================================================
Programa.:              AMZF01SA2
Autor....:              Atos
Data.....:              Não Há
Descricao / Objetivo:   Amazon Full | Atos
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function AMZF01SA2()

    Local   aCampos     := {}
    Local   cContaCTB   := SuperGetMV("AD_CONTAA2",.T.,'21101001')
    Local   cContaAd  := SuperGetMV("DUX_AMZCTA",.T.,'21101001') //Conta de adiantamento    

    aAdd(aCampos, {"A2_CALCIRF"  	, "1"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECINSS"  	, "N"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECISS"  	, "N"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECPIS"  	, "2"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECCOFI"  	, "2"	    ,	NIL} )
    aAdd(aCampos, {"A2_RECCSLL"  	, "2"	    ,	NIL} )
    aAdd(aCampos, {"A2_CONTA"  	    , cContaCTB	,	NIL} )
    aAdd(aCampos, {"A2_ZZCTAAD"  	, cContaAd	,	NIL} )
    

Return(aCampos)
