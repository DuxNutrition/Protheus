#INCLUDE  'TOTVS.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ADIGNGAT
Fonte Criado para Definir em quais rotinas os Gatilhos Não devem ser Executados
Deve ser adicionado no X7_CONDIC. 
Exemplo: INCLUI .AND. U_ADIGNGAT()  

@author    Douglas F Martins 
@version   1.xx
@since     01/02/2023
@return    lRet, logical, .T. = Executa o gatilho, .F. = não executa

/*/
//------------------------------------------------------------------------------------------
User Function ADIGNGAT()

    Local lRet      := .T.
    Local cRotinas  := SuperGetMV("AD_IGNOGAT", , "U_WSVTEX46/U_MLFLXML1/U_MLFLXML2")


    lRet := !(AllTrim(FunName()) $ cRotinas)

Return lRet
