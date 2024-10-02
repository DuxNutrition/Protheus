#include "totvs.ch"

User Function  MT110TOK()

    Local aArea     := GetArea()
    Local aAreaSC1  := SC1->(GetArea())
    Local nPosDtNec := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_DATPRF" })
    Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_ITEM" })
    Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2]) == "C1_PRODUTO" })
    Local lRet      := .T.
    Local _nX       := 0
    Local lJob      := IsBlind()

    For _nX := 1 To Len(aCols)
        //Verifica se a data de entrega está menor que a data atual
        If aCols[_nX][nPosDtNec] < Date()
            lRet := .F.
            If lJob
                ConOut("DUX | MT110TOK_PE - Não é permitido informar data de necessidade menor que data atual " + FWTimeStamp())
            Else
                ApMsgInfo( "Não é permitido informar data de necessidade menor que data atual" + CRLF + CRLF +;
                                    "Item: " + AllTrim(aCols[_nX][nPosItem]) +" - Produto: " + AllTrim(aCols[_nX][nPosProd]) + CRLF + CRLF +;
                                    "Corrija a data para prosseguir!!", "[ MT110TOK_PE ]")
            EndIf
            Exit
        EndIf
     Next _nX

     RestArea(aArea)
     RestArea(aAreaSC1)

Return(lRet)
