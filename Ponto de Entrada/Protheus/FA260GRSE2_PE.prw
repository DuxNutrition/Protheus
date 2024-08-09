#include "rwmake.ch"


/*********************************************************************************************
* Rotina	:	FA260GRSE2
* Autor		:	Dux | Allan R
* Data		:	17/06/2024
* Descricao	:	Ponto de entrada que permite a gravação de informações adicionais na tabela SE2 
                (contas a pagar).A chamada deste ponto de entrada ocorre após efetivar a 
                conciliação do título e na sequência da gravação do código de barras, 
                mantendo o título conciliado posicionado permitindo a gravação de outras 
                informações.
* Gap	    :   GAP011 	
*********************************************************************************************/

User Function FA260GRSE2()

    Local cFPagItau     := SuperGetMv("DUX_FIN001",.T.,"30")
    Local cFPagOutros   := SuperGetMv("DUX_FIN002",.T.,"31")
    Local cBanco        := SuperGetMV("DUX_FIN003",.T.,"341")
    Local aArea         := GetArea()
    Local aAreaSE2      := SE2->(GetArea())

    If Left(SE2->E2_CODBAR,3) $ Alltrim(cBanco)
        SE2->E2_FORMPAG := Alltrim(cFPagItau)
    Else
        SE2->E2_FORMPAG := Alltrim(cFPagOutros)
    EndIf 

    Restarea(aArea)
    Restarea(aAreaSE2)

Return Nil
