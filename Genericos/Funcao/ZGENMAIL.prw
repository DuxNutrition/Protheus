#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PRTOPDEF.CH"

/*{Protheus.doc} ZGENMAIL
Função para envio de email.
@author Equipe de Desenvolvimento. 
@since 24/06/2024
@history 
@version 1.0
@database MSSQL
*/

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
	Local cRet  		:= " "
	Local cData 		:= Transform(dDataBase, "@D 99/99/9999")

	Default cMensagem	:= ""
	Default cRotina		:= ""
	Default cSubject	:= ""
	
	cRet += '<html> '
	cRet += '<head> '
    cRet += '	<meta charset="utf-8"> '
    cRet += '	<title>Dux</title> '
    cRet += '	<style> '
    cRet += '    	hr { '
    cRet += '    	display: block; '
    cRet += '    	margin-block-start: 1em; '
    cRet += '    	margin-block-end: 1em; '
    cRet += '    	margin-inline-start: auto; '
    cRet += '    	margin-inline-end: auto; '
    cRet += '    	unicode-bidi: isolate; '
    cRet += '    	overflow: hidden; '
    cRet += '    	border-style: inset; '
    cRet += '    	border-width: 1px; } '
    cRet += '	</style> ' 
	cRet += '</head> '
	cRet += '<header> '
    cRet += '	<center> '
    cRet += '		<div style="overflow:hidden"><img src="https://i.postimg.cc/xT050ksV/DUX-COMPANY-LOGO-HORIZONTAL-AZUL.png" alt="image" width="480" height="130" data-image-whitelisted="" class="CToWUd" data-bit="iit"></div> '
    cRet += '	</center> '
	cRet += '</header> '
	cRet += '<body> '
    cRet += '<br> '
    cRet += '	<center> '
    cRet += '		<div style="margin-left: -200px;"> '
    cRet += '		<table cellspacing="0" cellpadding="0" border="0"> '
    cRet += '<tbody> '
    cRet += '<tr> '
    cRet += '	<td> '
    cRet += '		<p class="DescrMsgDocto"><b><i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Data: <i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:sans-serif"> '+cData+'</span></span></i></b> </p> '            
    cRet += '	</td> '
    cRet += '</tr> '
    cRet += '<tr> '
    cRet += '	<td> '
    cRet += '		<p class="DescrMsgDocto"><b><i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Horário: <i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:sans-serif"> '+Time()+'</span></span></i></b> </p> '
    cRet += '	</td> '
    cRet +=	'</tr> '
    cRet +=	'<tr> '
    cRet +=	'	<td> '
    cRet +=	'		<p class="DescrMsgDocto"><b><i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Função: <i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:sans-serif"> '+cRotina+'</span></span></i></b> </p> '
    cRet +=	'	</td> '
    cRet +=	'</tr> '
    cRet +=	'<tr> '
    cRet +=	'	<td> '
    cRet +=	'		<p class="DescrMsgDocto"><b><i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Assunto: <i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:sans-serif"> '+cSubject+'</span></span></i></b> </p> '
    cRet +=	'   </td> '
    cRet +=	'</tr> '
	If !Empty(cMensagem)
		cRet +=	'<tr> '
    	cRet +=	'	<td> '
    	cRet +=	'		<p class="DescrMsgDocto"><b><i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Mensagem: <i style="color:rgb(83, 83, 83);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:sans-serif"> '+cMensagem+'</span></span></i></b> </p> '
    	cRet +=	'   </td> '
    	cRet +=	'</tr> '
	EndIf
    cRet +=	'</tbody> '
    cRet +=	'</table> '
    cRet +=	'</div> '
    cRet +=	'<br> '
    cRet +=	'<div><i style="color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Anexo arquivo referente ao processamento da rotina.</span></i><div class="yj6qo"></div><div class="adL"><br></div></div> '    
    cRet +=	'    <div><hr></div> '
    cRet +=	'    <br> '
    cRet +=	'    <div> '
    cRet +=	'        <table cellspacing="0" cellpadding="0" border="0"> '
    cRet +=	'            <tbody> '
    cRet +=	'               <td width="100%" align="center" style="word-break:break-word"><div style="text-align:center"><a href="https://www.linkedin.com/company/dux-nutrition/" style="width:32px;height:32px;margin:6px;background-color:rgb(95,99,104);background-image:linear-gradient(rgb(95,99,104),rgb(95,99,104));border-radius:50%;box-sizing:content-box;overflow:hidden;display:inline-block;vertical-align:middle;line-height:0;font-size:10pt" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://www.linkedin.com/company/dux-nutrition/&amp;source=gmail&amp;ust=1721320038955000&amp;usg=AOvVaw2mgnkzUFS-5HrWoSW42J8n"><img src="https://ci3.googleusercontent.com/meips/ADKq_NYi_nox4WQXhJWN_yfG0NP46Rr7DIg58kXNx-RfPaFnOHsfcS_OlEp_OA9c_4UWr3KnSoOresUF_Ml_yYFcTvhZTHZrVWdt_10q2a1PK9pcT5m4Yijx-v75nyJuuaE=s0-d-e1-ft#https://ssl.gstatic.com/atari/images/sociallinks/linkedin_white_28dp.png" alt="LinkedIn" style="width:28px;height:28px;margin:2px;box-sizing:content-box;border:0px" width="28" height="28" class="CToWUd" data-bit="iit"></a><a href="https://www.instagram.com/duxnutritionlab" style="width:32px;height:32px;margin:6px;background-color:rgb(95,99,104);background-image:linear-gradient(rgb(95,99,104),rgb(95,99,104));border-radius:50%;box-sizing:content-box;overflow:hidden;display:inline-block;vertical-align:middle;line-height:0;font-size:10pt" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://www.instagram.com/duxnutritionlab&amp;source=gmail&amp;ust=1721320038955000&amp;usg=AOvVaw3uBMSv3dDpo7GcnrDqooJQ"><img src="https://ci3.googleusercontent.com/meips/ADKq_NaBSA_ecptkKAamT1SHxyS_6XlIWdZH5WeryJA3PZ0gEdkakp1VVVz1P6JE49NaF_eMySEIFruruDFnWoIGvhLCZ1qjDvDCdGWZovJ9opzdmp1gq2cp2BaSaveqZbz4=s0-d-e1-ft#https://ssl.gstatic.com/atari/images/sociallinks/instagram_white_28dp.png" alt="Instagram" style="width:28px;height:28px;margin:2px;box-sizing:content-box;border:0px" width="28" height="28" class="CToWUd" data-bit="iit"></a><a href="https://www.facebook.com/duxnutritionlab/?locale=pt_BR" style="width:32px;height:32px;margin:6px;background-color:rgb(95,99,104);background-image:linear-gradient(rgb(95,99,104),rgb(95,99,104));border-radius:50%;box-sizing:content-box;overflow:hidden;display:inline-block;vertical-align:middle;line-height:0;font-size:10pt" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://www.facebook.com/duxnutritionlab/?locale%3Dpt_BR&amp;source=gmail&amp;ust=1721320038955000&amp;usg=AOvVaw3Qato0oJstyv2UGO5Qh1fY"><img src="https://ci3.googleusercontent.com/meips/ADKq_NY37bb0x-Cffk0bQ_x_3I4LCQkATt-R30zlBNH5aImA9JVH6A5XIqK8Mn97QA4xulOeHggtHdvXxwqDBayAeXHR0biksIubJ-TmnQiW64RB0arKZ4YkXAccz7gygvg=s0-d-e1-ft#https://ssl.gstatic.com/atari/images/sociallinks/facebook_white_28dp.png" alt="Facebook" style="width:28px;height:28px;margin:2px;box-sizing:content-box;border:0px" width="28" height="28" class="CToWUd" data-bit="iit"></a></div></td> '
    cRet +=	'            </tbody> '
    cRet +=	'        </table> '
    cRet +=	'    </div> '
    cRet +=	'    <br> '
    cRet +=	'    <div><i style="color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Canal de Escuta (de 2a a 6a, das 9h às 18h, exceto feriados): 0800 887 0880, ou a qualquer hora pela internet.</span></i><div class="yj6qo"></div><div class="adL"><br></div></div> '
    cRet +=	'    <div><i style="color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">Chamados pelo Zendesk para TI, RBO, SAC, facilities e jurídico - ou procure o RBO pelo WhatsApp</span></i><div class="yj6qo"></div><div class="adL"><br></div></div> '
    cRet +=	'    <br> '
    cRet +=	'    <div class="col-xs-12 col-sm-4"> '
    cRet +=	'        <div style="overflow:hidden" width="625" height="89" ><img src="https://i.postimg.cc/NM68tYm0/rodape.jpg" alt="image" style="height:auto;display:block;width:50%;border:0px" width="625" height="89" data-image-whitelisted="" class="CToWUd" data-bit="iit"></div>
    cRet +=	'    </div> '
    cRet +=	'    <br> '
    cRet +=	'    <div><hr></div> '
    cRet +=	'    <div><i style="color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">O conteúdo desta mensagem contém informações de caráter confidencial, protegidas por lei. Se você não é a pessoa autorizada a receber esta mensagem, por favor elimine-a e avise o remetente imediatamente. </span></i><div class="yj6qo"></div><div class="adL"><br></div></div> '
    cRet +=	'    <div><i style="color:rgb(34,34,34);font-family:Arial,Helvetica,sans-serif;font-size:small"><span lang="EN-US" style="font-family:Verdana,sans-serif">The content of this message contains confidential information that is privileged under applicable laws. If you are not the authorized recipient of this message, please delete it and warn the sender immediately.</span></i><div class="yj6qo"></div><div class="adL"><br></div></div> '
    cRet +=	'</center> '
	cRet +=	'</body> '

Return(cRet)









