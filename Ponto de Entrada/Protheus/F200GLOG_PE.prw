#Include 'Protheus.ch'

/*/{Protheus.doc} F200GLOG
Ponto de entrada para informar se será gravado as tabelas de LOG de CNAB para todos processados ou somente para as baixas efetivadas.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 20/08/2024
@return logical, Retorna .T. ou .F.
/*/
User Function F200GLOG()

Local cBancoVal := "033|637"
Local lRet      := .T.

If AllTrim(SE1->E1_PORTADO) $ cBancoVal

    cUpdate := " "
    cUpdate := " UPDATE " + RetSqlName("FI0")                          + CRLF
    cUpdate	+= " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "     + CRLF
    cUpdate += " WHERE FI0_FILIAL = '" + FWxFilial("FI0") + "'"        + CRLF    
    cUpdate += " AND FI0_IDARQ = '" + AllTrim(FI0->FI0_IDARQ) + "'"    + CRLF
    cUpdate += " AND D_E_L_E_T_ = ' ' "                                + CRLF

    If TcSqlExec(cUpdate) < 0
        lRet := .F.
        Help( ,, "Dux",, TcSqlError() , 1, 0)
        Disarmtransaction()
    EndIf

    cUpdate := " "
    cUpdate := " UPDATE " + RetSqlName("FI1")                          + CRLF
    cUpdate	+= " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "     + CRLF
    cUpdate += " WHERE FI1_FILIAL = '" + FWxFilial("FI1") + "'"        + CRLF    
    cUpdate += " AND FI1_IDARQ = '" + AllTrim(FI0->FI0_IDARQ) + "'"    + CRLF
    cUpdate += " AND D_E_L_E_T_ = ' ' "                                + CRLF

    If TcSqlExec(cUpdate) < 0
        lRet := .F.
        Help( ,, "Dux",, TcSqlError() , 1, 0)
        Disarmtransaction()
    EndIf
EndIf

Return(lRet)
