#include 'protheus.ch'
/*/{Protheus.doc} DescProd
	
	Função para sugerir a Descrição do Produto

@author CI RESULT - Luciano Corrêa
@since 17/01/2023
@version Protheus 12.1.33
@param 
@return cRet, character, Dado para o Contradomínio do Gatilho
@example

	Gatilho B1_GRUPO -> B1_DESC -> U_DescProd() se M->B1_TIPO = 'PA'
	Gatilho B1_ZTAM -> B1_DESC -> U_DescProd()
	Gatilho B1_ZSAB -> B1_DESC -> U_DescProd()
/*/
User Function DescProd()

	Local cRet		:= M->B1_DESC
	Local aArea		:= GetArea()

	If M->B1_TIPO == 'PA'

		cGrp	:= AllTrim( Posicione( "SBM", 1, xFilial( "SBM") + M->B1_GRUPO, "BM_DESC" ) )
		cTam	:= AllTrim( FWGetSX5( "ZE", M->B1_ZTAM )[ 1, 4 ] )
		cSab	:= AllTrim( FWGetSX5( "ZF", M->B1_ZSAB )[ 1, 4 ] )

		cRet	:= SubStr( cGrp, At( ' - ', cGrp ) + 3 )
		cRet	+= " " + SubStr( cTam, At( ' - ', cTam ) + 3 )
		cRet	+= if( !Empty(cSab)," - " + cSab,"") 

	EndIf

	RestArea( aArea )

Return cRet
