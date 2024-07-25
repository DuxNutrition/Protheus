// #########################################################################################
// Projeto: Dux
// Modulo : SIGAFAT
// Fonte  : M410PVNF
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 22/05/23 | Rafael Yera Barchi| Ponto de entrada para validação de faturamento.
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE 	"PROTHEUS.CH"		


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} M410PVNF
Ponto de entrada para validação de faturamento.

@author    Rafael Yera Barchi
@version   1.xx
@since     22/05/2023
/*/
//------------------------------------------------------------------------------------------
User Function M410PVNF()  

    Local _lRet     := .T.
    Local lVldTrp   := SuperGetMV("DN_VLTRFAT", , .T.)
    Local lVldVol   := SuperGetMV("DN_VLVOLUM", , .T.)


    If !(IsInCallStack("U_WSVTEX46") .Or. "WSVTEX" $ FunName())
        
        If lVldTrp .And. Empty(SC5->C5_TRANSP) .Or. SC5->C5_TRANSP == SuperGetMV("IP_TRPGEN", , "")
            _lRet := .F.
            FWAlertError("Não é permitido faturar sem informar a transportadora. Por favor, verifique! ", "Atenção! ")
        EndIf

        If lVldVol .And. SC5->C5_VOLUME1 == 0
            _lRet := .F.
            FWAlertError("Não é permitido faturar sem informar a quantidade de volumes. Por favor, verifique! ", "Atenção! ")
        EndIf

    EndIf

    // Integração Protheus x VTEX - Atos Data Consultoria
    If ExistBlock("ADM410PVNF")
        _lRet := ExecBlock("ADM410PVNF", .F., .F., _lRet)
    EndIf

Return _lRet
