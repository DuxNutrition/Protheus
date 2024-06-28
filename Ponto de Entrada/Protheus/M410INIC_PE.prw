#INCLUDE "PROTHEUS.CH"


/*
Programa : M410INIC
Autor    : Douglas Ferreira Martins
Data     : 17/12/2019
Descrição: Ponto de Entrada na Inicialização do Pedido - Usado tanto para Inclusão quanto para Logistica Reversa
*/
User Function M410INIC()
	
	
	// Integração Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADM410INIC")
		ExecBlock("ADM410INIC", .F., .F.)
	EndIf
		
	
Return 