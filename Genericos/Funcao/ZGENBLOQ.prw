#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*/{Protheus.doc} ZGENBLOQ
Valida se o usuário pode acessar a rotina.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 05/09/2024
@param cParam01, character, usuario
@param cParam02, character, rotina
@param cParam03, character, mensagem
@return logical, .T. or .F.
/*/
User Function ZGENBLOQ(cParam01,cParam02,cParam03)

Local cUser     := cParam01
Local cRotina   := cParam02
Local lMsg      := cParam03
Local lRet      := .T.
Local cMaster   := "**********" 
Local lMaster   := .F.

Default lMsg := .F.

/*Exemplo de chamada              
lUserAut := U_ZGENBLOQ( RetCodUsr() ,; //Cod do usuário
                        "ZMSBLQUSR" ,; //Rotina
                        	,.T.)   ,; // .F. não mostra .T. mostra
*/

DbSelectArea("SZX")
SZX->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA

//Verifica se usuário tem acesso master
// Então ele estará sempre liberado.
If SZX->( dbSeek( xFilial("SZX") + cUser + cMaster ))
	If SZX->ZX_ACESSO == "B"
		If lMsg
            ApMsgStop("Usuário Master Bloqueado."+ CRLF + CRLF + "Verifique o motivo do bloqueio, entre em contato com seu superior.","ZGENUSER")
            lRet := .F.
        EndIf
    EndIf
    If SZX->ZX_ACESSO == "N"
        If lMsg    
            ApMsgStop("Usuário Master Sem Acesso as Rotinas."+ CRLF + CRLF + "Verifique o motivo da falta de acesso e entre em contato com seu superior.","ZGENUSER")
            lRet := .F.
        EndIf
    EndIf
    lMaster := .T.
EndIf

//Se usuário é Master|FULL valida completo.
If !(lMaster)
    If SZX->( DbSeek( xFilial("SZX") + cUser + UPPER(Alltrim(cRotina)) ))
        
        //Verifica usuário com acesso Bloqueado
		If SZX->ZX_ACESSO == "B"
			If lMsg
                ApMsgStop("Usuário Bloqueado para utilizar essa rotina.( " + cRotina + " )"+ CRLF + CRLF + "Verifique o motivo do bloqueio e entre em contato com seu superior.","ZGENUSER")
			EndIf
			lRet := .F.
        EndIf
        
        //Verifica usuário sem acesso.
        If SZX->ZX_ACESSO == "N"
			If lMsg
                ApMsgStop("Usuário Sem Acesso para utilizar essa rotina.( " + cRotina + " )"+ CRLF + CRLF + "Verifique o motivo da falta de acesso e entre em contato com seu superior.","ZGENUSER")
			EndIf
			lRet := .F.
        EndIf
        
        //Verifica usuário com acesso temporario.
        If SZX->ZX_ACESSO == "T"
            If !( Date() >= SZX->ZX_DTAUTDE )
                If lMsg
                    ApMsgStop(" **** Acesso temporário ****" + CRLF + "De:  " + DToC(SZX->ZX_DTAUTDE) + CRLF + "Até: " + DToC(SZX->ZX_DTAUTAT) + CRLF + CRLF + "Acesso Temporário não habilitado para a data atual, verifique o acesso para utilizar essa rotina.( " + cRotina + " )" + CRLF + CRLF + "Data Atual: " + DToC( Date() ),"ZGENUSER" )
                EndIf                                                 
                lRet := .F.
            EndIf
            If !( Date() <= SZX->ZX_DTAUTAT )
                If lMsg
                    ApMsgStop(" **** Acesso temporário ****" + CRLF + "De:  " + DToC(SZX->ZX_DTAUTDE) + CRLF + "Até: " + DToC(SZX->ZX_DTAUTAT) + CRLF + CRLF + "Acesso Temporário não habilitado para a data atual, verifique o acesso para utilizar essa rotina.( " + cRotina + " )" + CRLF + CRLF + "Data Atual: " + DToC( Date() ),"ZGENUSER" )
                EndIf
                lRet := .F.
            EndIf
        EndIf
	Else
		If lMsg
			ApMsgStop("Usuário não possui acesso para utilizar essa rotina.( " + cRotina + " )"+ CRLF + CRLF + "Verifique o motivo da falta de acesso e entre em contato com seu superior.","ZGENUSER")
		EndIf
		lRet := .F.
	EndIf
EndIf

Return(lRet)
