#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"


/*/{Protheus.doc} M461LSF2
Est� localizado na rotina de grava��o da nota fiscal, � executado ap�s a grava��o dos dados da nota possibilitando alterar dados da tabela SF2.
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6784206
@since 21/10/2024
/*/
User Function M461LSF2()

    //Customiza��o com variavel private para altera��o de EMISSAO ZFATF008
    If FWIsInCallStack("U_ZFATF008")
        SF2->F2_EMISSAO := _DxFtC
        SF2->F2_EMINFE  := _DxFtC
        SF2->F2_CHVNFE  := _DxChv
        SF2->F2_FIMP    := "S"
    EndIf 

Return()
