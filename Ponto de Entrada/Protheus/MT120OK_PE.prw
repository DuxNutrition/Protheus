#include "totvs.ch"

/*/{Protheus.doc} MT120OK
O ponto se encontra no final da fun��o e � disparado ap�s a confirma��o dos itens da getdados 
e antes do rodap� da dialog do PC, deve ser utilizado para valida��es especificas do usuario
onde ser� controlada pelo retorno do ponto de entrada oqual se for .F. o processo ser� interrompido 
e se .T. ser� validado.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 02/10/2024
@return logical, .T. or .F.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085483
/*/
User Function MT120OK()

    Local aArea     := GetArea()
    Local aAreaSC7  := SC7->(GetArea())
    Local nPosDtEnt := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DATPRF" })
    Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEM" })
    Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO" })
    Local lRet      := .T.
    Local _nX       := 0
    Local lJob      := IsBlind()

    For _nX := 1 To Len(aCols)
        //Verifica se a data de entrega est� menor que a data atual
        If aCols[_nX][nPosDTEnt] < Date()
            lRet := .F.
            If lJob
                ConOut("DUX | MT120OK_PE - N�o � permitido informar data de entrega menor que data atual " + FWTimeStamp())
            Else
                ApMsgInfo( "N�o � permitido informar data de entrega menor que data atual" + CRLF + CRLF +;
                                    "Item: " + AllTrim(aCols[_nX][nPosItem]) +" - Produto: " + AllTrim(aCols[_nX][nPosProd]) + CRLF + CRLF +;
                                    "Corrija a data para prosseguir!!", "[ MT120OK_PE ]")
            EndIf
            Exit
        EndIf
     Next _nX

     RestArea(aArea)
     RestArea(aAreaSC7)

Return(lRet)
