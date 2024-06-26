#include "protheus.ch"

/*
=====================================================================================
Programa.:              LP597
Autor....:              ERP MAIS | Jos� Donizete R.silva
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
User Function LP597(cCampoCt5)

Local xRet
Local xArea		:= GetArea()
Local xAreaSE2	:= SE2->(getArea())
Local xAreaSE5	:= SE5->(getArea())
Local xAreaSA2	:= SA2->(getArea())
Local xAreaSED	:= SED->(getArea())
Local cTipoE5   := Alltrim(SE5->E5_TIPO)
Local cTipAb	:= ""
lOCAL cTipNF	:= ""
Local lUsaTempl	:= .f.

Local cChavNF	:= ""
Local cNumNF	:= ""
Local cFornNF 	:= ""
Local cNomNF	:= ""
Local cNatNF	:= ""
Local cCtaDeb	:= ""

Local cChavPA	:= ""
Local cNumPA	:= ""
Local cFornPA 	:= ""
Local cNomPA	:= ""
Local cNatPA	:= ""
Local cCtaCre	:= ""

If EXISTBLOCK("IPCWK")
	lUsaTempl := .t.
EndIf

cCampoCt5 := upper(alltrim(cCampoCt5))

If cTipoE5$"PA,NDF" && Posicionado em t�tulos de abatimento
	cChavNF	:= SE5->E5_FILORIG+SE5->E5_DOCUMEN
	cChavPA	:= SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA)
Else && Posicionado em t�tulos normais (NF, boleto, etc)
	cChavNF	:= SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA)
	cChavPA	:= SE5->E5_FILORIG+SE5->E5_DOCUMEN
EndIf

&& Obt�m dados a partir da NF/Outro que n�o seja o t�tulo de abatimento (PA/NDF)
dbSelectArea("SE2")
dbSetOrder(1)
If dbSeek(cChavNF)
	cTipNF := Alltrim(SE2->E2_TIPO)
	cFornNF := SE2->E2_FORNECE+SE2->E2_LOJA
	cNatNF := SE2->E2_NATUREZ
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+cFornNF)
		If lUsaTempl
			cCtaDeb := U_IPCWK("CTFORNECEDOR")  
			cNomNF := alltrim(SE2->E2_NOMFOR)
			cNumNF := Alltrim(SE2->E2_PREFIXO)+"/"+Alltrim(SE2->E2_NUM)+"/"+Alltrim(SE2->E2_PARCELA)
		Else
			cCtaDeb := SA2->A2_CONTA
			cNomNF := alltrim(SE2->E2_NOMFOR)
			cNumNF := Alltrim(SE2->E2_PREFIXO)+"/"+Alltrim(SE2->E2_NUM)+"/"+Alltrim(SE2->E2_PARCELA)
		EndIf
	EndIf
EndIf

&& Obt�m dados a partir do t�tulo de abatimento (PA/NDF)
dbSelectArea("SE2")
dbSetOrder(1)
If dbSeek(cChavPA)
	cTipAb := Alltrim(SE2->E2_TIPO)
	cFornPA := SE2->E2_FORNECE+SE2->E2_LOJA
	cNatPA := SE2->E2_NATUREZ
	cCtaCre := SE2->E2_DEBITO

	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+cFornNF)
		If lUsaTempl
			cNomPA := alltrim(SE2->E2_NOMFOR)
			cNumPA := Alltrim(SE2->E2_PREFIXO)+"/"+Alltrim(SE2->E2_NUM)+"/"+Alltrim(SE2->E2_PARCELA)
		Else
			cNomPA := alltrim(SE2->E2_NOMFOR)
			cNumPA := Alltrim(SE2->E2_PREFIXO)+"/"+Alltrim(SE2->E2_NUM)+"/"+Alltrim(SE2->E2_PARCELA)
		EndIf
	EndIf
	If cNomPA==cNomNF && Se for o mesmo fornecedor n�o levo para o hist�rico
		cNomPA := ""
	EndIf
	If Empty(cCtaCre)
		dbSelectArea("SED")
		dbSetOrder(1)
		If dbSeek(xFilial("SED")+cNatPA)
			If lUsaTempl
				If cTipAb=="NDF"
					cCtaCre := U_IPCWK("CTATF-DEVCOM")
				Else
					cCtaCre := U_IPCWK("CTDEB-SE2")
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
	xRet := "BX.COMP.CP."+cNumNF+" CONTRA "+cNumPA+" "+cNomPA
ElseIf cCampoCt5=="VALOR"
	&& Aqui pode testar a vari�vel cTipAb para decidir se contabiliza ou n�o quando for por exemplo NDF.
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
ElseIf cCampoCt5=="FORNNF"
	xRet := cFornNF
ElseIf cCampoCt5=="FORNPA"
	xRet := cFornPA
EndIf

RestArea(xAreaSE2)
RestArea(xAreaSE5)
RestArea(xAreaSA2)
RestArea(xAreaSED)
RestArea(xArea)

Return xRet
