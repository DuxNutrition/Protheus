#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} MTA650I 
	@description    - Geração de Ordens de Produção 
	@author Daniel Neumann - CI Result
	@since 12/04/2023
	@version 1.0
/*/

User Function MTA650I()

    Local aArea     := GetArea()
    Local aAreaSC2  := SC2->(GetArea())
    Local cAliasSC2 := ""

    If SC2->C2_SEQUEN <> '001'

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
    EndIf 
    
    RestArea(aArea)
    RestArea(aAreaSC2)

Return
