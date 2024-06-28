#include "TOTVS.CH"
#Include "TOPCONN.CH"
#include "protheus.ch"

/*/{Protheus.doc} F240FIL

F240FIL - Acrescenta filtro na seleção de títulos para borderôs de pagamento
@type function
@author TOTVS IP
@since 11/12/2023

/*/

User Function F240FIL()
 
cRet := "E2_FORMPAG == '" + cModPgto + "'"
 
Return cRet
