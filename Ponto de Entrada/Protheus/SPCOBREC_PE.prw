#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} SPCOBREC
	
	Ponto de Entrada para alterar campo F6_COBREC de forma autom�tica no momento do faturamento de notas com imposto de ICMS ST ou DIFAL

	Para utiliza��o do ponto de entrada � necess�rio habilitar par�metro MV_GNRENF

@author CI RESULT - Luciano Corr�a
@since 18/05/2023
@version Protheus 12.1.33
@param

Paramixb[1] => Tipo GNRE
Paramixb[2] => Estado da GNRE

@return cCod, char, conte�do a ser gravado no campo F6_COBREC
@example
/*/
User Function SPCOBREC()

	Local cTipoImp	:= Paramixb[1]	// Tipo de Imposto (3 - ICMS ST ou B - Difal e Fecp de Difal)
	//Local cEstado	:= Paramixb[2]	// Estado da GNRE
	Local cCod		:= ""			// Codigo a ser gravado no campo F6_COBREC

	If cTipoImp == "B"
		
		cCod := "090"
		
	ElseIf cTipoImp == "3"

		cCod := "999" 
		
	EndIf

Return cCod
