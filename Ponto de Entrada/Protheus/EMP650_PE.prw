#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} EMP650
Alteracao de Itens Empenhados na Abertura da OP.
@type Function
@version 12.1.23
@author Jedielson Rodrigues
@since 13/09/2024
@version 12.1.2310
@database MSSQL
@See https://tdn.totvs.com/display/public/PROT/EMP650+-+Ponto+de+Entrada
@Obs Realiza a troca do Armazem e o endereço Baseado no campo C2_XTPOP (Tipo de Producao)
/*/

User Function EMP650()

Local aArea  	 := FWGetArea()
Local aAreaSC2   := SC2->(GetArea())
Local aAreaSB1   := SB1->(GetArea())
Local _nPosCod	 := aScan(aHeader,{|x| AllTrim(x[2]) == "G1_COMP" })   //Armazena o numero da coluna no aCols referente ao codigo
Local _nPosLoc	 := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_LOCAL"})   //Armazena o numero da coluna no aCols referente ao armazem
Local cLocPro1   := SuperGetMv("DUX_EST008",.F.,"PR01;PRODUCAO")
Local cLocPro2   := SuperGetMv("DUX_EST009",.F.,"PR02;INDUSTRIALIZACA")
Local lAtivo   	 := SuperGetMv("DUX_EST010",.F.,.T.)
Local cFil    	 := SuperGetMv("DUX_EST011",.F.,"01")
Local nTam    	 := TamSX3("B1_COD")[1]
Local cLocaliz   := ""
Local i		     := 0
Local cTipo      := SC2->C2_XTPOP
Local aItem      := {}

If lAtivo == .T. .AND. cFilAnt $ cFil
                                     
	For i:= 1 To Len(aCols)

		aItem    := {}
		cLocaliz := NGSEEK('SB1',Padr(aCols[i,_nPosCod],nTam),1,"B1_LOCALIZ")

		If cTipo == "1"
			aItem := StrToKArr(cLocPro1,";")
			aCols[i,_nPosLoc] := Alltrim(aItem[1])
		Else 
			aItem := StrToKArr(cLocPro2,";")
			aCols[i,_nPosLoc] := Alltrim(aItem[1])
		Endif

	Next i

Else

	For i:= 1 To Len(aCols)						
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If SB1->(MsSeek(FWxFilial("SB1")+Padr(aCols[i,_nPosCod],nTam)))
			If !Empty(SB1->B1_ZZPENC)
				aCols[i,_nPosLoc] := SB1->B1_ZZPENC
			Else
				aCols[i,_nPosLoc] := SB1->B1_LOCPAD
			Endif                                                
		Endif
	Next i

Endif

FwRestArea(aArea)
RestArea(aAreaSC2)
RestArea(aAreaSB1)

Return

