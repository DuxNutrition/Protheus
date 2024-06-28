#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              VTX47SA1
Autor....:              Atos | Douglas F Martins
Data.....:              21/11/2018
Descricao / Objetivo:   Ponto de entrada para adicionar campos específicos no cadastro do cliente.
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function VTX47SA1()
	
	//------------------------------------------------------------------------
	// Variáveis de escopo Private declaradas na integração que não devem ser alteradas
	//------------------------------------------------------------------------
	// _cNomCli, _cDDD, _cTel, _cEmail, _cEst, _cIE, cNaturez, cTpFrete, _cBairro
	//------------------------------------------------------------------------
	Local 	aCpos 		:= {}
    Local	cPais		:= "105"	// Brasil
    Local 	cCdPais		:= "01058"	// Brasil
	Local   cNatur 		:= SuperGetMV("VT_NATUSA1",,"10101")
	Local   cVendVTX 	:= SuperGetMV("VT_VENDVTX",,"999998")
	Local   cVendMLFL 	:= SuperGetMV("AD_VNDXML",,"999997")
	Local   cContaC	    := SuperGetMV("VT_CTBSA1",,"11301001")
	Local   cGrTrib 	:= ""//SuperGetMV("VT_GRTRIB",,"CFN")
	Local   cEmailNFE	:= SuperGetMV("AD_EMAILNFE",.T.,'integracao@atosdata.com.br')
	Local  	cCelular 	:= _cDDD + _cTel


    If "ISENT" $ _cIE	
		cContrib	:= "2"
	Else		
		cContrib	:= "1"
	EndIf	

	If _cTpCli == "F"
		cGrTrib := "CFN"
	EndIf

	If Empty(_cBairro)
		AAdd(aCpos, {"A1_BAIRRO"		, "NAO INFORMADO"						,	Nil} )
	EndIf

	cCelular := StrTran(cCelular, " ", "")
    cCelular := StrTran(cCelular, "+", "")
    cCelular := StrTran(cCelular, "-", "")
    cCelular := StrTran(cCelular, "(", "")
    cCelular := StrTran(cCelular, ")", "")
    cCelular := AllTrim(cCelular)
    
    If Len(cCelular) >= 11
		AAdd(aCpos, {"A1_ZZWHATS"    , cCelular										,	Nil} )
    EndIf
    
    AAdd(aCpos, {"A1_TIPO"		, "F"											,	Nil} )
	AAdd(aCpos, {"A1_PAIS"		, cPais											,	Nil} )
	AAdd(aCpos, {"A1_CODPAIS"	, cCdPais										,	Nil} )
	AAdd(aCpos, {"A1_RISCO"	    , "A"	    									,	Nil} )
  	AAdd(aCpos, {"A1_IENCONT"	, cContrib										,	Nil} )
    AAdd(aCpos, {"A1_CONTRIB"   , cContrib										,	Nil} )
	AAdd(aCpos, {"A1_ZZEMNFE"   , IF("WSVTEX"$ FUNNAME(),_cEmailMD,cEmailNFE)	,	Nil} )
	AAdd(aCpos, {"A1_NATUREZ"   , cNatur										,	Nil} )
	AAdd(aCpos, {"A1_VEND"      , IF("WSVTEX"$ FUNNAME(),cVendVTX,cVendMLFL)	,	Nil} )
	AAdd(aCpos, {"A1_RECCOFI"   , "N"											,	Nil} )
	AAdd(aCpos, {"A1_RECCSLL"   , "N"											,	Nil} )
	AAdd(aCpos, {"A1_RECINSS"   , "N"											,	Nil} )
	AAdd(aCpos, {"A1_RECIRRF"   , "2"											,	Nil} )
	AAdd(aCpos, {"A1_RECISS "   , "2"											,	Nil} )
	AAdd(aCpos, {"A1_RECPIS "   , "N"											,	Nil} )
	AAdd(aCpos, {"A1_CONTA"      , cContaC										,	Nil} )
	AAdd(aCpos, {"A1_TPESSOA"    , "PF"											,	Nil} )	
	AAdd(aCpos, {"A1_GRPTRIB"    , cGrTrib										,	Nil} )	
	
Return aCpos
