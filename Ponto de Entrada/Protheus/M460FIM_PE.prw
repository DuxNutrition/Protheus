#INCLUDE 'TOTVS.CH'
/*
Programa : M460FIM
Autor    : Douglas Ferreira Martins
Data     : 17/12/2019
Descrição: Ponto de Entrada para Gravar informações no momento do Faturamento
*/
User Function M460FIM()

	Local aArea 	:= GetArea()
	Local aAreaSD2	:= SD2->(GetArea())
	Local aAreaSB1 	:= SB1->(GetArea())
	Local aAreaSA1 	:= SA1->(GetArea())
	Local nVolumes	:= 0
	
	//Ajusta Volume e espécie antes de exibir ao usuário.
	SA1->(DbSetOrder(1))
	If SC5->C5_TIPO == "N" .And. SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)) .And. SA1->A1_PESSOA == 'J'
		
		SD2->(DbSetOrder(3))
		If SD2->(DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
		
			SB1->(DbSetOrder(1))

			While SD2->(!EOF()) .And. SD2->D2_FILIAL == SF2->F2_FILIAL .And. SD2->D2_DOC == SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE .And. SD2->D2_CLIENTE == SF2->F2_CLIENTE .And. SD2->D2_LOJA == SF2->F2_LOJA

				If SB1->(DbSeek(xFilial("SB1") + SD2->D2_COD))
						
					nVolumes += SD2->D2_QUANT / SB1->B1_ZQEEXP

				EndIf 

				SD2->(DbSkip())

			EndDo

			If nVolumes > 0 
				//Incrementa um inteiro se o volume for quebrado
				If (nVolumes - Int(nVolumes) ) <> 0
					nVolumes := Int(nVolumes) + 1
				EndIf 
			EndIf 

			RECLOCK("SF2", .F.)
			SF2->F2_VOLUME1 := nVolumes
			SF2->F2_ESPECI1 := "CAIXA"
			SF2->(MSUNLOCK())
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSD2)
	RestArea(aAreaSB1)
	RestArea(aAreaSA1)

	//Fim customização de volume

	//Executa o Wizard do Acelerador de Mensagens da NF no final da geração da NF de Saída
	If !IsBlind() .And. !IsInCallStack("U_ADFATAUT") .And. U_ADIGNGAT()
		If ExistBlock("MSGNF02",.F.,.T.)
			ExecBlock("MSGNF02",.F.,.T.,{})
		Endif
	EndIf
	
	// Integração Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADM460FIM")
		aArea			:= GetArea()
		aAreaSC5		:= SC5->(GetArea())
		aAreaSC6		:= SC6->(GetArea())
		aAreaSE1		:= SE1->(GetArea())
		aAreaSE2		:= SE2->(GetArea())
		aAreaSF2		:= SF2->(GetArea())
		aAreaSD2		:= SD2->(GetArea())	
		
		ExecBlock("ADM460FIM", .F., .F.)
		
		RestArea(aAreaSC5)
		RestArea(aAreaSC6)
		RestArea(aAreaSE1)
		RestArea(aAreaSE2)
		RestArea(aAreaSF2)
		RestArea(aAreaSD2)
		RestArea(aArea)
	EndIf

Return
