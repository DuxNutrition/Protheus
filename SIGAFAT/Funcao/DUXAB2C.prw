#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"


/*/{Protheus.doc} DUXAB2C 
	@description Cadastro de Reserva de Estoque B2C
	@author Daniel Neumann - CI Result
	@since 20/03/2023
	@version 1.0
/*/

User Function DUXAB2C()
    Local oBrowse := FwLoadBrw("DUXAB2C")

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SER� �TIL PARA FUTURAS HERAN�AS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("ZBC")
    oBrowse:SetDescription("Reserva de Estoque B2C")

   // DEFINE DE ONDE SER� RETIRADO O MENUDEF
   oBrowse:SetMenuDef("DUXAB2C")

Return (oBrowse)

// OPERA��ES DA ROTINA
Static Function MenuDef()
    // FUN��O PARA CRIAR MENUDEF
    Local aRotina := FWMVCMenu("DUXAB2C")

    ADD OPTION aRotina TITLE "Importar dados de arquivo CSV"         ACTION "FWMsgRun(, {|oSay| U_DUXB2CIP(oSay) },'Aguarde', 'Processando requisi��o...')"   	OPERATION 3 ACCESS 0
    

Return (aRotina)

// REGRAS DE NEG�CIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("PEDXB2C")

    // INSTANCIA O SUBMODELO
    Local oStruZBC := FwFormStruct(1, "ZBC")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("ZBCMASTER", NIL, oStruZBC)

    // DESCRI��O DO MODELO
    oModel:SetDescription("Modelo de Reserva de Estoque B2C")

    // DESCRI��O DO SUBMODELO
    oModel:GetModel("ZBCMASTER"):SetDescription("Reserva de Estoque B2C")

    oModel:SetPrimaryKey( { "ZPE_FILIAL", "ZPE_CODPRO","ZPE_CAIXA","ZPE_DATA" } )

Return (oModel)

// INTERFACE GR�FICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruZBC := FwFormStruct(2, "ZBC")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("DUXAB2C")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_ZBC", oStruZBC, "ZBCMASTER")

    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_ZBC", "TELA")
Return (oView)


/*/{Protheus.doc} DUXB2CIP 
	@description Importa��o de registros atr�ves de arquivo CSV
	@author Daniel Neumann - CI Result
	@since 20/03/2023
	@version 1.0
/*/

