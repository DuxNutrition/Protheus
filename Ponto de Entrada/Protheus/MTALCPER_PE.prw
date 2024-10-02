#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} MTALCPER
	O ponto de entrada MTALCPER permite utilizar o controle de al�adas de forma customizada em documentos que n�o controlam al�ada por padr�o. 

	@See https://tdn.totvs.com/pages/releaseview.action?pageId=268571093
	@type function
  	@author 
  	@since 17/11/2021
  	@return aAlc
/*/
 
User function MTALCPER()

Local aAlc     := {}
Local cDoc     := "Z1"
Local aArea    := FwGetArea()
Local aAreaSCR := SCR->(FwGetArea())

If SCR->CR_TIPO == cDoc
    aAdd(aAlc,{SCR->CR_TIPO,'ZAD',1,'ZAD->ZAD_CONTRA','','',{'ZAD->ZAD_STATUS',"2","1","3"}})
Endif

FWRestArea(aArea)
FWRestArea(aAreaSCR)

Return(aAlc)
