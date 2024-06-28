// #########################################################################################
// Projeto: VTEX
// Modulo : Integração E-Commerce
// Fonte  : VTX46SC5
// Cliente: Elsys
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 18/02/20 | Rafael Yera Barchi| Ponto de entrada para adicionar campos específicos no 
//          |                   | cabeçalho do pedido de venda.
// ---------+-------------------+----------------------------------------------------------- 

#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VTX46SC5
Ponto de entrada para adicionar campos específicos no cabeçalho do pedido de venda.

@author    Rafael Yera Barchi
@version   1.xx
@since     18/02/2020
/*/
//------------------------------------------------------------------------------------------
User Function VTX46SC5()
	
	Local 	aCpos 		:= {}
	Local   nVol        := SuperGetMV("VT_VOLPED", , 1)
	Local   cEspecie    := SuperGetMV("VT_ESPECI1", , "CAIXA")
	Local 	cMktPlace	:= Substr(cPedLV,1,3)
	Local   aVendedor	:= GetVend2(cMktPlace)	
	Local  _c5Transp 	:= U_VTX46TRANSP()

	AAdd(aCpos, {"C5_NATUREZ"	,"10101"	, Nil})
	AAdd(aCpos, {"C5_VOLUME1"	,nVol		, Nil})
	AAdd(aCpos, {"C5_ESPECI1"	,cEspecie	, Nil})
	IF !Empty(aVendedor[1])
		cVendedor	:= aVendedor[1]
		AAdd(aCpos, {"C5_VEND1"	,cVendedor	, Nil})
	EndIF

	IF cFilAnt =='02'
		AAdd(aCpos, {"C5_ECVINCU"	,_c5Transp	, Nil})
	EndIF
	
Return aCpos



//=============================================================================
// GETVEND2
//=============================================================================  
Static Function GetVend2(cNome)
	
	Local aRet 		:= {"","",""}
	Local cQ		:= ""
	Local cQryVnd	:= GetNextAlias()


	ConOut("VTX46SC5 - MarketPlace " + cNome)
	
	If !Empty(cNome)
		
		cQ := " SELECT A3_COD, A3_NOME, A3_NREDUZ FROM " + RetSqlName("SA3") + " WHERE D_E_L_E_T_= ' ' AND A3_XVTXMKT = '" + cNome + "' "
		cQ := ChangeQuery(cQ)

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQ), (cQryVnd), .F., .T.)

		If !(cQryVnd)->(Eof())
			aRet[1] := (cQryVnd)->A3_COD
			aRet[2] := (cQryVnd)->A3_NOME
			aRet[3] := (cQryVnd)->A3_NREDUZ
			ConOut("VTX46SC5 - Vendedor " + aRet[1])
		Else
			ConOut("VTX46SC5 - Vendedor não localizado")
		EndIf

		(cQryVnd)->(DbCloseArea())

	EndIf

Return aRet
