#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT100TOK
Ponto de entrada para efetuar validações na inclusão de documento de
entrada.

@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MT100TOK()

Local lRet 	:= .t.
Local i
Local nVlrIR := 0
Local nVlrPCC:= 0 

// Validações Universais TOTVS IP
If ExistBlock("TIPAC007",.F.,.T.) .and. !FwIsInCallStack("SCHEDCOMCOL")  .And. U_ADIGNGAT()
    lRet := ExecBlock("TIPAC007",.F.,.T.,{})
Endif

// incluido 25/05/23 CI Ticket 11653 --------------------------------- ------------------------------------------------------
If lRet .and. !cTipo $ 'D/B' .and. FunName() $ 'MATA103' //Somente para fornecedores, A ROTINA MATA920 CHAMA A MATA103
	
	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+CA100FOR+CLOJA,.f.)
	
	If oFisRod <> NIL //na rotina de retorno nao existe este objeto
			
		If Len(oFisRod:aArray) > 0
			For i:=1 to Len(oFisRod:aArray)
				If oFisRod:aArray[i][1] == 'IRR'
					nVlrIR := oFisRod:aArray[i][5]
				EndIf
				If oFisRod:aArray[i][1] $ 'PIS,COF,CSL'      //incluido 14/04/22 (Marlovani) ticket 6611
					nVlrPCC := oFisRod:aArray[i][5]
				EndIf
			Next i
		EndIf
			
		If SA2->A2_DIRF == '1'
			If nVlrPCC > 0                                  //incluido 14/04/22 (Marlovani) ticket 6611
				cDirf   := SA2->A2_DIRF
			EndIf
			If nVlrIR > 0
				cDirf   := SA2->A2_DIRF
				cCodRet := SA2->A2_CODRET
			EndIf
		Else
			If nVlrIR > 0
				Alert('Fornecedor parametrizado com A2_DIRF = 2 (Gera DIRF = Não) mas NF tem valor de IRR!')
				lRet := .f.
			EndIf
			If nVlrPCC > 0
				Alert('Fornecedor parametrizado com A2_DIRF = 2 (Gera DIRF = Não) mas NF tem valor de PCC!')
				lRet := .f.
			EndIf
		EndIf
			
	EndIf
		
EndIf

Return lRet
