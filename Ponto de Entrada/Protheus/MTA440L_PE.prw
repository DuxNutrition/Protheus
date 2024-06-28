#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} MTA440L 
	@description    Executada na gravação de cada item liberado de um pedido de venda. 
                    O ponto de entrada MTA440L, permite que seja indicada um quantidade que deve ser abatida do saldo do produto.
	@author Daniel Neumann - CI Result
	@since 20/03/2023
	@version 1.0
/*/
User Function MTA440L()
    Local nRet          := 0
    Local cAliasZBC     := GetNextAlias()
    
    DEFAULT _lVldB2c    := .T. //Variável para validar se é alteração do pedido já liberado, nesse caso não abate a reserva.
    DEFAULT _aItLibC6   := {}
    DEFAULT _nItemLib   := 0
    
    //Caso a rotina tenha que ser validada, verifica se o produto do pedido de vendas é do armazém padrão
    SA1->(DbSetOrder(1))
    If !FWIsInCallStack("MATA521A") .And. _lVldB2c .And. SC6->C6_LOCAL == SB1->B1_LOCPAD  .And. !SC5->C5_TIPO $ "D_B" /*.And.  SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)) .And. SA1->A1_PESSOA == 'J' */ .And. Empty(SC5->C5_XPEDLV )
        If Len(_aItLibC6) > 0 .And. _nItemLib > 0 .And. _aItLibC6[_nItemLib][2] == "3" .And. _aItLibC6[_nItemLib][3] == "1"
            nRet := 9999999999
        Else 
            //Verifica se há regra cadsrada para o danielproduto
            BeginSQL Alias cAliasZBC
                COLUMN ZBC_DTINI AS DATE
                COLUMN ZBC_DTFIM AS DATE
                SELECT  ZBC_QUANTI,
                        ZBC_DTINI,
                        ZBC_DTFIM
                FROM %TABLE:ZBC% ZBC 
                WHERE   ZBC.%NOTDEL% 
                        AND ZBC_FILIAL = %xFilial:ZBC%
                        AND %EXP:DTOS(DATE())% BETWEEN ZBC_DTINI AND ZBC_DTFIM 
                        AND ZBC_CODPRO = %EXP:SC6->C6_PRODUTO%
            EndSQL 
            
            If (cAliasZBC)->(!EOF())
                nRet :=  MAX((cAliasZBC)->ZBC_QUANTI - U_SLDVDB2C(SC6->C6_FILIAL, SC6->C6_PRODUTO, (cAliasZBC)->ZBC_DTINI, (cAliasZBC)->ZBC_DTFIM, SB1->B1_LOCPAD ), 0)            
            EndIf 
            (cAliasZBC)->(DbCloseArea())
        EndIf      
    EndIf 
    
Return nRet
