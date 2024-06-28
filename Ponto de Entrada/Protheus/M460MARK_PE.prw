// #########################################################################################
// Projeto: Dux
// Modulo : SIGAFAT
// Fonte  : M460MARK
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 22/05/23 | Rafael Yera Barchi| Ponto de entrada para validação de faturamento.
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"PROTHEUS.CH"		


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} M460MARK
Ponto de entrada para validação de faturamento.

@author    Rafael Yera Barchi
@version   1.xx
@since     22/05/2023
/*/
//------------------------------------------------------------------------------------------
User Function M460MARK()

    Local _lRet     := .T.
    Local lVldTrp   := SuperGetMV("DN_VLTRFAT", , .T.)
    Local lVldVol   := SuperGetMV("DN_VLVOLUM", , .T.)


    If lVldTrp .And. Empty(SC5->C5_TRANSP) .Or. SC5->C5_TRANSP == SuperGetMV("IP_TRPGEN", , "")
        _lRet := .F.
        FWAlertError("Não é permitido faturar sem informar a transportadora. Por favor, verifique! ", "Atenção! ")
    EndIf

    If lVldVol .And. SC5->C5_VOLUME1 == 0
        _lRet := .F.
        FWAlertError("Não é permitido faturar sem informar a quantidade de volumes. Por favor, verifique! ", "Atenção! ")
    EndIf

    // Integração Protheus x VTEX - Atos Data Consultoria
    If ExistBlock("ADM460MARK")
        _lRet := ExecBlock("ADM460MARK", .F., .F., _lRet)
    EndIf

Return _lRet
