#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT010INC
Ponto de entrada na Inclus�o de produtos

@author    Douglas F Martins
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------
User Function MT010INC()

	if (!IsBlind())
		// Integra��o Protheus x VTEX - Atos Data ConsultoriA
		If ExistBlock("ADMT010INC")
			ExecBlock("ADMT010INC", .F., .F.)
		EndIf
	endif
Return
