#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} MVIEWSALDO 
	@description Utilizado para manipular os valores dos saldos apresentados na consulta F4 do cadastro de produtos
	@author Daniel Neumann - CI Result
	@since 20/03/2023
	@version 1.0
/*/

User Function MVIEWSALDO()
    
    Local cProd     := PARAMIXB[1]
    Local cLocal    := PARAMIXB[2]
    Local aSaldo    := PARAMIXB[3]
    Local aRet      := {}
    Local nQtdPed   := 0
    
    If Len(aSaldo) > 0      
        
        //Verifica se é o local padrão do sistema para fazer o decremento
        If SB1->B1_LOCPAD == cLocal

            //Verifica se há regra cadsrada para o produto
            ZBC->(DbSetOrder(1))
            If ZBC->(DbSeek(xFilial("ZBC") + cProd))

                //Percorre todas as regras do produto, a primeira que se encaixar no range de fatas retorna
                While ZBC->(!EOF()) .And. ZBC->ZBC_FILIAL == xFilial("ZBC") .And. ZBC->ZBC_CODPRO == cProd

                    nQtdPed := U_SLDVDB2C(xFilial("ZBC"), cProd, ZBC->ZBC_DTINI, ZBC->ZBC_DTFIM, SB1->B1_LOCPAD )

                    If ZBC->ZBC_DTINI <= DATE() .And. ZBC->ZBC_DTFIM >= DATE()
                        aAdd(aRet,{ MAX(aSaldo[1,1] - MAX((ZBC->ZBC_QUANTI - nQtdPed), 0), 0)         ,;   // Qtd. Disponivel (SaldoSB2())
                                    aSaldo[1,2]                                               ,;   // Saldo Atual (B2_QATU)
                                    aSaldo[1,3]                                               ,;   // Qtd. Pedido de Vendas (B2_QPEDVEN)
                                    aSaldo[1,4]                                               ,;   // Qtd. Empenhada (B2_QEMP)
                                    aSaldo[1,5]                                               ,;   // Qtd. Prevista Entrada (B2_SALPEDI)
                                    aSaldo[1,6]                                               ,;   // Qtd. Empenhada S.A. (B2_QEMPSA)
                                    aSaldo[1,7]                                               ,;   // Qtd. Reservada (B2_RESERVA)
                                    aSaldo[1,8]                                               ,;   // Qtd. Ter.Ns.Pd. (B2_QTNP)
                                    aSaldo[1,9]                                               ,;   // Qtd. Ns.Pd.Ter (B2_QNPT)
                                    aSaldo[1,10]                                              ,;   // Saldo Poder 3 (B2_QTER)
                                    aSaldo[1,11]                                              ,;   // Qtd. Emp. NF (B2_QEMPN)
                                    aSaldo[1,12]                                              ,;   // Qdt. a Endereçar (B2_QACLASS) 
                                    MAX(aSaldo[1,13] + (ZBC->ZBC_QUANTI - nQtdPed  ), 0)      ,;   // Qtd. B2_QEMPPRJ
                                    aSaldo[1,14]                                               })  // Qtd. B2_QEMPPRE    

                        Exit  
                    EndIf 
                    ZBC->(DbSkip())
                EndDo
            EndIf                    
        EndIf 
    Endif

Return(aRet)