User Function DUXB2CIP(oSay) 
		
	Local cArquivo		:= ""
	Local cLinha		:= "" 
	Local aDados		:= {}
	Local nI			:= 0
    Local lRept         := .F.
    Local lInclui       := .F.
    Local lDadDiv       := .F.
    Local cLinDadIn     := ""
    Local cLinRept      := ""
    Local cCodPro       := ""
    Local lExisPer      := .F.
	
	//Recebe o Arquivo CSV
	cArquivo := cGetFile( "Arquivo CSV (*.CSV) | *.CSV", "Selecione o arquivo para importa��o",,'C:\',.F., )
	
	If !File(cArquivo)
		MsgStop("O arquivo " + cArquivo + " n�o foi encontrado. A importa��o ser� abortada!","Aten��o")
	Else
	
		//Se retornou arquivo processa
		If !Empty(cArquivo)
		
			FT_FUSE(cArquivo)
			ProcRegua(FT_FLASTREC())
			FT_FGOTOP()
					
			oSay:cCaption := "Lendo arquivo..."
			ProcessMessages()	
			
			//Quebra as Colunas e Linhas da Planilha e alimenta array
			Do While !FT_FEOF()
				
				nI++

				IncProc("Lendo arquivo...")
				cLinha := FT_FREADLN()
				If nI > 1 .And. Len(cLinha) > 8
					aAdd(aDados,Separa(cLinha,";",.T.))
				EndIf
			 	FT_FSKIP()
			EndDo 
			
			FT_FUSE()     
			
			If Len(aDados) == 0
				MsgStop("Nenhum registro a ser importado!","Aten��o")
			Else
    
				ZBC->(DbSetOrder(1))

                For nI := 1 To Len(aDados)

                    cCodPro := PADR(aDados[nI][1], FWSX3Util():GetFieldStruct("ZBC_CODPRO")[3], "" )
                    
                    SB1->(DbSetOrder(1))
                    If  SB1->(DbSeek(xFilial("SB1") + cCodPro)) ; //Se Existe o produto 
                        .And.   ValType(STOD(aDados[nI][2])) == "D"  ;//Valida se � um campo de data
                        .And.   ValType(STOD(aDados[nI][3])) == "D"  ;//Valida se � um campo de data
                        .And.   Val(StrTran(aDados[nI][4], ",", ".")) > 0 ;//Valida se a quantidade � maior que zero 
                        .And.   STOD(aDados[nI][2]) <=  STOD(aDados[nI][3])  //Valida se a data inicial � menor ou igual a data final
                        
                        lExisPer    := .F.

                        If ZBC->(DbSeek(xFilial("ZBC") + cCodPro))
                            
                            While ZBC->(!EOF()) .And. ZBC->ZBC_FILIAL == xFilial("ZBC") .And. ZBC->ZBC_CODPRO == cCodPro
                                If ((STOD(aDados[nI][2]) <= ZBC->ZBC_DTFIM .And. STOD(aDados[nI][2]) >= ZBC->ZBC_DTINI) .Or. (STOD(aDados[nI][3]) <= ZBC->ZBC_DTFIM .And. STOD(aDados[nI][3]) >= ZBC->ZBC_DTINI)) .Or. (STOD(aDados[nI][2]) <= ZBC->ZBC_DTFIM .And. STOD(aDados[nI][3]) >= ZBC->ZBC_DTINI)
                      
                              //  If (aDados[nI][2] <= ZBC->ZBC_DTFIM .And. aDados[nI][2] >= ZBC->ZBC_DTINI) .Or. (aDados[nI][3] <= ZBC->ZBC_DTFIM .And. aDados[nI][3] >= ZBC->ZBC_DTINI)
                                    lRept       := .T. 
                                    lExisPer    := .T.
                                    cLinRept    := AllTrim(Str(nI + 1)) + ", "
                                    Exit
                                EndIf 

                                ZBC->(DbSkip())
                            EndDo
                        EndIf 

                        If !lExisPer
                        
                            RecLock("ZBC", .T. )
                            ZBC->ZBC_FILIAL := xFilial("ZBC")
                            ZBC->ZBC_CODPRO := cCodPro
                            ZBC->ZBC_DTINI  := STOD(aDados[nI][2])
                            ZBC->ZBC_DTFIM  := STOD(aDados[nI][3])
                            ZBC->ZBC_QUANTI := Val(StrTran(aDados[nI][4], ",", "."))
                            ZBC->(MsUnLock())

                            lInclui := .T.
                        EndIf 
                    Else 
                        lDadDiv := .T.

                        cLinDadIn   := AllTrim(Str(nI + 1)) + ", "
                    EndIf 
                   
                Next nI

                If lRept .And. lInclui
                    FWAlertWarning("A(s) linha(s) " + cLinRept + " n�o foi(ram) importada(s) pois o periodo conflita com outro(s) cadastro(s).","Aten��o!")
                EndIf 

                If lDadDiv .And. lInclui
                    FWAlertWarning("A(s) linha(s) " + cLinDadIn + " do arquivo n�o foi(ram) importada(s) pois possue(m) dado(s) invalido(s).","Aten��o!")
                EndIf 

                If lInclui .And. (!lRept .And. !lDadDiv)
                    FWAlertSuccess("Arquivo importado com �xito","Sucesso")
                ElseIf !lInclui
                    FWAlertError("N�o foram importados dados")
                EndIf 
			EndIf	
		EndIf 
	EndIf		
    
Return


/*/{Protheus.doc} DUXB2CVD 
	@description Valida��o se j� esite per�odo cadastrado para o produto
	@author Daniel Neumann - CI Result
	@since 20/03/2023
	@version 1.0
/*/

User Function DUXB2CVD() 
		
	Local lRet      := .T.
    Local aAreaZBC  := ZBC->(GetArea())
    Local nRecAlt   := ZBC->(RECNO())
	
    If !Empty(M->ZBC_DTFIM) .And. !Empty(M->ZBC_DTINI)
        If lRet .And. M->ZBC_DTFIM < M->ZBC_DTINI
            
            lRet     := .F. 
            Help(Nil, Nil,'DUXB2CVD', Nil, 'A data final de vig�ncia � menor que a data inicial.', 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe uma data de vig�ncia final maior ou igual a inicial."})		
        EndIf 

    EndIf 

    If  lRet .And. !Empty(M->ZBC_CODPRO)
        
        SB1->(DbSetOrder(1))
        If SB1->(DbSeek(xFilial("SB1") + M->ZBC_CODPRO))
        
            ZBC->(DbSetOrder(1))
            If ZBC->(DbSeek(xFilial("ZBC") + M->ZBC_CODPRO ))

                If ZBC->(DbSeek(xFilial("ZBC") +  M->ZBC_CODPRO))
                            
                    While ZBC->(!EOF()) .And. ZBC->ZBC_FILIAL == xFilial("ZBC") .And. ZBC->ZBC_CODPRO ==  M->ZBC_CODPRO

                        If ALTERA .And. ZBC->(RECNO()) == nRecAlt
                            ZBC->(DbSkip())
                            Loop
                        EndIf 
                        
                        If ((M->ZBC_DTINI <= ZBC->ZBC_DTFIM .And. M->ZBC_DTINI >= ZBC->ZBC_DTINI) .Or. (M->ZBC_DTFIM <= ZBC->ZBC_DTFIM .And. M->ZBC_DTFIM >= ZBC->ZBC_DTINI)) .Or. (M->ZBC_DTINI <= ZBC->ZBC_DTFIM .And. M->ZBC_DTFIM >= ZBC->ZBC_DTINI)
                            
                            lRet     := .F. 
                            Help(Nil, Nil,'DUXB2CVD', Nil, 'J� existe cadastro para este produto com esse intervalo de vig�ncia.', 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe outro intervalo de vig�ncia para o produto."})	
                            Exit
                        EndIf 

                        ZBC->(DbSkip())
                    EndDo
                EndIf 
            EndIf	
        EndIf
    EndIf 

    RestArea(aAreaZBC)

Return lRet

/*/{Protheus.doc} SLDVDB2C 
	@description Retorna a quantidade vendida dentro de uma per�odo de tempo
	@author Daniel Neumann - CI Result
	@since 29/03/2023
	@version 1.0
/*/

User Function SLDVDB2C(cFilEst, cCodPro, dDtIni, dDtFim, cLocPad)

    Local nRet          := 0
    Local cAliasSC6     := GetNextAlias()

    DEFAULT cFilEst     := xFilial("ZBC") 
    DEFAULT cCodPro     := ""
    DEFAULT dDtIni      := CTOD(" /  /    ")
    DEFAULT dDtFim      := CTOD(" /  /    ")
    DEFAULT cLocPad     := ""

    If Empty(cLocPad)

        SB1->(DbSetOrder(1))
        If SB1->(DbSeek(xFilial("SB1") + cCodPro))
            cLocPad := SB1->B1_LOCPAD
        EndIf  
    EndIf 

    BeginSQL Alias cAliasSC6 

        SELECT SUM(C6_QTDVEN) AS C6_QTDVEN
            FROM %TABLE:SC6% SC6 
            JOIN %TABLE:SC5% SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC5.%NOTDEL%
            JOIN %TABLE:SF4% SF4 ON F4_FILIAL = %EXP:xFilial("SF4")% AND F4_CODIGO = C6_TES AND SF4.%NOTDEL%
            JOIN %TABLE:SA1% SA1 ON A1_FILIAL = %EXP:xFilial("SA1")% AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.%NOTDEL%
            WHERE   SC6.%NOTDEL% 
                    AND C6_FILIAL   = %EXP:cFilEst%
                    AND C6_PRODUTO  = %EXP:cCodPro%
                    AND C6_LOCAL    = %EXP:cLocPad%
                    AND C5_EMISSAO  BETWEEN %EXP:dDtIni% AND %EXP:dDtFim%
                    AND F4_ESTOQUE  = 'S'
                    AND (A1_PESSOA   = 'F' OR C5_XPEDLV > ' ' )
                    AND C5_TIPO NOT IN ('D', 'B')

    EndSQL

    If (cAliasSC6)->(!EOF())
        nRet    := (cAliasSC6)->(C6_QTDVEN)
    EndIf 

    (cAliasSC6)->(DbCloseArea())

Return nRet
