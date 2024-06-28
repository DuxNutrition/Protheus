
#INCLUDE 	"TOTVS.CH"

/*
=====================================================================================
Programa.:              DuxRtVLQ
Autor....:              Atos
Data.....:              Não Há
Descricao / Objetivo:   Não Há
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

USER Function DuxRtVLQ(ADADOS,_ACABEC)

Local cModRef := ALLTRIM(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("DESCRIPTION"))})])
Local cValor := "0"

iF cModRef == "shipping" .or. cModRef == "SHIPPING"
    cValor := ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("SHIPPING_FEE_AMOUNT"))})] //SHIPPING_FEE_AMOUNT
Else
    cValor := Iif(U_RETMOTBX("DESCRIPTION") == "EST",cValToChar(Val(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("NET_DEBIT_AMOUNT"))})])*(-1)),ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("NET_CREDIT_AMOUNT"))})])
Endif

Return(cValor)
