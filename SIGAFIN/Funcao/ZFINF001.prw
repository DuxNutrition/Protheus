    
#include "totvs.ch"

/*/{Protheus.doc} ZFINF001
Rotina para gerar boletos por titulo.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 23/07/2024
@param aTitulos, array, titulos selecionados
@obs GAP008 | Impressao de boleto
/*/
User Function ZFINF001(aTitulos)

	Local oCombo	:= Nil
	Local oCombo2   := Nil
	Local cTipoImp  := " "
	Local cCaminho	:= ""
	Private oDlg    := Nil      // Dialog Principal

    DEFINE MSDIALOG oDlg TITLE "[ ZFINF001 ] - Boleto Dux" FROM C(178),C(160) TO C(490),C(450) PIXEL

    @ C(005),C(006) TO C(140),C(140) LABEL "Preencha os Parametros" PIXEL OF oDlg

    @ C(022),C(020) Say "Imprime por ?:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
    @ C(030),C(020) COMBOBOX oCombo VAR cTipoImp ITEMS {"Parcela","Titulo"} SIZE 100,08  PIXEL OF oDlg
    
	@ C(042),C(020) Say "Salvar PDF ?:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
    @ C(050),C(020) COMBOBOX oCombo2 VAR cCaminho ITEMS {"Local [ C:\BoletosDux\ ]","FTP iRecebi"} SIZE 100,08  PIXEL OF oDlg
        
    DEFINE SBUTTON FROM C(143),C(095) TYPE 6 ENABLE OF oDlg ACTION ( Processa( { || ZFINS001(aTitulos,cTipoImp,cCaminho)} ,"[ ZFINF001 ] - Imprimindo Boleto Dux..." )  ,oDlg:End() )
            
    ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function ZFINS001(aTitulos,cTipoImp,cCaminho)

    Local nI 			:= 0
	Local nX			:= 1
	Local lImprime		:= .F.
	Local lFtp			:= .F.
	Local aBoletos  	:= {}
	Local aPrint  		:= {}
	Local cArquivo 		:= ""
	Local cDiretorio	:= ""
	Local cPrefixo		:= ""
	Local cNumero		:= ""
	Local cParcela		:= ""
	Local cTipo			:= ""
	Local cCliente		:= ""
	Local cLoja			:= ""
	Local cFtpSrv   	:= SuperGetMV("DUX_FIN010", , "app.irecebi.com")
    Local cFtpPor   	:= SuperGetMV("DUX_FIN011", , "22")
    Local cFtpUsr   	:= SuperGetMV("DUX_FIN012", , "dux")
    Local cFTpPss   	:= SuperGetMV("DUX_FIN013", , "dUx6De2i-RU9O3E")
    Local cFtpDir   	:= SuperGetMV("DUX_FIN014", , "/dados/homologacao/")
	Local nPosMark		:= 1
	Local nPosPrefix	:= 2
	Local nPosNum		:= 3
	Local nPosParcel	:= 4
	Local nPosTipo		:= 5
	Local nPosCli		:= 7
	Local nPosLj		:= 8

	Default aTitulos	:= {}
	Default cTipoImp	:= ""
	Default cCaminho	:= ""

	If cCaminho == "Local [ C:\BoletosDux\ ]"
		cDiretorio := "C:\BoletosDux\"
	Else
		cDiretorio := "/boletosirecebi/"
		lFtp := .T.
	EndIf

	If lFtp == .F.
		If !ExistDir( cDiretorio )
			MakeDir( cDiretorio )
			ApMsgInfo("Pasta para salvar o(s) boleto(s) criada com sucesso."+CRLF+"Caminho: "+cCaminho,"[ ZFINF001 ]")
		Endif
	EndIf
	
	For nI := 1 To Len(aTitulos)
		
		If aTitulos[nI,nPosMark] //Adiciona os boletos que foram selecionados no array

			cPrefixo	:= aTitulos[nI, nPosPrefix	]
			cNumero		:= aTitulos[nI, nPosNum		]
			cParcela	:= aTitulos[nI, nPosParcel	]
			cTipo		:= aTitulos[nI, nPosTipo	]
			cCliente	:= aTitulos[nI, nPosCli		]
			cLoja		:= aTitulos[nI, nPosLj		]

			aAdd(aBoletos, {cPrefixo, cNumero, cParcela, cTipo, cCliente, cLoja })
		EndIf

	Next nI

	While nX <= Len(aBoletos)
		
		cNumero 	:= aBoletos[nX, 02]
		cParcela 	:= aBoletos[nX, 03]

		aAdd(aPrint, {	aBoletos[nX, 01],; //Prefixo
						aBoletos[nX, 02],; //Numero
						aBoletos[nX, 03],; //Parcela
						aBoletos[nX, 04],; //Tipo
						aBoletos[nX, 05],; //Cliente
						aBoletos[nX, 06]}) //Loja
		Nx++

		If ( nX > Len(aBoletos) )
			lImprime := .T.
		Else
			If cTipoImp == "Titulo"
				If ( cNumero <> aBoletos[nX, 02] )
					lImprime := .T.
				Else
					lImprime := .F.
				EndIf
			Else
				If ( cNumero+cParcela <> aBoletos[nX, 02]+aBoletos[nX, 03] )
					lImprime := .T.
				Else
					lImprime := .F.
				EndIf
			EndIf
		EndIf

		If lImprime

			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(FwxFilial("SA1") + cCliente + cLoja ))
				If cTipoImp == "Parcela"
					cArquivo 	:= "nfiscal_" + AllTrim(SA1->A1_CGC) + "_" + AllTrim(MV_PAR01) + "_" + AllTrim(cPrefixo) + "_" + AllTrim(cNumero)+"_"+AllTrim(cParcela)+".pdf"
				Else
					cArquivo 	:= "nfiscal_" + AllTrim(SA1->A1_CGC) + "_" + AllTrim(MV_PAR01) + "_" + AllTrim(cPrefixo) + "_" + AllTrim(cNumero)+"_"+'.pdf'
				EndIf
			EndIf

			oBol:SetTitulos(aPrint)
			oBol:Imprime(cDiretorio+cArquivo)

			lImprime 	:= .F.
			aPrint		:= {}

			//Envia os arquivos para o ftp do iRecebi
			If lFtp
				U_ZGENSTFP(cDiretorio+cArquivo, cArquivo, cFtpSrv, cFtpPor, cFtpUsr, cFTpPss, cFtpDir)
						//(Caminho+Arquivo salvo no Protheus_Data, Nome do Arquivo, URL do FTP, Porta do FTP, Usuario do FTP, Senha do FTP, Caminho)
			EndIf
		EndIf

	EndDo	

	If !Empty(cArquivo) 
		ApMsgInfo("Boleto(s) Gerado(s) com sucesso"+CRLF+"Caminho: "+cCaminho,"[ ZFINF001 ]")
	EndIf

Return()
