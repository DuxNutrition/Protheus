#include 'totvs.ch'

/*
=====================================================================================
Programa.:              ZFATF001
Autor....:              Daniel Neumann CI RESULT
Data.....:              22/06/2023
Descricao / Objetivo:   Ajusta a volumetria do pedido de venda 
Doc. Origem:            GAP022
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

User Function ZFATF001()
    
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
    
Return()
