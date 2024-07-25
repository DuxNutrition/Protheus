#include "protheus.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT010BRW
Adiciona mais Opções no Menu do Browse do Cadastro de Produtos

@author    Douglas F Martins 
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------

User Function MT010BRW()
	
	Local 	aRot 	:= {}
	
	
	// Integração Protheus x VTEX - Atos Data Consultoria	
	If ExistBlock("ADMT010BRW")
		aRot := ExecBlock("ADMT010BRW", .F., .F.)
		If ValType(aRot) == "A"
			AEval(aRot, {|x| AAdd(aRotina, x)})
		EndIf
	EndIf
	
Return (aRot)
