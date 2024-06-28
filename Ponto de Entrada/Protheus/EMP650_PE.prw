#Include "Protheus.ch"
#Include "Protheus.ch"

	    
/*
P.E.		: EMP650
Autor		: Dione Oliveira
Data		: 08/10/2019
Descricao	: EMP650 - Edição de Itens Empenhados na Abertura da OP
Obs.		: Realiza a troca do armazem padrao pelo armazem de producao, caso o armazem de producao nao esteja preenchido, sera utilizado o armazem padrao
Link		: https://tdn.totvs.com/display/public/PROT/EMP650+-+Ponto+de+Entrada

*/

User Function EMP650()
 
	Local aArea  	:= GetArea()
	Local aAreaSB1  := SB1->(GetArea())
                                     
	For i := 1 To Len(aCols)
								  
		DbSelectArea("SB1")
		If DbSeek(xFilial("SB1")+aCols[i,1])
			If !Empty(SB1->B1_ZZPENC) //Criar este parâmetro para que o PE funcione
				aCols[i,3] := SB1->B1_ZZPENC
			Else
				aCols[i,3] := SB1->B1_LOCPAD
			Endif                                                
		Endif
	Next
	
	RestArea(aArea)
	RestArea(aAreaSB1)

Return

