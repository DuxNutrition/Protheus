    
#include "totvs.ch"

/*/{Protheus.doc} ZFINF001
Rotina para gerar boletos por titulo.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 23/07/2024
@param aTitulos, array, titulos selecionados
@obs GAP008 | Impressao de boleto
/*/
User Function ZFINF001(aTitulos)

    Local nI 			:= 0
	Local nX			:= 1
	Local lImprime		:= .F.
	Local aBoletos  	:= {}
	Local aPrint  		:= {}
	Local cArquivo 		:= ""
	Local cDiretorio	:= "C:\BoletosDux\"
	Local cPrefixo		:= ""
	Local cNumero		:= ""
	Local cParcela		:= ""
	Local cTipo			:= ""
	Local cCliente		:= ""
	Local cLoja			:= ""
	Local nPosMark		:= 1
	Local nPosPrefix	:= 2
	Local nPosNum		:= 3
	Local nPosParcel	:= 4
	Local nPosTipo		:= 5
	Local nPosCli		:= 7
	Local nPosLj		:= 8

	If !ExistDir( cDiretorio )
		MakeDir( cDiretorio )
		ApMsgInfo("Pasta para salvar o(s) boleto(s) criada com sucesso."+CRLF+"Caminho: "+cDiretorio,"[ ZFINF001 ]")
	Endif
	
	For nI := 1 To Len(aTitulos)
		
		If aTitulos[nI,nPosMark] //Adiciona os boletos que foram selecionados no array

			cPrefixo	:= aTitulos[nI, nPosPrefix	]
			cNumero		:= aTitulos[nI, nPosNum		]
			cParcela	:= aTitulos[nI, nPosParcel	]
			cTipo		:= aTitulos[nI, nPosTipo	]
			cCliente	:= aTitulos[nI, nPosCli		]
			cLoja		:= aTitulos[nI, nPosLj		]

			aAdd(aBoletos, {cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja })
		EndIf

	Next nI

	While nX <= Len(aBoletos)
		
		cNumero := aBoletos[nX, 02]

		aAdd(aPrint, {	aBoletos[nX, 01],; //Prefixo
						aBoletos[nX, 02],; //Numero
						aBoletos[nX, 03],; //Parcela
						aBoletos[nX, 04],; //Tipo
						aBoletos[nX, 05],; //Cliente
						aBoletos[nX, 06]}) //Loja
		Nx++

		If ( nX > Len(aBoletos) )
			lImprime := .T.
		Else
			If ( cNumero <> aBoletos[nX, 02] )
				lImprime := .T.
			Else
				lImprime := .F.
			EndIf
		EndIf

		If lImprime

			cArquivo 	:= "NF_" + AllTrim(cPrefixo) + "_" + AllTrim(cNumero) + ".pdf"

			oBol:setTitulos(aPrint)
			oBol:Imprime(cDiretorio+cArquivo)

			lImprime 	:= .F.
			aPrint		:= {}
		EndIf

	EndDo	

	If !Empty(cArquivo) 
		ApMsgInfo("Boleto(s) Gerado(s) com sucesso"+CRLF+"Caminho: "+cDiretorio,"[ ZFINF001 ]")
	EndIf

Return()
