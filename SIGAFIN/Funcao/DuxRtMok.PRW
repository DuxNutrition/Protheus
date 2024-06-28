#INCLUDE 	"TOTVS.CH"

/*
=====================================================================================
Programa.:              DuxRtMok
Autor....:              Atos
Data.....:              Não Há
Descricao / Objetivo:   Não Há
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

User Function DuxRtMok(cOrder,ADADOS,_ACABEC)

LOCAL cRet := "A"
LOCAL cTpReg := Iif(U_RETMOTBX("DESCRIPTION") == "NOR",'11','12')
Local cModRef := ALLTRIM(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("DESCRIPTION"))})])
//Local cPSPREF := "MPG-"+ALLTRIM(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("PAYMENT_METHOD"))})])
IF Empty(AllTrim(cOrder))
    cRet := "I"
ElseIf  "RESERVE" $ UPPER(ALLTRIM(cModRef))  .OR. UPPER(ALLTRIM(cModRef))  == "PAYOUT"
     cRet := "I"
ELSE
    If cTpReg == "12"
        cRet := "P"
    ENDIF
ENDIF

return(cRet)
