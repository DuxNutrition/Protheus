#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MC090MNU
Ponto de entrada para adicionar funções no browse da rotina Consulta NF Saída (MATC090).

@author    Douglas F Martins 
@version   1.xx
@since     23/07/2016
/*/
//------------------------------------------------------------------------------------------
User Function MC090MNU()
	
	Local 	aRot 	:= {}
	
	
	// Integração Protheus x VTEX - Atos Data Consultoria	
	If ExistBlock("ADMC090MNU")
		aRot := ExecBlock("ADMC090MNU", .F., .F.)
		If ValType(aRot) == "A"
			AEval(aRot, {|x| AAdd(aRotina, x)})
		EndIf
	EndIf
	
Return