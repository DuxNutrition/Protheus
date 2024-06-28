#Include 'Protheus.ch'

/*/{Protheus.doc} DUXAVLDB  
	@description Validação do bloqueio do item 
	@author Daniel Neumann - CI Result
	@since 15/04/2023
	@version 1.0
*/

User Function DUXAVLDB()

    Local cRet          := ""
    Local cAliasSC9     := GetNextAlias()

    If (SC6->C6_QTDVEN - SC6->C6_QTDENT) <= 0  //Faturado
        cRet    := "9"
    ElseIf AllTrim(SC6->C6_BLQ) == 'R' //Residuo Eliminado
        cRet    := "7"
    Else 

        BeginSQL Alias cAliasSC9
            SELECT  C9_PEDIDO,
                    MAX(C9_BLCRED) AS C9_BLCRED,
                    MAX(C9_BLEST) AS C9_BLEST
                FROM %TABLE:SC9% SC9 
                WHERE   SC9.%NOTDEL%
                        AND C9_FILIAL 	= %EXP:SC5->C5_FILIAL%
                        AND C9_PEDIDO 	= %EXP:SC5->C5_NUM%
                        AND C9_ITEM 	= %EXP:SC6->C6_ITEM%  
                        AND C9_BLCRED   <> "10"
                        AND C9_BLEST    <> "10"
                GROUP BY C9_PEDIDO, C9_BLCRED, C9_BLEST
        EndSQL 

        If !Empty((cAliasSC9)->C9_PEDIDO)
            If !Empty((cAliasSC9)->C9_BLCRED) //Bloqueio por crédito
                cRet    := "2"
            ElseIf Empty((cAliasSC9)->C9_BLCRED) .And. !Empty((cAliasSC9)->C9_BLEST) //Bloqueio por Estoque
                cRet    := "3"
            ElseIf Empty((cAliasSC9)->C9_BLEST) .And. Empty((cAliasSC9)->C9_BLEST) //Apto a Faturar
                cRet    := "8"
            EndIf 
        Else 
            cRet    := "1" //Bloqueio por regra
        EndIf 

        (cAliasSC9)->(DbCloseArea())
    EndIf 

Return cRet
