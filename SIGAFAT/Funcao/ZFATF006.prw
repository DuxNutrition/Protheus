#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} ZFATF006
Atualiza o status do documento na tabela ZAD na opção Estorno de Documento. 
@See 
@type function
@author Jedielson Rodrigues
@since 04/10/2024
@return 
/*/

User function ZFATF006(cChv,cMotRej)

Local aArea := FwGetArea()
Local lRet  := .F.

Default cChv    := " "
Default cMotRej := " "

cChv := AllTrim(cChv)

If EMPTY(cChv)
	Return .F.
Endif

ZAD->(dbSetOrder(1))
If ZAD->(dbSeek(cChv))
	lRet:= .T.

	RecLock('ZAD',.F.)
	ZAD->ZAD_STATUS := "3"
	ZAD->ZAD_OBS    := cMotRej
	ZAD->(msUnlock())
Endif

RestArea(aArea)

Return lRet
