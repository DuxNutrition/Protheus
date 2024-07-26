#include 'Protheus.ch'

/*/{Protheus.doc} FA290OK
Ponto de entrada que permite incluir validações de usuário na rotina Faturas a Pagar (FINA290).
@type function
@version 12.1.2310 
@author Dux | Evandro Mariano
@since 25/07/2024
@return logical, .T.
@link	https://tdninterno.totvs.com/pages/releaseview.action?pageId=653409728
@obs
/*/
User Function FA290OK()

Local _lRet := .T.

cFatura := Upper(cFatura)
    
Return(_lRet)
