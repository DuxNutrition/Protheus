#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F460SE1
Ponto de Entrada para Gravar campos no final da cria��o do processo de Liquida��o

@author    Douglas F Martins 
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------
User Function F460SE1()
	

// Integra��o Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADF460SE1")
		ExecBlock("ADF460SE1", .F., .F.)
	EndIf
	
Return