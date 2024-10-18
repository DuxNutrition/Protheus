#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MTA650I 
@description - Geração de Ordens de Produção 
@author Daniel Neumann - CI Result
@history Dux | Jedielson Rodrigues
@since 12/04/2023
@version 1.0
@See https://tdn.totvs.com/pages/releaseview.action;jsessionid=19F8795DFB06DE77D5C94BA940E27BB3?pageId=6089303
/*/

User Function MTA650I()

Local aArea     := GetArea()
Local aAreaSC2  := SC2->(GetArea())
Local cAliasSC2 := ""
Local cNum      := SC2->C2_NUM
Local cProduto  := SC2->C2_PRODUTO
Local cEmissao  := SC2->C2_EMISSAO
Local cProdRb   := SC2->C2_XRBD  
Local cTpInd    := SC2->C2_XTPIND 
Local cLotectl  := ""

If ExistFunc("U_ZPCPF001")
    cLotectl := U_ZPCPF001(cNum,cProduto,cEmissao,cProdRb,cTpInd)
Endif

If SC2->C2_SEQUEN == '001'
    RECLOCK("SC2", .F. )
    SC2->C2_LOTECTL := cLotectl    
    SC2->(MSUNLOCK())
Else
    cAliasSC2 := GetNextAlias()

    BeginSQL Alias cAliasSC2 

        SELECT  C2_TPPR,
                C2_ZZFORN,
                C2_ZZLOJA
            FROM %TABLE:SC2% SC2 
            WHERE   SC2.%NOTDEL% 
                    AND C2_FILIAL   = %EXP:SC2->C2_FILIAL%
                    AND C2_NUM      = %EXP:SC2->C2_NUM%
                    AND C2_ITEM     = %EXP:SC2->C2_ITEM%
                    AND C2_SEQUEN   = '001'

    EndSQL

    If (cAliasSC2)->(!EOF())

        RECLOCK("SC2", .F. )
        SC2->C2_TPPR    := (cAliasSC2)->C2_TPPR      
        SC2->C2_ZZFORN  := (cAliasSC2)->C2_ZZFORN
        SC2->C2_ZZLOJA  := (cAliasSC2)->C2_ZZLOJA
        SC2->(MSUNLOCK())
    EndIf 

(cAliasSC2)->(DbCloseArea())

Endif
    
    RestArea(aArea)
    RestArea(aAreaSC2)

Return

