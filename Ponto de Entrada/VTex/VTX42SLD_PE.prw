#INCLUDE "TOTVS.CH"

/*
=====================================================================================
Programa.:              VTX42SLD
Autor....:              Atos | Douglas F Martins
Data.....:              13/03/2023
Descricao / Objetivo:   Retorna o saldo do produto na integração da VTEX.
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function VTX42SLD()
    Local nSaldo := 0
    Local aArea  := GetArea()


    SB2->(DBSelectArea("SB2"))
    SB2->(DBSetOrder(1))
    SB2->(DBSeek((cAliasTRB)->B2_FILIAL + SB1->B1_COD + (cAliasTRB)->ARMAZEM))


    nSaldo :=  SB2->B2_QATU - SB2->B2_RESERVA - SB1->B1_XESTABA

    RestArea(aArea)

Return(nSaldo)
