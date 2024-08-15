#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} 
O ponto de entrada FA050GRV sera utilizado apos a gravacao de todos os dados (na inclusão do título) e antes da sua contabilização.

@auhor Jedielson Rodrigues
@since 14/08/2024
@history 
@version P11,P12
@database MSSQL
@See https://tdn.totvs.com/display/public/mp/FA050GRV+-+Grava+dados+--+11855

/*/

User Function FA050GRV()

Local _aArea    := GetArea()
Local dDatAtual := dDataBase //Date()
Local dDataVenc := CtoD( "" )
Local nUtiOco	:= SuperGetMV("MV_RESUTCO",.F.,1) //"1" = útil
Local dDtVenc1  := SuperGetMV("DUX_FIN004",.F.,"15")
Local dDtVenc2  := SuperGetMV("DUX_FIN005",.F.,"30")
Local nDia      := Day(dDatAtual)
Local dDtProximo := CtoD( "" ) 

If FwIsInCallStack("FN677TCP")
    If (nDia >= 26 .OR. nDia <= 10)
        dDataVenc  := Ctod(Alltrim(dDtVenc1)+"/"+Alltrim(STR(Month(dDatAtual)))+"/"+Alltrim(STR(Year(dDatAtual))))
        dDtProximo := MonthSum(dDataVenc, 1)

        If dDatAtual > dDataVenc
            dDataVenc := dDtProximo
        Endif					

    Else
        dDataVenc  := Ctod(Alltrim(STR(dDtVenc2))+"/"+Alltrim(STR(Month(dDatAtual)))+"/"+Alltrim(STR(Year(dDatAtual))))						
        dDtProximo := MonthSum(dDataVenc, 1)

        If dDatAtual > dDataVenc
            dDataVenc := dDtProximo
        Endif	

    EndIf

    If nUtiOco == 1 //Se for dia Util
        dDataVenc := DataValida(dDataVenc)
    Endif

    DbSelectArea( "SE2" )
    SE2->(dbSetOrder(1))
    If SE2->(DbSeek(xfilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))
        RecLock("SE2",.F.)
        SE2->E2_VENCTO  := dDataVenc
        SE2->E2_VENCREA := dDataVenc
        SE2->E2_VENCORI := dDataVenc
        MsUnlock("SE2")
    Endif
Endif

RestArea(_aArea)

Return Nil
