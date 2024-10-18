#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

user function M461LSF2()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Customiza豫o com variavel private para altera豫o de EMISSAO ZFATF008       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    if FWIsInCallStack("U_ZFATF008")
        SF2->F2_EMISSAO := _DxFtC
        SF2->F2_EMINFE  := _DxFtC
        SF2->F2_CHVNFE  := _DxChv
        SF2->F2_FIMP    := "S"
    endif 

return
