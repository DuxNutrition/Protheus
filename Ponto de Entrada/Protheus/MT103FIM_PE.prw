#Include 'rwmake.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} MT103FIM

Ponto de Entrada no final da gravação da Nota Fiscal Entrada

/*/

User Function MT103FIM()
	
	Local aArea 	:= GetArea()
	Local aAreaSE2 		:= SE2->(GetArea())
	Local aAreaSA2 		:= SA2->(GetArea())

	// para titulo principal ser considerado na DIRF -----------
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(MsSeek( xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA ))

	If  SA2->A2_DIRF == '1' .and. SA2->A2_CODRET="3208"

		SE2->( dbSetOrder(6) )
		If  SE2->(dbSeek(xFilial('SE2')+SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_PREFIXO+SF1->F1_DUPL, .F.) )

			RecLock("SE2",.F.)
				SE2->E2_DIRF	:= SA2->A2_DIRF
				SE2->E2_CODRET  := SA2->A2_CODRET
			MsUnlock()

		ENDIF

	EndIf

	RestArea(aArea)
	RestArea(aAreaSE2)
	RestArea(aAreaSA2)
Return
