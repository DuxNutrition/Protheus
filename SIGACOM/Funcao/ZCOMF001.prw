#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} 
Fun��o para validar a data de vencimento do t�tulo se � menor que a data atual da
classifica��o do documento de entrada!
@author Jedielson Rodrigues
@since 28/06/2024
@history 
@version P11,P12
@database MSSQL

/*/

User Function ZCOMF001(dDtVencto)

Local _aArea    := GetArea()
Local _lRet     := .T.

If !EMPTY(dDtVencto) .AND. dDtVencto < dDataBase
    _lRet := .F.
Endif 

RestArea(_aArea)

Return (_lRet)


