#INCLUDE "Protheus.ch"
#INCLUDE "Totvs.Ch"
#INCLUDE "PRTOPDEF.ch"

//--------------------------------------------------------------
/*/{Protheus.doc} 
Função para envio de email.
@author Equipe de Desenvolvimento. 
@since 24/06/2024
@history 
@version P11,P12
@database MSSQL

/*/

User Function ZGENMAIL(cSubject,cMensagem,cEMail,aFiles,lMensagem,cRotina)

Local lEnvioOK 		:= .F.	// Variavel que verifica se foi conectado OK
Local lMailAuth		:= SuperGetMv("MV_RELAUTH",,.F.)
Local cMailServer	:= SuperGetMv("MV_RELSERV",, "")
Local cMailConta	:= SuperGetMV("MV_RELACNT",, "")
Local cMailSenha	:= SuperGetMV("MV_RELPSW" ,, "")
Local lUseSSL		:= SuperGetMV("MV_RELSSL" ,,.F.)
Local lUseTLS		:= SuperGetMV("MV_RELTLS" ,,.F.)
Local oMail			:= NIL
Local nErro			:= 0
Local nArqErro		:= 0
Local cMsgErro		:= ""
Local cUsuario		:= SubStr(cMailConta,1,At("@",cMailConta)-1)
Local cFrom         := SuperGetMV("MV_RELFROM",,"" )
Local oMessage		:= NIL
Local nPort			:= 0
Local nAt			:= 0
Local cServer		:= " "
Local nX			:= 0 

DEFAULT aFiles 		:= {}
DEFAULT lMensagem 	:= .T.
DEFAULT lErroFile   := .F.

//Em servidores linux, é necessário que os arquivos estejam em caracteres minusculos
If GetSrvInfo()[2] == "Linux"
    For nX := 1 to len(aFiles)
        aFiles[nx] := Lower(aFiles[nX]) 
	Next nX
EndIf 

If Empty(cFrom)
	If At("@",cMailConta) > 0
		cFrom := cMailConta
	Else
		//MsgAlert( OemToAnsi( STR0024 ) )
		Return Nil
	EndIf
EndIf

