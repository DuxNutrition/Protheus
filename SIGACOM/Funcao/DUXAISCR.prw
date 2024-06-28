#include "protheus.ch"

//------------------------------------------------------------------------
/*/{Protheus.doc} DUXAISCR
	@description Inicializador padrão utilizados em campos da SCR
	@author Daniel Neumann
	@since 23.05.2023
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function DUXAISCR(cCampo)
	
	Local xRet		:= ""
	Local aArea		:= GetArea()
	Local aAreaSC7 	:= SC7->(GetArea())
	Local aAreaSC1 	:= SC1->(GetArea())
	Local aAreaSE4 	:= SE4->(GetArea())
	Local aAreaSB1 	:= SB1->(GetArea())
	Local aAreaSA2 	:= SA2->(GetArea())
	
	DEFAULT cCampo	:= ""

	If "CR_XCODPG" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC7->C7_COND
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC1->C1_CONDPAG
            EndIf 
        EndIf 
    EndIf 

	If "CR_XDESPG" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := POSICIONE("SE4", 1, xFilial("SE4") + SC7->C7_COND, "E4_DESCRI")
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := POSICIONE("SE4", 1, xFilial("SE4") + SC1->C1_CONDPAG, "E4_DESCRI")
            EndIf 
        EndIf 
    EndIf 

	If "CR_XCODFOR" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC7->C7_FORNECE
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC1->C1_FORNECE
            EndIf
        EndIf 
    EndIf 

	If "CR_XLJFOR" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC7->C7_LOJA
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC1->C1_LOJA
            EndIf 
        EndIf 
    EndIf 

	If "CR_XNOMFOR" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := POSICIONE("SA2", 1, xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, "A2_NOME")
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := POSICIONE("SA2", 1, xFilial("SA2") + SC1->C1_FORNECE + SC1->C1_LOJA, "A2_NOME")
            EndIf 
        EndIf 
    EndIf 

	If "CR_XCODPRO" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC7->C7_PRODUTO
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC1->C1_PRODUTO
            EndIf 
        EndIf 
    EndIf 

	If "CR_XDESPRO" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := POSICIONE("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "B1_DESC")
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC1->C1_DESCRI
            EndIf 
        EndIf 
    EndIf 

	If "CR_XOBS" $ cCampo 

        If SCR->CR_TIPO == 'IP'
            SC7->(DbSetOrder(1))
            If SC7->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC7->C7_OBS
            EndIf 
        ElseIf SCR->CR_TIPO == 'SC' 
            SC1->(DbSetOrder(1))
            If SC1->(DbSeek(SCR->CR_FILIAL + AllTrim(SCR->CR_NUM)))
                xRet := SC1->C1_OBS
            EndIf 
        EndIf 
    EndIf 

    RestArea(aArea)
	RestArea(aAreaSC7)
	RestArea(aAreaSC1)
	RestArea(aAreaSE4)
	RestArea(aAreaSB1)
	RestArea(aAreaSA2)

Return xRet
