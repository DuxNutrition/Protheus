#INCLUDE "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"



/*/{Protheus.doc} User Function DUACOM01
    Função para Alterar a Data de Entrega de um Item e Dispar um E-mail
    @type  Function
    @author TOTVS IP/TM
    @since 20/07/2023
    /*/
User Function DUACOM01()
    local cDtEntAntiga  := DTOS(SC7->C7_DATPRF)
    local dDataNova     := cDtEntAntiga

    Private lCancelado  := .F.
    
    //Chama a Parambox para Alteração do Campo
    dDataNova := getParam(cDtEntAntiga)

    if lCancelado
        if dDataNova >= DATE()
            if (!Empty(C7_CONTRA)) .OR. (C7_QUJE >= C7_QUANT) // Valida se o Pedido foi Recebido ou possui Contrato
                Alert("Não é permitido alterar pedido recebido ou de contratos")
            else
                //Altera o Campo
                RecLock("SC7",.F.)
                SC7->C7_DATPRF := dDataNova
                MsUnlock()

                //faz o Envio do Email
                U_ACOM01(cDtEntAntiga)
            endif
        else
            Alert("A nova Data de Entrega não pode ser Retroativa")
        endif
    endif
Return 


/*
    Função para Criar a Parambox
*/
Static Function getParam(cDtEntAntiga)
    Local aPergs    := {}
    Local dDataNova := STOD(cDtEntAntiga)
 
    aAdd(aPergs, {1, "Data de Entrega Atual",  STOD(cDtEntAntiga),  "", ".T.", "", ".F.", 80,  .F.})
    aAdd(aPergs, {1, "Data de Entrega Nova", dDataNova,  "", ".T.", "", ".T.", 80,  .T.})

    lCancelado := ParamBox(aPergs, "Informe os parâmetros")
    If lCancelado
        dDataNova := MV_PAR02
    EndIf

Return dDataNova


/*
    Envio de E-mail de Notificação de Alteração de Data de Entrega
*/
USER Function ACOM01(cDtEntAntiga)
	Local xRet
	Local oServer, oMessage

    //Variaveis com os Parametros
	Local lMailAuth	    := SuperGetMv("MV_RELAUTH",,.F.)
	Local cMailDest	    := SuperGetMv("ZZ_MAILALT",,"pcp@duxnutrition.com,compras@duxnutrition.com") //Parametro com os E-mails para Envio Separados por , 
    Local lUseSSL	    := GetMV("MV_RELSSL")
    Local lUseTLS	    := GetMV("MV_RELTLS")	
    Local nSMTPTime     := GetMV("MV_RELTIME")
    Local cRemetente    := Getmv("MV_RELFROM")
    Local cMailConta	:= NIL
	local cMailServer	:= NIL
	local cMailSenha	:= NIL
	Local nPorta        := 587  //informa a porta que o servidor SMTP irá se comunicar, podendo ser 25 ou 587

    //Variaveis da Construcao Mensagem
    Local cAssunto      := ""
    Local cMensagem     := ""
    Local cDtDe         := SubStr(cDtEntAntiga,7,2) + "/" + SubStr(cDtEntAntiga,5,2) + "/" + SubStr(cDtEntAntiga,1,4)
    Local cDtAte        := SubStr(DTOS(SC7->C7_DATPRF),7,2) + "/" + SubStr(DTOS(SC7->C7_DATPRF),5,2) + "/" + SubStr(DTOS(SC7->C7_DATPRF),1,4)
    Local nPos          := 0
    Local cFornec       := Alltrim(POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE + SC7->C7_LOJA,"A2_NOME"))
    Local cTpProd       := Alltrim(POSICIONE("SB1",1,xFilial("SB1") + SC7->C7_PRODUTO,"B1_TIPO"))

    //Monta o Assunto do E-mail
    cAssunto  := " PC " + SC7->C7_NUM + " | [" + cTpProd + "] " + Alltrim(SC7->C7_DESCRI) + " | " + cFornec + " - DATA DE ENTREGA ALTERADA"

    //Monta o Corpo do E-mail
    cMensagem := "Data de entrega alterada para o item abaixo:
    cMensagem += "<br><b>Empresa/Filial:</b> " + cEmpAnt + "/" +  cFilAnt + " - " + FwFilialName( cEmpAnt, cFilAnt, 1) + CRLF 
    cMensagem += "<br><b>Pedido de Compra:</b> " + SC7->C7_NUM + CRLF 
    cMensagem += "<br><b>Item:</b> " + SC7->C7_ITEM + CRLF
    cMensagem += "<br><b>Fornecedor:</b> " + SC7->C7_FORNECE + " - " + SC7->C7_LOJA  + " - " + cFornec + CRLF
    cMensagem += "<br><b>Código do Produto:</b> " + SC7->C7_PRODUTO + CRLF
    cMensagem += "<br><b>Descrição:</b> " + SC7->C7_DESCRI + CRLF
    cMensagem += "<br><b>Data de entrega alterada:</b> de <b>" + cDtDe + "</b> para <b>" + cDtAte + "</b>."
    cMensagem += "<br><b>Alterado Por:</b> " + UsrFullName(RetCodUsr())
			
    //Recebe os Parametros de Conexão ao Servidor SMTP
	cMailConta  := (GETMV("MV_RELACNT"))  //Conta de Autenticacao e Conexão
	cMailServer := GETMV("MV_RELSERV")   //Endereço do Servidor SMTP
	cMailSenha  := GETMV("MV_RELPSW")    //Senha para Autenticacao e Conexao
	
    if (nPos := AT(':',cMailServer)) > 0
		nPorta 		:= Val(Substr(cMailServer, nPos + 1,Len(cMailServer)))
		cMailServer := Substr(cMailServer, 0, nPos - 1)
	endIf

	//Cria a Classe para Conexão no Servidor SMTP
	oServer := tMailManager():New()
    oServer:setUseSSL(lUseSSL) //Usa SSL na conexao
	oServer:SetUseTLS(lUseTLS) //Usa TLS na conexao
   
    //inicilizar o servidor
    xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta )
	if xRet != 0
		alert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		return
	endif
    
     //Indica o tempo de espera em segundos.
	if oServer:SetSMTPTimeout(nSMTPTime) != 0
		alert("Não foi possível definir " + cProtocol + " tempo limite")
	endif
   
    //Prepara a Conexão com o Servidor de E-mail
	if oServer:SMTPConnect() <> 0
		alert("Não foi possível conectar ao servidor SMTP")
		return
	endif
   
   //Verifica a Autorização do E-mail 
	if lMailAuth
		xRet := oServer:SmtpAuth(cMailConta, cMailSenha)
        if xRet <> 0
			alert("Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ) )
			oServer:SMTPDisconnect()
			return
		endif
   	Endif


    //Cria a Classe dos Dados do E-mail
    oMessage:= TMailMessage():New()
	oMessage:Clear()


    //Prepara os Parametros da Classe de E-mail
	oMessage:cDate	    := cValToChar( Date() )
	oMessage:cFrom 	    := cRemetente
	oMessage:cTo 	    := cMailDest
	oMessage:cSubject   := cAssunto
	oMessage:cBody 	    := cMensagem


    //Faz o Envio do E-mail de Notificação
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
	endif
   
    //Disconecta do Servidor SMTP
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		alert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	endif

return
