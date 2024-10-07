#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} MTALCPER
O ponto de entrada MTALCPER permite utilizar o controle de al�adas de forma customizada em documentos que n�o controlam al�ada por padr�o. 
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
    aAdd(aAlc,{SCR->CR_TIPO,'ZAD',1,'ZAD->ZAD_CONTRA',{||visuZAD(AllTrim(SCR->(CR_FILIAL+CR_NUM)))},{||U_estZAD(AllTrim(SCR->(CR_FILIAL+CR_NUM)))},{'ZAD->ZAD_STATUS',"2","1","3"}})
Endif

FWRestArea(aArea)
FWRestArea(aAreaSCR)

Return(aAlc)

/*----------------------------------------------------
	Visualiza documento de Aprova��o na tabela ZAD.
----------------------------------------------------*/

Static function visuZAD(cChv)

Local   aArea     := FwGetArea()
Private cTela	  := "Contratos de Bonific�o"
Private cCadastro := "Contratos de Bonific�o"

Default cChv:= ''

ZAD->(dbSetOrder(1))
If ZAD->(dbSeek(cChv))
	AxVisual('ZAD',ZAD->(recno()),4)
Endif

RestArea(aArea)

Return

/*--------------------------------------------------------------------------------
	Atualiza o status do documento na tabela ZAD na op��o Estorno de Documento.
--------------------------------------------------------------------------------*/

User function estZAD(cChv)

Local aArea := FwGetArea()
Local lRet  := .F.

Default cChv := " "

cChv:= AllTrim(cChv)

If EMPTY(cChv)
	Return .F.
Endif

ZAD->(dbSetOrder(1))
If ZAD->(dbSeek(cChv))
	lRet:= .t.

	RecLock('ZAD',.F.)
	ZAD->ZAD_STATUS := "3"
	ZAD->(msUnlock())
Endif

RestArea(aArea)

Return lRet

