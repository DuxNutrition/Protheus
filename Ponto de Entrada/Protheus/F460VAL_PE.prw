#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F460VAL
Ponto de entrada para adicionar campos na grava��o dos novos t�tulos na rotina Liquida��o (FINA460).

@author    Douglas F Martins 
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------
User Function F460VAL()
	

Local aDadosSE1	:= {}


aadd(aDadosSE1, {"E1_NSUTEF",SE1->E1_NSUTEF})
	

// Integra��o Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADF460VAL")
		ExecBlock("ADF460VAL", .F.,.F., aDadosSE1)
	EndIf
	
Return
