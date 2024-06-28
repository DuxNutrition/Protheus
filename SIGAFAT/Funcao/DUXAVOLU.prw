#include 'totvs.ch'

/*/{Protheus.doc} A410Cons
	
	Ponto de Entrada para inserir botões no Pedido de Venda
	
	@type  Function
	@author Daniel Neumann CI RESULT
	@since 22/06/2023
	@version P12
/*/

User Function AJUSTVOL()
    
    Local nVolume   := AllTrim(Str(SC5->C5_VOLUME1))
    Local cRetImp   := ""
    
    cRetImp :=  FwInputBox("Informe o volume desejado!", nVolume)
    
    If !Empty(cRetImp) //Se vazio é porque cancelou a tela
        
        nVolume :=  Val(cRetImp)

        If nVolume != SC5->C5_VOLUME1
            RECLOCK("SC5", .F.)
            SC5->C5_VOLUME1 := nVolume
            SC5->(MSUNLOCK())
        EndIf 
    EndIf 
Return 
