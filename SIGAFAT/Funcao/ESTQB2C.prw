#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} ESTQB2C 
	@description Retorna quantidade reservada para o B2C vigente
	@author Daniel Neumann - CI Result
	@since 20/03/2023
	@version 1.0
/*/

User Function ESTQB2C(nOpc) 

    Local nRet      := 0 
    Local aAreaZBC  := ZBC->(GetArea())
    Local aAreaSB1  := SB1->(GetArea())
    Local cCodPro   := ""
    Local cLocPad   := ""

    DEFAULT nOpc    := 1
        
    //Verifica se há regra cadsrada para o produto
    If !INCLUI
        cCodPro := SC6->C6_PRODUTO
        cLocPad := SC6->C6_LOCAL  
    Else 
        If nOpc == 1
            cCodPro := GdFieldGet("C6_PRODUTO")
            cLocPad := GdFieldGet("C6_LOCAL")
        EndIf 
    EndIf 

    SB2->(DbSetOrder(1))
    SB2->(DbSeek(xFilial("SB2") + cCodPro + cLocPad, .F.))
    
    nRet := SaldoSB2()

    SB1->(dbSetOrder(1))
    If SB1->(Dbseek(xFilial("SB1") + cCodPro))

        If SB2->B2_LOCAL = SB1->B1_LOCPAD
            ZBC->(DbSetOrder(1))
            If ZBC->(DbSeek(xFilial("ZBC") + cCodPro))

                //Percorre todas as regras do produto, a primeira que se encaixar no range de fatas retorna
                While ZBC->(!EOF()) .And. ZBC->ZBC_FILIAL == xFilial("ZBC") .And. ZBC->ZBC_CODPRO == cCodPro

                    If ZBC->ZBC_DTINI <= DATE() .And. ZBC->ZBC_DTFIM >= DATE()

                        //nRet -=  ZBC->ZBC_QUANTI - U_SLDVDB2C(xFilial("ZBC"), cCodPro, ZBC->ZBC_DTINI, ZBC->ZBC_DTFIM, cLocPad ) Correção Paulo e Daniel 21/04/2023 
                        nRet -=  MAX(ZBC->ZBC_QUANTI - U_SLDVDB2C(xFilial("ZBC"), cCodPro, ZBC->ZBC_DTINI, ZBC->ZBC_DTFIM, cLocPad ),0)  

                        nRet := MAX(nRet, 0)

                        Exit  
                    EndIf 
                    ZBC->(DbSkip())
                EndDo
            EndIf 
        EndIf   
    EndIf 

    RestArea(aAreaZBC)
    RestArea(aAreaSB1)

Return nRet
