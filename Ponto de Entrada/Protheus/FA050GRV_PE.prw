#INCLUDE "PROTHEUS.CH"
#INCLUDE "PRTOPDEF.CH"

/*********************************************************************************************
* Rotina	:	FA050GRV
* Autor		:	Dux | Allan R
* Data		:	17/06/2024
* Descricao	:	Chamada ponto de entrada correção de financeiro -> DDA 341
* Apoio		: 	
*********************************************************************************************/
User Function FA050GRV()
    
    Local cFPagItau     := SuperGetMv("DUX_FIN01",.T.,"30")
    Local cFPagOutros   := SuperGetMv("DUX_FIN02",.T.,"31")
    Local cBanco        := SuperGetMV("DUX_FIN03",.T.,"341")
    Local aArea         := GetArea()
    Local aAreaSE2      := SE2->(GetArea())

    If Left(SE2->E2_CODBAR,3) $ Alltrim(cBanco)
        Reclock("SE2",.F.)
            SE2->E2_FORMPAG := Alltrim(cFPagItau)
        SE2->(MsUnlock())
    Else
       Reclock("SE2",.F.)
            SE2->E2_FORMPAG := Alltrim(cFPagOutros)
        SE2->(MsUnlock())   
    EndIf 

    Restarea(aArea)
    Restarea(aAreaSE2)

Return()