If (!Empty(cMailServer)) .AND. (!Empty(cMailConta)) .AND. (!Empty(cMailSenha))

	oMessage := TMailMessage():New()
		
	//Limpa o objeto
	oMessage:Clear()
	
	//Popula com os dados de envio
	oMessage:cFrom 		:= cFrom
	oMessage:cTo 		:= cEmail
	oMessage:cCc 		:= ""
	oMessage:cBcc 		:= ""
	oMessage:cSubject 	:= cSubject
	oMessage:cBody 		:= GetxBody(cMensagem,cRotina,cSubject)

	For nX :=1 to Len(aFiles)  
		If File(aFiles[nX])

			nArqErro := oMessage:AttachFile( aFiles[nX] )
		Else
			If (nArqErro < 0) 
				If lMensagem .AND. !Isblind() 
						Aviso("[ZGENMAIL] - Aviso","Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})	
				Else
						Conout("[ZGENMAIL] - Falha no envio do e-mail. Erro retornado:") //"Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"}) 	
				EndIf
				lErroFile	:= .T.
				Exit
			EndIf
		Endif
	Next
	
	oMail	:= TMailManager():New()
	oMail:SetUseSSL(lUseSSL)
	oMail:SetUseTLS(lUseTLS)
	nAt	:=  At(':' , cMailServer)
	
	// Para autenticacao, a porta deve ser enviada como parametro[nSmtpPort] na chamada do método oMail:Init().
	// A documentacao de TMailManager pode ser consultada por aqui : http://tdn.totvs.com/x/moJXBQ
	If ( nAt > 0 )
		cServer		:= SubStr(cMailServer , 1 , (nAt - 1) )
		nPort		:= Val(AllTrim(SubStr(cMailServer , (nAt + 1) , Len(cMailServer) )) )
	Else
		cServer		:= cMailServer
	EndIf
	
	oMail:Init("", cServer, cMailConta, cMailSenha , 0 , nPort)	
	//Init( < cMailServer >, < cSmtpServer >, < cAccount >, < cPassword >, [ nMailPort ], [ nSmtpPort ] )
	
	nErro := oMail:SMTPConnect()
		
	If ( nErro == 0 )

		If lMailAuth

			// try with account and pass
			nErro := oMail:SMTPAuth(cMailConta, cMailSenha)
			If nErro != 0
				// try with user and pass
				nErro := oMail:SMTPAuth(cUsuario, cMailSenha)
				If nErro != 0
				    If lMensagem .AND. !Isblind() 
						Aviso("[ZGENMAIL] - Atencao","Falha na conexão com servidor de e-mail" + CHR(13) + oMail:GetErrorString(nErro) ,{"Ok"})	
					Else
						Conout("[ZGENMAIL] - Falha na conexão com servidor de e-mail") //"Atencao"###"Falha na conexão com servidor de e-mail"	
					EndIf
					Return Nil
				EndIf
			EndIf
		Endif
		
		If !lErroFile
			//Envia o e-mail
			nErro := oMessage:Send( oMail )
			
			If !(nErro == 0)
				cMsgErro := oMail:GetErrorString(nErro)
				If lMensagem .AND. !Isblind() 
						Aviso("[ZGENMAIL] - Aviso","Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})	
				Else
						Conout("[ZGENMAIL] - Falha no envio do e-mail. Erro retornado:") //"Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})
				EndIf
			Else
				lEnvioOk	:= .T.
			EndIf
		EndIf

		//Desconecta do servidor
		oMail:SmtpDisconnect()
		
	Else
	
		cMsgErro := oMail:GetErrorString(nErro)
		If lMensagem .AND. !Isblind() 
			Aviso("[ZGENMAIL] - Atencao","Falha na conexão com servidor de e-mail " + CHR(13) + cMsgErro,{"OK"})	
		Else
			Conout("[ZGENMAIL] - Falha na conexão com servidor de e-mail") //"Atencao"###"Falha na conexão com servidor de e-mail"
		EndIf
		
	EndIf
	
Else

	If ( Empty(cMailServer) )
		If lMensagem .AND. !Isblind() 
			Aviso("[ZGENMAIL] - Atencao","O Servidor de SMTP nao foi configurado !!!" + CHR(13),{"Ok"})	
		Else
			Conout("[ZGENMAIL] - O Servidor de SMTP nao foi configurado !!!") 
		EndIf
		//Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
	EndIf

	If ( Empty(cMailConta) )
		If lMensagem .AND. !Isblind() 
			Aviso("[ZGENMAIL] - Atencao","A Conta do email nao foi configurado !!!" + CHR(13),{"Ok"})	
		Else
			Conout("[ZGENMAIL] - A Conta do email nao foi configurado !!!") 
		EndIf
		//Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
	EndIf
	
	If Empty(cMailSenha)
		If lMensagem .AND. !Isblind() 
			Aviso("[ZGENMAIL] - Atencao","A Senha do email nao foi configurado !!!" + CHR(13),{"Ok"})	
		Else
			Conout("[ZGENMAIL] - A Senha do email nao foi configurado !!!") 
		EndIf
		//Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
	EndIf
	
EndIf

Return( lEnvioOK )

Static Function GetxBody(cMensagem,cRotina,cSubject)
	Local cRet  	:= " "
	Local cData 	:= Transform(dDataBase, "@D 99/99/9999")
	Local cDescFil	:= FwFilialName()

	cRet += '<table width="100%" bgcolor="#cccccc">'
	cRet += '<tbody>'
	cRet += '<tr>'
	cRet += '<td colspan="2">'
	cRet += '<table width="100%" bgcolor="#FFFFFF">'
	cRet += '<tbody>'
	cRet += '<tr>'
	cRet += '<td>'
	cRet += '<br>'
	cRet += '<h1 style="text-align: center;"><strong><img style="float: left;" src="https://guide.duxnutrition.com/hc/theming_assets/01HZPQ6DRTKWFEKNNCNFA21XNK" alt="" width="150" height="050" />
	cRet += ' '+cSubject+' '
	cRet += '</strong></h1>'
	cRet += '<br>'
	cRet += '<center> '
	cRet += '<table border="1" width="1000" cellspacing="0" cellpadding="2">
	cRet += '<tbody>'
	cRet += '<tr>'
	cRet += '<td width="34%"><strong>Empresa/Filial: </strong>
	cRet += ' '+cEmpAnt+'/'+cFilAnt+' '
	cRet += '</td>'
	cRet += '<td width="33%"><strong>Razao Social: </strong>Dux Company Ltda</td>'
	cRet += '<td width="33%"><strong>Nome da Filial: </strong>'+cDescFil+'</td>'
	cRet += '</tr>'
	cRet += '</tbody>'
	cRet += '</table>'
	cRet += '<table border="1" width="1000" cellspacing="0" cellpadding="2">'
	cRet += '<tbody>'
	cRet += '<tr>'
	cRet += '<td width="34%"><strong>Data: </strong>'+cData+'</td>'
	cRet += '<td width="33%"><strong>Hora: </strong>'+Time()+'</td>'
	cRet += '<td width="33%"><strong>Rotina: </strong>' +cRotina+ '</td>'
	cRet += '</tr>'
	cRet += '</tbody>'
	cRet += '</table>'
	cRet += '</center> '
	cRet += '<p style="text-align: center;">
	cRet += '<center> '
	cRet += ''+cMensagem+' ' 
	cRet += '</center> '
	cRet += '</p>'
	cRet += '</td>'
	cRet += '</tr>'
	cRet += '<tr>'
	cRet += '<td>&nbsp;</td>'
	cRet += '</tr>'
	cRet += '</tbody>'
	cRet += '</table>'
	cRet += '</td>'
	cRet += '</tr>'
	cRet += '<tr>'
	cRet += '</center> '
	cRet += '<td colspan="2"><center>'
	cRet += '<p><strong><img src="https://guide.duxnutrition.com/hc/theming_assets/01HZPQ6DRTKWFEKNNCNFA21XNK" alt="" width="185" height="76" /></strong></p>
	cRet += '<br />Uma mensagem gerada automaticamente pelo sistema, portanto nao pode ser respondida. <br />Em caso de duvidas ou sugestoes, por favor, entre em contato com o suporte tecnico.</center></td>'
	cRet += '</tr>'
	cRet += '<tr>'
	cRet += '<td colspan="2"><center>Rotina: ' +cRotina+ '</center></td>'
	cRet += '</tr>'
	cRet += '</tbody>'
	cRet += '</table>'

Return(cRet)









