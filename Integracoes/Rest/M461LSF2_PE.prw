#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

user function M461LSF2()

//���������������������������������������������������������������������������Ŀ
//� Customiza��o com variavel private para altera��o de EMISSAO ZFATF008       �
//�����������������������������������������������������������������������������
    if FWIsInCallStack("U_ZFATF008")
        SF2->F2_EMISSAO := _DxFtC
        SF2->F2_EMINFE  := _DxFtC
        SF2->F2_CHVNFE  := _DxChv
        SF2->F2_FIMP    := "S"
    endif 

return
