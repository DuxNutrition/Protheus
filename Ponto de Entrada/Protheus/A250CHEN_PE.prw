#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A250CHEN
Forca endereco especifico para verificacao de saldos.
@type Function
@version 12.1.23
@author Jedielson Rodrigues
@since 23/09/2024
@version 12.1.2310
@database MSSQL
@See https://tdn.totvs.com/pages/releaseview.action?pageId=235599366
@Obs Verifica se tem saldo no endereço baseado no campo C2_XTPOP (Tipo de Producao).
/*/

User Function A250CHEN()

Local aArea    := FWGetArea()
Local aAreaSC2 := SC2->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aSD4     := PARAMIXB[1]  
Local nItem    := PARAMIXB[2] 
Local nCampo   := PARAMIXB[3]  
Local cLocPro1 := SuperGetMv("DUX_EST008",.F.,"PR01;PRODUCAO")
Local cLocPro2 := SuperGetMv("DUX_EST009",.F.,"PR02;INDUSTRIALIZACA")
Local lAtivo   := SuperGetMv("DUX_EST010",.F.,.T.)
Local cFil     := SuperGetMv("DUX_EST011",.F.,"02")
Local aItem    := {}
Local cTipo    := SC2->C2_XTPOP
Local nTam     := TamSX3("B1_COD")[1]
Local cEnd     := " "
Local cLocaliz := " "

cLocaliz := NGSEEK('SB1',Padr(SD4->D4_COD,nTam),1,"B1_LOCALIZ")

If lAtivo == .T. .AND. cFilAnt $ cFil
    If cTipo == "1"
        aItem := StrToKArr(cLocPro1,";")
        If cLocaliz == "S"
            cEnd := Alltrim(aItem[2])
        Endif
	Else 
        aItem := StrToKArr(cLocPro2,";")
        If cLocaliz == "S"
            cEnd := Alltrim(aItem[2])
        Endif
	Endif
Endif 

FwRestArea(aArea)
RestArea(aAreaSC2)
RestArea(aAreaSB1)

Return cEnd 
