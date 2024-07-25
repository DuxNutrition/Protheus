#Include 'Protheus.ch'

/*/{Protheus.doc} MA410COR  
	@description Alterar cores do cadastro do status do pedido 
	@author Daniel Neumann - CI Result
	@since 14/04/2023
	@version 1.0
*/

User Function MA410COR()

    Local aCores    := {}

    If !(IsInCallStack("U_WSVTEX46") .Or. "WSVTEX" $ FunName())
        
        aAdd(aCores, {"u_LegPdVd(1) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)", "BR_BRANCO"   , "Pedido Bloqueado por Credito"}) //Bloqueio por Crédito
        aAdd(aCores, {"u_LegPdVd(2) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)", "BR_CINZA"    , "Pedido Bloqueado por Estoque"}) //Bloqueio por Estoque
    
        aAdd(aCores, {"Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)" , "ENABLE"      , "Pedido em Aberto"            })
        aAdd(aCores, {"!Empty(SC5->C5_NOTA).Or.SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ)"   , "DISABLE"     , "Pedido Encerrado"            })
        aAdd(aCores, {"!Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA).And. Empty(SC5->C5_BLQ)" , "BR_AMARELO"  , "Pedido Liberado"             })
        aAdd(aCores, {"SC5->C5_BLQ == '1'"                                                      , "BR_AZUL"     , "Pedido Bloqueado por Regra"  })
        aAdd(aCores, {"SC5->C5_BLQ == '2'"                                                      , "BR_LARANJA"  , "Pedido Bloqueado por Verba"  })

    EndIf

Return aCores


/*/{Protheus.doc} LegPdVd  
	@description Consulta se o item tem bloqueio de estoque ou crédito 
	@author Daniel Neumann - CI Result
	@since 15/04/2023
	@version 1.0
*/
User Function LegPdVd(nOpc)

    Local aArea     := GetArea()
    Local cAliasSC9 := GetNextAlias()
    Local lRet      := .F.
    Local cWhere    := IIF(nOpc == 1, "% C9_BLCRED NOT IN ('10', '  ')%", "% C9_BLCRED  = ' ' AND C9_BLEST NOT IN ('10', '  ')%") // nOpc = 1 Estoque, nOpc = 2 Crédito
    
    BeginSQL Alias cAliasSC9

        SELECT SUM(C9_QTDLIB) AS C9_QTDLIB
            FROM %TABLE:SC9% SC9 
            WHERE 	SC9.%NOTDEL% 
                    AND C9_FILIAL 	= %EXP:SC5->C5_FILIAL%
                    AND C9_PEDIDO 	= %EXP:SC5->C5_NUM%
                    AND %Exp:cWhere%
    EndSQL 

    If (cAliasSC9)->C9_QTDLIB > 0
        
        lRet := .T.
    EndIf 

    (cAliasSC9)->(DbCloseArea())

    RestArea(aArea)

Return lRet
