#INCLUDE "TOTVS.CH"
 
User Function MT120LOK()

	Local lRet      := .T.
	Local aAreaAtu	:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local nPosicao	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "C7_PRODUTO"})
	Local cProduto	:= AllTrim(aCols[n, nPosicao])
	Local cCompra	:= AllTrim(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_ZZCOM")) 
	
	If lRet .And. cCompra == "2"
		MsgAlert("O produto não pode ser comprado! ","PRODUTO")
		lRet := .F.
	EndIf
	
	RestArea(aAreaAtu)
	RestArea(aAreaSC7)
	
Return lRet
