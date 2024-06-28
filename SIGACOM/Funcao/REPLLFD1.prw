#Include 'Protheus.ch'

/*/{Protheus.doc} REPLLFD1
	@type function
	@description Replica o armazém para os demais itens do pedido
	@author Daniel Neumann - CI Result
	@since 08/06/2023
	@version 1.0
/*/

User Function REPLLFD1(cCampo) 

    Local nPosLocal     := aScan(aHeader,{|x| AllTrim(x[2])== "D1_LOCAL"})
    Local nPosTES       := aScan(aHeader,{|x| AllTrim(x[2])== "D1_TES"})
    Local nI            := 0   
    Local nBkpN         := n 
    Local cLocalRep     := ""
    Local cTESRep       := ""
    Local nMV_PAR       := 0 //Validado pois quando chamado da MATA910 vem como caracter e da MATA103 vem numérico

    If  FWIsInCallStack("MATA103")
        nMV_PAR := MV_PAR22
    Else 
        nMV_PAR := 1
    EndIf 
    
    If !FWIsInCallStack("U_IPIMPXML") .And.  nMV_PAR == 1 //Opção do F12 para replicar tipo de Operação
        
        If cCampo == "LOCAL"
            
            cLocalRep := M->D1_LOCAL

            For nI	:= n + 1 to Len(aCols)

                n := nI
                aCols[nI][nPosLocal] := cLocalRep
                A103Trigger('D1_LOCAL')
                If ExistTrigger('D1_LOCAL') 
                    RunTrigger(2,nI,nil,,'D1_LOCAL')
                EndIf 

            Next nI     

            n := nBkpN

        ElseIf cCampo == 'TES'
            
            cTESRep := M->D1_TES

            For nI	:= n + 1 to Len(aCols)

                n := nI
                aCols[nI][nPosTES] := cTESRep
                A103Trigger('D1_TES')
                If ExistTrigger('D1_TES') 
                    RunTrigger(2,nI,nil,,'D1_TES')
                EndIf 

            Next nI     

            n := nBkpN
        EndIf 

        If FWIsInCallStack("MATA103")
            If oGetDados <> Nil
                oGetDados:oBrowse:Refresh()
            Endif
        EndIf
    Endif 
    
Return .T.
