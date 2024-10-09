#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} MTALCPER
O ponto de entrada MTALCPER permite utilizar o controle de alçadas de forma customizada em documentos que não controlam alçada por padrão. 
@See https://tdn.totvs.com/pages/releaseview.action?pageId=268571093
@type function
@author Jedielson Rodrigues
@since 04/10/2024
@return aAlc
/*/

User function MTALCPER()

Local aAlc     := {}
Local cDoc     := "Z1"
Local aArea    := FwGetArea()
Local aAreaSCR := SCR->(FwGetArea())

If SCR->CR_TIPO == cDoc
    aAdd(aAlc,{SCR->CR_TIPO,'ZAD',1,'ZAD->ZAD_CONTRA',{||visuZAD(AllTrim(SCR->(CR_FILIAL+CR_NUM)))},{||U_ZFATF006(AllTrim(SCR->(CR_FILIAL+CR_NUM)))},{'ZAD->ZAD_STATUS',,,"3"}})
Endif

FWRestArea(aArea)
FWRestArea(aAreaSCR)

Return(aAlc)

/*----------------------------------------------------
	Visualiza documento de Aprovação na tabela ZAD.
----------------------------------------------------*/

Static function visuZAD(cChv)

Local   aArea     := FwGetArea()
Private cTela	  := "Contratos de Bonificação"
Private cCadastro := "Contratos de Bonificação"

Default cChv := ''

ZAD->(dbSetOrder(1))
If ZAD->(dbSeek(cChv))
	AxVisual('ZAD',ZAD->(recno()),4)
Endif

RestArea(aArea)

Return



