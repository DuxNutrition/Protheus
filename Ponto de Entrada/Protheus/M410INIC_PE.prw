#INCLUDE "PROTHEUS.CH"


/*
Programa : M410INIC
Autor    : Douglas Ferreira Martins
Data     : 17/12/2019
Descri��o: Ponto de Entrada na Inicializa��o do Pedido - Usado tanto para Inclus�o quanto para Logistica Reversa
*/
User Function M410INIC()
	
	
	// Integra��o Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADM410INIC")
		ExecBlock("ADM410INIC", .F., .F.)
	EndIf
		
	
Return 