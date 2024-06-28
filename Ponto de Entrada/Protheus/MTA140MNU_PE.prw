#Include "TOTVS.CH"

/*/{Protheus.doc} MTA140MNU

Ponto de Entrada para adicionar Rotinas no Menu da Rotina Padrão de Pré-Nota (MATA140)  

@type function
@author Carlos Eduardo Niemeyer Rodrigues
@since 01/07/2016

@see IPCOM005

@obs
	Contexto:	
	
	//Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("MTA140MNU")
		ExecBlock("MTA140MNU",.F.,.F.)
	EndIf
/*/
User Function MTA140MNU()

	//Adiciona no Menu a Rotina de Importação de XML do Gestor de XML da TOTVS IP
	If ExistBlock("IpMenuGestorXML",.F.,.T.)
		ExecBlock("IpMenuGestorXML",.F.,.T.,{})
	Endif
	
Return
