// #########################################################################################
// Projeto: VTEX
// Modulo : Integração E-Commerce
// Fonte  : VTX46C6US
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 09/04/20 | Rafael Yera Barchi| Ponto de entrada para personalizar a gravação do item no
//          |                   | pedido de venda.
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"PROTHEUS.CH"

#DEFINE 	cEOL			Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              VTX46C6US
Autor....:              Atos | Rafael Yera Barchi
Data.....:              09/04/2021
Descricao / Objetivo:   Ponto de entrada para personalizar a gravação do item no pedido de venda.
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function VTX46C6US()

	
	Local 	aArea		:= GetArea()

	Local 	aItem		:= {}
	Local 	aItens		:= {}	
	Local 	cPedido		:= ParamIXB[1]
	Local 	cItem		:= ParamIXB[2]
	Local 	_cProdut	:= ParamIXB[3]
	Local 	nQuant		:= ParamIXB[4]
	Local 	nPrecoVenda	:= ParamIXB[5]
	Local 	cTpPreco	:= ParamIXB[6]
	Local 	nValor		:= ParamIXB[7]
	Local 	nPrecoLista	:= ParamIXB[8]
	Local 	nPDescItem	:= ParamIXB[9]
	Local 	nDesconto	:= ParamIXB[10]
	Local 	nDescTot	:= ParamIXB[11]
	Local 	cTES		:= ParamIXB[12]
	Local 	nTotItem	:= ParamIXB[13]
	Local 	nQtdLib		:= ParamIXB[14]
	Local 	cLocEst		:= ParamIXB[15]
	Local 	lUsaReserva	:= ParamIXB[16]
	Local 	lBrinde		:= ParamIXB[17]
	Local 	cMesPres	:= ParamIXB[18]
	Local 	_cProdX		:= ""
	Local 	nValSC6		:= 0
	Local 	lAchou		:= .F.
	Local 	_cLog		:= ""
	Local 	_cLogDir	:= SuperGetMV("VT_LOGDIR", , "\log\")
	Local 	_cItemCta	:= SuperGetMV("VT_ITEMCTA", , "03")
	Local 	_cLogArq	:= ""
	Local   cDescPrd    := ""

	Local 	cMascGrd	:= GetMV("MV_MASCGRD")
	Local 	aMascara	:= StrTokArr(cMascGrd, ",")
	
	Local 	cOperVend	:= SuperGetMV("VT_TINTVND", , "01")
	Local 	cOperBrnd	:= SuperGetMV("VT_TINTBRD", , "04")
    Local   nFator      := 0 
	Local   cTabBon		:= SuperGetMV("VT_TABBONI", , "004")
  

	Private lUsaGrade	:= SuperGetMV("VT_USAGRAD", , .F.)
	Private lProdAvo	:= SuperGetMV("VT_PRODAVO", , .F.)//


	
	SB1->(DBSelectArea("SB1"))
	SB1->(DBSetOrder(14))
	If SB1->(DBSeek(xFilial("SB1") + _cProdut))
	   //Verifica se encontra o produto com o codigo antigo
	   _cProdut := Alltrim(SB1->B1_COD)
	   cDescPrd := SB1->B1_DESC
	Else
		SB1->(DBSetOrder(1))
		If SB1->(DBSeek(xFilial("SB1") + _cProdut))
			 //Verifica se encontra o produto com o codigo antigo
	   		_cProdut := Alltrim(SB1->B1_COD)
	   		cDescPrd := SB1->B1_DESC
	   EndIF
	EndIf

   
	If lBrinde
		cTES := MaTESInt(2, cOperBrnd, SA1->A1_COD, SA1->A1_LOJA, "C", SB1->B1_COD, Nil)
		cOper := cOperBrnd

		//IF Alltrim(cCondPag) == Alltrim(SuperGetMV("VT_SEMPAGT",	 , ""))
			DbSelectArea("DA1")
			DA1->(DbSetOrder(1))
			IF DA1->(DbSeek(xFilial("DA1")+Alltrim(cTabBon)+SB1->B1_COD))
				nValor	:= DA1->DA1_PRCVEN
			Else
				nValor	:= 0 //Coloco 0 para forcar o erro na integração
			EndIF
		//EndIF
	Else
		cTES := MaTESInt (2, cOperVend, SA1->A1_COD, SA1->A1_LOJA, "C", SB1->B1_COD, Nil)
		cOper := cOperVend
	EndIf


	AAdd(aItem, {"C6_NUM"   	, cPedido								, Nil})
	//AAdd(aItem, {"C6_ITEM"   	, cItem									, Nil})
	AAdd(aItem, {"C6_PRODUTO"	, _cProdut								, Nil})
	If !Empty(cDescPrd)
		AAdd(aItem, {"C6_DESCRI" 	, cDescPrd 							, Nil})
	EndIf
	AAdd(aItem, {"C6_QTDVEN" 	, A410Arred(nQuant, "C6_QTDVEN") 		, Nil})
	AAdd(aItem, {"C6_QTDLIB" 	, A410Arred(nQuant, "C6_QTDLIB") 		, Nil})
	AAdd(aItem, {"C6_PRCVEN" 	, A410Arred(nValor, "C6_PRCVEN") 		, Nil})
	AAdd(aItem, {"C6_PRUNIT" 	, A410Arred(nValor, "C6_PRUNIT")  		, Nil})
	AAdd(aItem, {"C6_OPER"		, cOper									, Nil})  
	AAdd(aItem, {"C6_TES"		, cTES									, Nil})
	AAdd(aItem, {"C6_LOCAL"		, cLocEst								, Nil})
	AAdd(aItem, {"C6_VALOR"		, A410Arred(nValor* nQuant, "C6_VALOR") , Nil})
    AAdd(aItem, {"C6_VALDESC"   , nDescTot, Nil})
    AAdd(aItem, {"C6_ITEMCTA"   , _cItemCta, Nil})

	AAdd(aItens, aItem)


		nPosTES := AScan(aItem, {|x| AllTrim(x[1]) == "C6_TES"})
	
		AAdd(aItemPed, {A410Arred(nPrecoVenda, "C6_PRCVEN"), 0, 0, 0,;
		0, 0, (SB1->B1_PESBRU * nQuant), GetAdvFVal("SF4", "F4_ISS", xFilial("SF4") + aItem[nPosTES][1], 1, "N") == "N",;
		0, 0 , 0})


	RestArea(aArea)

Return aItens
