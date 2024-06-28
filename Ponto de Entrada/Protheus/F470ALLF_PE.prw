/*/ F470ALLF
No relatorio extrato bancario, mostra todas filiais ou nao.
Data: 28/03/2023
Mauricio Duarte
/*/

#include "rwmake.ch"
#Include "Totvs.ch"

User Function F470ALLF()
    Local aArea := GetArea()
    Local lRet  := MsgYesNo("Considera todas as filiais?", "Atenção")
     
    RestArea(aArea)
Return lRet