#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

user function M461LSF2()

//���������������������������������������������������������������������������Ŀ
//� Customiza��o com variavel private para altera��o de EMISSAO DUXFATB       �
//�����������������������������������������������������������������������������
    if FWIsInCallStack("U_DuxFatB")
        SF2->F2_EMISSAO := _DxFtC
    endif 

return
