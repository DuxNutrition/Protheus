// #########################################################################################
// Projeto: VTEX
// Modulo : SIGAFAT
// Fonte  : MT410INC
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 28/04/15 | Douglas F Martins | Ponto de entrada na Inclusão do pedido de venda (MATA410).
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT410INC
Ponto de entrada na Inclusão do pedido de venda (MATA410).

@author    Douglas F Martins 
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------
User Function MT410INC()
	

	// Ponto de entrada para manutenção de compatibilidade
	If ExistBlock("ADMT410INC")
		ExecBlock("ADMT410INC", .F., .F.)
	EndIf
	
Return