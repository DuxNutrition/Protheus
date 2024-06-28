#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              LP596
Autor....:              ERP MAIS | José Donizete R.silva
Data.....:              19/12/2003
Descricao / Objetivo:   Programa para retornar informacoes para o lancamento de compesacao.
						Este LP faz o devido tratamento de posicionar nas tabelas com base
						na sequencia de operacao que o usuario fez.
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function LP596(cCampoCt5)

Local xRet
Local xArea		:= GetArea()
Local xAreaSE1	:= SE1->(getArea())
Local xAreaSE5	:= SE5->(getArea())
Local xAreaSA1	:= SA1->(getArea())
Local xAreaSED	:= SED->(getArea())
Local cTipoE5   := Alltrim(SE5->E5_TIPO)
Local cTipAb	:= ""
lOCAL cTipNF	:= ""
Local lUsaTempl	:= .f.

Local cChavNF	:= ""
Local cNumNF	:= ""
Local cCliNF 	:= ""
Local cNomNF	:= ""
Local cNatNF	:= ""
Local cCtaDeb	:= ""

Local cChavRA	:= ""
Local cNumRA	:= ""
Local cCliRA 	:= ""
Local cNomRA	:= ""
Local cNatRA	:= ""
Local cCtaCre	:= ""

If EXISTBLOCK("IPCWK")
	lUsaTempl := .t.
EndIf

cCampoCt5 := upper(alltrim(cCampoCt5))

If cTipoE5$"RA,NCC" // Posicionado em títulos de abatimento
	cChavNF	:= SE5->E5_FILORIG+SE5->E5_DOCUMEN
	cChavRA	:= SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIENTE+E5_LOJA)
Else // Posicionado em títulos normais (NF, boleto, etc)
	cChavNF	:= SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIENTE+E5_LOJA)
	cChavRA	:= SE5->E5_FILORIG+SE5->E5_DOCUMEN
EndIf

// Obtém dados a partir da NF/Outro que não seja o título de abatimento (RA/NCC)
dbSelectArea("SE1")
dbSetOrder(1)
If dbSeek(cChavNF)
	cTipNF := Alltrim(SE1->E1_TIPO)
	cCliNF := SE1->E1_CLIENTE+SE1->E1_LOJA
	cNatNF := SE1->E1_NATUREZ
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+cCliNF)
		If lUsaTempl
			cCtaCre := U_IPCWK("CTCLIENTE")
			cNomNF := alltrim(SE1->E1_NOMCLI)
			cNumNF := Alltrim(SE1->E1_PREFIXO)+"/"+Alltrim(SE1->E1_NUM)+"/"+Alltrim(SE1->E1_PARCELA)
		Else
			cCtaCre := SA1->A1_CONTA
			cNomNF := alltrim(SE1->E1_NOMCLI)
			cNumNF := Alltrim(SE1->E1_PREFIXO)+"/"+Alltrim(SE1->E1_NUM)+"/"+Alltrim(SE1->E1_PARCELA)
		EndIf
	EndIf
EndIf

// Obtém dados a partir do título de abatimento (RA/NCC)
dbSelectArea("SE1")
dbSetOrder(1)
If dbSeek(cChavRA)
	cTipAb := Alltrim(SE1->E1_TIPO)
	cCliRA := SE1->E1_CLIENTE+SE1->E1_LOJA
	cNatRA := SE1->E1_NATUREZ
	cCtaDeb := SE1->E1_CREDIT

	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+cCliNF)
		If lUsaTempl
			cNomRA := alltrim(SE1->E1_NOMCLI)
			cNumRA := Alltrim(SE1->E1_PREFIXO)+"/"+Alltrim(SE1->E1_NUM)+"/"+Alltrim(SE1->E1_PARCELA)
		Else
			cNomRA := alltrim(SE1->E1_NOMCLI)
			cNumRA := Alltrim(SE1->E1_PREFIXO)+"/"+Alltrim(SE1->E1_NUM)+"/"+Alltrim(SE1->E1_PARCELA)
		EndIf
	EndIf
	If cNomRA==cNomNF // Se for o mesmo cliente não levo para o histórico
		cNomRA := ""
	EndIf
	If Empty(cCtaDeb)
		dbSelectArea("SED")
		dbSetOrder(1)
		If dbSeek(xFilial("SED")+cNatRA)
			If lUsaTempl
				If cTipAb=="NCC"
					cCtaDeb := U_IPCWK("CTPAS-DEVVEN")
				Else
					cCtaDeb := U_IPCWK("CTCRE-SE1")
				Endif
			Else
				cCtaCre := SED->ED_CONTA
			EndIf
		EndIf
	Endif
EndIf

If cCampoCt5=="DEBITO"
	xRet := cCtaDeb
ElseIf cCampoCt5=="CREDITO"
	xRet := cCtaCre
ElseIf cCampoCt5=="HISTORICO"
	xRet := "BX.COMP.CR."+cNumNF+" CONTRA "+cNumRA+" "+cNomRA
ElseIf cCampoCt5=="VALOR"
	// Aqui pode testar a variável cTipAb para decidir se contabiliza ou não quando for por exemplo NCC.
	If SE5->E5_MOEDA<>"01"
		xRet := SE5->E5_VLMOED2
	Else
		xRet := SE5->E5_VALOR
	Endif
ElseIf cCampoCt5=="TIPO_NF"
	xRet := cTipNF
ElseIf cCampoCt5=="TIPO_ABAT"
	xRet := cTipAb
ElseIf cCampoCt5=="TIPOS"
	xRet := cTipNF+"/"+cTipAb
ElseIf cCampoCt5=="CLINF"
	xRet := cCliNF
ElseIf cCampoCt5=="CLIRA"
	xRet := cCliRA
EndIf

RestArea(xAreaSE1)
RestArea(xAreaSE5)
RestArea(xAreaSA1)
RestArea(xAreaSED)
RestArea(xArea)

Return xRet
