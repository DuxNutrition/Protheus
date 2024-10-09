#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} FATF006
Atualiza o status do documento na tabela ZAD na opção Estorno de Documento. 
@See 
@type function
@author Jedielson Rodrigues
@since 04/10/2024
@return 
/*/

User function FATF006(cChv)

Local aArea := FwGetArea()
Local lRet  := .F.

Default cChv := " "

cChv := AllTrim(cChv)

If EMPTY(cChv)
	Return .F.
Endif

ZAD->(dbSetOrder(1))
If ZAD->(dbSeek(cChv))
	lRet:= .T.

	RecLock('ZAD',.F.)
	ZAD->ZAD_STATUS := "3"
	ZAD->(msUnlock())
Endif

RestArea(aArea)

Return lRet
