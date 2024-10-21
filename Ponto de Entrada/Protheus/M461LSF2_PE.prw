#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"


/*/{Protheus.doc} M461LSF2
Está localizado na rotina de gravação da nota fiscal, é executado após a gravação dos dados da nota possibilitando alterar dados da tabela SF2.
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6784206
@since 21/10/2024
/*/
User Function M461LSF2()

    //Customização com variavel private para alteração de EMISSAO ZFATF008
    If FWIsInCallStack("U_ZFATF008")
        SF2->F2_EMISSAO := _DxFtC
        SF2->F2_EMINFE  := _DxFtC
        SF2->F2_CHVNFE  := _DxChv
        SF2->F2_FIMP    := "S"
    EndIf 

Return()
