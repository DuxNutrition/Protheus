#INCLUDE 'TOTVS.CH'

/*
=====================================================================================
Programa.:              VTX47COD
Autor....:              Atos
Data.....:              Não Há
Descricao / Objetivo:   Não Há
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

User Function VTX47COD()

//	Local cCodCli   := U_NEXTCOD("SA1")
	Local 	aAreaA1 := SA1->(GetArea())
	Local 	nIdxSA1 := SA1->(IndexOrd())
	Local	aRet	:= {}
	Local	cMyCod 	:= ""
	Local 	cMyLoj	:= ""

	//Variáveis de escopo Private recebidas da Integração VTEX: 
	// _cDoc 		- CNPJ/CPF
	// _cCEP 		- CEP
	// _cRua 		- Rua
	// _cNumRua 	- Número
	// _cComplem	= Complemento
	If Len(AllTrim(_cDoc)) > 11
		cMyCod	:= SubStr(PadL(_cDoc, 14, "0"), 1, 8)
		cMyLoj	:= SubStr(PadL(_cDoc, 14, "0"), 9, 4)
	Else
		cMyCod	:= SubStr(PadL(_cDoc, 11, "0"), 1, 9)
		SA1->(DBSelectArea("SA1"))
		SA1->(DBSetOrder(3))
		If SA1->(MSSeek(FWxFilial("SA1") + PadR(_cDoc, TamSX3("A1_CGC")[1])))
			While !SA1->(EOF()) .And. SA1->A1_FILIAL == FWxFilial("SA1") .And. SA1->A1_CGC == PadR(_cDoc, TamSX3("A1_CGC")[1])
				If AllTrim(SA1->A1_CEP) == AllTrim(_cCEP) .And. AllTrim(SA1->A1_COMPLEM) == AllTrim(_cComplem) ;
					.And. (_cRua $ SA1->A1_END .And. _cNumRua $ SA1->A1_END)
					cMyLoj	:= SA1->A1_LOJA
					Exit
				Else
					cMyLoj	:= Soma1(SA1->A1_LOJA)
				EndIf
				SA1->(DBSkip())
			EndDo
		Else
			cMyLoj	:= "0001"
		EndIf
	EndIf

	AAdd(aRet, cMyCod)
	AAdd(aRet, cMyLoj)

	SA1->(DBSetOrder(nIdxSA1))
	RestArea(aAreaA1)

//Return(cCodCli)
Return aRet
