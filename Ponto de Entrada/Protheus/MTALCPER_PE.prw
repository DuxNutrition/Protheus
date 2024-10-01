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

Local aAlc := {}
Local cDoc := "CT"

    aAdd(aAlc,{ cDoc, 'ZAD', 3, 'ZAD->ZAD_CONTRA','','',{'ZAD->ZAD_SITUACA','3',"1","4"}})

Return(aAlc)
