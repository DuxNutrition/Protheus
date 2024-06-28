#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT010INC
Ponto de entrada na Inclusão de produtos

@author    Douglas F Martins 
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------
User Function MT010INC()
	

// Integração Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADMT010INC")
		ExecBlock("ADMT010INC", .F., .F.)
	EndIf
	
Return