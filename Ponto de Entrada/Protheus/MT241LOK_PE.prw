#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT241LOK
Ap�s a confirma��o da digita��o da linha, antes da grava��o, 
deve ser utilizado como valida��o complementar desta. 
Este ponto de entrada somente ser� executado se a linha da getdados for validada pela fun��o A241LinOk.
@type Function
@version 12.1.23
@author Jedielson Rodrigues
@since 05/09/2024
@version 12.1.2310
@database MSSQL
@See 
/*/
User Function MT241LOK()

Local lRet 	    := .T.
Local n_PosLOC	:= ASCAN(aHeader,{|x|Alltrim(x[2])=="D3_LOCAL"})
Local clocal    := aCols[n][n_PosLOC]
Local cArm      := SuperGetMv("DUX_EST006",.F.,"ME01")
Local cUser     := SuperGetMv("DUX_EST007",.F.,"000743")

If FwIsInCallStack("MATA241") .AND. FwIsInCallStack("A241LinOk")
    If !__cUserID $ cUser .AND. clocal $ cArm
        FWAlertWarning("Usuario nao tem acesso para movimentar produtos do armazem "+clocal+" .!", "Aten��o [ MT241LOK ]")
        lRet := .F.
    Endif 
Endif

Return (lRet)
