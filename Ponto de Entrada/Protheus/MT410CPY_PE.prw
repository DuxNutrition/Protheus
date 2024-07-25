// #########################################################################################
// Projeto: VTEX
// Modulo : SIGAFAT
// Fonte  : MT410CPY
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 28/04/15 | Douglas F Martins | Ponto de entrada na cópia do pedido de venda (MATA410).
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT410CPY
Ponto de entrada na cópia do pedido de venda (MATA410).

@author    Douglas F Martins 
@version   1.xx
@since     28/04/2015
/*/
//------------------------------------------------------------------------------------------
User Function MT410CPY()
	
	Local lRefCotFrt	:= SuperGetMV("IP_REFCOT", , .T.)
	Local cCodTr 		:= SuperGetMV("IP_TRPGEN", , "000000")

	
	// *****************************************************************************
	//
	// Se necessário, adicionar regras antes da chamada do ponto de entrada ADMT410CPY
	//
	// *****************************************************************************
	
	// Ponto de entrada para manutenção de compatibilidade
	If ExistBlock("ADMT410CPY")
		ExecBlock("ADMT410CPY", .F., .F.)
	EndIf

	// Integração Intelipost
	If lRefCotFrt
		ZC2->(DBSelectArea("ZC2"))
		ZC2->(DBSetOrder(1))
		If ZC2->(MSSeek(SC5->C5_FILIAL + "SC5" + SC5->C5_NUM))
			M->C5_TRANSP := cCodTr
		EndIf
	EndIf
	
Return
