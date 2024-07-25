#INCLUDE "PROTHEUS.CH"


/*
Programa : M410STTS
Autor    : Douglas Ferreira Martins
Data     : 17/12/2019
Descrição: Ponto de Entrada para Modificar Informaçães do Pedido de Vendas no momento da Alteração
*/
User Function M410STTS()

	Local lHomolog	    := SuperGetmv("DN_HOMOLOG", , .F.)
	Local lCotFrete	    := SuperGetmv("VT_COTFRET", , .F.)
	Local cStatusInt	:= SuperGetMV("VT_STPROCE", , "INTEG")
	
	Local cTransGen		:= SuperGetMV("IP_TRPGEN", , "")

    Local nOper         := PARAMIXB[1]
    Local nVolumes      := 0
    Local aAreaSB1      := SB1->(GetArea())
    Local aAreaSC6      := SC6->(GetArea())
    Local aAreaSA1      := SA1->(GetArea())
	Local lResiduo		:= .F.
	Local cAliasSC9		:= ""
	Local lAtuLib		:= .F.
	Local aAreaSC5 		:= SC5->(GetArea())
	Local lSchd 		:= FWGetRunSchedule()

	// Variáveis declaradas como públicas no ponto de entrada M410GET
	Default _aItLibC6		:= {}
	Default _lVldB2c		:= .T.
	Default _nItemLib		:= 0


	ConOut("DUX - Fim da rotina automatica de inclusao de pedido MATA410: " + FWTimeStamp())

	// Integração Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADM410STTS") .And. AllTrim(SC5->C5_XITEMCC) <> "SALESFORC" .And. AllTrim(SC5->C5_XSTATUS) == "BLCRD"
		ExecBlock("ADM410STTS", .F., .F.)
		ConOut("DUX - Executou o ponto de entrada ADM410STTS: " + FWTimeStamp())
	EndIf

	//	Mensagem na tela para operação triangular
	If !lSchd
		If SC5->C5_XOPTRIA == "1"	//	operação triangular
			MsgInfo("Atenção, Pedido com operação triangular")
		EndIf
	EndIf

	//Cotação de Frete Intelipost
	If !lSchd .And. lCotFrete .And. Alltrim(SC5->C5_TRANSP) == Alltrim(cTransGen)
		ConOut("DUX - Inicio da cotacao de frete: " + FWTimeStamp())
		FWMsgRun( , {|| U_ADIP01()}, "Cotação de Frete Intelipost", "Por favor, aguarde. Processando... ")
		ConOut("DUX - Fim da cotacao de frete: " + FWTimeStamp())
	EndIf

	// *** APENAS AMBIENTE DE TESTE ***
	// Por estarmos testando com pedidos já faturados, alteramos o status para seguir com o processo em Homologação
	// Essa configuração deve ficar desabilitada no ambiente de produção
	If lHomolog //.And. !FWGetRunSchedule()

		// Alteramos o status para seguir com o processo em Homologação
		RecLock("SC5", .F.)
		SC5->C5_XSTATUS := cStatusInt
		SC5->(MSUnLock())

		/*
		// Liberação do Pedido
		ConOut("DUX - Inicio da liberacao do pedido: " + FWTimeStamp())
		FWMsgRun( , {|| U_VTXLibAnCrd(SC5->C5_NUM, SC5->C5_XSTATUS)}, "Liberação do Pedido", "Por favor, aguarde. Processando... ")
		ConOut("DUX - Fim da liberacao do pedido: " + FWTimeStamp())
		
		// Faturamento Automático
		ConOut("DUX - Inicio do faturamento automatico: " + FWTimeStamp())
		FWMsgRun( , {|| U_ADFATAUT()}, "Faturamento Automático", "Por favor, aguarde. Processando... ")
		ConOut("DUX - Fim do faturamento automatico: " + FWTimeStamp())

		// Pedido de Entrega Intelipost
		If lCotFrete
			ConOut("DUX - Inicio do pedido de entrega: " + FWTimeStamp())
			FWMsgRun( , {|| U_ADIP02()}, "Pedido de Entrega Intelipost", "Por favor, aguarde. Processando... ")
			ConOut("DUX - Fim do pedido de entrega: " + FWTimeStamp())
		EndIf
		*/

	EndIf   

	// Liberação do pedido após alteração. 
	// Alterado em 17/04/2023 Daniel Neumann - CI Result
	If VALTYPE( _aItLibC6 ) == "A" .And. Len(_aItLibC6) > 0

		For _nItemLib := 1 To Len(_aItLibC6)
				
			CONOUT("INICIO LOG POR ITEM M410STTS: " 						)					
			CONOUT(" Pedido: " 					+ SC5->C5_NUM 				)
			CONOUT(" Item: " 					+ SC6->C6_ITEM				)
			CONOUT(" C6_ZAJUSIT: " 				+ _aItLibC6[_nItemLib][2] 	)
			CONOUT(" C6_ZBLOQ: "				+ _aItLibC6[_nItemLib][3] 	)
			CONOUT(" Usuário: " 				+ cUserName 				)
			CONOUT(" Data: " 					+ TIME() 					)
			CONOUT(" Hora: " 					+ DTOC(DATE()) 				)
			
			SC6->(DBGOTO( _aItLibC6[_nItemLib][1] ))

			If _aItLibC6[_nItemLib][3] == "3" //Elimina Resíduo
				
				lAtuLib		:= .T.
				lResiduo	:= .T.
				MaResDoFat(,.T.,.F.,,.F.,.F.)

				RestArea(aAreaSC5)
			Else 

				cAliasSC9 := GetNextAlias()

				BeginSQL Alias cAliasSC9
					SELECT  C9_PEDIDO,
							MAX(C9_BLCRED) AS C9_BLCRED,
							MAX(C9_BLEST) AS C9_BLEST
						FROM %TABLE:SC9% SC9 
						WHERE   SC9.%NOTDEL%
								AND C9_FILIAL 	= %EXP:SC5->C5_FILIAL%
								AND C9_PEDIDO 	= %EXP:SC5->C5_NUM%
								AND C9_ITEM 	= %EXP:SC6->C6_ITEM%  
								AND C9_BLCRED   <> "10"
                        		AND C9_BLEST    <> "10" 
						GROUP BY C9_PEDIDO, C9_BLCRED, C9_BLEST
				EndSQL 
				
				//Reavalia o estoque considerando a reserva B2C
				If _aItLibC6[_nItemLib][3] == "2" .And. Empty((cAliasSC9)->C9_PEDIDO)

					CONOUT(" Reavaliação de estoque ")

					lAtuLib		:= .T.
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.T.,.F.,.F.) 
					RestArea(aAreaSC5)
				
				//Se ao alterar estava apto a faturar e não estiver liberado, libera o item desconsiderando a reserva B2C
				ElseIf _aItLibC6[_nItemLib][2] == "8" .And. (Empty((cAliasSC9)->C9_PEDIDO) .Or. !Empty((cAliasSC9)->C9_BLEST))
					
					CONOUT("Realiza nova liberação no item ")

					lAtuLib		:= .T.
					_lVldB2c	:= .F.
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.T.,.F.,.F.) 
					RestArea(aAreaSC5)
				
				//Se ao alterar estava bloqueado por estoque 
				ElseIf _aItLibC6[_nItemLib][2] == "3" .And. _aItLibC6[_nItemLib][3] == "1" 

					//Se há liberação por regra verifica se manteve o bloqueio de estoque
					If !Empty((cAliasSC9)->C9_PEDIDO) 
						
						If Empty((cAliasSC9)->C9_BLCRED) .And. Empty((cAliasSC9)->C9_BLEST)

							CONOUT("Estorno da liberação do item")
							
							EstLibPV(SC5->C5_FILIAL, SC5->C5_NUM, SC6->C6_ITEM)
							RestArea(aAreaSC5)

							CONOUT("Nova liberação do item pois foi estornada a liberação, para gerar o bloqeuio de estoque")

							lAtuLib		:= .T.
							MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.F.,.F.,.F.)
							RestArea(aAreaSC5)

						EndIf 
					//Se não possui liberação por regra chama liberação para bloquear (6º parâmetro) não avalia estoque
					Else 

						CONOUT("Força liberação para bloquear o item, pois não há registros na SC9")

						lAtuLib		:= .T.
						MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.F.,.F.,.F.)
						RestArea(aAreaSC5)

					EndIf
				EndIf 

				(cAliasSC9)->(DbCloseArea())
			EndIf 

			CONOUT("FIM LOG POR ITEM M410STTS: " )						

		Next _nItemLib 

		If lAtuLib

			MaLiberOk({SC5->C5_NUM},lResiduo)
			RestArea(aAreaSC5)
		EndIf
		
	EndIf 

    //  Integração do Sales Force nos casos de pedidos não liberados, não pode seguir
    If SC5->C5_XITEMCC == "SALESFORC" .And. SC5->C5_XSTATUS == "BLCRD" .And. lAtuLib
	    FWAlertError("Pedido aguardando liberação de crédito no SalesForce","Atenção!")
	    RestArea(aAreaSB1)
	    RestArea(aAreaSC5)
	    RestArea(aAreaSC6)
	    RestArea(aAreaSA1)
        Return
    Endif 

	//CÁLCULO DE VOLUMES PARA EXPEDIÇÃO B2B (SEM VOLUMETRIA) - CI Result
	SA1->(DbSetOrder(1))
    If (nOper == 3 .Or. nOper == 4) .And. SC5->C5_TIPO == "N" .And. SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)) .And. SA1->A1_PESSOA == 'J'

        SC6->(DbSetOrder(1))

        If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))

            SB1->(DbSetOrder(1))

            While SC6->(!EOF()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM 

                If AllTrim(SC6->C6_BLQ) <> 'R' .And. SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
                    
                    nVolumes += (SC6->C6_QTDVEN - SC6->C6_QTDENT) / SB1->B1_ZQEEXP

                EndIf 
                
                SC6->(DbSkip())
            EndDo 

            If nVolumes > 0 

                //Incrementa um inteiro se o volume for quebrado
                If (nVolumes - Int(nVolumes) ) <> 0
                    nVolumes := Int(nVolumes) + 1
                EndIf 
            EndIf 
			
			RECLOCK("SC5", .F.)
			SC5->C5_VOLUME1 := nVolumes
			SC5->C5_ESPECI1 := "CAIXA"
			SC5->(MSUNLOCK())
        EndIf        
    EndIf 

	ConOut("DUX - Fim da gravacao do pedido M410STTS: " + FWTimeStamp())
    
    RestArea(aAreaSB1)
    RestArea(aAreaSC6)
    RestArea(aAreaSA1)

Return


/*/{Protheus.doc} EstLibPV
	@type function
	@description Rotina para estorna as liberaçãoes do pedido de venda
	@author Daniel Neumann CI Result
	@since 18/04/2023
	@version 1.0
/*/

Static Function EstLibPV(cFilPed, cNumPed, cItemPed)

    Local aArea     := GetArea()
    Local aAreaSC9  := SC9->(GetArea())
    Local cAliasSC9 := GetNExtAlias()

    BeginSQL Alias cAliasSC9 
        SELECT R_E_C_N_O_ AS RECNO
            FROM %TABLE:SC9% SC9 
            WHERE   SC9.%NOTDEL%
                    AND C9_FILIAL   = %EXP:cFilPed% 
                    AND C9_PEDIDO   = %EXP:cNumPed%
                    AND C9_ITEM     = %EXP:cItemPed%
                    AND C9_NFISCAL  = ' '
    EndSQL 
    
    If (cAliasSC9)->(!EOF())
        
        While (cAliasSC9)->(!EOF())
            
            SC9->(DBGOTO((cAliasSC9)->RECNO))
            If SC9->(!EOF())
            
                SC9->(A460Estorna())
            EndIf

            (cAliasSC9)->(DbSkip())
        EndDo
    EndIf

    (cAliasSC9)->(DbCloseArea())

    Restarea(aArea)
    RestArea(aAreaSC9)

Return 
