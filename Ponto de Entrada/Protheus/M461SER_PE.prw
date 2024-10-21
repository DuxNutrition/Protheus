#INCLUDE 'PROTHEUS.CH'


/*/{Protheus.doc} M461SER
Ponto de Entrada para Mudar Numero da Nota Fiscal e Serie
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 21/10/2024
/*/
User Function M461SER()

	Local aDados	:= {}

	// Incluido uma validação de chamada, pois ele entrava mesmo sem ser solicitado.
	if FWIsInCallStack("ADM461SER")
		If ( ExistBlock("ADM461SER") )
			aDados  := ExecBlock("ADM461SER",.T.,.T.)
			cSerie  := aDados[1]
			cNumero := aDados[2]
		EndIf
	endif 
	
	//Customização com variavel private para alteração de DOC ZFATF008
	If FWIsInCallStack("U_ZFATF008")
        cNumero := _DxNfc
    EndIf 

Return
