#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MLFL01SA2
Ponto de entrada para tratar os campos na inclusao do fornecedor.
@type function
@version 12.1.2310
@author Atos Data
@since 06/08/2024
@return array, acampos
/*/
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
    aAdd(aCampos, {"A2_ZZCTAAD"  	, '11303001'	,	NIL} )
    aAdd(aCampos, {"A2_FORMPAG"  	, 'CC'	,	NIL} )
    
    
    

Return(aCampos)
