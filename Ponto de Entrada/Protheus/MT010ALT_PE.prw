#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT010ALT
Ponto de entrada na Altera��o de produtos

@author    Douglas F Martins 
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------
User Function MT010ALT()
	

// Integra��o Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADMT010ALT")
		ExecBlock("ADMT010ALT", .F., .F.)
	EndIf
	
Return