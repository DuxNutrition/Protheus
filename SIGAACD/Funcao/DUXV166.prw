#INCLUDE "ACDV166.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
#INCLUDE 'TOTVS.CH'

Static __nSem := 0
Static __PulaItem := .F.
Static __aOldTela :={}

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � DUXV166    � Autor � Desenv.    ACD      � Data � 17/06/01 	 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Movimentacao interna de produtos                           ���
�������������������������������������������������������������������������Ĵ��
���Parametro � ExpC1 = Caso queira padronizar programas de movimentacao in���
���          �         terna deve passar o nome do programa               ���
�������������������������������������������������������������������������Ĵ��
��� Uso	     � SIGAACD                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DUXV166()
	Local aTela
	Private nOpc


	aTela := VtSave()
	VTCLear()
	/*If lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSAY STR0008 //"Expedicao Selecione"
		nOpc:=VTaChoice(2,0,3,VTMaxCol(),{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"###"Ordem Producao"
	ElseIf Vtmodelo()=="RF"*/
		@ 0,0 VTSAY "Transf. p/ Producao" //"Transferencia p/ Producao"
		@ 1,0 VTSay "Selecione:" //"Selecione:"
		
		//Desligando customiza��o DUX - Envio e Trf de material
		//nOpc:=VTaChoice(3,0,6,VTMaxCol(),{"Enviar Material","Receber Material","Env. Retorno Producao","Receb. Retorno Producao"}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"###"Ordem Producao"

		nOpc:=VTaChoice(3,0,6,VTMaxCol(),{"Embarque Material","Recebimento Material"}) 

	/*ElseIf VtModelo()=="MT44"
		@ 0,0 VTSAY STR0007 //"Expedicao"
		@ 1,0 VTSay STR0002 //"Selecione:"
		nOpc:=VTaChoice(0,20,1,39,{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"###"Ordem Producao"
	ElseIf VtModelo()=="MT16"
		@ 0,0 VTSAY STR0008 //"Expedicao Selecione"
		nOpc:=VTaChoice(1,0,1,19,{STR0003,STR0004,STR0005,STR0006}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"###"Ordem Producao"
	EndIf*/

	//Dux - desligando customiza��o de OS - Mantendo o processo somente de transferencia
	If nOpc == 1
		nOpc := 3
	ElseIf nOpc == 2
		nOpc := 4
	Endif

	VtRestore(,,,,aTela)
	if nOpc == 3 
	u_duxv150()
	else 
	DUXV166X(nOpc)
	endif

Return 1


Static Function DUXV166X(nOpc)
Local cAliasCB8	:= " "
Local cAliasCB9	:= " "
Local cAliasZD3 := " "
Local cKey04  := VTDescKey(04)
Local cKey09  := VTDescKey(09)
Local cKey12  := VTDescKey(12)
Local cKey16  := VTDescKey(16)
Local cKey22  := VTDescKey(22)
Local cKey24  := VTDescKey(24)
Local cKey21  := VTDescKey(21)
Local bKey04  := VTSetKey(04)
Local bKey09  := VTSetKey(09)
Local bKey12  := VTSetKey(12)
Local bKey16  := VTSetKey(16)
Local bKey22  := VTSetKey(22)
Local bKey24  := VTSetKey(24)
Local bKey21  := VTSetKey(21)
Local lRetPE  := .T.
Local lACD166VL     := ExistBlock("ACD166VL")
Local lACD166VI     := ExistBlock("ACD166VI")
Local lSai			:= .F.
Local cWhere		:= "%1 = 1%
Local cMVDIVERCT	:= SuperGetMV("MV_DIVERCT",.F.,"")
Private cCodOpe     := CBRetOpe()
Private cImp        := CBRLocImp("MV_IACD01")
Private cNota
Private lMSErroAuto := .F.
Private lMSHelpAuto := .t.
Private lExcluiNF   := .f.
Private lForcaQtd   := .T. //GetMV("MV_CBFCQTD",,"2") =="1"
Private lEtiProduto := .F.			//Indica se esta lendo etiqueta de produto
Private cDivItemPv  := Alltrim(GetMV("MV_DIVERPV"))
Private cPictQtdExp := PesqPict("CB8","CB8_QTDORI")
Private cArmazem    := Space(Tamsx3("B1_LOCPAD")[1])
Private cEndereco   := Space(TamSX3("BF_LOCALIZ")[1])
Private nSaldoCB9   := 0
Private nSaldoZD3	:= 0
Private cVolume     := Space(TamSX3("CB9_VOLUME")[1])
Private cCodSep     := Space(TamSX3("CB9_ORDSEP")[1])
Private cCodTrf     := Space(TamSX3("ZD3_DOCMOV")[1])

If Type("cOrdSep")=="U"
	Private cOrdSep := Space(TamSX3("CB9_ORDSEP")[1])
EndIf
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
__aOldTela :={}
__nSem := 0 // variavel static do fonte para controle de semaforo

//����������������������������������������������������������������������Ŀ
//�Validacoes                                                            �
//������������������������������������������������������������������������
If Empty(cCodOpe)
	VTAlert(STR0009,STR0010,.T.,4000,3) //"Operador nao cadastrado"###"Aviso"
	Return 10 // valor necessario para finalizar o acv170
EndIf
CB5->(DbSetOrder(1))
If !CB5->(DbSeek(xFilial("CB5")+cImp))  //cadastro de locais de impressao
	VtBeep(3)
	VtAlert(STR0011,STR0010,.t.) //"O conteudo informado no parametro MV_IACD01 deve existir na tabela CB5."###"Aviso"
	Return 10 // valor necessario para finalizar o acv170
EndIf

//Verifica se foi chamado pelo programa ACDV170 e se ja foi separado
If ACDGet170() .AND. CB7->CB7_STATUS >= "2"
	If !A170SLProc()
		//Nao eh necessario  liberar o semaforo pois ainda nao criou nada
		Return 1
	EndIf
	//����������������������������������������������������������������������Ŀ
	//�Ativa/Destativa a tecla avanca e retrocesa                            �
	//������������������������������������������������������������������������
	A170ATVKeys(.t.,.f.)	 //Ativa tecla avanca e desativa tecla retrocede
ElseIf ACDGet170()
	//����������������������������������������������������������������������Ŀ
	//�Desativa as teclas de retrocede e avanca                              �
	//������������������������������������������������������������������������
	A170ATVKeys(.f.,.f.)
EndIf

VTClear()
If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VtSay "Transferencia" //"Transferencia"
EndIf
If ! DXSolCB7(nOpc,{|| VldCodSep()})
	Return MSCBASem() // valor necessario para finalizar o acv170 e liberar o semaforo
EndIf

If Empty(cOrdSep)
	cCodSep := CB7->CB7_ORDSEP
Else
	cCodSep := cOrdSep
EndIf

//Valida se o processo foi separado /[pendente]
If ((CB7->CB7_STATUS == "2" ) .And. Separou(cOrdSep))
	VTAlert(STR0012,STR0010,.t.,4000,3) //"Processo de separacao finalizado"###"Aviso"
	If lACD166VL
		lRetPE := ExecBlock("ACD166VL")
		lRetPE := If(ValType(lRetPE)=="L",lRetPE,.T.)
	EndIf
	If lRetPE .And. VTYesNo(STR0013,STR0014,.T.) //"Deseja estornar a separacao ?"###"Atencao"
		If "07" $ CB7->CB7_TIPEXP .AND. CB7->CB7_REQOP == "1"
			RequisitOP(.t.)
		EndIf
		VTSetKey(09,{|| Informa()},STR0015) //"Informacoes"
		Estorna()
		vtsetkey(09,bKey09,cKey09)
		MSCBASem()
		Return FimProcess(,cOrdSep,cCodTrf,nOpc)
	EndIf
EndIf

VTSetKey(09,{|| Informa()},STR0015) //"Informacoes"
if nOpc <> 4
VTSetKey(24,{|| Estorna()},STR0016) //"Estorna"
else 
VTSetKey(24,{|| RejeitItem()},"Rejeita") //"Estorna"
endif 
If VtModelo() # "RF"
	vtsetkey(21,{|| UltTela()},STR0017) //"Ultima Tela"
EndIf
If "01" $ CB7->CB7_TIPEXP
	VTSetKey(22,{|| Volume()} ,STR0018) //"Volume"
EndIf

//IniProcesso()

if nOpc == 1 //Transfer�ncia para envio

	cAliasCB9 := GetNextAlias()

	While .T.
		BeginSql Alias cAliasCB9
		SELECT 
			CB9_ORDSEP AS OrdSep,
			CB9.R_E_C_N_O_ AS REG
		FROM  
			%table:CB8% CB8
		INNER JOIN %table:CB9% CB9 
		ON CB8_FILIAL = CB9_FILIAL AND
		CB8_ORDSEP = CB9_ORDSEP AND 
		CB8_ITEM = CB9_ITESEP AND 
		CB8_PROD = CB9_PROD AND 
		CB8_LOCAL = CB9_LOCAL AND 
		CB8_LCALIZ = CB9_LCALIZ AND 
		CB8_LOTECT = CB9_LOTECT

		WHERE 
			CB8_FILIAL = %xFilial:CB8% AND 
			CB8_ORDSEP = %exp:cCodSep% AND
			CB8_SALDOS = 0 AND
			%Exp:cWhere% AND
			CB8.D_E_L_E_T_ = '' AND 
			CB9.D_E_L_E_T_ = '' AND 
			CB9_XQTDTR < CB9_QTESEP
		ORDER BY
		%Order:CB8,7%

		EndSQL

		If (cAliasCB9)->(EOF()) .Or. lSai
			Exit
		EndIf



		While (cAliasCB9)->(!Eof())
			CB9->(dbGoTo((cAliasCB9)->REG))
			If __PulaItem
				__PulaItem := .F.
				(cAliasCB9)->(DbSkip())
				Loop
			EndIf

			If Empty(CB9->(CB9_QTESEP-CB9_XQTDTR)) // ja transferido
				(cAliasCB9)->(DbSkip())
				Loop
			EndIf

			If (lSai := !Endereco(nOpc))
				Exit
			EndIf
			If (lSai := !Tela())
				Exit
			EndIf
			VTSetKey(16,{|| PulaItem()},STR0020) //"Pula"

			If UsaCb0("01") //Quando utiliza codigo interno
				VTSetKey(04,{|| ACDV210() },STR0021) //"Div.Etiqueta"
				VTSetKey(12,{|| ACDV240() },STR0022) //"Div.Pallet"

				If CBProdUnit(CB9->CB9_PROD) // etiqueta do produto
					If (lSai := !EtiProduto())
						Exit
					EndIf
				Else  // produto a granel etiqueta da caixa
					If (lSai := !EtiCaixa())
						Exit
					EndIf
					If (lSai := !EtiAvulsa())
						Exit
					EndIf
				EndIf
			Else  // somente para codigo natural ou EAN
				If (lSai := !EtiProduto())
					Exit
				ElseIf (CB9->CB9_QTESEP - CB9->CB9_XQTDTR) == 0
					IF	ACDCB8PESQUISA()
						// Verifica se existe outra item na ordem de separa��o em aberto
						(cAliasCB9)->(DbSkip())
					EndIF
				EndIf
			EndIf
			VTSetKey(16,Nil)

			//E necessario para os casos em que tem estorno.
			//CB8->(DbSeek(xFilial("CB8")+cCodSep))
		EndDo
		(cAliasCB9)->(DbCloseArea())
	End
elseif nOpc == 2 //Transferencia para recebimento
	cAliasZD3 := GetNextAlias()

	While .T.
		BeginSql Alias cAliasZD3
		SELECT 
			ZD3_ORDSEP AS OrdSep,
			ZD3.R_E_C_N_O_ AS REG
		FROM  
			%table:ZD3% ZD3
		WHERE 
			ZD3_FILIAL = %xFilial:ZD3% AND 
			ZD3_ORDSEP = %exp:cCodSep% AND
			%Exp:cWhere% AND
			ZD3.D_E_L_E_T_ = '' AND 
			ZD3_QTDDES < ZD3_QTDORI
		ORDER BY
		%Order:ZD3,1%

		EndSQL

		If (cAliasZD3)->(EOF()) .Or. lSai
			Exit
		EndIf



		While (cAliasZD3)->(!Eof())
			ZD3->(dbGoTo((cAliasZD3)->REG))
			If __PulaItem
				__PulaItem := .F.
				(cAliasZD3)->(DbSkip())
				Loop
			EndIf

			If Empty(ZD3->(ZD3_QTDORI-ZD3_QTDDES)) // ja transferido
				(cAliasZD3)->(DbSkip())
				Loop
			EndIf

			If (lSai := !Endereco(nOpc))
				Exit
			EndIf
			If (lSai := !TelaRcb())
				Exit
			EndIf
			VTSetKey(16,{|| PulaItem()},STR0020) //"Pula"

			If UsaCb0("01") //Quando utiliza codigo interno
				VTSetKey(04,{|| ACDV210() },STR0021) //"Div.Etiqueta"
				VTSetKey(12,{|| ACDV240() },STR0022) //"Div.Pallet"

				If CBProdUnit(ZD3->ZD3_PROD) // etiqueta do produto
					If (lSai := !EtiProduto())
						Exit
					EndIf
				Else  // produto a granel etiqueta da caixa
					If (lSai := !EtiCaixa())
						Exit
					EndIf
					If (lSai := !EtiAvulsa())
						Exit
					EndIf
				EndIf
			Else  // somente para codigo natural ou EAN
				If (lSai := !EtiProduto())
					Exit
				ElseIf (ZD3->ZD3_QTDORI - ZD3->ZD3_QTDDES) == 0
					IF	ACDCB8PESQUISA()
						// Verifica se existe outra item na ordem de separa��o em aberto
						(cAliasZD3)->(DbSkip())
					EndIF
				EndIf
			EndIf
			VTSetKey(16,Nil)

			//E necessario para os casos em que tem estorno.
			//CB8->(DbSeek(xFilial("CB8")+cCodSep))
		EndDo
		(cAliasZD3)->(DbCloseArea())
	End
elseif nOpc == 4 //Recebimento de Retorno
	cAliasZD3 := GetNextAlias()

	While .T.
		BeginSql Alias cAliasZD3
		SELECT 
			ZD3_ORDSEP AS OrdSep,
			ZD3.R_E_C_N_O_ AS REG
		FROM  
			%table:ZD3% ZD3
		WHERE 
			ZD3_FILIAL = %xFilial:ZD3% AND 
			ZD3_DOCMOV = %exp:cCodTrf% AND
			%Exp:cWhere% AND
			ZD3.D_E_L_E_T_ = '' AND 
			ZD3_QTDDES < ZD3_QTDORI AND 
			ZD3_FLAG = ''
		ORDER BY
		%Order:ZD3,1%

		EndSQL

		If (cAliasZD3)->(EOF()) .Or. lSai
			Exit
		EndIf



		While (cAliasZD3)->(!Eof())
			ZD3->(dbGoTo((cAliasZD3)->REG))
			If __PulaItem
				__PulaItem := .F.
				(cAliasZD3)->(DbSkip())
				Loop
			EndIf

			If Empty(ZD3->(ZD3_QTDORI-ZD3_QTDDES)) // ja transferido
				(cAliasZD3)->(DbSkip())
				Loop
			EndIf

			If !Empty(ZD3->ZD3_FLAG) 
				(cAliasZD3)->(DbSkip())
				Loop
			EndIf

			If (lSai := !Endereco(nOpc))
				Exit
			EndIf
			If (lSai := !TelaRcb())
				Exit
			EndIf
			VTSetKey(16,{|| PulaItem()},STR0020) //"Pula"

			If UsaCb0("01") //Quando utiliza codigo interno
				VTSetKey(04,{|| ACDV210() },STR0021) //"Div.Etiqueta"
				VTSetKey(12,{|| ACDV240() },STR0022) //"Div.Pallet"

				If CBProdUnit(ZD3->ZD3_PROD) // etiqueta do produto
					If (lSai := !EtiProduto())
						Exit
					EndIf
				Else  // produto a granel etiqueta da caixa
					If (lSai := !EtiCaixa())
						Exit
					EndIf
					If (lSai := !EtiAvulsa())
						Exit
					EndIf
				EndIf
			Else  // somente para codigo natural ou EAN
				If (lSai := !EtiProduto())
					Exit
				ElseIf (ZD3->ZD3_QTDORI - ZD3->ZD3_QTDDES) == 0
					IF	ACDCB8PESQUISA()
						// Verifica se existe outra item na ordem de separa��o em aberto
						(cAliasZD3)->(DbSkip())
					EndIF
				EndIf
			EndIf
			VTSetKey(16,Nil)

			//E necessario para os casos em que tem estorno.
			//CB8->(DbSeek(xFilial("CB8")+cCodSep))
		EndDo
		(cAliasZD3)->(DbCloseArea())
	End
endif


vtsetkey(04,bKey04,cKey04)
vtsetkey(09,bKey09,cKey09)
vtsetkey(12,bKey12,cKey12)
vtsetkey(16,bKey16,cKey16)
vtsetkey(22,bKey22,cKey22)
vtsetkey(21,bKey21,cKey21)
MSCBASem() // valor necessario para finalizar o acv170 e liberar o semaforo
Return FimProcess(,cOrdSep,cCodTrf,nOpc)









//============================================================================================
// FUNCOES REVISADAS
//============================================================================================
/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun�ao    � Separou  � Autor � ACD                   � Data � 06/02/05      ���
������������������������������������������������������������������������������Ĵ��
���Descri�ao � Verifica se todos os itens da Ordem de Separacao foram separados���
������������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAACD                                                          ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function Separou(cOrdSep)
	Local lRet:= .t.
	Local lV166SPOK
	Local aCB9	:= CB9->(GetArea())

	CB9->(DBSetOrder(1))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		If CB9->(CB9_QTESEP-CB9_XQTDTR) <> 0
			lRet:= .f.
			Exit
		EndIf
		CB9->(DbSkip())
	EndDo

	CB9->(RestArea(aCB9))
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � IniProcesso� Autor � ACD                 � Data � 03/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Expedicao                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IniProcesso()
	RecLock("CB7",.f.)
// AJUSTE DO STATUS
	If CB7->CB7_STATUS == "0" .or. Empty(CB7->CB7_STATUS) // nao iniciado
		CB7->CB7_STATUS := "1"  // em separacao
		CB7->CB7_DTINIS := dDataBase
		CB7->CB7_HRINIS := StrTran(Time(),":","")
	EndIf
	CB7->CB7_STATPA := " "  // se estiver pausado tira o STATUS  de pausa
	CB7->CB7_CODOPE := cCodOpe
	CB7->(MsUnlock())
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FimProcesso� Autor � ACD                 � Data � 03/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Finaliza o processo de separacao                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FimProcess(lApp,cOrdSep,cCodTrf,nOpc)
	Local lDiverg := .f.
	Local lRet    := .t.
	Local nSai    := 1
	Local cStatus := "2"
	Local lCloseOp := .F.
	Local lACDOCSE := SuperGetMV("MV_ACDOCSE",.F.,"S")=="S"
	Default 	lApp	:= .F.
	If lApp
		cDivItemPv  := Alltrim(GetMV("MV_DIVERPV"))
	Endif

	IF nOpc <> 4

		If !Empty(CB7->CB7_OP) .Or. CBUltExp(CB7->CB7_TIPEXP) $ "00*01*"
			cStatus  := "9"
		EndIf




		If Separou(cOrdSep)

			//If CB7->CB7_STATUS == "2" .OR. CB7->CB7_STATUS == "9"


			VTAlert("Processo de Transferencia finalizado.",STR0010,.t.,4000)  //"Processo de separacao finalizado"###"Aviso"

			//EndIf
		Else
			If !lDiverg .AND. ACDGet170() .AND. ;
					VTYesNo(STR0023,STR0014,.T.) //"Ainda existem itens nao separados. Deseja separalos agora?"###"Atencao"
				nSai := 0
			Else
				/*Reclock("CB7",.f.)
				CB7->CB7_STATUS := "1"  // separando
				CB7->CB7_STATPA := "1"  // Em pausa
				CB7->CB7_DTFIMS := Ctod("  /  /  ")
				CB7->CB7_HRFIMS := "     "
				nSai := 10*/
			EndIf
		EndIf
		//CB7->(MsUnlock())

		If CB7->CB7_ORIGEM == "3" //Ordem de Separacao
			CB9->( dbSetOrder( 1 ) )
			CB9->( dbSeek( FWxFilial( "CB9" ) + CB7->CB7_ORDSEP ) )
			While CB9->( !Eof() ) .And. CB9->CB9_FILIAL == FWxFilial( 'CB9' ) .And. CB9->CB9_ORDSEP == CB7->CB7_ORDSEP
				If (CB9->(CB9_QTESEP-CB9_XQTDTR)) == 0
					lCloseOp := .T.
				Else
					lCloseOp := .F.
					Exit
				EndIf
				CB9->( dbSkip() )
			EndDo


		EndIf


		If CB7->CB7_STATUS == "2"
			If !lApp
				VTAlert(STR0012,STR0010,.t.,4000)  //"Processo de separacao finalizado"###"Aviso"
			Endif
		EndIf
		CBLogExp(cOrdSep)



		//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
		//ou retrocesso forcado pelo operador
		If ACDGet170() .AND. A170AvOrRet() .AND. A170SLProc()
			If CB7->CB7_STATUS=="1" //Ainda esta separando
				nSai := 0
			Else
				nSai := A170ChkRet()
			EndIf
		EndIf

	ENDIF 

	IF nOpc == 4

		U_DUXEMP1("","",cCodTrf,nOpc)

	ENDIF 
Return nSai

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Endereco   � Autor � ACD                 � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Rotina de solicitacao do endereco                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Endereco(nOpc)
	Local nTamArmz	:= 0
	Local nTamEnd 	:= TamSX3("BF_LOCALIZ")[1]
	Local lCONFEND 	:= SuperGETMV("MV_CONFEND") # "1"
	Local cArmAgl	:= SuperGetMV('ES_AMZAGL', .F., "PR01") //Armaz�m definido para envio de OP aglutinada

	If  nOpc == 1 //Transferencia envio
		cArmazem := CB9->CB9_LOCAL
		cEndereco := CB9->CB9_LCALIZ
		Return .t.
	EndIf

	nTamArmz :=len(cArmazem)

	if nOpc == 2 .AND. empty(cEndereco)

		//Localiza a OP da Ordem de Produ��o
		SC2->(DbSetOrder(1))
		If  SC2->(DbSeek(xFilial("ZD3")+IIF(SUBSTR(ZD3->ZD3_OP,1,4)=='AGLT',SUBSTR(ZD3->ZD3_OP,5,6),ZD3->ZD3_OP)))
			cArmazem := IIF(SUBSTR(ZD3->ZD3_OP,1,4)=='AGLT',cArmAgl,SC2->C2_LOCAL)
		EndIf

		VtClear()
		If SuperGetMV("MV_LOCALIZ")<>"S" .or. ! Localiza(ZD3->ZD3_PROD)
			// quando nao controla o endereco GERAL ou
			// quanto este produto nao tiver controle de endereco

			@ 0,0 VTSay "Local de Destino:" //"Va para o armazem"
			@ 1,0 VTSay cArmazem
			@ 6,0 VTPause STR0025 //"Enter para continuar"


			cEndereco := Space(nTamEnd)
			Return .t.
		Else

			@ 1,0 VTSay "Local Recebimento:" //"Va para o endereco"
			@ 2,0 VTSay cArmazem

		EndIf

		While .t.
			//cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
			cEndereco := Space(nTamEnd)
			cEtiqEnd  := Space(20)


			@ 4,0 VTSay STR0030 //"Leia o endereco"

			VtClearBuffer()
			//@ 5,0          VTGet cArmazem pict "@!" valid ! Empty(cArmazem)
			//@ 5,nTamArmz   VTSay "-"
			//@ 5,nTamArmz+1 VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,"")
			@ 5,0 VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,"")


			VTRead
			If VtLastKey() == 27
				//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
				//ou retrocesso forcado pelo operador
				If ACDGet170() .AND. A170AvOrRet()
					Return .F.
				EndIf

				If VTYesNo(STR0019,STR0014,.T.) //"Confirma a saida?"###"Atencao"
					Return .f.
				Endif
				Loop
			Endif

			Exit
		EndDo
	endif
Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Tela       � Autor � ACD                 � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Somente monta a tela do respectivo produto a separar       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Tela()
	Local aTam    := TamSx3("CB8_QTDORI")
	Local cUnidade
	Local nQtdSep := 0
	Local nQtdCX  := 0
	Local nQtdPE  := 0
	Local aInfo   :={}
	static ccodant:=""

	VtClear()
// posiconando o produto
	SB1->(DbSetOrder(1))
	If ! SB1->(DbSeek(xFilial("SB1")+CB9->CB9_PROD))
		VtAlert(STR0031+CB9->CB9_PROD+STR0032) //"Inconsistencia de Base, produto "###" nao encontrado"
		// isto nao deve acontecer
		Return .f.
	EndIf
	nSaldoCB9 := CB9->(AglutCB9(CB9_ORDSEP,CB9_LOCAL,CB9_LCALIZ,CB9_PROD,CB9_LOTECT,CB9_NUMLOT,CB9_NUMSER))
	If GetNewPar("MV_OSEP2UN","0") $ "0 " // verifica se separa utilizando a 1 unidade de media
		nQtdSep := nSaldoCB9
		cUnidade:= If(nQtdSep==1,STR0033,STR0034) //"item "###"itens "
	Else                                          // ira separar por volume se possivel
		nQtdCX:= CBQEmb()
		If ExistBlock("CBRQEESP")
			nQtdPE:=ExecBlock("CBRQEESP",,,SB1->B1_COD) // ponto de entrada possibilitando ajustar a quantidade por embalagem
			nQtdCX:=If(ValType(nQtdPE)=="N",nQtdPE,nQtdCX)
		EndIf
		If nSaldoCB9/nQtdCX < 1
			nQtdSep := nSaldoCB9
			cUnidade:= If(nQtdSep==1,STR0033,STR0034) //"item "###"itens "
		Else
			nQtdSep := nSaldoCB9/nQTdCx
			cUnidade:= If(nQtdSep==1,STR0035,STR0036) //"volume "###"volumes "
		EndIf
	EndIf

//��������������������������������������������������������������Ŀ
//�Ponto de Entrada na montagem da tela de separ��o de expedi��o.�
//����������������������������������������������������������������
	If ExistBlock("A166TELA")
		ExecBlock("A166TELA",.F.,.F.,{nQtdSep,aTam,cUnidade})
	ElseIf lVT100B // GetMv("MV_RF4X20")//4x20
		@ 0,0 VTSay Padr("Envie "+Alltrim(Str(nQtdSep,aTam[1],aTam[2]))+" "+cUnidade,20) // //"Separe "
		@ 1,0 VTSay CB9->CB9_PROD
		@ 2,0 VTSay Left(SB1->B1_DESC,20)
		VTInkey(0)
		VTClear
		If Rastro(CB9->CB9_PROD,"L")
			If Len(AllTrim(CB9->CB9_LOTECT)) < 12
				@ 0,0 VTSay STR0038+CB9->CB9_LOTECT //"Lote: "
			Else
				@ 0,0 VTSay STR0038 //"Lote: "
				@ 1,0 VTSay CB9->CB9_LOTECT
			EndIf
		ElseIf Rastro(CB9->CB9_PROD,"S")
			@ 0,0 VTSay CB9->CB9_LOTECT+"-"+CB9->CB9_NUMLOT
		EndIf
		If !Empty(CB9->CB9_NUMSER)
			If Rastro(CB9->CB9_PROD,"L") .And. Len(AllTrim(CB9->CB9_LOTECT)) >= 12
				@ 2,0 VTSay CB9->CB9_NUMSER
			Else
				@ 1,0 VTSay CB9->CB9_NUMSER
			EndIf
		EndIf
		VTClear
	ElseIf VtModelo()=="RF"
		@ 0,0 VTSay Padr("Envie "+Alltrim(Str(nQtdSep,aTam[1],aTam[2]))+" "+cUnidade,20) // //"Separe "
		@ 1,0 VTSay CB9->CB9_PROD
		@ 2,0 VTSay Left(SB1->B1_DESC,20)
		If Rastro(CB9->CB9_PROD,"L")
			If Len(AllTrim(CB9->CB9_LOTECT)) < 12
				@ 3,0 VTSay STR0038+CB9->CB9_LOTECT //"Lote: "
			Else
				@ 3,0 VTSay STR0038 //"Lote: "
				@ 4,0 VTSay CB9->CB9_LOTECT
			EndIf
		ElseIf Rastro(CB9->CB9_PROD,"S")
			@ 3,0 VTSay CB9->CB9_LOTECT+"-"+CB9->CB9_NUMLOT
		EndIf
		If !Empty(CB9->CB9_NUMSER)
			If Rastro(CB9->CB9_PROD,"L") .And. Len(AllTrim(CB9->CB9_LOTECT)) >= 12
				@ 5,0 VTSay CB9->CB9_NUMSER
			Else
				@ 4,0 VTSay CB9->CB9_NUMSER
			EndIf
		EndIf
	Else
		aAdd(aInfo,{"",""})
		aAdd(aInfo,{STR0039,CB9->CB9_PROD}) //"Produto"
		aAdd(aInfo,{STR0040,SB1->B1_DESC}) //"Descricao"
		aAdd(aInfo,{STR0041,Alltrim(Str(nQtdSep,aTam[1],aTam[2]))+" "+cUnidade}) //"Qtde"
		If Rastro(CB9->CB9_PROD,"L")
			aAdd(aInfo,{STR0042,CB9->CB9_LOTECT}) //"Lote"
		ElseIf Rastro(CB9->CB9_PROD,"S")
			aAdd(aInfo,{STR0042,CB9->CB9_LOTECT}) //"Lote"
			aAdd(aInfo,{STR0043,CB9->CB9_NUMLOT}) //"Sub-Lote"
		EndIf
		If !Empty(CB9->CB9_NUMSER)
			aadd(aInfo,{STR0044,CB9->CB9_NUMSER}) //"Num. Serie"
		EndIf
		If cCodAnt <> CB9->(CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)
			cCodAnt := CB9->(CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)
			VTaBrowse(0,0,VTMaxRow(),VtMaxCol(),{STR0045,""},aInfo,{10,VtMaxCol()},,," ") //"Separe"
		EndIf
		__aOldTela:= aClone(aInfo)
	EndIf

Return .T.

/*/{Protheus.doc} TelaRcb
Tela de Recebimento da Produ��o validando quantidade lida
@type function
@version 12.1.2210
@author vnucc
@since 12/16/2023
@return logical, .t.
/*/
Static Function TelaRcb()
	Local aTam    := TamSx3("CB8_QTDORI")
	Local cUnidade
	Local nQtdSep := 0
	Local nQtdCX  := 0
	Local nQtdPE  := 0
	Local aInfo   :={}
	static ccodant:=""

	VtClear()
	// posiconando o produto
	SB1->(DbSetOrder(1))
	If ! SB1->(DbSeek(xFilial("SB1")+ZD3->ZD3_PROD))
		VtAlert("Inconsistencia de Base, produto "+CB9->CB9_PROD+" nao encontrado")
		Return .f.
	EndIf

	nSaldoZD3 := ZD3->(AglutZD3(ZD3_ORDSEP,ZD3_ITEM,ZD3_PROD,ZD3_LOCORI,ZD3_ENDORI,ZD3_LOTORI,ZD3_OP))
	If GetNewPar("MV_OSEP2UN","0") $ "0 " // verifica se separa utilizando a 1 unidade de media
		nQtdSep := nSaldoZD3
		cUnidade:= If(nQtdSep==1,STR0033,STR0034) //"item "###"itens "
	Else                                          // ira separar por volume se possivel
		nQtdCX:= CBQEmb()
		If ExistBlock("CBRQEESP")
			nQtdPE:=ExecBlock("CBRQEESP",,,SB1->B1_COD) // ponto de entrada possibilitando ajustar a quantidade por embalagem
			nQtdCX:=If(ValType(nQtdPE)=="N",nQtdPE,nQtdCX)
		EndIf
		If nSaldoZD3/nQtdCX < 1
			nQtdSep := nSaldoZD3
			cUnidade:= If(nQtdSep==1,STR0033,STR0034) //"item "###"itens "
		Else
			nQtdSep := nSaldoZD3/nQTdCx
			cUnidade:= If(nQtdSep==1,STR0035,STR0036) //"volume "###"volumes "
		EndIf
	EndIf


	@ 0,0 VTSay Padr("Receba "+Alltrim(Str(nQtdSep,aTam[1],aTam[2]))+" "+cUnidade,20)
	@ 1,0 VTSay ZD3->ZD3_PROD
	@ 2,0 VTSay Left(SB1->B1_DESC,20)
	If Rastro(ZD3->ZD3_PROD,"L")
		If Len(AllTrim(ZD3->ZD3_LOTORI)) < 12
			@ 3,0 VTSay STR0038+ZD3->ZD3_LOTORI //"Lote: "
		Else
			@ 3,0 VTSay STR0038 //"Lote: "
			@ 4,0 VTSay ZD3->ZD3_LOTORI
		EndIf
	ElseIf Rastro(ZD3->ZD3_PROD,"S")
		@ 3,0 VTSay ZD3->ZD3_LOTORI+"-"+ZD3->ZD3_NUMLOT
	EndIf



Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � AglutCB8   � Autor � ACD                 � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao que retorna o valor aglutinado de um produto confor-���
���          � parametros informados.                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AglutCB9(cOrdSep,cArm,cEnd,cProd,cLote,cSLote,cNumSer)
	Local nRecnoCB9:= CB9->(Recno())
	Local nSaldo:=0

	CB9->(DbSetOrder(12))
	CB9->(DbSeek(xFilial("CB9")+cCodSep+cArm))
	While ! CB9->(Eof()) .and. CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_LOCAL==xFilial("CB9")+cCodSep+cArm)
		If ! CB9->(CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER) ==cProd+cLote+cSLote+cNumSer
			CB9->(DbSkip())
			Loop
		EndIf
		If Empty(CB7->CB7_PRESEP) .and. CB9->CB9_LCALIZ <> cEnd
			CB9->(DbSkip())
			Loop
		EndIf
	/*If Empty(CB9->CB9_SALDOS) // ja separado
		CB9->(DbSkip())
		Loop
	EndIf*/
	nSaldo += (CB9->CB9_QTESEP - CB9->CB9_XQTDTR)
	CB9->(DbSkip())
EndDo
CB9->(DbGoto(nRecnoCB9))
Return nSaldo

/*/{Protheus.doc} AglutZD3
Aglutina o Saldo da ZD3 para receber
@type function
@version 12.1.2210
@author vnucc
@since 12/16/2023
@return numeric, nSaldo
/*/
Static Function AglutZD3(cOrdSep,cItem,cProd,cArm,cEnd,cLote,cOP)
	Local nRecnoZD3:= ZD3->(Recno())
	Local nSaldo:=0

	IF nOpc <> 4
		//ZD3_ORDSEP,ZD3_ITEM,ZD3_PROD,ZD3_LOCORI,ZD3_ENDORI,ZD3_LOTORI,ZD3_OP
		ZD3->(DbSetOrder(1))
		ZD3->(DbSeek(xFilial("ZD3")+cCodSep+cItem+cProd+cArm))
		While ! ZD3->(Eof()) .and. ZD3->(ZD3_FILIAL+ZD3_ORDSEP+ZD3_LOCORI==xFilial("ZD3")+cCodSep+cArm)
			If ! ZD3->(ZD3_PROD+ZD3_LOTORI+ZD3_ENDORI) ==cProd+cLote+cEnd
				ZD3->(DbSkip())
				Loop
			EndIf

			If Empty(ZD3->(ZD3_QTDORI-ZD3_QTDDES)) // ja separado
				ZD3->(DbSkip())
				Loop
			EndIf
			nSaldo += (ZD3->ZD3_QTDORI - ZD3->ZD3_QTDDES)
			ZD3->(DbSkip())
		EndDo
		ZD3->(DbGoto(nRecnoZD3))
	ELSE 
		//ZD3_FILIAL+ZD3_DOCMOV
		ZD3->(DbSetOrder(3))
		ZD3->(DbSeek(xFilial("ZD3")+cCodTrf))
		While ! ZD3->(Eof()) .and. ZD3->(ZD3_FILIAL+ZD3_DOCMOV==xFilial("ZD3")+cCodTrf)
			If ! ZD3->(ZD3_PROD+ZD3_LOTORI) ==cProd+cLote
				ZD3->(DbSkip())
				Loop
			EndIf
			
			If Empty(ZD3->(ZD3_QTDORI-ZD3_QTDDES)) // ja separado
				ZD3->(DbSkip())
				Loop
			EndIf
			nSaldo += (ZD3->ZD3_QTDORI - ZD3->ZD3_QTDDES)
			ZD3->(DbSkip())
		EndDo
		ZD3->(DbGoto(nRecnoZD3))
	ENDIF 

Return nSaldo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � EtiProduto � Autor � ACD                 � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Leitura da etiqueta                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EtiProduto()
	Local cEtiCB0 	:= Space(TamSx3("CB0_CODET2")[1])
	Local cEtiProd 	:= IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	Local nQtde 	:= 1
	Local uRetQtde 	:= 1
	Local bKey16 	:= VtSetKey(16)
	Local bKey24 	:= VtSetKey(24)
	Local lDiverge 	:= .F.
	Local lRejeita	:= .F.
	Local lV166NQTDE:= ExistBlock("V166NQTDE")

	lEtiProduto := .T.

	VtSetKey(16,{||  lDiverge:= .t.,VtKeyboard(CHR(27)) },STR0020)  // CTRL+P //"Pula Item"
	if nOpc == 4
	VtSetKey(24,{||  lRejeita:= .t.,VtKeyboard(CHR(27)) },"Rejeita Item ")  //CTRL+X Rejeita Item
	Endif 

	While .t.

		If __PulaItem
			Exit
		EndIf
/*
������������������������������������������������������������������������
Ponto de entrada permite que o usu�rio informe o valor da vari�vel nQtde
������������������������������������������������������������������������
*/
		If lV166NQTDE
			uRetQtde :=Execblock("V166NQTDE")
			If(ValType(uRetQtde)=="N" .And. uRetQtde > 0)
				nQtde := uRetQtde
			EndIf
		EndIf

		If lVT100B // GetMv("MV_RF4X20")
			VTClear
			If UsaCB0("01")
				@ 1,0 VTSay STR0046 //"Leia a etiqueta"
				@ 2,0 VTGet cEtiCB0 pict "@!" Valid VldProduto(cEtiCB0,NIL,NIL)
			Else
				@ 0,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) // //"Qtde "
				@ 1,0 VTSay STR0048 //"Leia o produto"
				@ 2,0 VTGet cEtiProd pict "@!" VALID VTLastkey() == 5 .or. VldProduto(NIL,cEtiProd,nQtde)
			EndIf
		ElseIf VtModelo()=="RF"
			If UsaCB0("01")
				@ 6,0 VTSay STR0046 //"Leia a etiqueta"
				@ 7,0 VTGet cEtiCB0 pict "@!" Valid VldProduto(cEtiCB0,NIL,NIL)
			Else
				@ 5,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) // //"Qtde "
				@ 6,0 VTSay STR0048 //"Leia o produto"
				@ 7,0 VTGet cEtiProd pict "@!" VALID VTLastkey() == 5 .or. VldProduto(NIL,cEtiProd,nQtde)
			EndIf
		Else // para microterminal 44 e 16 teclas
			VtClear()
			If UsaCB0("01")
				@ 0,0 VTSay STR0046 //"Leia a etiqueta"
				@ 1,0 VTGet cEtiCB0 pict "@!" Valid VldProduto(cEtiCB0,NIL,NIL)
			Else
				@ 0,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Qtde "
				@ 1,0 VTSay STR0039 VTGet cEtiProd pict "@!" VALID VTLastkey() == 5 .or. VldProduto(NIL,cEtiProd,nQtde) //"Produto"
			EndIf
		EndIf
		VTRead
		VtSetKey(16, bKey16,"")
		if nOpc == 4
		VtSetKey(24, bKey24,"")
		Endif 
		If lDiverge
			PulaItem()
			Exit
		EndIF
		If lRejeita
			RejeitItem()
			Exit
		EndIF
		// tratamento de ocorrencia pular o item
		If VTLastkey() == 27
			//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
			//ou retrocesso forcado pelo operador
			If ACDGet170() .AND. A170AvOrRet()
				Return .F.
			EndIf
			If VTYesNo(STR0019,STR0014,.T.) //"Confirma a saida?"###"Atencao"
				Return .f.
			Else
				Loop
			Endif
		Endif

		Exit
	Enddo
	lEtiProduto := .F.
Return .t.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � EtiCaixa o � Autor � ACD                 � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Leitura da etiqueta da caixa qdo granel                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EtiCaixa()
	Local cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
	Local bKey16 	:= VtSetKey(16)
	Local lDiverge 	:= .F.
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf

	VtSetKey(16,{||  lDiverge:= .t.,VtKeyboard(CHR(27)) },STR0020)  // CTRL+P //"Pula Item"

	While .t.
		If __PulaItem
			Exit
		EndIf
		If lVT100B // GetMv("MV_RF4X20")
			VtClear()
			@ 0,0 VTSay STR0049 //"Leia a caixa"
			@ 1,0 VtGet cEtiqCaixa pict "@!" Valid VldCaixa(cEtiqCaixa)
		ElseIf VtModelo()=="RF"
			@ 6,0 VTSay STR0049 //"Leia a caixa"
			@ 7,0 VtGet cEtiqCaixa pict "@!" Valid VldCaixa(cEtiqCaixa)
		Else // para mt44 e mt16
			VtClear()
			@ 0,0 VTSay STR0049 //"Leia a caixa"
			@ 1,0 VtGet cEtiqCaixa pict "@!" Valid VldCaixa(cEtiqCaixa)
		EndIf
		VTRead
		VtSetKey(16, bKey16,"")
		If lDiverge
			PulaItem()
			Exit
		EndIF
		// tratamento de ocorrencia pular o item
		If VTLastkey() == 27
			//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
			//ou retrocesso forcado pelo operador
			If ACDGet170() .AND. A170AvOrRet()
				Return .F.
			EndIf

			If VTYesNo(STR0019,STR0014,.T.) //"Confirma a saida?"###"Atencao"
				Return .f.
			Else
				Loop
			Endif
		Endif
		Exit
	Enddo
Return .t.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � EtiAvulsa  � Autor � ACD                 � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Leitura da etiqueta avulsa                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EtiAvulsa()
	Local cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
	Local bKey16 	:= VtSetKey(16)
	Local lDiverge 	:= .F.
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf

	VtSetKey(16,{||  lDiverge:= .t.,VtKeyboard(CHR(27)) },STR0020)  // CTRL+P //"Pula Item"

	While .t.
		If __PulaItem
			Exit
		EndIf
		If lVT100B // GetMv("MV_RF4X20")
			VTClear
			@ 0,0 VTSay STR0050 //"Leia a etiq. avulsa"
			@ 1,0 VtGet cEtiqAvulsa pict "@!" Valid VldEtiqAvulsa(cEtiqAvulsa)
		ElseIf VtModelo()=="RF"
			@ 6,0 VTClear to 7,19
			@ 6,0 VTSay STR0050 //"Leia a etiq. avulsa"
			@ 7,0 VtGet cEtiqAvulsa pict "@!" Valid VldEtiqAvulsa(cEtiqAvulsa)
		Else // para mt44 e mt16
			VtClear()
			@ 0,0 VTSay STR0050 //"Leia a etiq. avulsa"
			@ 1,0 VtGet cEtiqAvulsa pict "@!" Valid VldEtiqAvulsa(cEtiqAvulsa)
		EndIf
		VTRead
		VtSetKey(16, bKey16,"")
		If lDiverge
			PulaItem()
			Exit
		EndIF
		// tratamento de ocorrencia pular o item
		If VTLastkey() == 27
			//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
			//ou retrocesso forcado pelo operador
			If ACDGet170() .AND. A170AvOrRet()
				Return .F.
			EndIf
			If VTYesNo(STR0019,STR0014,.T.) //"Confirma a saida?"###"Atencao"
				Return .f.
			Else
				Loop
			Endif
		Endif
		Exit
	Enddo
Return .t.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GravaCB8 � Autor � ACD                   � Data � 28/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Expedicao                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GravaCB8( nQtde,;
		cArm,;
		cEnd,;
		cProd,;
		cLote,;
		cSLote,;
		cLoteNew,;
		cSLoteNew,;
		cNumSer,;
		cCodCB0,;
		cNumSerNew,;
		lApp,;
		cItemSep,;
		cCodSep,;
		cType,;
		cDocument,;
		cSequ)

	Local cEndNew		:= CriaVar("CB8_LCALIZ")
	Local cSequen		:= ""
	Local aCB9			:= CB9->(GetArea())
	Local lRet			:= .F.
	Local cSUBNSER 		:= SuperGetMV("MV_SUBNSER",.F.,'1')
	Local cAliasTMP		:= GetNextAlias()
	Local cQuery 		:= ""
	Local aAreaCB8		:= {}
	Local lAchouCB8		:= .F.

	Default lApp		:= .F.
	Default cItemSep	:= ''
	Default cType		:= ''
	Default cDocument	:= ''
	Default cSequ		:= ''


	CB9->(DbSetOrder(12)) // CB9_FILIAL+CB9_ORDSEP+CB9_LOCAL+CB9_LCALIZ+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER
	CB9->(DbSeek(xFilial("CB9")+cCodSep+cArm))
	While !CB9->(Eof()) .and. CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_LOCAL==xFilial("CB9")+cCodSep+cArm)

		cEndNew := CB9->CB9_LCALIZ
		cSequen	:= CB9->CB9_SEQUEN


		If !CB9->(CB9_PROD+CB9_LOTECT==cProd+cLote)
			CB9->(DbSkip())
			Loop
		EndIf
		If !CB9->(CB9_PROD==cProd)
			CB9->(DbSkip())
			Loop
		EndIf
		If Empty(CB7->CB7_PRESEP) .and. CB9->CB9_LCALIZ <> cEnd
			CB9->(DbSkip())
			Loop
		EndIf

		lRet:= .T.
		If CB7->CB7_ORIGEM == "1" .And. !Empty(cNumSerNew) .And. cNumSerNew # CB9->CB9_NUMSER
			lRet:= .F.
			If cSUBNSER $ '2|3'
				VTMSG(STR0126) //"Processando"

				//Verifica se est� no mesmo armaz�m
				lRet := NSerLocal(CB8->CB8_PROD,CB8->CB8_LOCAL,cNumSerNew,@cEndNew)

				// Faz a troca do numero de serie
				If lRet

					SubNSer(@cLoteNew,@cSLoteNew,@cEndNew,cNumSerNew,@cSequen)

					// Se este produto existir em outro CB8 devo fazer uma "troca"
					If !Empty(cNumSerNew)
						aAreaCB8 := CB8->(GetArea())
						cQuery := "SELECT " + chr(10)+chr(13)
						cQuery += "       CB8.CB8_ORDSEP, CB8.CB8_LOCAL, CB8.CB8_LCALIZ, CB8.CB8_PROD, CB8.CB8_LOTECT, CB8.CB8_NUMLOT, CB8.CB8_NUMSER " + chr(10)+chr(13)
						cQuery += " FROM  " + chr(10)+chr(13)
						cQuery += "       " + RetSQLName("CB8") + " CB8 " + chr(10)+chr(13)
						cQuery += " WHERE " + chr(10)+chr(13)
						cQuery += "       CB8.CB8_FILIAL = '" + xFilial("CB8") + "' " + chr(10)+chr(13)
						cQuery += "       AND CB8.CB8_LOCAL  = '" + CB8->CB8_LOCAL + "' " + chr(10)+chr(13)
						cQuery += "       AND CB8.CB8_LCALIZ = '" + cEndNew + "' " + chr(10)+chr(13)
						cQuery += "       AND CB8.CB8_PROD   = '" + CB8->CB8_PROD + "' " + chr(10)+chr(13)
						cQuery += "       AND CB8.CB8_LOTECT = '" + cLoteNew + "' " + chr(10)+chr(13)
						cQuery += "       AND CB8.CB8_NUMLOT = '" + cSLoteNew + "' " + chr(10)+chr(13)
						cQuery += "       AND CB8.CB8_NUMSER = '" + cNumSerNew + "' " + chr(10)+chr(13)
						cQuery += "       AND CB8.D_E_L_E_T_=  ' ' "
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP)
						If (cAliasTMP)->(!Eof())
							CB8->(DbSetOrder(7)) // CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL+CB8_LCALIZ+CB8_PROD+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
							If CB8->(DbSeek(xFilial("CB8")+(cAliasTMP)->(CB8_ORDSEP+CB8_LOCAL+CB8_LCALIZ+CB8_PROD+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER)))
								Reclock("CB8",.F.)
								CB8->CB8_LOTECT = cLote
								CB8->CB8_NUMLOT = cSLote
								CB8->CB8_NUMSER = cNumSer
								MsUnLock()
							EndIf
						EndIf
						(cAliasTMP)->(dbCloseArea())
						CB8->(RestArea(aAreaCB8))
					EndIf
				EndIf
				If !lRet
					VtAlert(STR0084 + " " + STR0134,STR0010,.t.,4000,4) //"Endereco invalido" "O n�mero de s�rie n�o foi localizado na tabela de saldos"#"Aviso"
					Exit
				EndIf
			EndIf
		EndIF

		If lRet
			RecLock("CB9",.F.)


			//GravaCB9(CB8->CB8_SALDOS,cEndNew,cLoteNew,cSLoteNew,cCodCB0,cNumSerNew,cSequen)
			GravaZD3(nQtde,cEndNew,cLoteNew,cSLoteNew,cCodCB0,cNumSerNew,cSequen)

			CB9->CB9_XQTDTR += nQtde




			CB9->(MsUnlock())
		EndIf
		If Empty(nQtde)
			Exit
		EndIf
		CB9->(DbSkip())
	EndDo
	CB9->(RestArea(aCB9))


Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GravaCB9 � Autor � ACD                   � Data � 28/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Expedicao                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GravaCB9(nQtde,cEndNew,cLoteNew,cSLoteNew,cCodCB0,cNumSerNew,cSequen,lApp)
	Default cCodCB0 := Space(10)

	If lApp
		cVolume := ''
	Endif
	CB9->(DbSetOrder(10))
	If !CB9->(DbSeek(xFilial("CB9")+CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+cLoteNew+cSLoteNew+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER+cVolume+cCodCB0+CB8_PEDIDO)))
		RecLock("CB9",.T.)
		CB9->CB9_FILIAL := xFilial("CB9")
		CB9->CB9_ORDSEP := CB7->CB7_ORDSEP
		CB9->CB9_CODETI := cCodCB0
		CB9->CB9_PROD   := CB8->CB8_PROD
		CB9->CB9_CODSEP := CB7->CB7_CODOPE
		CB9->CB9_ITESEP := CB8->CB8_ITEM
		CB9->CB9_SEQUEN := cSequen
		CB9->CB9_LOCAL  := CB8->CB8_LOCAL
		If lApp	// Funcionalidade para troca de lote / endereco nao disponivel pelo App, serao mantidos os dados da CB8
			CB9->CB9_LCALIZ := CB8->CB8_LCALIZ
			CB9->CB9_LOTECT := CB8->CB8_LOTECT
			CB9->CB9_NUMLOT := CB8->CB8_NUMLOT
			CB9->CB9_NUMSER := CB8->CB8_NUMSER
		Else
			CB9->CB9_LCALIZ := cEndNew
			CB9->CB9_LOTECT := cLoteNew
			CB9->CB9_NUMLOT := cSLoteNew
			CB9->CB9_NUMSER := cNumSerNew
		EndIf
		CB9->CB9_LOTSUG := CB8->CB8_LOTECT
		CB9->CB9_SLOTSU := CB8->CB8_NUMLOT
		CB9->CB9_NSERSU := CB8->CB8_NUMSER
		CB9->CB9_PEDIDO := CB8->CB8_PEDIDO

		If '01' $ CB7->CB7_TIPEXP .Or. !Empty(cVolume)
			If !('02' $ CB7->CB7_TIPEXP)
				CB9->CB9_VOLUME := cVolume
			Else
				CB9->CB9_SUBVOL := cVolume
			EndIf
		EndIf

	Else
		RecLock("CB9",.F.)
	EndIf
	CB9->CB9_QTESEP += nQtde
	CB9->CB9_STATUS := "1"  // separado
	CB9->(MsUnlock())

//permite validar a quantidade separada.
	If ExistBlock("ACDGCB9")
		ExecBlock("ACDGCB9",.F.,.F.,{nQtde})
	EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �GrvEstCB9 � Autor � ACD                   � Data � 28/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Estorna CB9                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GrvEstCB9(nQtde)
	Local nDevQtd := 0
	Local cProd	  := CB9->CB9_PROD
	Local cArm 	  := CB9->CB9_LOCAL
	Local cEnd 	  := CB9->CB9_LCALIZ
	Local cLote   := CB9->CB9_LOTECT
	Local cSLote  := CB9->CB9_NUMLOT
	Local cNumSer := CB9->CB9_NUMSER
	Local cVolAux := CB9->CB9_VOLUME

//Permite validar a quantidade no estorno da ordem de separacao.
	If ExistBlock("ACDGCB9E")
		ExecBlock("ACDGCB9E",.F.,.F.,{nQtde})
	EndIf

	If nQtde <= CB9->CB9_QTESEP
		//Devolve item(s) ja separados para o CB8
		DevItemCB8(nQtde)

		//Atualiza item(s) separados
		RecLock("CB9",.F.)
		CB9->CB9_QTESEP -= nQtde
		If Empty(CB9->CB9_QTESEP)
			CB9->(DbDelete())
		EndIf
		CB9->(MsUnlock())
	Else
		CB9->(DbSetOrder(9))
		CB9->(DbSeek(xFilial("CB9")+cCodSep+cProd+cArm))
		While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOCAL == xFilial("CB9")+cCodSep+cProd+cArm)
			If Empty(CB7->CB7_PRESEP) .AND. CB9->CB9_LCALIZ <> cEnd
				CB9->(DbSkip())
				Loop
			EndIf
			If ! CB9->(CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+CB9_VOLUME) ==cLote+cSLote+cNumSer+cVolAux
				CB9->(DbSkip())
				Loop
			EndIf
			If Empty(nQtde)
				Exit
			EndIf
			If Empty(CB9->CB9_QTESEP) // ja devolvido
				CB9->(DbSkip())
				Loop
			EndIf

			If nQtde <= CB9->CB9_QTESEP
				nDevQtd := nQtde
				nQtde	  := 0
			Else
				nDevQtd := CB9->CB9_QTESEP
				nQtde   -= nDevQtd
			EndIf

			If !DevItemCB8(nDevQtd)
				VTAlert(STR0051,STR0010,.T.,4000,3) //"Item separado nao localizado!"###"Aviso"
				CB9->(DbSetOrder(12))
				CB9->(DbSeek(xFilial("CB9")+cOrdSep))
				Return
			EndIf

			RecLock("CB9",.F.)
			CB9->CB9_QTESEP -= nDevQtd
			If Empty(CB9->CB9_QTESEP)
				CB9->(DbDelete())
			EndIf
			CB9->(MsUnlock())
		EndDo
	EndIf

	RecLock("CB7",.F.)
	CB7->CB7_STATUS := "1"
	CB7->(MsUnlock())
Return

Static Function GravaZD3(nQtde,cEndNew,cLoteNew)

	Local aZD3			:= ZD3->(GetArea())
	Local cOP 			:= CB7->CB7_OP
	Default cCodCB0 := Space(10)


	if nOpc == 1
		ZD3->(DbSetOrder(1)) //ZD3_FILIAL+ZD3_ORDSEP+ZD3_ITEM+ZD3_PROD+ZD3_LOCORI+ZD3_ENDORI+ZD3_LOTORI+ZD3_OP+ZD3_DOCMOV
		If !ZD3->(DbSeek(xFilial("ZD3")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+cOP)))
			RecLock("ZD3",.T.)
			ZD3->ZD3_FILIAL := xFilial("ZD3")
			ZD3->ZD3_ORDSEP := CB9->CB9_ORDSEP
			ZD3->ZD3_ITEM 	:= CB9->CB9_ITESEP
			ZD3->ZD3_PROD   := CB9->CB9_PROD
			ZD3->ZD3_LOCORI	:= CB9->CB9_LOCAL
			ZD3->ZD3_ENDORI := CB9->CB9_LCALIZ
			ZD3->ZD3_LOTORI := CB9->CB9_LOTECT
			ZD3->ZD3_OP		:= cOP
			ZD3->ZD3_QTDORI := nQtde
			ZD3->ZD3_USRORI := UsrRetName(RetCodUsr())
			ZD3->ZD3_DTORI  := dDataBase
			//ZD3->ZD3_EMPORI := CB8->CB8_QTDORI
		Else

			RecLock("ZD3",.F.)
			ZD3->ZD3_QTDORI += nQtde

		EndIf


		ZD3->(MsUnlock())
	elseIF nOpc <> 4
		ZD3->(DbSetOrder(1)) //ZD3_FILIAL+ZD3_ORDSEP+ZD3_ITEM+ZD3_PROD+ZD3_LOCORI+ZD3_ENDORI+ZD3_LOTORI+ZD3_OP+ZD3_DOCMOV
		If ZD3->(DbSeek(xFilial("ZD3")+ZD3->(ZD3_ORDSEP+ZD3_ITEM+ZD3_PROD+ZD3_LOCORI+ZD3_ENDORI+ZD3_LOTORI+ZD3_OP)))
			RecLock("ZD3",.F.)
			ZD3->ZD3_LOCDES := cArmazem
			ZD3->ZD3_ENDDES := cEndereco
			ZD3->ZD3_LOTDES := cLoteNew
			ZD3->ZD3_QTDDES += nQtde
			ZD3->ZD3_USRDES := UsrRetName(RetCodUsr())
			ZD3->ZD3_DTDES  := dDataBase
			ZD3->(MsUnlock())
		EndIf
	else
		ZD3->(DbSetOrder(3)) //
		If ZD3->(DbSeek(xFilial("ZD3")+ZD3->(ZD3_DOCMOV+ZD3_PROD+ZD3_LOCORI+ZD3_ENDORI+ZD3_LOTORI)))
			RecLock("ZD3",.F.)
			ZD3->ZD3_LOTDES := cLoteNew
			ZD3->ZD3_QTDDES += nQtde
			ZD3->ZD3_USRDES := UsrRetName(RetCodUsr())
			ZD3->ZD3_DTDES  := dDataBase
			ZD3->(MsUnlock())
		EndIf
	endif

	ZD3->(RestArea(aZD3))

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �DevItemCB8  � Autor � ACD                 � Data � 16/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Devolve Items separados para o itens a separar CB8         ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DevItemCB8(nQtde)
	Local aCB8 := CB8->(GetArea())

	CB8->(DbSetOrder(4))
	If !CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
		CB8->(RestArea(aCB8))
		Return .F.
	EndIf

	While CB8->(!Eof() .AND. ;
			CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER ==;
			xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER))
		If CB8->CB8_PEDIDO # CB9->CB9_PEDIDO
			CB8->(DbSkip())
			Loop
		EndIf

		RecLock("CB8")
		CB8->CB8_SALDOS := CB8->CB8_SALDOS + nQtde
		If "01" $ CB7->CB7_TIPEXP
			CB8->CB8_SALDOE := CB8->CB8_SALDOE + nQtde
		EndIf
		CB8->(MsUnlock())
		CB8->(DbSkip())
	EndDo
//Restaura Ambiente
	CB8->(RestArea(aCB8))
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Informa    � Autor � ACD                 � Data � 31/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra produtos que ja foram lidos                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Informa()
	Local aCab,aSize,aSave := VTSAVE()
	Local aTemp:={}
	Local nTam



	If Empty(cOrdSep)
		Return .f.
	Endif
	VTClear()
	If UsaCB0("01")
		aCab  := {STR0039,STR0052,STR0053,STR0054,STR0042,STR0043,STR0018,STR0055,STR0056,STR0057} //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Volume"###"Sub-Volume"###"Num.Serie"###"Id Etiqueta"
	Else
		aCab  := {STR0039,STR0052,STR0053,STR0054,STR0042,STR0043,STR0018,STR0055,STR0056} //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Volume"###"Sub-Volume"###"Num.Serie"
	EndIf
	nTam := len(aCab[2])
	If nTam < len(Transform(0,cPictQtdExp))
		nTam := len(Transform(0,cPictQtdExp))
	EndIf
	If UsaCB0("01")
		aSize := {15,nTam,7,10,10,8,10,10,20,12}
	Else
		aSize := {15,nTam,7,10,10,8,10,10,20}
	Endif
	CB9->(DbSetOrder(6))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		If UsaCB0("01")
			aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_VOLUME,CB9->CB9_SUBVOL,CB9->CB9_NUMSER,CB9->CB9_CODETI})
		Else
			aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_VOLUME,CB9->CB9_SUBVOL,CB9->CB9_NUMSER})
		Endif
		CB9->(DbSkip())
	EndDo

	VTaBrowse(,,,VtMaxCol(),aCab,aTemp,aSize)
	VtRestore(,,,,aSave)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Volume   � Autor � ACD                   � Data � 31/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Geracao de volume para Embalagem simultanea                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Volume(lForcaEntrada)
	Local aTela
	Local cVolAnt
	Default lForcaEntrada := .t.
// identificar se tem embalagem simultanea
	If ! ("01" $ CB7->CB7_TIPEXP) // nao utiliza embalagem simultanea
		Return .t.
	EndIf
	If ! lForcaEntrada
		Return .t.
	EndIf
	If CB7->CB7_ORIGEM == "3"
		Return .t.
	EndIf
	cVolAnt := cVolume
	aTela   := VTSave()
	VTClear()
	cVolume := Space(20)
	If VtModelo()=="RF"
		@ 0,0 VTSay STR0058 //"Embalagem"
		@ 1,0 VtSay STR0059 //"Leia o volume:"
		@ 2,0 VtGet cVolume Pict "@!" Valid VldVolume()
		@ 4,0 VtSay STR0060 //"Tecle ENTER para"
		@ 5,0 VtSay STR0061 //"novo volume.    "
	Else
		If VtModelo()=="MT44"
			@ 0,0 VTSay STR0062 //"Leia o volume ou ENTER p/ novo volume"
		Else // mt16
			@ 0,0 VTSay STR0063 //"Leia o volume"
		Endif
		@ 1,0 VtGet cVolume Pict "@!" Valid VldVolume()
	EndIf
	VTRead
	VTRestore(,,,,aTela)
	cVolume := Padr(cVolume,10)
	If VTLastkey() == 27
		cVolume := cVolAnt
		Return .f.
	EndIf
Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldVolume� Autor � Anderson Rodrigues    � Data � 25/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da Geracao do Volume                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function VldVolume()
	Local cCodEmb := Space(3)
	Local aRet    := {}
	Local aTela   := {}
	Local cRet
	Local lACD166V1
	Private cCodVol
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf

	If ExistBlock("ACD166V1")
		lACD166V1 := ExecBlock("ACD166V1",.F.,.F.)
		lACD166V1 := If(ValType(lACD166V1)=="L",lACD166V1,.T.)
		If !lACD166V1
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		Endif
	Endif

	If Empty(cVolume)
		aTela := VTSave()
		VtClear()
		If lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VtSay STR0064 //"Digite o codigo do"
			@ 1,0 VtSay STR0065 //"tipo de embalagem"
			If ExistBlock("ACD170EB")
				cRet := ExecBlock("ACD170EB")
				If ValType(cRet)=="C"
					cCodEmb := cRet
				EndIf
			EndIf
			@ 2,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 "CB3"
			VTRead
		ElseIf VtModelo()=="RF"
			@ 1,0 VtSay STR0064 //"Digite o codigo do"
			@ 2,0 VtSay STR0065 //"tipo de embalagem"
			If ExistBlock("ACD170EB")
				cRet := ExecBlock("ACD170EB")
				If ValType(cRet)=="C"
					cCodEmb := cRet
				EndIf
			EndIf
			@ 3,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 "CB3"
			VTRead
		Else
			@ 0,0 VtSay STR0065 //"Tipo de embalagem"
			If ExistBlock("ACD170EB")
				cRet := ExecBlock("ACD170EB")
				If ValType(cRet)=="C"
					cCodEmb := cRet
				EndIf
			EndIf
			@ 1,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 "CB3"
			VTRead
		EndIf
		If VTLastkey() == 27
			VtRestore(,,,,aTela)
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		VtRestore(,,,,aTela)
		If CB5SetImp(cImp,.t.) .and. ExistBlock("IMG05")
			cCodVol := CB6->(GetSX8Num("CB6","CB6_VOLUME"))
			ConfirmSX8()
			VTAlert(STR0066,STR0010,.T.,2000) //"Imprimindo etiqueta de volume "###"Aviso"
			ExecBlock("IMG05",.F.,.F.,{cCodVol,CB7->CB7_PEDIDO,CB7->CB7_NOTA,CB7->CB7_SERIE})
			MSCBCLOSEPRINTER()
			CB6->(RecLock("CB6",.T.))
			CB6->CB6_FILIAL := xFilial("CB6")
			CB6->CB6_VOLUME := cCodVol
			CB6->CB6_PEDIDO := CB7->CB7_PEDIDO
			CB6->CB6_NOTA   := CB7->CB7_NOTA
			CB6->CB6_SERIE  := CB7->CB7_SERIE
			CB6->CB6_TIPVOL := CB3->CB3_CODEMB
			CB6->CB6_STATUS := "1"   // ABERTO
			CB6->(MsUnlock())
		EndIf
		Return .f.
	Else
		If UsaCB0("05")
			aRet:= CBRetEti(cVolume)
			If Empty(aRet)
				VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
			cCodVol:= aRet[1]
		Else
			cCodVol:= cVolume
		Endif
		CB6->(DBSetOrder(1))
		If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
			VtAlert(STR0068,STR0010,.t.,4000,3) //"Codigo de volume nao cadastrado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		If CB7->CB7_ORIGEM == "1"
			If ! CB6->CB6_PEDIDO == CB7->CB7_PEDIDO
				VtAlert(STR0069+CB6->CB6_PEDIDO,STR0010,.t.,4000,3) //"Volume pertence ao pedido "###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
		ElseIf CB7->CB7_ORIGEM == "2"
			If ! CB6->(CB6_NOTA+CB6_SERIE) == CB7->(CB7_NOTA+CB7_SERIE)
				VtAlert(STR0070+CB6->(CB6_NOTA+"-"+CB6_SERIE),STR0010,.t.,4000,3) //"Volume pertence a nota "###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
		EndIf
	EndIf
	cVolume:= CB6->CB6_VOLUME
Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldEmb   � Autor � ACD                   � Data � 31/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao do Tipo de Embalagem                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldEmb(cEmb)
	If Empty(cEmb)
		Return .f.
	EndIf
	CB3->(DbSetOrder(1))
	If ! CB3->(DbSeek(xFilial("CB3")+cEmb))
		VtAlert(STR0071,STR0010,.t.,4000,3) //"Embalagem nao cadastrada"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
Return .t.


//======================================================================================================
// Funcoes de validacoes de gets
//======================================================================================================

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldCodSep� Autor � ACD                   � Data � 25/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da Ordem de Separacao                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldCodSep()
	Local lRet := .T.

	if nOpc <> 4

		If Empty(cOrdSep)
			VtKeyBoard(chr(23))
			Return .f.
		EndIf

		CB7->(DbSetOrder(1))
		If !CB7->(DbSeek(xFilial("CB7")+cOrdSep))
			VtAlert(STR0072,STR0010,.t.,4000,3) //"Ordem de separacao nao encontrada."###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf


		If (!Empty(CB7->CB7_PEDIDO))
			VtAlert("O.S. Pedido de Venda n�o � v�lida para este processo","Aviso",.t.,4000,3) //"Ordem de separacao possui etiquetas oficiais de volumes"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf



		If !(!Empty(CB7->CB7_OP)) .And. CB7->CB7_STATUS <> "9"
			VtAlert("A Separa��o deve estar encerrada antes de iniciar a transfer�ncia","Aviso",.t.,4000,3)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf

		If CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E" O MESMO
			VtBeep(3)
			If ! VTYesNo(STR0081+CB7->CB7_CODOPE+STR0082,STR0010,.T.) //"Ordem Separacao iniciada pelo operador "###". Deseja continuar ?"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
		EndIf



		If lRet .And. !MSCBFSem() //fecha o semaforo, somente um separador por ordem de separacao
			VtAlert(STR0083,STR0010,.t.,4000,3) //"Ordem Separacao ja esta em andamento...!"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf

	else

		If Empty(cCodTrf)
			VtKeyBoard(chr(23))
			Return .f.
		EndIf

	endif


Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldEnd   � Autor � ACD                   � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao do endereco                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
// nOpc = 1 --> Separacao
// nOpc = 2 --> Estorno da Separacao
// nOpc = 3 --> Devolucao da Separacao (Funcao EstEnd())
*/
Static Function VldEnd(cArmazem,cEndereco,cEtiqEnd,nOpc)
	Local cChave
	Local aRet
	Local aCB9
	Local nRecCB9
	Local lErro := .f.
	Default cEndereco :=""
	Default cEtiqEnd  :=""
	Default nOpc      := 3

	/*If nOpc == 1
		cChave := CB8->(CB8_LOCAL+CB8_LCALIZ)
	ElseIf nOpc == 3
		cChave := CB9->(CB9_LOCAL+CB9_LCALIZ)
	EndIf*/

	VtClearBuffer()
	/*If Empty(cArmazem+cEndereco+cEtiqEnd)
		If ! UsaCB0("02")
			VTGetSetFocus("cArmazem")
		EndIf
		Return .f.
	EndIf
	If UsaCB0("02")
		aRet := CBRetEti(cEtiqEnd,"02")
		If Empty(aRet)
			VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		cArmazem  := aRet[2]
		cEndereco := aRet[1]
	EndIf

	If nOpc==2  //ESTORNO
		aCB9      := CB9->(GetArea())
		nRecCB9	 := CB9->(RecNo())
		CB9->(DbSetOrder(12))
		If CB9->(DbSeek(xFilial("CB9")+cOrdSep+cArmazem+cEndereco))
			Return .t.
		EndIf
		lErro := .t.
	Else
		If cArmazem+cEndereco <> cChave
			lErro := .t.
		EndIf
	EndIf*/

	SBE->(DbSetOrder(1))
	If !SBE->(DbSeek(xFilial("SBE")+cArmazem+cEndereco))
		lErro := .t.
	EndIf

	If lErro
		VtAlert(STR0084,STR0010,.t.,4000,3) //"Endereco invalido"###"Aviso"
		If UsaCB0("02")
			VTClearGet("cEtiqEnd")
		Else
			VTClearGet("cArmazem")
			VTClearGet("cEndereco")
			VTGetSetFocus("cArmazem")
		EndIf
		Return .f.
	EndIf

	If !CBEndLib(cArmazem,cEndereco) // verifica se o endereco esta liberado ou bloqueado
		VtAlert(STR0085,STR0010,.t.,4000,3) //"Endereco Bloqueado."###"Aviso"
		If UsaCB0("02")
			VTClearGet("cEtiqEnd")
		Else
			VTClearGet("cArmazem")
			VTClearGet("cEndereco")
			VTGetSetFocus("cArmazem")
		EndIf
		Return .f.
	EndIf

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �VldProduto� Autor � ACD                   � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da etiqueta de produto com ou sem CB0            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldProduto(cEtiCB0,cEtiProd,nQtde)
	Local cCodCB0
	Local cLote 	:= Space(TamSX3("B8_LOTECTL")[1])
	Local cSLote 	:= Space(TamSX3("B8_NUMLOTE")[1])
	Local cNumSer 	:= Space(TamSX3("BF_NUMSERI")[1])
	Local cV166VLD 	:= If(UsaCB0("01"),Space(TamSx3("CB0_CODET2")[1]), IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) )
	Local nP 		:= 0
	Local nQtdTot 	:= 0
	Local cEtiqueta
	Local aEtiqueta := {}
	Local aItensPallet:= {}
	Local lIsPallet := .T.
	Local cMsg 		:= ""
	Local nSaldo 	:= 0
	Local nSaldoLote:= 0
	Local aAux 		:= {}
	Local lErrQTD 	:= .F.
	Local lACD166BEmp := .T.
	Local lACD170VE	:= ExistBlock("ACD170VE")
	Local lESTNEG 	:= SuperGetMv("MV_ESTNEG") =="N"
	Local lContinua	:= .T.

	Local cProdVld  := ''
	Local cAmzVld	:= ''
	Local cLotVld	:= ''

	DEFAULT cEtiCB0   := Space(TamSx3("CB0_CODET2")[1])
	DEFAULT cEtiProd  := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	DEFAULT nQtde     := 1

	If __PulaItem
		Return .t.
	EndIf

	If Empty(cEtiCB0+cEtiProd)
		Return .f.
	EndIf

	//Tratamento para vari�veis, quando Envio ou Recebimento:
	if nOpc == 1
		cProdVld := CB9->CB9_PROD
		cAmzVld  := CB9->CB9_LOCAL
		cLotVld  := CB9->CB9_LOTECT
	else
		cProdVld := ZD3->ZD3_PROD
		cAmzVld  := ZD3->ZD3_LOCORI
		cLotVld	 := ZD3->ZD3_LOTORI
	endif

	If UsaCB0("01")
		aItensPallet := CBItPallet(cEtiCB0)
	Else
		aItensPallet := CBItPallet(cEtiProd)
	EndIf
	If Len(aItensPallet) == 0
		If UsaCB0("01")
			aItensPallet:={cEtiCB0}
		Else
			aItensPallet:={cEtiProd}
		EndIf
		lIsPallet := .f.
	EndIf

//�����������������������������������������������������������������������Ŀ
//�Ponto de entrada para configurar se a consulta ao Saldo por Localizacao�
//� sera ou nao considerado o empenho (SaldoSBF)                          �
//�������������������������������������������������������������������������
	If ExistBlock("ACD166BEMP")
		lACD166BEmp := ExecBlock("ACD166BEMP",.F.,.F.)
		lACD166BEmp := (If(ValType(lACD166BEmp) == "L",lACD166BEmp,.T.))
	Endif

	For nP:= 1 to Len(aItensPallet)
		cEtiqueta:= aItensPallet[nP]

		If UsaCB0("01")
			aEtiqueta := CBRetEti(cEtiqueta,"01")
			If Empty(aEtiqueta)
				cMsg := STR0067 //"Etiqueta invalida"
				lContinua := .F.
			EndIf
			If lContinua
				cLote  := aEtiqueta[16]
				cSLote := aEtiqueta[17]
				cNumSer:= aEtiqueta[23]
				cCodCB0:= CB0->CB0_CODETI
				If ! lIsPallet .And. ! Empty(CB0->CB0_PALLET)
					cMsg := STR0086 //"Etiqueta invalida, Produto pertence a um Pallet"
					lContinua := .F.
				EndIf
				If lContinua .And. !Empty(CB0->CB0_STATUS)
					cMsg := STR0137 //"Etiqueta invalida, ja consumida por outro processo."
					lContinua := .F.
				EndIf
				If lContinua .And. CB9->CB9_LOCAL <> aEtiqueta[10]
					cMsg := STR0127 //"Armazem associado a esta etiqueta esta diferente do item da separacao"
					lContinua := .F.
				EndIf
				If lContinua .And. CB9->(CB9_LOCAL+CB9_LCALIZ) <> aEtiqueta[10]+aEtiqueta[9] .and. ! Empty(CB9->CB9_LCALIZ)
					cMsg := STR0087 //"Endereco associado a esta etiqueta esta diferente"
					lContinua := .F.
				EndIf
				If lContinua .And. Ascan(aAux,{|x| x[4] == CB0->CB0_CODETI}) > 0
					cMsg := STR0088 //"Etiqueta ja lida"
					lContinua := .F.
				EndIf
				If lContinua .And. A166VldCB9(aEtiqueta[1], CB0->CB0_CODETI)
					cMsg := STR0088 //"Etiqueta ja lida"
					lContinua := .F.
				EndIf
			EndIf
		Else
			cCodCB0  := Space(10)
			If !CBLoad128(@cEtiqueta)
				cMsg:=""
				lContinua := .F.
			EndIf
			If lContinua .And. ! CbRetTipo(cEtiqueta) $ "EAN8OU13-EAN14-EAN128"
				cMsg := STR0067  //"Etiqueta invalida"
				lContinua := .F.
			EndIf
			If lContinua
				aEtiqueta := CBRetEtiEan(cEtiqueta)
				If len(aEtiqueta) == 0
					cMsg := STR0067  //"Etiqueta invalida"
					lContinua := .F.
				Else
					cLote  := aEtiqueta[3]
				EndIf
			EndIf
		EndIf
		If lContinua .And. lACD170VE
			aEtiqueta := ExecBlock("ACD170VE",,,aEtiqueta)
			If Empty(aEtiqueta)
				cMsg := STR0067  //"Etiqueta invalida"
				lContinua := .F.
			EndIf
			If lContinua
				cProduto:= aEtiqueta[1]
				If UsaCB0("01")
					cLote  := aEtiqueta[16]
					cNumSer:= aEtiqueta[23]
				Else
					cLote 	:= aEtiqueta[3]
					cNumSer	:= aEtiqueta[5]
				EndIf
			EndIf
		EndIf
		If lContinua .And. cProdVld <> aEtiqueta[1]
			cMsg := STR0089 //"Produto diferente"
			lContinua := .F.
		EndIf
		If lContinua .And. ! CBProdLib(cAmzVld,aEtiqueta[1])
			cMsg:=""
			lContinua := .F.
		EndIf
		If lContinua .And. iif(nOpc==1,nSaldoCB9,nSaldoZD3) < (aEtiqueta[2]*nQtde)
			cMsg := STR0090 //"Quantidade maior que necessario"
			lErrQTD := .t.
			lContinua := .F.
		EndIf
		If lContinua .And. !CBRastro(cProdVld,@cLote,@cSLote)
			cMsg:=""
			lContinua := .F.
		EndIf
		If lContinua
			If  cLotVld <> cLote
				cMsg := STR0091 //"Lote invalido"
				lContinua := .F.
			EndIf
		EndIf
		If lContinua .And. !UsaCB0("01")
			If CbRetTipo(cEtiqueta)=="EAN128"
				cNumSer := aEtiqueta[5]
			Else
				If ! Empty(CB9->CB9_NUMSER) .AND. ! CBNumSer(@cNumSer,CB9->CB9_NUMSER,aEtiqueta,.F.)
					lContinua := .F.
				EndIf
				If lContinua
					If Empty(cNumSer)
						cNumSer := CB9->CB9_NUMSER
					EndIf
					If !Empty(CB9->CB9_NUMSER)
						// Valida se o numero de serie pertece ao lote informado pelo operador
						SBF->(dbSetOrder(4))
						If SBF->(dbSeek(xFilial("SBF")+(cProdVld+cNumSer)))
							If cLote+cSlote # SBF->(BF_LOTECTL+BF_NUMLOTE)
								cMsg := STR0133// "O n�mero de s�rie n�o pertence ao lote informado"
								lContinua := .F.
							EndIf
						Else
							cMsg := STR0134 // "O n�mero de s�rie n�o foi localizado na tabela de saldos"
							lContinua := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		If lContinua .And. CB7->CB7_ORIGEM # "2" .and. lESTNEG .and. nOpc == 1
			If Localiza(cProdVld)
				nSaldo := SaldoSBF(cAmzVld,cEndereco,cProdVld,cNumSer,cLote,cSLote,lACD166BEmp)
			Else
				SB2->(DbSetOrder(1))
				SB2->(DbSeek(xFilial("SB2")+cProdVld+cAmzVld))
				nSaldo := SaldoSB2()
			EndIf
			If aEtiqueta[2]*nQtde > nSaldo+(CB9->CB9_QTESEP-CB9->CB9_XQTDTR) // CB9->CB9_SALDOS
				cMsg := STR0093  //"Saldo em estoque insuficiente"
				lErrQTD := .t.
				lContinua := .F.
			EndIf
		EndIf
		If lContinua
			aAdd(aAux,{aEtiqueta[2]*nQtde,cLote,cSLote,cNumSer,cCodCB0})
			nQtdTot+=aEtiqueta[2]*nQtde
		EndIf
	Next nP
	If lContinua .And. nQtdTot > iif(nOpc==1,nSaldoCB9,nSaldoZD3)
		cMsg := STR0094 //"Pallet excede a quantidade a separar"
		lErrQTD := .t.
		lContinua := .F.
	EndIf

	If lContinua
		Begin Transaction
			For nP:= 1 to Len(aAux)
				if nOpc == 1
					CB9->(GravaZD3(aAux[nP,1],CB9_LCALIZ,aAux[nP,2]))
					RecLock("CB9",.F.)
					CB9->CB9_XQTDTR += aAux[nP,1]
					CB9->(MsUnlock())
				else
					//ZD3_FILIAL+ZD3_ORDSEP+ZD3_ITEM+ZD3_PROD+ZD3_LOCORI+ZD3_ENDORI+ZD3_LOTORI+ZD3_OP+ZD3_DOCMOV
					GravaZD3(aAux[nP,1],cEndereco,aAux[nP,2])
				endif
			Next nP
		End Transaction
		aAux := {}
	Else
		If ! Empty(cMsg)
			VtAlert(cMsg,STR0010,.t.,4000,4) //"Aviso"
		EndIf
		If UsaCB0("01")
			VtClearGet("cEtiCB0")
			VtGetSetFocus("cEtiCB0")
		Else
			VtClearGet("cEtiProd")
			VtGetSetFocus("cEtiProd")
			If lForcaQtd .and. lErrQTD
				VtGetSetFocus("nQtde")
			EndIf
		EndIf
	EndIf

Return lContinua

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldCaixa � Autor � ACD                   � Data � 27/01/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Rotina de validacao da leitura da etiq da caixa "granel"   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldCaixa(cEtiqCaixa,lEstEnd)
	Local aRet
	Default lEstEnd := .F.

	If Empty(cEtiqCaixa)
		Return .f.
	EndIf
	aRet := CBRetEti(cEtiqCaixa,"01")
	If Empty(aRet)
		VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If ! Empty(aRet[2])
		VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf

	If lEstEnd
		If !(CB9->CB9_PROD == aRet[1])
			VtAlert(STR0095,STR0010,.t.,4000,3) //"Etiqueta de produto diferente"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		Return .T.
	EndIf

	If ! CBProdLib(CB9->CB9_LOCAL,CB9->CB9_PROD)
		VTKeyBoard(chr(20))
		Return .f.
	Endif
	If CB9->CB9_PROD <> aRet[1]
		VtAlert(STR0095,STR0010,.t.,4000,3) //"Etiqueta de produto diferente"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
Return .t.

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ�
���Fun�ao    �VldEtiqAvulsa� Autor � ACD                   � Data � 27/01/05 ��
����������������������������������������������������������������������������Ĵ�
���Descri�ao � Rotina de registro da etiqueta avulsa  qdo "granel"           ��
����������������������������������������������������������������������������Ĵ�
��� Uso      � SIGAACD                                                       ��
�����������������������������������������������������������������������������ٱ
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function VldEtiqAvulsa(cEtiqAvulsa,lEstEnd)
	Local nQE
	Local aEtiqueta:= {}
	Local cLote    := CB0->CB0_LOTE
	Local cSLote   := CB0->CB0_SLOTE
	Local nRecnoCb0:= CB0->(Recno())
	Default lEstEnd:= .F.

	If Empty(cEtiqAvulsa)
		Return .f.
	EndIf

	aEtiqueta:= CBRetEti(cEtiqAvulsa,"01")

	If lEstEnd //somente eh executado ao desfazer a separacao
		If Empty(aEtiqueta)
			VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		nQtdLida := aEtiqueta[2]
		Return .t.
	EndIf

	If Empty(aEtiqueta)
		VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		CB0->(DbGoto(nRecnoCb0))
		Return .f.
	EndIf
	nQE  :=CBQtdEmb(CB9->CB9_PROD)
	If Empty(nQE)
		VtAlert(STR0096,STR0010,.t.,4000,3) //"Quantidade invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		CB0->(DbGoto(nRecnoCb0))
		Return .F.
	EndIf
	If nQE > nSaldoCB9
		VtAlert(STR0097,STR0010,.t.,4000,3) //"Quantidade maior que solicitado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		CB0->(DbGoto(nRecnoCb0))
		Return .f.
	EndIf
	If ! CBRastro(CB9->CB9_PROD,@cLote,@cSLote)
		VTKeyBoard(chr(20))
		CB0->(DbGoto(nRecnoCb0))
		Return .f.
	EndIf
	CB9->(CBGrvEti("01",{SB1->B1_COD,nQE,cCodSep,,,,,,CB9_LCALIZ,CB9_LOCAL,,,,,,cLote,cSLote,,,CB9_LOCAL,,,CB9_NUMSER,},Padr(cEtiqAvulsa,10)))
	If ! VldProduto(CB0->CB0_CODETI)
		RecLock("CB0",.f.)
		CB0->(DbDelete())
		CB0->(MSUnlock())
		CB0->(DbGoto(nRecnoCb0))
		Return .f.
	EndIf
Return .t.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PulaItem � Autor � ACD                   � Data � 18/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Pula Item gravando o codigo de ocorrencia.                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PulaItem()
	Local cChave	:= CB8->(CB8_LOCAL+CB8_LCALIZ+CB8_PROD+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER)
	Local cChSeek	:= CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER)
	Local nRecCB8	:= CB8->(RecNo())
	Local aSvTela	:= {}
	Local aAreaCB8	:= CB8->(GetArea())
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf

	/*aSvTela := VtSave()
	cOcoSep := CB8->CB8_OCOSEP
	CB4->(DbSetOrder(1))
	CB4->(DbSeek(xFilial("CB4")+cOcoSep))
	VTClear
	If lVT100B // GetMv("MV_RF4X20")
		@ 1,0 VTSay STR0098 //"Informe o codigo"
		@ 2,0 VTSay STR0099 //"da divergencia:"
		@ 3,0 VtGet cOcoSep pict "@!" Valid VldOcoSep(cOcoSep,cChave) F3 "CB4"
	ElseIf VTModelo()=="RF"
		@ 2,0 VTSay STR0098 //"Informe o codigo"
		@ 3,0 VTSay STR0099 //"da divergencia:"
		@ 4,0 VtGet cOcoSep pict "@!" Valid VldOcoSep(cOcoSep,cChave) F3 "CB4"
	ElseIf VTModelo()=="MT44"
		@ 0,0 VTSay STR0100 //"Informe o codigo da divergencia:"
		@ 1,0 VtGet cOcoSep pict "@!" Valid VldOcoSep(cOcoSep,cChave) F3 "CB4"
	ElseIf VTModelo()=="MT16"
		@ 0,0 VTSay STR0101 //"Divergencia:"
		@ 1,0 VtGet cOcoSep pict "@!" Valid VldOcoSep(cOcoSep,cChave) F3 "CB4"
	EndIf
	
	VtRead()
	VtRestore(,,,,aSvTela)
	__PulaItem := .F.
	If VtLastKey() == 27
		Return .t.
	EndIf*/
	
	__PulaItem := .T.
	VtKeyboard(CHR(13))
	RestArea(aAreaCB8)
Return .t.

Static Function RejeitItem()
	
	Local aSvTela	:= {}
	Local aAreaCB8	:= CB8->(GetArea())
	

	aSvTela := VtSave()
	
	VTClear
	
	If VTYesNo("Confirma rejeicao do item?","Aviso",.t.) 
		__PulaItem := .T.
		RecLock("ZD3",.F.)
			ZD3->ZD3_FLAG := 'R' //Rejeitado
		ZD3->(MsUnlock())
	Else 
		__PulaItem := .F.
	Endif 

	
	VtRestore(,,,,aSvTela)
	
	If VtLastKey() == 27
		Return .t.
	EndIf
	
	
	VtKeyboard(CHR(13))
	RestArea(aAreaCB8)
Return .t.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldOcoSep� Autor � ACD                   � Data � 18/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao do codigo de ocorrencia da separacao             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldOcoSep(cOcoSep,cChave)

	/*If Empty(cOcoSep)
		VtKeyBoard(chr(23))
	EndIf

	CB4->(DBSetOrder(1))
	If !CB4->(DbSeek(xFilial("CB4")+cOcoSep))
		VtAlert(STR0102,STR0010,.t.,4000,3) //"Ocorrencia nao cadastrada"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If AllTrim(cOcoSep) $ cDivItemPv
		Return .T.
	EndIf

	If !CB8->(DbSeek(xFilial("CB8")+cOrdSep+cChave))
		VtAlert(STR0103,STR0010,.t.,4000,3) //"Item nao localizado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	While CB8->(!Eof() .AND. ;
			CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL+CB8_LCALIZ+CB8_PROD+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER==;
			xFilial("CB8")+cOrdSep+cChave)
		If CB8->(CB8_QTDORI<>CB8_SALDOS)
			VtAlert(STR0104,STR0010,.t.,4000,3) //"Esta ocorrencia exige o estorno dos itens lidos deste produto!"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		CB8->(DbSkip())
	EndDo*/
Return .t.

Static Function UltTela()
	Local aTela:= VTSave()
	If Len(__aOldTela) ==0
		Return
	EndIf
	VtClear()
	If ValType(__aOldTela[1])=="C"
		VTaChoice(,,,,__aOldTela)   //ultima tela da funcao endereco
	Else
		VTaBrowse(,,,,{STR0045,""},__aOldTela,{10,VtMaxCol()},,," ") // ultima tela da funcao tela() //"Separe"
	EndIf

	VtRestore(,,,,aTela)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Estorna  � Autor � ACD                   � Data � 14/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Faz a devolucao do que foi separado                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Estorna()
	Local cKey24  := VTDescKey(24)
	Local bKey24  := VTSetKey(24)
	Local nQtdSep := 0
	Local nQtdCX  := 0
	Local nQtdPE  := 0
	Local cUnidade:=""
	Local nRecCB8 := CB8->(RecNo())
	Local aTela   := VTSave()
	Local aTam    := TamSx3("CB8_QTDORI")
	Local lRet    := .f.
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf
	If Empty(cOrdSep)
		Return .f.
	Endif

	VTSetKey(24,nil)

	If !ExistCB9Sp(cOrdSep)
		VTAlert(STR0105,STR0010,.T.,4000,3) //"Nao existe itens  a serem Estornados"###"Aviso"
	Else
		If UsaCB0("01")
			VtClear()
			If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
				@ 0,0 VTSAY STR0106 //"Estorno"
				@ 1,0 VTSay STR0002 //"Selecione:"
				nOpc:=VTaChoice(3,0,4,VTMaxCol(),{STR0107,STR0108}) //"Por Produto"###"Por Endereco"
			Else
				@ 0,0 VTSAY STR0109 //"Estorno selecione:"
				nOpc:=VTaChoice(1,0,1,VTMaxCol(),{STR0107,STR0108}) //"Por Produto"###"Por Endereco"
			EndIf
			VtClearBuffer()
			If nOpc == 1
				lRet:= EstProd()
			ElseIf nOpc == 2
				lRet:= EstEnd()
			EndIf
		Else
			lRet:= EstEnd()
		Endif
	Endif
	VTkeyBoard(chr(13))
	VTRestore(,,,,aTela)
	If lEtiProduto
		//Atualizacao de valores
		CB8->(DbGoto(nRecCB8))

		nSaldoCB8 := CB8->(AglutCB8(CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_PROD,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER))
		If GetNewPar("MV_OSEP2UN","0") $ "0 " // verifica se separa utilizando a 1 unidade de media
			nQtdSep := nSaldoCB8
			cUnidade:= If(nQtdSep==1,STR0033,STR0034) //"item "###"itens "
		Else                                          // ira separar por volume se possivel
			nQtdCX:= CBQEmb()
			If ExistBlock("CBRQEESP")
				nQtdPE:=ExecBlock("CBRQEESP",,,SB1->B1_COD) // ponto de entrada possibilitando ajustar a quantidade por embalagem
				nQtdCX:=If(ValType(nQtdPE)=="N",nQtdPE,nQtdCX)
			EndIf
			If nSaldoCB8/nQtdCX < 1
				nQtdSep := nSaldoCB8
				cUnidade:= If(nQtdSep==1,STR0033,STR0034) //"item "###"itens "
			Else
				nQtdSep := nSaldoCB8/nQTdCx
				cUnidade:= If(nQtdSep==1,STR0035,STR0036) //"volume "###"volumes "
			EndIf
		EndIf
		If VTModelo()=="RF"
			@ 0,0 VTSay Padr(STR0037+Alltrim(Str(nQtdSep,aTam[1],aTam[2]))+" "+cUnidade,20) // //"Separe "
		Else
			If Len(__aOldTela	) >= 4
				__aOldTela[4,2]:= Alltrim(Str(nQtdSep,aTam[1],aTam[2]))+" "+cUnidade
			EndIf
		EndIf
	EndIf
	VTSetKey(24,bKey24,cKey24)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � EstEnd   � Autor � ACD                   � Data � 14/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Estorno da Separacao da Expedicao                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD  UTILIZADO PARA CODIGO INTERNO E NATURAL           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EstEnd()
	Local aTela
	Local cEtiqEnd   := Space(20)
	Local cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
	Local cEndereco  := Space(TamSX3("BF_LOCALIZ")[1])
	Local cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	Local cIdVol     := Space(10)
	Local nQtde      := 1
	Local nOpc       := 1
	Local cKey21
	Local bKey21

	Private cLoteNew := Space(TamSX3("B8_LOTECTL")[1])
	Private cSLoteNew:= Space(TamSX3("B8_NUMLOTE")[1])
	Private lForcaQtd:= GetMV("MV_CBFCQTD",,"2") =="1"
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf


	If SuperGetMv("MV_LOCALIZ")=="S"
		VtClear()
		If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VTSAY STR0106 //"Estorno"
			@ 1,0 VTSay STR0002 //"Selecione:"
			nOpc:=VTaChoice(3,0,4,VTMaxCol(),{STR0107,STR0108}) //"Por Produto"###"Por Endereco"
		Else
			@ 0,0 VTSAY STR0109 //"Estorno selecione:"
			nOpc:=VTaChoice(1,0,1,VTMaxCol(),{STR0107,STR0108}) //"Por Produto"###"Por Endereco"
		EndIf
	EndIf
	cVolume := Space(10)
	aTela := VTSave()
	VTClear()
	@ 0,0 VtSay Padc(STR0110,VTMaxCol()) //"Estorno da leitura"
	If lVT100B // GetMv("MV_RF4X20")
		While .T.
			@ 0,0 VtSay Padc(STR0110,VTMaxCol()) //"Estorno da leitura"
			If SuperGetMv("MV_LOCALIZ")=="S" .and. nOpc == 2 .and. Empty(CB7->CB7_PRESEP)
				@ 1,0 VTSay STR0030 //"Leia o endereco"
				If UsaCB0("02")
					@ 2,0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
				Else
					@ 2,0 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem)
					@ 2,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2)
				EndIf
			Else
				@ 1,0 VTSay STR0111 //"Leia o Armazem"
				@ 2,0 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. (!Empty(cArmazem) .AND. VldEnd(@cArmazem,NIL,NIL,2))
			EndIf


			If "01" $ CB7->CB7_TIPEXP
				@ 0,0 VTSay STR0063 //"Leia o volume"
				@ 1,0 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume)
			EndIf
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )

			cKey21  := VTDescKey(21)
			bKey21  := VTSetKey(21)

			If ! UsaCB0("01")
				@ 2,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Qtde "
			EndIf
			@ 3,0 VTSay STR0048 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstEnd(cProduto,@nQtde,cArmazem,cEndereco,cVolume,nOpc) //"Leia o produto"
			//@ 7,0 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstEnd(cProduto,@nQtde,cArmazem,cEndereco,cVolume,nOpc)
		EndDo
	Else //N�o usa parametro MV_RF4X20
		If SuperGetMv("MV_LOCALIZ")=="S" .and. nOpc == 2 .and. Empty(CB7->CB7_PRESEP)
			If VTModelo()=="RF"
				@ 1,0 VTSay STR0030 //"Leia o endereco"
				If UsaCB0("02")
					@ 2,0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
				Else
					@ 2,0 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem)
					@ 2,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2)
				EndIf
			Else
				@ 1,0 VTSay STR0054 //"Endereco"
				If UsaCB0("02")
					@ 1,10 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
				Else
					@ 1,10 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem)
					@ 1,13 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2)
				EndIf
				VtRead
				If VtLastKey() == 27
					VTRestore(,,,,aTela)
					Return .f.
				EndIf
			EndIf
		Else
			If VTModelo()=="RF"
				@ 1,0 VTSay STR0111 //"Leia o Armazem"
				@ 2,0 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. (!Empty(cArmazem) .AND. VldEnd(@cArmazem,NIL,NIL,2))
			Else
				@ 1,0 VTSay STR0053 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. (!Empty(cArmazem) .AND. VldEnd(@cArmazem,NIL,NIL,2)) //"Armazem"
				VtRead
				If VtLastKey() == 27
					VTRestore(,,,,aTela)
					Return .f.
				Endif
			EndIf
		EndIf
		If "01" $ CB7->CB7_TIPEXP
			If VTModelo()=="RF"
				@ 3,0 VTSay STR0063 //"Leia o volume"
				@ 4,0 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume)
			Else
				@ 1,0 Vtclear to 1,VtMaxCol()
				@ 1,0 VTSay STR0018 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume) //"Volume"
				VtRead
				If VtLastKey() == 27
					VTRestore(,,,,aTela)
					Return .f.
				Endif
			EndIf
		EndIf
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )

		cKey21  := VTDescKey(21)
		bKey21  := VTSetKey(21)

		If VtModelo() =="RF"
			If ! UsaCB0("01")
				@ 5,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Qtde "
			EndIf
			@ 6,0 VTSay STR0048 //"Leia o produto"
			@ 7,0 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstEnd(cProduto,@nQtde,cArmazem,cEndereco,cVolume,nOpc)
		Else
			VTClear()
			If ! UsaCB0("01")
				If VtModelo() =="MT44"
					@ 0,0 VTSay STR0112 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Estorno Qtde "
				Else // mt 16
					@ 0,0 VTSay STR0113 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Est.Qtde "
				EndIf
			Else
				@ 0,0 VTSay STR0106 //"Estorno"
			EndIf
			@ 1,0 VTSay STR0039 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstEnd(cProduto,@nQtde,cArmazem,cEndereco,cVolume,) //"Produto"
		EndIf
		VTRead
	EndIf
	VTSetKey(21,bKey21,cKey21)
	If VtLastKey() == 27
		VTRestore(,,,,aTela)
		Return .f.
	Endif
	VTRestore(,,,,aTela)
Return .t.



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VldVolEst� Autor � Anderson Rodrigues    � Data � 26/11/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao do Volume no estorno do mesmo                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldVolEst(cIDVolume,cVolumeAux)
	Local aRet := CBRetEti(cIDVolume,"05")
	Local cVolume
	If VtLastkey()== 05
		Return .t.
	EndIf
	If Empty(cIDVolume)
		Return .f.
	EndIf

	If UsaCB0("05")
		aRet := CBRetEti(cIDVolume,"05")
		If Empty(aRet)
			VtAlert(STR0114,STR0010,.t.,4000,3) //"Etiqueta de volume invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		cVolume := aRet[1]
	Else
		cVolume := 	cIDVolume
	EndIf

	CB6->(DBSetOrder(1))
	If ! CB6->(DbSeek(xFilial("CB6")+cVolume))
		VtAlert(STR0068,STR0010,.t.,4000,3) //"Codigo de volume nao cadastrado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	CB9->(DBSetOrder(2))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cVolume))
		VtAlert(STR0115,STR0010,.t.,4000,3) //"Volume pertence a outra ordem de separacao"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	cVolumeAux := cVolume
Return .t.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �VldEstEnd � Autor � ACD                   � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Expedicao                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAACD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldEstEnd(cEProduto,nQtde,cArmazem,cEndereco,cVolume,nOpc)
	Local cTipo
	Local aEtiqueta,aRet
	Local cLote 	:= Space(TamSX3("B8_LOTECTL")[1])
	Local cSLote 	:= Space(TamSX3("B8_NUMLOTE")[1])
	Local cNumSer 	:= Space(TamSX3("BF_NUMSERI")[1])
	Local nQE 		:=0
	Local nP
	Local cProduto
	Local nTQtde 	:= 0
	Local aItensPallet:= {}
	Local lIsPallet := .T.
	Local lExistCB8 := .F.
	Local lTemSerie := .T.
	Local nQtdCB9 	:= 0
	Local nRecnoCB9 := 0
	Local aCB9Recno := {}
	Local lACD166EST:= ExistBlock("ACD166EST")

	Private nQtdLida  := 0

	If Empty(cEProduto)
		Return .F.
	EndIf

	If !CBLoad128(@cEProduto)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
//--Permite valida��o especifica no estorno da ordem de separa��o.
	If ExistBlock("V166VLDE")
		If ! ExecBlock("V166VLDE",,,{cEProduto})
			Return .F.
		EndIf
	EndIf

	aItensPallet := CBItPallet(cEProduto)
	If Empty(aItensPallet)
		aItensPallet:={cEProduto}
		lIsPallet := .f.
	EndIf

	DbSelectArea("CB8")
	CB8->(DbSetOrder(7))
	aCB9Recno :={}
	For nP:= 1 to Len(aItensPallet)
		cTipo := CbRetTipo(aItensPallet[nP])
		If cTipo == "01"
			cEtiqueta:= aItensPallet[nP]
			aEtiqueta:= CBRetEti(cEtiqueta,"01")
			If Empty(aEtiqueta)
				VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			EndIf
			If ! lIsPallet
				If ! Empty(CB0->CB0_PALLET)
					VTALERT(STR0086,STR0010,.T.,4000,3) //"Etiqueta invalida, Produto pertence a um Pallet"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .f.
				EndIf
			EndIf
			If (cArmazem+cEndereco) # aEtiqueta[10]+aEtiqueta[9]
				VtAlert(STR0116,STR0010,.t.,4000,3) //"Endereco diferente"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
			CB9->(DbSetorder(1))
			If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(aItensPallet[nP],10))) //
				VtAlert(STR0117,STR0010,.t.,4000,3) //"Produto nao separado"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
		ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
			aRet := CBRetEtiEan(aItensPallet[nP])
			If Empty(aRet)
				VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
			cProduto := aRet[1]
			If cTipo $ "EAN8OU13"
				nQE  :=aRet[2] * nQtde
			Else
				nQE  :=aRet[2] * CBQtdEmb(aItensPallet[nP])*nQtde
			EndIf
			If Empty(nQE)
				VtAlert(STR0096,STR0010,.t.,4000,3) //"Quantidade invalida"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .F.
			EndIf
			cLote := aRet[3]
			If ! CBRastro(aRet[1],@cLote,@cSLote)
				VTKeyBoard(chr(20))
				Return .f.
			EndIf
			If Empty(cEndereco) .And. Localiza(cProduto)
				A166GetEnd(@cArmazem,@cEndereco)
			EndIf
			If ! Empty(aRet[5])
				cNumSer := aRet[5]
			Else
				// pedir  o numero de serie se tiver
				// descobrir se o produto tem numero de serie
				lTemSerie := .f.
				CB8->(DbSetOrder(7))
				CB8->(DbSeek(xFilial("CB8")+cOrdSep+cArmazem))
				While CB8->(!Eof() .AND. CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL== xFilial("CB8")+cOrdSep+cArmazem)
					// no cb8 n�o tem volume portanto nao sendo necessario analisar o volume
					If ! CB8->(CB8_PROD+CB8_LOTECT+CB8_NUMLOT)==cProduto+cLote+cSLote
						CB8->(DbSkip())
						Loop
					EndIf
					If ! Empty(CB8->CB8_NUMSER)
						lTemSerie := .t.
						Exit
					EndIf
					CB8->(DbSkip())
				EndDo
				If lTemSerie
					If ! CBNumSer(@cNumSer,,,.T.)
						VTKeyBoard(chr(20))
						Return .f.
					EndIf
				EndIf
			EndIf

			If lACD166EST
				aRet := ExecBlock("ACD166EST",.F.,.F.,{aRet,cArmazem,cEndereco})
				If Empty(aRet) .Or. ValType(aRet)<> "A"
					VTKeyBoard(chr(20))
					Return .f.
				EndIf
				cProduto:= aRet[1]
				cLote 	:= aRet[3]
				cNumSer	:= aRet[5]
			EndIf

			If Empty(CB7->CB7_PRESEP) // convencional
				//Verifica se existe no CB8 se existem itens quantidades separadas para o produto informado
				CB8->(DbSetOrder(7))
				CB8->(DbSeek(xFilial("CB8")+cOrdSep+cArmazem+cEndereco+cProduto+cLote+cSLote+cNumSer))
				While CB8->(!Eof() .AND. CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL+CB8_LCALIZ+CB8_PROD+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER== ;
						xFilial("CB8")+cOrdSep+cArmazem+cEndereco+cProduto+cLote+cSLote+cNumSer)
					If CB8->(CB8_QTDORI > CB8_SALDOS)
						lExistCB8 := .t.
						Exit
					EndIf
					CB8->(DbSkip())
				EndDo
				If !lExistCB8
					VtAlert(STR0118,STR0010,.t.,4000,3) //"Item nao encontrado"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .F.
				EndIf

				cLoteNew  := cLote
				cSLoteNew := cSLote

				nTQtde := 0
				CB9->(DbSetorder(8))
				If !CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLoteNew+cSLoteNew+cNumSer+cVolume+CB8->CB8_ITEM+cArmazem+cEndereco))
					VtAlert(STR0119,STR0010,.t.,4000,3) //"Volume ou etiqueta invalida"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .f.
				EndIf
				If nQE > CB9->CB9_QTESEP
					VtAlert(STR0120,STR0010,.t.,4000,3) //"Quantidade informada maior do que separada"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .F.
				EndIf
			Else // quando a origem for uma pre-separacao
				//Verifica se existe no CB8 se existem itens quantidades separadas para o produto informado
				CB8->(DbSetOrder(7))
				CB8->(DbSeek(xFilial("CB8")+cOrdSep+cArmazem))
				While CB8->(!Eof() .AND. CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL== xFilial("CB8")+cOrdSep+cArmazem)
					// no cb8 n�o tem volume portanto nao sendo necessario analisar o volume
					If ! CB8->(CB8_PROD+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER)==cProduto+cLote+cSLote+cNumSer
						CB8->(DbSkip())
						Loop
					EndIf
					If CB8->(CB8_QTDORI > CB8_SALDOS)
						lExistCB8 := .t.
						Exit
					EndIf
					CB8->(DbSkip())
				EndDo
				If !lExistCB8
					VtAlert(STR0118,STR0010,.t.,4000,3) //"Item nao encontrado"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .F.
				EndIf
				cLoteNew  := cLote
				cSLoteNew := cSLote

				nTQtde := 0
				CB9->(DbSetorder(10))
				If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep))
					VtAlert(STR0119,STR0010,.t.,4000,3) //"Volume ou etiqueta invalida"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .f.
				EndIf
				nQtdCB9:=0
				While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
					If CB9->(CB9_LOCAL+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+CB9_VOLUME) == cArmazem+cProduto+cLoteNew+cSLoteNew+cNumSer+cVolume
						If Empty(nRecnoCB9)
							nRecnoCB9 := CB9->(Recno())
						EndIf
						nQtdCB9+=CB9->CB9_QTESEP
					EndIf
					CB9->(DbSkip())
				EndDo
				CB9->(DbGoto(nRecnoCB9)) // necessario posicionar no primeiro valido para a rotina   GrvEstCB9(...)
				If Empty(nQtdCB9)
					VtAlert(STR0119,STR0010,.t.,4000,3) //"Volume ou etiqueta invalida"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .f.
				EndIf
				If nQE > nQtdCB9
					VtAlert(STR0120,STR0010,.t.,4000,3) //"Quantidade informada maior do que separada"###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					Return .F.
				EndIf
			EndIf
		Else
			VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		AADD(aCB9Recno,CB9->(Recno()))
	Next
	If ! VtYesNo(STR0121,STR0010,.t.)  //"Confirma o estorno?"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf


	For nP:= 1 to Len(aItensPallet)
		If UsaCB0("01")
			cTipo := CbRetTipo(aItensPallet[nP])
			If cTipo # "01"
				Loop
			Endif
			cEtiqueta:= aItensPallet[nP]
			aEtiqueta:= CBRetEti(cEtiqueta,"01")
			cProduto := aEtiqueta[1]
			nQE      := aEtiqueta[2]
			cLote    := aEtiqueta[16]
			cSLote   := aEtiqueta[17]
			nQtdLida := nQE
			CB9->(DbSetorder(1))
			If !CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(aItensPallet[nP],10)))
				Loop
			EndIf
			GrvEstCB9(nQtdLida)

		Else
			CB9->(DbGoto(aCB9Recno[nP]))
			nQtdLida := nQE
			GrvEstCB9(nQtdLida)
		EndIf
	Next nP
	nQtde:= 1
	VTGetRefresh("nQtde") //
	VtKeyboard(Chr(20))  // zera o get
	If !UsaCB0("01") .and. lForcaQtd
		A166MtaEst(nQtde,cArmazem,cEndereco,cVolume,nOpc)
		Return
	Else
		Return .F.
	EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � EstProd  � Autor � ACD                   � Data � 15/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Expedicao                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD SOMENTE COM CODIGO INTERNO                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EstProd()
	Local aTela	    := VTSave()
	Local cEtiqEnd  := Space(20)
	Local cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
	Local cEndereco := Space(TamSX3("BF_LOCALIZ")[1])
	Local cArm2     := Space(Tamsx3("B1_LOCPAD")[1])
	Local cEnd2     := Space(15)
	Local cProduto  := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	Local cIdVol    := Space(10)
	Local cEtiqueta := Space(20)
	Local cLote     := Space(TamSX3("B8_LOTECTL")[1])
	Local cSLote    := Space(TamSX3("B8_NUMLOTE")[1])
	Local nQtde     := 1
	Local nP		:= 0
	Local nQE	    := 0
	Local nTamEti1  := TamSx3("CB0_CODETI")[1]
	Local nTamEti2  := TamSx3("CB0_CODET2")[1]-1
	Local cEtiAux   := ""
	Local lCONFEND 	:= GETMV("MV_CONFEND") # "1"

	Private nQtdLida := 0
	Private aItensPallet:= {}
	Private cLoteNew := Space(TamSX3("B8_LOTECTL")[1])
	Private cSLoteNew:= Space(TamSX3("B8_NUMLOTE")[1])
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf


	While .t.
		cVolume    := Space(10)

		VTClear()
		If lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VtSay Padc(STR0110,VTMaxCol()) //"Estorno da leitura"
			If "01" $ CB7->CB7_TIPEXP
				@ 1,0 VTSay STR0063 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume) //"Leia o volume"
				//@ 2,0 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume)
			EndIf
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! UsaCB0("01")
				@ 2,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when VtLastkey()==5 //"Qtde "
			EndIf

			@ 3,0 VTSay STR0048 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstProd(cProduto,@nQtde,@cArmazem,@cEndereco,cVolume) //"Leia o produto"
			//@ 5,0 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstProd(cProduto,@nQtde,@cArmazem,@cEndereco,cVolume)
		ElseIf VTModelo()=="RF"
			@ 0,0 VtSay Padc(STR0110,VTMaxCol()) //"Estorno da leitura"
			If "01" $ CB7->CB7_TIPEXP
				@ 1,0 VTSay STR0063 //"Leia o volume"
				@ 2,0 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume)
			EndIf
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! UsaCB0("01")
				@ 3,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when VtLastkey()==5 //"Qtde "
			EndIf
			@ 4,0 VTSay STR0048 //"Leia o produto"
			@ 5,0 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstProd(cProduto,@nQtde,@cArmazem,@cEndereco,cVolume)
		Else // Mt44 e mt16
			@ 0,0 VtSay Padc(STR0110,VTMaxCol()) //"Estorno da leitura"
			If "01" $ CB7->CB7_TIPEXP
				@ 1,0 VTSay STR0063 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume) //"Leia o volume"
				VTRead
				If VtLastKey() == 27
					VTRestore(,,,,aTela)
					Return .f.
				Endif
			EndIf
			VTClear()
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! UsaCB0("01")
				@ 0,0 VTSay STR0047 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when VtLastkey()==5  //"Qtde "
			EndIf
			@ 1,0 VTSay STR0039 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstProd(cProduto,@nQtde,@cArmazem,@cEndereco,cVolume) //"Produto"
		EndIf
		VTRead
		If VtLastKey() == 27
			VTRestore(,,,,aTela)
			Return .f.
		Endif
		VtClear()
		If Empty(cArm2+cEnd2) .or. (cArm2+cEnd2 # cArmazem+cEndereco)
			If VtModelo()=="RF"
				@ 0,0 VTSay STR0028 //"Va para o endereco"
				@ 1,0 VTSay cArmazem+"-"+cEndereco
			ElseIf VtModelo()=="MT44"
				@ 0,0 VTSay STR0028+" "+cArmazem+"-"+cEndereco //"Va para o endereco"
			ElseIf VtModelo()=="MT16"
				@ 0,0 VTSay STR0028 //"Va para o Endereco"
				@ 1,0 VTSay cArmazem+"-"+cEndereco
			EndIf
			cArm2   := cArmazem
			cEnd2   := cEndereco
			cEtiqEnd:= Space(20)
			If lCONFEND
				If VtModelo()=="RF"
					@ 4,0 VTPause STR0025 //"Enter para continuar"
				ElseIf VtModelo()=="MT44"
					@ 1,0 VTPause STR0025 //"Enter para continuar"
				Else
					VTClearBuffer()
					VtInkey(0)
				EndIf
			Else
				If VtModelo()=="RF"
					@ 4,0 VTSay STR0030 //"Leia o endereco"
					If UsaCB0("02")
						@ 5,0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
					Else
						@ 5,0 VTGet cArmazem pict "@!" valid ! Empty(cArmazem)
						@ 5,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
					EndIf
				ElseIf VtModelo()=="MT44"
					@ 1,0 VTSay STR0030 //"Leia o endereco"
					If UsaCB0("02")
						@ 1,19 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
					Else
						@ 1,19 VTGet cArmazem pict "@!" valid ! Empty(cArmazem)
						@ 1,22 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
					EndIf
				ElseIf VtModelo()=="MT16"
					VTClearBuffer()
					VtInkey(0)
					VtClear()
					@ 0,0 VTSay STR0030 //"Leia o endereco"
					If UsaCB0("02")
						@ 1,0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
					Else
						@ 1,0 VTGet cArmazem pict "@!" valid ! Empty(cArmazem)
						@ 1,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
					EndIf
				EndIf
				VTRead
			Endif
		Endif
		If VtLastKey() == 27
			VTRestore(,,,,aTela)
			Return .f.
		Endif
		If ! VtYesNo(STR0121,STR0010,.t.) //"Confirma o estorno?"###"Aviso"
			Loop
		EndIf
		For nP:= 1 to Len(aItensPallet)
			cEtiqueta:= aItensPallet[nP]
			aEtiqueta:= CBRetEti(cEtiqueta,"01")
			cProduto := aEtiqueta[1]
			nQE      := aEtiqueta[2]
			cLote    := aEtiqueta[16]
			cSLote   := aEtiqueta[17]

			// Verifica se valida pelo codigo interno ou de cliente
			If Len(Alltrim(aItensPallet[nP])) <=  nTamEti1 // Codigo Interno
				cEtiAux := Left(aItensPallet[nP],nTamEti1)
			ElseIf Len(Alltrim(aItensPallet[nP])) ==  nTamEti2 // Codigo Cliente
				cEtiAux := A166RetEti(Left(aItensPallet[nP],nTamEti2))
			EndIf

			CB9->(DbSetorder(1))
			If CB9->(DbSeek(xFilial("CB9")+cOrdSep+cEtiAux))
				GrvEstCB9(nQE)
			EndIf
		Next
		If VtLastKey() == 27
			Exit
		Endif
	Enddo
	VTRestore(,,,,aTela)
Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �VldEstProd� Autor � ACD                   � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Validacao da etiqueta para fazer estorno / devolucao        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldEstProd(cEProduto,nQtde,cArmazem,cEndereco,cVolume)
	Local  aEtiqueta
	Local  nP
	Local  lIsPallet:= .T.
	Local nTamEti1   := TamSx3("CB0_CODETI")[1]
	Local nTamEti2   := TamSx3("CB0_CODET2")[1]-1
	Local cEtiAux    := ""
	Private nQtdLida :=0

	If Empty(cEProduto)
		Return .f.
	EndIf

	aItensPallet := CBItPallet(cEProduto)
	If Len(aItensPallet) == 0
		aItensPallet:={cEProduto}
		lIsPallet := .f.
	EndIf

	For nP:= 1 to Len(aItensPallet)
		cEtiqueta:= aItensPallet[nP]
		aEtiqueta:= CBRetEti(cEtiqueta,"01")
		If Empty(aEtiqueta)
			VtAlert(STR0067,STR0010,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		If ! lIsPallet
			If ! Empty(CB0->CB0_PALLET)
				VTALERT(STR0086,STR0010,.T.,4000,3) //"Etiqueta invalida, Produto pertence a um Pallet"###"Aviso"
				VtKeyboard(Chr(20))  // zera o get
				Return .f.
			Endif
		Endif

		// Verifica se valida pelo codigo interno ou de cliente
		If Len(Alltrim(aItensPallet[nP])) <=  nTamEti1 // Codigo Interno
			cEtiAux := Left(aItensPallet[nP],nTamEti1)
		ElseIf Len(Alltrim(aItensPallet[nP])) ==  nTamEti2 // Codigo Cliente
			cEtiAux := A166RetEti(Left(aItensPallet[nP],nTamEti2))
		EndIf

		CB9->(DbSetorder(1))
		If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cEtiAux))
			VtAlert(STR0117,STR0010,.t.,4000,3) //"Produto nao separado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	Next
	cArmazem := CB0->CB0_LOCAL
	cEndereco:= CB0->CB0_LOCALI
Return .t.

Static Function MSCBFSem()
	CB7->(dbSetOrder(1))
	CB7->(MsSeek(xFilial("CB7")+cOrdSep))
Return CB7->(SimpleLock())

Static Function MSCBASem()
	CB7->(MsRUnlock())
Return 10

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �ExistCB9Sp� Autor � ACD                   � Data � 15/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Verifica se existe algum produto ja separado para a ordem  ���
���          � de separacao informada.                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametro � cOrdSep : codigo da ordem de separacao a ser analisada.    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ExistCB9Sp(cOrdSep)
	CB9->(DBSetOrder(1))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		If ! Empty(CB9->CB9_QTESEP)
			Return .T.
		EndIf
		CB9->(DbSkip())
	Enddo
Return .F.

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun�ao    � EstItemPv � Autor � ACD                 � Data � 23/02/05 ���
������������������������������������������������������������������������Ĵ��
���Descri�ao � Estorna itens do Pedido de Vendas                         ���
������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                   ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Static Function EstItemPv(lApp)
	Local  aSvAlias     := GetArea()
	Local  aSvCB8       := CB8->(GetArea())
	Local  aSvSC6       := SC6->(GetArea())
	Local  aSvSB7       := SB7->(GetArea())
	Local  aItensDiverg := {}
	Local  i
	Local  cPRESEP := CB7->CB7_PRESEP

	Default lApp := .F.

// Verifica se a Ordem de separacao possui pre-separacao se possuir verificar se existe divergencia
// excluindo o item do pedido de venda.
	If !Empty(CB7->CB7_PRESEP)
		CB7->(DbSetOrder(1))
		If CB7->(DbSeek(xFilial("CB7")+cPRESEP))
			If CB7->CB7_DIVERG # "1"
				RestArea(aSvSB7)
			EndIf
			cOrdSep := cPRESEP
		EndIf
	EndIf

	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))

	If CB8->CB8_CFLOTE <> "1" .And. !lApp	// Funcionalidade para troca de lote nao disponivel pelo App
		v166TcLote (CB7->CB7_ORDSEP)
	EndIf

	If CB7->CB7_ORIGEM # "1" .or. CB7->CB7_DIVERG # "1"
		Return
	EndIf

	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
	While CB8->(!Eof() .and. CB8_ORDSEP == CB7->CB7_ORDSEP)
		If ! AllTrim(CB8->CB8_OCOSEP) $ cDivItemPv
			CB8->(DbSkip())
			Loop
		EndIf
		If (Ascan(aItensDiverg,{|x| x[1]+x[2]+x[3]+x[6]+x[7]+x[8]== ;
				CB8->(CB8_PEDIDO+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_SEQUEN)})) == 0
			aAdd(aItensDiverg,{CB8->CB8_PEDIDO,CB8->CB8_ITEM,CB8->CB8_PROD,If(CB8->(CB8_QTDORI-CB8_SALDOS)==0,CB8->CB8_QTDORI,CB8->(CB8_QTDORI-CB8_SALDOS)),CB8->(Recno()),CB8->CB8_LOCAL,CB8->CB8_LCALIZ,CB8->CB8_SEQUEN})
		EndIf
		CB8->(DbSkip())
	EndDo
	If Empty(aItensDiverg)
		RestArea(aSvSC6)
		RestArea(aSvCB8)
		RestArea(aSvAlias)
		Return
	EndIf

	Libera(aItensDiverg)  //Estorna a liberacao de credito/estoque dos itens divergentes ja liberados

// ---- Exclusao dos itens da Ordem de Separacao com divergencia (MV_DIVERPV):
	For i:=1 to len(aItensDiverg)
		CB8->(DbGoto(aItensDiverg[i][5]))
		RecLock("CB8")
		CB8->(DbDelete())
		CB8->(MsUnlock())

		// ---- Exclusao dos itens separados com divergencias
		CB9->(DbSetOrder(9))
		CB9->(DbSeek(xFilial("CB9")+CB8->(CB8_ORDSEP+CB8_PROD+CB8_LOCAL)))
		While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOCAL == xFilial("CB9")+CB8->(CB8_ORDSEP+CB8_PROD+CB8_LOCAL))
			If CB9->(CB9_ITESEP+CB9_SEQUEN) == CB8->(CB8_ITEM+CB8_SEQUEN)
				RecLock("CB9")
				CB9->(DbDelete())
				CB9->(MsUnlock())
				CB9->(DbSkip())
			Else
				CB9->(DbSkip())
			EndIf
		EndDo
	Next i

// ---- Alteracao do CB7:
	RecLock("CB7")
	CB8->(dbSetOrder(1))
	If !CB8->(MsSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
		CB7->(dbDelete())
	Else
		CB7->CB7_DIVERG := ""
	EndIf
	CB7->(MsUnlock())

	RestArea(aSvSB7)
	RestArea(aSvSC6)
	RestArea(aSvCB8)
	RestArea(aSvAlias)
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Libera   � Autor � ACD                   � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Faz a liberacao do Pedido de Venda para a geracao da NF    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Libera(aItensDiverg)
	Local nX,ny
	Local nQtdLib   := 0
	Local lContinua := .f.
	Local aPedidos  := {}
	Local aEmp      := {}
	Local aCB8      := CB8->( GetArea() )
	Local lACD166FLIB := .F.
	Local l166FLIB 	:= ExistBlock("ACD166FLIB")
	Local nPosDiv 	:= 0

	Default aItensDiverg := {}

	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))
	While  CB8->(! Eof() .AND. CB8_FILIAL+CB8_ORDSEP==xFilial("CB8")+cOrdSep)
		If Ascan(aPedidos,{|x| x[1]+x[2]== CB8->(CB8_PEDIDO+CB8_ITEM)}) == 0
			aAdd(aPedidos,{CB8->CB8_PEDIDO,CB8->CB8_ITEM})
		EndIf
		CB8->(DbSkip())
		Loop
	EndDo

	aPvlNfs  :={}
	For nX:= 1 to len(aPedidos)
		//���������������������������Ŀ
		//�Libera quantidade embarcada�
		//�����������������������������
		SC5->(dbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+aPedidos[nx,1]))
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6")+aPedidos[nx,1]+aPedidos[nx,2]))
		SC9->(DbSetOrder(1))
		If !SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+aPedidos[nx,2]))
			While SC6->(!Eof() .and. C6_FILIAL+C6_NUM+C6_ITEM==xFilial("SC6")+aPedidos[nX,1]+aPedidos[nx,2])
				aEmp := LoadEmpEst()
				nQtdLib := SC6->C6_QTDVEN
				//��������������������������������������������������������������Ŀ
				//� LIBERA (Pode fazer a liberacao novamente caso com novos lotes�
				//�         caso possua)                                         �
				//����������������������������������������������������������������
				MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmp,.T.)
				SC6->(DbSkip())
			EndDo
			Loop
		EndIf

		ny:= nx
		While SC6->(!Eof() .and. C6_FILIAL+C6_NUM+C6_ITEM==xFilial("SC6")+aPedidos[ny,1]+aPedidos[ny,2])
			If !Empty(aItensDiverg)
				If Empty(Ascan(aItensDiverg,{|x| x[1]+x[2]+x[3]== SC6->(C6_NUM+C6_ITEM+C6_PRODUTO)}))
					SC6->(DbSkip())
					Loop
					ny ++
				EndIf
			EndIf
			nQtdLib   := SC6->C6_QTDVEN
			lContinua := .f.
			While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO+C9_ITEM==xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))
				If Empty(SC9->C9_NFISCAL) .and. SC9->C9_AGREG == CB7->CB7_AGREG
					lContinua:= .t.
					Exit
				EndIf
				SC9->(DbSkip())
			EndDo
			If ! lContinua
				SC6->(DbSkip())
				Loop
			EndIf

			If l166FLIB
				// Ponto de entrada para forcar a liberacao de pedidos:
				lACD166FLIB := ExecBlock("ACD166FLIB",.F.,.F.)
				lACD166FLIB := (If(ValType(lACD166FLIB) == "L",lACD166FLIB,.F.))
			Endif

			//Esta validacao sera verdadeira se o produto tiver rastro e nao houver verficacao no momento da leitura
			//sendo assim sendo necessario estonar o SDC e gera outro conforme os itens lidos pelo coletor.
			//ou se o item do pedido estiver marcado com divergencia da leitura o mesmo devera ser estornado e sera
			//necessario liberar novamente sem o vinculo da ordem de separacao.
			If (RASTRO(SC6->C6_PRODUTO) .AND. CB8->CB8_CFLOTE <> "1" ) .or. !Empty(aItensDiverg) .or. lACD166FLIB
				aEmp := LoadEmpEst()
				While (nPosDiv := Ascan(aItensDiverg,{|x| x[1]+x[2]+x[3]== SC6->(C6_NUM+C6_ITEM+C6_PRODUTO)},nPosDiv+1)) > 0
					A166AvalLb(aEmp,aItensDiverg[nPosDiv])
				End
			EndIf

			SC9->(DbSetOrder(1))
			SC9->(DbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))               //FILIAL+NUMERO+ITEM
			While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO+C9_ITEM==xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))
				If ! Empty(SC9->C9_NFISCAL) .or. SC9->C9_AGREG # CB7->CB7_AGREG .or. SC9->C9_ORDSEP # CB7->CB7_ORDSEP
					SC9->(DbSkip())
					Loop
				EndIf
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))              //FILIAL+PRODUTO
				SB2->(DbSetOrder(1))
				SB2->(DbSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))  //FILIAL+PRODUTO+LOCAL
				SF4->(DbSetOrder(1))
				SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES) )                 //FILIAL+CODIGO
				SC9->(aadd(aPvlNfs,{C9_PEDIDO,;
					C9_ITEM,;
					C9_SEQUEN,;
					C9_QTDLIB,;
					C9_PRCVEN,;
					C9_PRODUTO,;
					(SF4->F4_ISS=="S"),;
					SC9->(RecNo()),;
					SC5->(RecNo()),;
					SC6->(RecNo()),;
					SE4->(RecNo()),;
					SB1->(RecNo()),;
					SB2->(RecNo()),;
					SF4->(RecNo())}))
				SC9->(DbSkip())
			EndDo
			SC6->(DbSkip())
		Enddo
	Next

	CB8->(RestArea(aCB8))
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � LoadEmpEst      � Autor � ACD            � Data � 21/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Reajusta o empenho dos produtos separados caso necessario  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LoadEmpEst(lLotSug,lTroca)
	Local aEmp:={}
	Local aEtiqueta:={}
	Default lLotSug := .T.
	Default lTroca  := .F.

	CB9->(DBSetOrder(11))
	CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PEDIDO == xFilial("CB9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM)
		If !lLotSug .And. lTroca
			nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[11] == CB9->(CB9_LOTECT+CB9_NUMLOT+CB9_LCALIZ+CB9_NSERSU+CB9_LOCAL)})
			If !CB9->(a166VldSC9(1,CB9_PEDIDO+CB9_ITESEP+CB9_SEQUEN+CB9_PROD))
				If Empty(nPos)
					CB9->(aadd(aEmp,{CB9_LOTECT, ;								                  // 1
					CB9_NUMLOT,;								                  // 2
					CB9_LCALIZ, ;								                  // 3
					CB9_NSERSU,;                                             // 4
					CB9_QTESEP,;								                  // 5
					ConvUM(CB9_PROD,CB9_QTESEP,0,2),;                        // 6
					a166DtVld(CB9_PROD,CB9_LOCAL,CB9_LOTECT, CB9_NUMLOT),;  // 7
					,;                 						                  // 8
					,;									                         // 9
					,;									                         // 10
					CB9_LOCAL,;								                  // 11
					0}))								                         // 12
				Else
					aEmp[nPos,5] +=CB9->CB9_QTESEP
				EndIf
			EndIf
		ElseIf !lLotSug
			nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[11] == CB9->(CB9_LOTECT+CB9_NUMLOT+CB9_LCALIZ+CB9_NSERSU+CB9_LOCAL)})
			If Empty(nPos)
				CB9->(aadd(aEmp,{CB9_LOTECT, ;								                  // 1
				CB9_NUMLOT,;								                  // 2
				CB9_LCALIZ, ;								                  // 3
				CB9_NSERSU,;                                             // 4
				CB9_QTESEP,;								                  // 5
				ConvUM(CB9_PROD,CB9_QTESEP,0,2),;                        // 6
				a166DtVld(CB9_PROD,CB9_LOCAL,CB9_LOTECT, CB9_NUMLOT),;  // 7
				,;                 						                  // 8
				,;									                         // 9
				,;									                         // 10
				CB9_LOCAL,;								                  // 11
				0}))								                         // 12
			Else
				aEmp[nPos,5] +=CB9->CB9_QTESEP
			EndIf
		Else
			nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[11] == CB9->(CB9_LOTSUG+CB9_SLOTSUG+CB9_LCALIZ+CB9_NSERSU+CB9_LOCAL)})
			If Empty(nPos)
				CB9->(aadd(aEmp,{CB9_LOTSUG,;								                  // 1
				CB9_SLOTSUG,;								                  // 2
				CB9_LCALIZ,;								                  // 3
				CB9_NSERSU,;                                             // 4
				CB9_QTESEP,;								                  // 5
				ConvUM(CB9_PROD,CB9_QTESEP,0,2),;                        // 6
				a166DtVld(CB9_PROD,CB9_LOCAL,CB9_LOTECT, CB9_NUMLOT),;  // 7
				,;                                                       // 8
				,;                                                       // 9
				,;                                                       // 10
				CB9_LOCAL,;								                  // 11
				0}))								                         // 12
			Else
				aEmp[nPos,5] +=CB9->CB9_QTESEP
			EndIf
		EndIf
		If ! Empty(CB9->CB9_CODETI)
			aEtiqueta := CBRetEti(CB9->CB9_CODETI,"01")
			If ! Empty(aEtiqueta)
				aEtiqueta[13]:= CB7->CB7_NOTA
				aEtiqueta[14]:= CB7->CB7_SERIE
				CBGrvEti("01",aEtiqueta,CB9->CB9_CODETI)
			EndIf
		EndIf
		CB9->(DBSkip())
	EndDo
Return aEmp


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � RequisitOP � Autor � ACD                 � Data � 03/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Executa rotina automatica de requisicao - MATA240          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RequisitOP(lEstorno,lApp)
	Local aMata     := {}
	Local aEmp      := {}
	Local dValid    := ctod('')
	Local nModuloOld:= nModulo
	Local aCB8      := CB8->(GetArea())
	Local aSD3      := SD3->(GetArea())
	Local cTRT      := ""
	Local n1        := 0
	Local aRetPESD3 := {}
	Local lEstReq   := .F.
	Local lACD166RQ := ExistBlock("ACD166RQ")

	Private nModulo  := 4
	Private cTM      := GETMV("MV_CBREQD3")
	Private cDistAut := GETMV("MV_DISTAUT")

	Default lEstorno := .F.
	Default lApp	 := .F.

/*
SANDRO E ERIKE:

- Criei um campo para controle do N.Docto na separacao: CB9_DOC cujo contira o documento D3_DOC.
  O mesmo deverah ser criado no ATUSX, certo!

BY ERIKE : O campo ja foi criado no ATUSX
*/
	If !lApp
		If ! lEstorno
			If ! VTYesNo(STR0124,STR0010,.t.) //"Confirma a requisicao dos itens?"###"Aviso"
				Return .f.
			EndIf
		Else
			If ! VTYesNo(STR0125,STR0010,.t.) //"Confirma o estorno da requisicao dos itens?"###"Aviso"
				Return .f.
			EndIf
		EndIf
		VTMSG(STR0126) //"Processando"
	EndIf

	aEmp := A166AvalEm(lEstorno)

	Begin Transaction
		SB1->(DbSetOrder(1))
		CB8->(DbSetOrder(4))
		CB9->(DBSetOrder(1))
		CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
		While CB9->(! Eof() .And. xFilial("CB9")+CB7->CB7_ORDSEP == CB9_FILIAL+CB9_ORDSEP)
			If	If(lEstorno,!Empty(CB9->CB9_DOC),Empty(CB9->CB9_DOC))
				If	(n1 := aScan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[5]==CB9->(CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU)}))>0
					If lEstorno .AND. CBArmProc(CB9->CB9_PROD,cTM) .AND. !Empty(cDistAut)
						//Usuario deve estornar o enderecamento do Armazem de Processo (MV_DISTAUT), atraves do Protheus
						//para posteriormente estornar a requisicao e a separacao atraves desta rotina
						lEstReq := .T.
						If !lApp
							VTBeep(2)
							VTAlert(STR0136,STR0010,.T.,6000)//"Existem produtos enderecados para o Armazem de processo!","Aviso"
						EndIf
						DisarmTransaction()
						Break
					Endif
					cTRT := aEmp[n1,7]
					If !Empty(cTRT)
						aEmp[n1,1] := ' '
					EndIf
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
					SB1->(DbSeek(xFilial("SB1")+CB9->CB9_PROD))
					aMata  := {}
					If	!lEstorno
						aadd(aMata,{"D3_TM"  ,cTM				,nil})
						aadd(aMata,{"D3_DOC" ,NextDoc()			,nil})
					Else
						aadd(aMata,{"D3_DOC" ,CB9->CB9_DOC		,nil})
					EndIf
					aadd(aMata,{"D3_COD"    ,CB9->CB9_PROD		,nil})
					aadd(aMata,{"D3_UM"     ,SB1->B1_UM			,nil})
					aadd(aMata,{"D3_QUANT"  ,CB9->CB9_QTESEP	,nil})
					aadd(aMata,{"D3_LOCAL"  ,CB9->CB9_LOCAL		,nil})
					aadd(aMata,{"D3_LOCALIZ",CB9->CB9_LCALIZ	,nil})
					aadd(aMata,{"D3_LOTECTL",CB9->CB9_LOTECT	,nil})
					aadd(aMata,{"D3_NUMLOTE",CB9->CB9_NUMLOT	,nil})
					If !CBArmProc(CB9->CB9_PROD,cTM)
						aadd(aMata,{"D3_OP"     ,CB8->CB8_OP		,nil})
					Endif
					aadd(aMata,{"D3_EMISSAO",dDataBase			,nil})
					aadd(aMata,{"D3_TRT"    ,cTRT				,nil})
					If	Rastro(CB9->CB9_PROD)
						dValid := dDataBase+SB1->B1_PRVALID
						aadd(aMata,{"D3_LOTECTL",CB9->CB9_LOTECT	,nil})
						aadd(aMata,{"D3_NUMLOTE",CB9->CB9_NUMLOT   	,nil})
						aadd(aMata,{"D3_DTVALID",dValid            	,nil})
					EndIf

					aadd(aMata,{"D3_NUMSERI"    , CB9->CB9_NUMSER	,nil})

					If	lACD166RQ
						aRetPESD3 := ExecBlock("ACD166RQ",.F.,.F.,{aMata})
						If	Valtype(aRetPESD3) == 'A'
							aMata := aClone(aRetPESD3)
						EndIf
					EndIf
					If	lEstorno
						aadd(aMata,{"INDEX"  ,2						,nil}) // Ordem do indice SD3(2) = D3_FILIAL+D3_DOC+D3_COD
					Endif
					lMSErroAuto := .F.
					lMSHelpAuto := .T.
					SD3->(DbSetOrder(2))
					SD3->(DbSeek(xFilial("SD3")+CB9->CB9_DOC))
					MSExecAuto({|x,y|MATA240(x,y)},aMata,If(!lEstorno,3,5))
					lMSHelpAuto := .F.
					If	lMSErroAuto
						VTBeep(2)
						VTAlert(STR0029+cTM,STR0010,.T.,6000) //"Falha na gravacao movimentacao TM "###"Aviso"
						DisarmTransaction()
						Break
					EndIf
					RecLock("CB9",.F.)
					CB9->CB9_DOC := If(lEstorno,Space(TamSx3("CB9_DOC")[1]),SD3->D3_DOC)
					CB9->(MsUnlock())
				EndIf
			EndIf
			CB9->(DbSkip())
		EndDo
		nModulo := nModuloOld
		CB7->(RecLock("CB7"))
		If	lEstorno
			CB7->CB7_REQOP := "0"
		Else
			CB7->CB7_REQOP := "1"
		EndIf
		CB7->(MsUnlock())
	End Transaction
	If	lMSErroAuto
		VTDispFile(NomeAutoLog(),.t.)
	EndIf

	CB8->(RestArea(aCB8))
	SD3->(RestArea(aSD3))
Return !lMSErroAuto .OR. !lEstReq


Static Function NextDoc()
	Local aSvAlias   := GetArea()
	Local aSvAliasD3 := SD3->(GetArea())
	Local cDoc := Space(TamSx3("D3_DOC")[1])

	SD3->(DbSetOrder(2))
	cDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	While SD3->(DbSeek(xFilial("SD3")+cDoc))
		cDoc := Soma1(cDoc,Len(SD3->D3_DOC))
	Enddo

	RestArea(aSvAliasD3)
	RestArea(aSvAlias)
Return cDoc

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A166AvalEm� Autor � Flavio Luiz Vicco     � Data � 08/03/08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida se pode baixar o empenho e campo _TRT               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A166AvalEm(lEstorno)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametro � lEstorno = .T. - Estorno                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = Empenhos                                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � ACDV166                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A166AvalEm(lEstorno)
	Local aEmp     := {}
	Local n1       := 0
	Local nTam     := TamSx3("CB7_OP")[1]
	Local aAreaCB8 := CB8->(GetArea())
	Local aAreaSD4 := SD4->(GetArea())
	Local aAreaSDC := SDC->(GetArea())
	CB8->(DbSetOrder(6))
	SDC->(DbSetOrder(2))
	SD4->(DbSetOrder(2))
	SD4->(DbSeek(xFilial('SD4')+CB7->CB7_OP))
	While SD4->(!Eof() .And. D4_FILIAL+Left(D4_OP,nTam) == xFilial('SD4')+CB7->CB7_OP)
		If	If(lEstorno,.T.,SD4->D4_QUANT > 0)
			If !CBArmProc(SD4->D4_COD,cTM) .AND. Localiza(SD4->D4_COD)
				SDC->(DbSeek(SD4->(xFilial('SDC')+D4_COD+D4_LOCAL+D4_OP+D4_TRT)))
				While SDC->(!Eof() .And. DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT == SD4->(xFilial('SD4')+D4_COD+D4_LOCAL+D4_OP+D4_TRT))
					If	If(lEstorno,.T.,SDC->DC_QUANT > 0)
						If	(n1:=aScan(aEmp,{|x| x[1]+x[2]==SDC->(DC_PRODUTO+DC_TRT)}))==0
							SDC->(aAdd(aEmp,{DC_PRODUTO, DC_LOCAL, DC_LOCALIZ, DC_LOTECTL, DC_NUMLOTE, If(lEstorno,DC_QTDORIG,DC_QUANT), DC_TRT}))
						Else
							aEmp[n1,6] += SDC->DC_QUANT
						EndIf
					EndIf
					SDC->(DbSkip())
				EndDo
			ElseIf CBArmProc(SD4->D4_COD,cTM)
				CB8->(DBSeek(xFilial("CB8")+CB7->CB7_OP))
				While CB8->(!Eof() .AND. CB8_FILIAL+CB8_OP == xFilial("CB8")+CB7->CB7_OP)
					If (CB8->CB8_PROD <> SD4->D4_COD)
						CB8->(DbSkip())
						Loop
					Endif
					If	(n1:=aScan(aEmp,{|x| x[1]+x[2]+x[3]+x[4]+x[5]==CB8->(CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT)}))==0
						CB8->(aAdd(aEmp,{CB8_PROD, CB8_LOCAL, CB8_LCALIZ, CB8_LOTECT, CB8_NUMLOT, If(lEstorno,CB8_QTDORI,CB8_QTDORI), SD4->D4_TRT}))
					Else
						aEmp[n1,6] += CB8->CB8_QTDORI
					EndIf
					CB8->(DbSkip())
				Enddo
			Else
				If	(n1:=aScan(aEmp,{|x| x[1]+x[2]==SD4->(D4_COD+D4_TRT)}))==0
					SD4->(aAdd(aEmp,{D4_COD, D4_LOCAL, Space(TamSX3("BF_LOCALIZ")[01]), D4_LOTECTL, D4_NUMLOTE, If(lEstorno,D4_QTDEORI,D4_QUANT), D4_TRT}))
				Else
					aEmp[n1,6] += SD4->D4_QUANT
				EndIf
			EndIf
		EndIf
		SD4->(DbSkip())
	EndDo
	RestArea(aAreaSDC)
	RestArea(aAreaSD4)
	RestArea(aAreaCB8)
Return aEmp

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A166VldCB9� Autor � Felipe Nunes de Toledo� Data � 15/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida se a etiqueta ja foi separada.                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A166VldCB9(cProd, cCodEti)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametro � cProd     = Cod. Produto                                   ���
���          � cCodEti   = Cod. Etiqueta                                  ���
���          � lPreSep   = Verifica Pre-Separacao                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico = (.T.) Ja separada  / (.F.) Nao separada           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � ACDV166 / ACDV165                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A166VldCB9(cProd, cCodEti, lPreSep)
	Local cSeekCB9  := ""
	Local lRet      := .F.
	Local aArea     := { CB7->(GetArea()), CB9->(GetArea()) }

	Default lPreSep := .F.

	CB9->(DbSetOrder(3))
	If CB9->(DbSeek(cSeekCB9 := xFilial("CB9")+cProd+cCodEti))
		If lPreSep
			lRet := .T.
		EndIf
		Do While !lRet .And. CB9->(CB9_FILIAL+CB9_PROD+CB9_CODETI) == cSeekCB9
			CB7->(DbSetOrder(1))
			If CB7->(DbSeek(xFilial("CB7")+CB9->CB9_ORDSEP)) .And. !("09*" $ CB7->CB7_TIPEXP)
				lRet := .T.
				Exit
			EndIf
			CB9->(dbSkip())
		EndDo
	EndIf

	RestArea(aArea[1])
	RestArea(aArea[2])
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} SubNSer
Faz a troca do numero de serie selecionado pelo sistema na libera��o do PV;
 pelo numero de serie lido pelo operador no ato da separacao

@author: Aecio Ferreira Gomes
@since: 25/09/2013
@Obs: ACDV166
/*/
// -------------------------------------------------------------------------------------
Static Function SubNSer(cLote,cSLote,cEndNew,cNumSer,cSequen)
	Local aSvAlias		:= GetArea()
	Local aSvSC5		:= SC5->(GetArea())
	Local aSvSC6		:= SC6->(GetArea())
	Local aSvSC9		:= SC9->(GetArea())
	Local aSvCB8		:= CB8->(GetArea())
	Local aSvSB7		:= SB7->(GetArea())
	Local aSvCB9		:= CB9->(GetArea())
	Local aCampos		:= {}
	Local cAlias1 		:= "TMPNSSUG"
	Local cAlias2 		:= "TMPNSLIDO"
	Local nQuant 		:= 0
	Local nQuant2       := 0
	Local nBaixa        := 0
	Local nBaixa2		:= 0
	Local nX			:= 0
	Local lRastro		:= .F.

	Default cSequen		:= ""

	If Select(cAlias1) <= 0
		Return
	EndIf

	If (cAlias1)->REG > 0
		lRastro := Rastro((cAlias1)->DC_PRODUTO)

		If Select(cAlias2) > 0 .And. (cAlias2)->REG > 0

			If SC9->(dbSeek(xFilial("SC9")+(cAlias2)->(DC_PEDIDO+DC_ITEM+DC_SEQ+DC_PRODUTO)))

				// Atualiza a libera��o do pedido de vendas quando produto controlar lote e for diferente do lote sugerido
				If lRastro .And. (cAlias2)->(DC_LOTECTL+DC_NUMLOTE) # (cAlias1)->(DC_LOTECTL+DC_NUMLOTE)
					AtuLibPV(@cSequen,cAlias1,"DC_LOTECTL","DC_NUMLOTE")
				EndIf

				// Atualiza o empenho
				aCampos := SDC->(dbStruct())
				SDC->(dbGoTo((cAlias1)->REG))
				RecLock("SDC",.F.)
				SDC->(dbDelete())
				SDC->(MsUnlock())

				RecLock("SDC",.T.)
				For nX:= 1 To Len(aCampos)
					If (aCampos[nX,1] $ "DC_LOTECTL|DC_NUMLOTE|DC_LOCALIZ|DC_NUMSERI")
						&(aCampos[nX,1]) := (cAlias2)->&(aCampos[nX,1])
						Loop
					EndIf
					If(aCampos[nX,1] $ "DC_SEQ|DC_TRT")
						&(aCampos[nX,1]) := cSequen
						Loop
					EndIf
					&(aCampos[nX,1]) := (cAlias1)->&(aCampos[nX,1])
				Next
				SDC->(MsUnlock())
			EndIf

			If SC9->(dbSeek(xFilial("SC9")+(cAlias1)->(DC_PEDIDO+DC_ITEM+DC_SEQ+DC_PRODUTO)))

				// Atualiza a libera��o do pedido de vendas quando produto controlar lote e for diferente do lote sugerido
				If lRastro .And. (cAlias2)->(DC_LOTECTL+DC_NUMLOTE) # (cAlias1)->(DC_LOTECTL+DC_NUMLOTE)
					AtuLibPV(@cSequen,cAlias2,"DC_LOTECTL","DC_NUMLOTE")
				EndIf

				// Atualiza o empenho
				aCampos := SDC->(dbStruct())
				SDC->(dbGoTo((cAlias2)->REG))
				RecLock("SDC",.F.)
				SDC->(dbDelete())
				SDC->(MsUnlock())

				RecLock("SDC",.T.)
				For nX:= 1 To Len(aCampos)
					If (aCampos[nX,1] $ "DC_LOTECTL|DC_NUMLOTE|DC_LOCALIZ|DC_NUMSERI")
						&(aCampos[nX,1]) := (cAlias1)->&(aCampos[nX,1])
						Loop
					EndIf
					If(aCampos[nX,1] $ "DC_SEQ|DC_TRT")
						&(aCampos[nX,1]) := cSequen
						Loop
					EndIf
					&(aCampos[nX,1]) := (cAlias2)->&(aCampos[nX,1])
				Next
				SDC->(MsUnlock())
			EndIf
			// Guarda os dados do registro lido
			cLote	:= (cAlias2)->DC_LOTECTL
			cSLote	:= (cAlias2)->DC_NUMLOTE
			cEndNew	:= (cAlias2)->DC_LOCALIZ
		Else
			If SC9->(dbSeek(xFilial("SC9")+(cAlias1)->(DC_PEDIDO+DC_ITEM+DC_SEQ+DC_PRODUTO)))

				//---------------------------------------------------------------------------
				// Apaga empenho do numero de serie sugerido e atualiza os saldos
				//---------------------------------------------------------------------------
				// Deleta empenho da tabela SDC
				SDC->(dbGoto((cAlias1)->REG))
				RecLock("SDC")
				SDC->(dbDelete())
				MsUnlock()

				// Atualiza empenhos da tabela SB8
				If lRastro
					cSeek := xFilial("SB8")+(cAlias1)->(DC_PRODUTO+DC_LOCAL+DC_LOTECTL+If(Rastro( (cAlias1)->(DC_PRODUTO) , "S"), DC_NUMLOTE, "") )
					nQuant := (cAlias1)->DC_QUANT
					nQuant2 := (cAlias1)->DC_QTSEGUM
					SB8->(dbSetOrder(3))
					If SB8->(dbSeek(cSeek))
						If Rastro((cAlias1)->(DC_PRODUTO), "S")
							SB8->( GravaB8Emp("-",nQuant,"F",.T.,nQuant2) )
						Else
							Do While SB8->(!Eof() .And. B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL == cSeek) .And. nQuant > 0
								//��������������������������������������������Ŀ
								//� Baixa o empenho que conseguir neste lote   �
								//����������������������������������������������
								nBaixa := Min(SB8->B8_EMPENHO,nQuant)
								nBaixa2:= Min(SB8->B8_EMPENH2,nQuant2)
								nQuant -= nBaixa
								nQuant2 -= nBaixa2
								SB8->(GravaB8Emp("-",nBaixa,"F",.T.,nBaixa2))
								SB8->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf

				// Atualiza empenhos da tabela SBF
				SBF->(dbSetOrder(4))
				If SBF->(dbSeek(xFilial("SBF")+(cAlias1)->(DC_PRODUTO+DC_NUMSERIE)))
					SBF->(GravaBFEmp("-",1,"F",.T.,(cAlias1)->DC_QTSEGUM))
				EndIf

				// Atualiza empenhos da tabela SB2
				SB2->(dbSetOrder(1))
				If SB2->(dbSeek(xFilial("SB2")+(cAlias1)->(DC_PRODUTO+DC_LOCAL)))
					SB2->(GravaB2Emp("-",1,"F",.T.,(cAlias1)->DC_QTSEGUM))
				EndIf

				//---------------------------------------------------------------------------
				// Grava empenho do numero de serie lido para o pedido de vendas
				//---------------------------------------------------------------------------
				SBF->(dbSetOrder(4))
				SBF->(dbSeek(xFilial("SBF")+(cAlias1)->(DC_PRODUTO)+cNumSer))

				// Atualiza a libera��o do pedido de vendas quando produto controlar lote e for diferente do lote sugerido
				If lRastro .And. SBF->(BF_LOTECTL+BF_NUMLOTE) # (cAlias1)->(DC_LOTECTL+DC_NUMLOTE)
					AtuLibPV(@cSequen,"SBF","BF_LOTECTL","BF_NUMLOTE")
				EndIf

				SBF->(GravaEmp(BF_PRODUTO,;  //-- 01.C�digo do Produto
				BF_LOCAL,;    	//-- 02.Local
				BF_QUANT,;   	//-- 03.Quantidade
				BF_QTSEGUM,;  //-- 04.Quantidade
				BF_LOTECTL,;  //-- 05.Lote
				BF_NUMLOTE,;  //-- 06.SubLote
				BF_LOCALIZ,;  //-- 07.Localiza��o
				BF_NUMSERIE,; //-- 08.Numero de S�rie
				Nil,;         	//-- 09.OP
				cSequen,;        	//-- 10.Seq. do Empenho/Libera��o do PV (Pedido de Venda)
				(cAlias1)->DC_PEDIDO,;  	//-- 11.PV
				(cAlias1)->DC_ITEM,;     	//-- 12.Item do PV
				'SC6',;       	//-- 13.Origem do Empenho
				Nil,;        	//-- 14.OP Original
				Nil,;			//-- 15.Data da Entrega do Empenho
				NIL,;			//-- 16.Array para Travamento de arquivos
				.F.,;     	   	//-- 17.Estorna Empenho?
				.F.,;         	//-- 18.? chamada da Proje��o de Estoques?
				.T.,;         	//-- 19.Empenha no SB2?
				.F.,;         	//-- 20.Grava SD4?
				.T.,;         	//-- 21.Considera Lotes Vencidos?
				.T.,;         //-- 22.Empenha no SB8/SBF?
				.T.))         //-- 23.Cria SDC?

				// Guarda os dados do registro lido
				cLote	:= SBF->BF_LOTECTL
				cSLote	:= SBF->BF_NUMLOTE
				cEndNew	:= SBF->BF_LOCALIZ
			EndIf
		EndIf
	EndIf

	RestArea(aSvAlias)
	RestArea(aSvSC5)
	RestArea(aSvSC6)
	RestArea(aSvSC9)
	RestArea(aSvCB8)
	RestArea(aSvSB7)
	RestArea(aSvCB9)
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuLibPV
Atualiza a libera��o do pedido de vendas

@param: cSequen - Sequencia do item da libera��o
		 cArqTRB - Alias do arquivo que contem os dados do item de troca do numero de serie
		 cCPOlote - Coluna do arquivo que contem o dado do Lote
		 cCPONLote - Coluna do arquivo que contem o dado do SubLote

@author: Aecio Ferreira Gomes
@since: 25/09/2013
@Obs: ACDV166
/*/
// -------------------------------------------------------------------------------------
Static Function AtuLibPV(cSequen, cArqTRB, cCPOLote, cCPONLote)
	Local aArea		:= GetArea()
	Local aCampos	:= {}
	Local aDados 	:= {}
	Local nX		:= 0
	Local cChave	:= ""
	Local cProduto	:= SC9->C9_PRODUTO

	cSequen := SC9->C9_SEQUEN
	cChave	:= SC9->(xFilial("SC9")+C9_PEDIDO+C9_ITEM)

	aCampos := SC9->(dbStruct())
	For nX := 1 To Len(aCampos)
		AADD(aDados,{aCampos[nX,1], SC9->&(aCampos[nX,1])})
	Next nX

	If SC9->C9_QTDLIB > 1
		Reclock("SC9",.F.)
		SC9->C9_QTDLIB -= 1
		MsUnlock()
	Else
		Reclock("SC9",.F.)
		SC9->(dbdelete())
		MsUnlock()
	EndIf

// Recupera a proxima sequencia livre
	While SC9->(dbSeek(cChave+cSequen+cProduto))
		cSequen := Soma1(SC9->C9_SEQUEN)
	End

	RecLock("SC9",.T.)
	For nX:= 1 To Len(aDados)
		Do Case
		Case aDados[nX,1] == "C9_LOTECTL"
			&(aDados[nX,1]) := (cArqTRB)->&(cCPOLote)
		Case aDados[nX,1] == "C9_NUMLOTE"
			&(aDados[nX,1]) := (cArqTRB)->&(cCPONLote)
		Case aDados[nX,1] $ "C9_SEQUEN"
			&(aDados[nX,1]) := cSequen
		Case aDados[nX,1] == "C9_QTDLIB"
			&(aDados[nX,1]) := 1
		OtherWise
			&(aDados[nX,1]) := aDados[nX,2]
		EndCase
	Next nX
	MsUnlock()

	RestArea(aArea)
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} v166TcLote
Efetua a troca dos lotes na liberacao do pedido de vendas.

@param: cOrdSep - Numero da ordem de separacao

@author: Anieli Rodrigues
@since: 15/12/2013
@Obs: ACDV166
/*/
// -------------------------------------------------------------------------------------

Static Function v166TcLote (cOrdSep)

	Local aAreaCB7 		:= CB7->(GetArea())
	Local aAreaCB8 		:= CB8->(GetArea())
	Local aAreaCB9 		:= CB9->(GetArea())
	Local aAreaSC6 		:= SC6->(GetArea())
	Local aAreaSC9 		:= SC9->(GetArea())
	Local aEmpPronto 	:= {}
	Local aItensTrc 	:= {}
	Local lLoteSug 		:= .F.
	Local nQtdSep		:= 0
	Local nX			:= 0
	Local nPos			:= 0
	Local nSaldoLote 	:= 0
	Local cItemAnt   	:= ""

	CB9->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	CB7->(DbSetOrder(1))
	CB7->(MsSeek(xFilial("CB7")+cOrdSep))
	CB9->(MsSeek(xFilial("CB9")+cOrdSep))
	SC6->(MsSeek(xFilial("SC6")+CB9->CB9_PEDIDO+CB9->CB9_ITESEP))

	While !CB9->(Eof()) .And. CB9->CB9_ORDSEP == cOrdSep
		If CB9->CB9_LOTECT != CB9->CB9_LOTSUG
			nPos := aScan (aItensTrc,{|x| x[1]+x[2]+x[3]+x[5] == CB9->CB9_PEDIDO+CB9->CB9_ITESEP+CB9->CB9_SEQUEN+CB9->CB9_LOTECT})
			If nPos == 0
				aAdd(aItensTrc, {CB9->CB9_PEDIDO, CB9->CB9_ITESEP, CB9->CB9_SEQUEN, CB9->CB9_QTESEP, CB9->CB9_LOTECT, CB9->CB9_NUMLOT,CB9->CB9_PROD, CB9->CB9_LOCAL})
				nQtdSep += CB9->CB9_QTESEP
			Else
				aItensTrc[nPos][4] 	+= CB9->CB9_QTESEP
				nQtdSep 			+= CB9->CB9_QTESEP
			EndIf
			CB9->(DbSkip())
		Else
			CB9->(DbSkip())
		EndIf
	EndDo

	SC9->(DbSetOrder(1))

	For nx := 1 to Len(aItensTrc)
		nSaldoLote := SaldoLote(aItensTrc[nX][7],aItensTrc[nX][8],aItensTrc[nX][5],aItensTrc[nX][6],,,,dDataBase,,)
		If nSaldoLote < aItensTrc[nX][4]
			VtAlert(STR0130 + Alltrim(aItensTrc[nX][5]) + STR0131 ,STR0014) //"Saldo do lote insuficiente. Sera utilizado o lote original da liberacao do pedido"
			lLoteSug := .T.
			Exit
		EndIf
		If !lLoteSug .And. SC9->(MsSeek(xFilial("SC9")+aItensTrc[nX][1]+aItensTrc[nX][2]+aItensTrc[nX][3]))
			SC9->(a460Estorna())
		EndIf
	Next nX

	CB9->(DbSetOrder(11)) // CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PEDIDO
	CB7->(DbSetOrder(1))	 // CB7_FILIAL+CB7_ORDSEP
	CB7->(MsSeek(xFilial("CB7")+cOrdSep))
	CB9->(MsSeek(xFilial("CB9")+cOrdSep))

	If !lLoteSug
		For nX := 1 to Len(aItensTrc)
			If SC6->(MsSeek(xFilial("SC6")+aItensTrc[nX][1]+aItensTrc[nX][2]))
				If cItemAnt != aItensTrc[nX][1]+aItensTrc[nX][2]
					aEmpPronto := LoadEmpEst(.F.,.T.)
					MaLibDoFat(SC6->(Recno()),aItensTrc[nX][4],.T.,.T.,.F.,.F.,.F.,.F.,NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmpPronto,.T.)
				EndIf
			EndIf
			cItemAnt := aItensTrc[nX][1]+aItensTrc[nX][2]
		Next nX
	EndIf

	RestArea(aAreaCB7)
	RestArea(aAreaCB8)
	RestArea(aAreaCB9)
	RestArea(aAreaSC6)
	RestArea(aAreaSC9)

Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A166AvalLb
Realiza a avalia��o da libera��o/estorno

@param: aEmp - Rela��o de Empenho
@param: aItensDiverg - Rela��o de Itens com Diverg�ncia

@author: Robson Sales
@since: 03/01/2014
@Obs: ACDV166
/*/
// -------------------------------------------------------------------------------------
Static Function A166AvalLb(aEmp,aItensDiverg)

	If !Empty(aItensDiverg)
		SC9->(DbSetOrder(1))
		If SC9->(DbSeek(xFilial("SC9")+aItensDiverg[1]+aItensDiverg[2]+aItensDiverg[8])) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			SC9->(a460Estorna())	 //estorna o que estava liberado no sdc e sc9
		EndIf
		// NAO LIBERA CREDITO NEM ESTOQUE...ITEM COM DIVERGENCIA APONTADA (MV_DIVERPV)
		MaLibDoFat(SC6->(Recno()),0,.F.,.F.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := Space(TamSx3("C9_ORDSEP")[1])},aEmp,.T.)

	Else
		// LIBERA NOVAMENTE COM OS NOVOS LOTES
		MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmp,.T.)
	EndIf

Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A166RetEti1
Retorno o codigo da etiqueta interna (CB0_CODETI) ou do cliente (CB0_CODET2)
dependendo do cID passado.

@param: cID - Numero da etiqueta

@author: Robson Sales
@since: 07/05/2014
@Obs: ACDV166
/*/
// -------------------------------------------------------------------------------------
Static Function A166RetEti(cID)

	Local cEtiqueta := ""
	Local aAreaCB0 := CB0->(GetArea())

	If Len(Alltrim(cID)) <=  TamSx3("CB0_CODETI")[1]
		CB0->(DbSetOrder(1))
		CB0->(MsSeek(xFilial("CB0")+Padr(cID,TamSx3("CB0_CODETI")[1])))
		cEtiqueta := CB0->CB0_CODET2
	ElseIf Len(Alltrim(cID)) ==  TamSx3("CB0_CODET2")[1]-1   // Codigo Interno  pelo codigo do cliente
		CB0->(DbSetOrder(2))
		CB0->(MsSeek(xFilial("CB0")+Padr(cID,TamSx3("CB0_CODET2")[1])))
		cEtiqueta := CB0->CB0_CODETI
	EndIf

	RestArea(aAreaCB0)

Return cEtiqueta

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} a166DtVld
Retorna a data de validade do lote

@param:  cProd    - Codigo do produto
          cLocal   - Armaz�m
          cLote    - Lote
          cSubLote - SubLote

@author: Isaias Florencio
@since: 06/10/2014
/*/
// -------------------------------------------------------------------------------------
Static Function a166DtVld(cProd,cLocal,cLote,cSubLote)
	Local aAreaAnt := GetArea()
	Local aAreaSB8 := SB8->(GetArea())
	Local dDtVld   := CTOD("")

// Indice 3 - SB8 - FILIAL + PRODUTO + LOCAL + LOTECTL + NUMLOTE + DTOS(B8_DTVALID)
	dDtVld := Posicione("SB8",3,xFilial("SB8")+cProd+cLocal+cLote+cSubLote,"B8_DTVALID")

	RestArea(aAreaSB8)
	RestArea(aAreaAnt)
Return dDtVld

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} a166VldSC9
Verifica se existe registro na SC9

@param:    nOrdem - Ordem de pesquisa
			cChave - Chave de pesquisa

@author: Isaias Florencio
@since: 06/10/2014
/*/
// -------------------------------------------------------------------------------------
Static Function a166VldSC9(nOrdem,cChave)
	Local aAreaAnt := GetArea()
	Local aAreaSC9 := SC9->(GetArea())
	Local lRet     := .F.

	SC9->(DbSetOrder(nOrdem))
	lRet := SC9->(MsSeek(xFilial("SC9")+cChave))

	RestArea(aAreaSC9)
	RestArea(aAreaAnt)
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A166GetEnd
Obt�m endereco do produto a ser estornado

@param:    cArmazem  - codigo do armazem
           cEndereco - codigo do endereco a ser obtido

@author: Isaias Florencio
@since:  22/01/2015
/*/
// -------------------------------------------------------------------------------------

Static Function A166GetEnd(cArmazem,cEndereco)
	Local aAreaAnt := GetArea()
	Local aSave    := VTSAVE()
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf

	If VTModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
		@ 1,0 VTSay STR0030 //"Leia o endereco"
		If UsaCB0("02")
			@ 2,0 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
		Else
			If Empty(cArmazem)
				@ 2,0 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem)
			Else
				@ 2,0 VTSay cArmazem pict "@!"
			EndIf
			@ 2,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2)
		EndIf
	Else
		@ 1,0 VTSay STR0054 //"Endereco"
		If UsaCB0("02")
			@ 1,10 VTGet cEtiqEnd pict "@!" valid VldEnd(@cArmazem,@cEndereco,cEtiqEnd,2)
		Else
			If Empty(cArmazem)
				@ 1,10 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem)
			Else
				@ 1,10 VTSay cArmazem pict "@!"
			EndIf
			@ 1,13 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2)
		EndIf
	EndIf
	VtRead
	VtRestore(,,,,aSave)

	RestArea(aAreaAnt)

Return Nil

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A166MtaEst
Monta tela de estorno at� o termino do processo

@param:    cEProduto - Produto da etiqueta
			nQtde     - Quantidade
			cArmazem  - codigo do armazem
           	cEndereco - codigo do endereco a ser obtido
          	cVolume   - Volume informado.

@author: Andre Maximo
@since:  03/05/2016
/*/
// -------------------------------------------------------------------------------------

Static Function A166MtaEst(nQtde,cArmazem,cEndereco,cVolume,nOpc)

	Local aSave	     := VTSave()
	Local aAreaAnt   := GetArea()
	Local cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	Local cIdVol     := Space(10)
	Local lLocaliz := SuperGetMV("MV_LOCALIZ") == "S"
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf
	Default nQtde     := 1
	Default cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
	Default cEndereco	 := Space(TamSX3("BF_LOCALIZ")[1])
	Default cVolume	 := Space(10)
	Default nOpc       := 1


	VtClear
	@ 0,0 VtSay Padc(STR0110,VTMaxCol()) //"Estorno da leitura"
	If lVT100B // GetMv("MV_RF4X20")
		While .T.
			VTClear(1,0,3,19)
			If lLocaliz .and. nOpc == 2 .and. Empty(CB7->CB7_PRESEP)
				@ 1,0 VTSay STR0054 //"Endereco"
				@ 1,10 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem) when IIF( !Empty(cArmazem), .F., .T.) .and. iif(lVolta,(VTKeyBoard(chr(13)),.T.),.T.)
				@ 1,13 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2) when IIF(!Empty(cEndereco) .And. !Empty(cEndereco),.F.,.T.) .and. iif(lVolta .and. (lForcaQtd .or. "01" $ CB7->CB7_TIPEXP),(VTKeyBoard(chr(13)),.T.),.T.)
			Else
				If Empty(cArmazem)
					@ 1,0 VTSay STR0053 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. (!Empty(cArmazem) .AND. VldEnd(@cArmazem,NIL,NIL,2)) when iif(lVolta .and. (lForcaQtd .or. "01" $ CB7->CB7_TIPEXP),(VTKeyBoard(chr(13)),.T.),.T.)//"Armazem"
				Else
					@ 1,0 VTSay STR0053 //"Armazem"
					@ 1,8 VTSay cArmazem
				EndIf
			EndIf

			If "01" $ CB7->CB7_TIPEXP
				@ 2,0 VTSay STR0063 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume) when IIF(!Empty(cVolume), .F., .T.) .and. iif(lVolta .and. lForcaQtd,(VTKeyBoard(chr(13)),.T.),.T.) //"Leia o volume"
				//@ 3,0 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume) when IIF(!Empty(cVolume), .F., .T.)
			EndIf

			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			cKey21  := VTDescKey(21)
			bKey21  := VTSetKey(21)

			@ 3,0 VTSay STR0047 VtGet nQtde PICTURE cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5, lVolta := .F.) //"Qtde "

			If !(vtLastKey() == 27)
				//segunda tela
				lVolta := .F.
				VTClear(1,0,3,19)
				//@ 0,0 VTSay STR0047 VtGet nQtde PICTURE cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Qtde "
				@ 1,0 VTSay STR0048 //"Leia o produto"
				@ 2,0 VTGet cProduto PICTURE "@!" VALID VTLastkey() == 5 .or. VldEstEnd(cProduto,@nQtde,cArmazem,cEndereco,cVolume,nOpc)
			EndIf

			If lVolta
				Loop
			EndIf
		EndDo
	Else
		If lLocaliz .and. nOpc == 2 .and. Empty(CB7->CB7_PRESEP)
			If VTModelo()=="RF"
				@ 1,0 VTSay STR0030 //"Leia o endereco"
				@ 2,0 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem) when IIF( !Empty(cArmazem), .F., .T.)
				@ 2,3 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2) when IIF(!Empty(cArmazem).And. !Empty(cEndereco), .F., .T.)
			Else
				@ 1,0 VTSay STR0054 //"Endereco"
				@ 1,10 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. !Empty(cArmazem) when IIF( !Empty(cArmazem), .F., .T.)
				@ 1,13 VTSay "-" VTGet cEndereco pict "@!" valid VtLastKey()==5 .or. VldEnd(@cArmazem,@cEndereco,NIL,2) when IIF(!Empty(cEndereco),.F.,.T.)
				VtRead
				If VtLastKey() == 27
					VTRestore(,,,,aTela)
					Return .f.
				EndIf
			EndIf
		Else
			If VTModelo()=="RF"
				@ 1,0 VTSay STR0111 //"Leia o Armazem"
				If Empty(cArmazem)
					@ 2,0 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. (!Empty(cArmazem) .AND. VldEnd(@cArmazem,NIL,NIL,2))
				Else
					@ 2,0 VTSay cArmazem
				EndIf
			Else
				@ 1,0 VTSay STR0053 VTGet cArmazem pict "@!" valid VtLastKey()==5 .or. (!Empty(cArmazem) .AND. VldEnd(@cArmazem,NIL,NIL,2)) //"Armazem"
				If VtLastKey() == 27
					VTRestore(,,,,aTela)
					Return .f.
				Endif
			EndIf
		EndIf
		If "01" $ CB7->CB7_TIPEXP
			If VTModelo()=="RF"
				@ 3,0 VTSay STR0063 //"Leia o volume"
				@ 4,0 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume) when IIF(!Empty(cVolume), .F., .T.)
			Else
				@ 1,0 Vtclear to 1,VtMaxCol()
				@ 1,0 VTSay STR0018 VTGet cIdVol pict "@!" Valid VldVolEst(cIdVol,@cVolume) when IIF(!Empty(cVolume), .F., .T.) //"Volume"
				VtRead
				If VtLastKey() == 27
					VTRestore(,,,,aTela)
					Return .f.
				Endif
			EndIf
		EndIf
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		cKey21  := VTDescKey(21)
		bKey21  := VTSetKey(21)

		If VtModelo() =="RF"
			@ 5,0 VTSay STR0047 VtGet nQtde PICTURE cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Qtde "
			@ 6,0 VTSay STR0048 //"Leia o produto"
			@ 7,0 VTGet cProduto PICTURE "@!" VALID VTLastkey() == 5 .or. VldEstEnd(cProduto,@nQtde,cArmazem,cEndereco,cVolume,nOpc)
		Else
			If VtModelo() =="MT44"
				@ 0,0 VTSay STR0112 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Estorno Qtde "
			Else // mt 16
				@ 0,0 VTSay STR0113 VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5) //"Est.Qtde "
			EndIf
			@ 1,0 VTSay STR0039 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldEstEnd(cProduto,@nQtde,cArmazem,cEndereco,cVolume,nOpc) //"Produto"
		EndIf
		VtRead
	Endif
	VTSetKey(21,bKey21,cKey21)

	If VtLastKey() == 27
		VTRestore(,,,,aSave)
		Return .f.
	Endif

	VtRestore(,,,,aSave)
	RestArea(aAreaAnt)

Return Nil
/*/{Protheus.doc} A166GetSld
Valida saldo disponivel por lote x saldo jah coletado

@param: cOrdSep,cProd,cArmazem,cEndereco,cLote,cSLote,cNumSer
Ordem de separacao, Produto,Armazem, endereco, lote, sublote e numero de serie

@author: Isaias Florencio
@since:  02/03/2015
/*/
// -------------------------------------------------------------------------------------

Static Function A166GetSld(cOrdSep,cProd,cArmazem,cEndereco,cLote,cSLote,cNumSer)
	Local aAreaAnt  := GetArea()
	Local nSaldo    := 0
	Local lRet      := .T.
	Local cAliasTmp := GetNextAlias()
	Local cQuery    := ""

	cQuery := "SELECT SUM(CB9.CB9_QTESEP) AS QTESEP FROM "+ RetSqlName("CB9")+" CB9 WHERE "
	cQuery += "CB9.CB9_FILIAL	= '" + xFilial('CB9') + "' AND "
	cQuery += "CB9.CB9_ORDSEP	= '" + cOrdSep        + "' AND CB9.CB9_PROD   = '"+ cProd     + "' AND "
	cQuery += "CB9.CB9_LOCAL	= '" + cArmazem       + "' AND CB9.CB9_LCALIZ = '"+ cEndereco + "' AND "
	cQuery += "CB9.CB9_LOTECT	= '" + cLote          + "' AND CB9.CB9_NUMLOT = '"+ cSLote    + "' AND "
	cQuery += "CB9.CB9_NUMSER	= '" + cNumSer        + "' AND CB9.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	nSaldo := (cAliasTmp)->QTESEP

	nSaldoAtu := SaldoLote(cProd,cArmazem,cLote,cSLote,,,,dDataBase,,)

//�����������������������������������������������������������������Ŀ
//� Se jah houver saldo separado na CB9, verifica se saldo eh menor �
//� ou igual ao saldo disponivel, devido a funcao SaldoLote() nao   |
//� considerar saldos separados na CB9. Caso ainda nao tenha havido |
//� separacoes na CB9, faz verificacao simples (menor)              |
//�������������������������������������������������������������������
	If nSaldo > 0
		lRet := !(nSaldoAtu <= nSaldo)
	Else
		lRet := !(nSaldoAtu < nSaldo)
	EndIf

	(cAliasTmp)->(DbCloseArea())

	RestArea(aAreaAnt)
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A166EndLot
Verifica se lote pertence ao endereco da OS

.T. = pertence ao mesmo endereco
.F. = nao pertence ao endereco da OS

@param: Produto, Lote, Sublote, Numero de serie, armazem e endereco da CB8

@author: Isaias Florencio
@since:  16/03/2015
/*/
// -------------------------------------------------------------------------------------

Static Function A166EndLot(cProduto,cLoteProd,cSublote,cNumSerie,cArmazem,cEndereco)
	Local aAreas   := { GetArea(), SBF->(GetArea()) }
	Local lRet	   := .T.

	SBF->(dbSetOrder(1)) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	If ! SBF->(MsSeek(xFilial("SBF")+cArmazem+cEndereco+cProduto+cNumSerie+cLoteProd+cSublote))
		lRet := .F.
	EndIf

	RestArea(aAreas[2])
	RestArea(aAreas[1])
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} 166PESQUISACB8
Verifica Integra��o com SIGAMNT e a Existencia de OS para OP


@author: BRUNO.SCHMIDT
@since:  02/08/2017
/*/
// -------------------------------------------------------------------------------------
Static Function ACDCB8PESQUISA()

	Local cAliasTmp	:= GetNextAlias()
	Local cQuery		:= ''
	Local lRet		:= .F.

	cQuery := "SELECT 1 FROM"+ RetSqlName("CB9")+" CB9 WHERE "
	cQuery += "CB9.CB9_FILIAL	= '" + xFilial('CB9') + "' AND CB9.CB9_LOCAL	= '" + cArmazem +"' AND "
	cQuery += "CB9.CB9_ORDSEP	= '" + cCodSep        +"' AND (CB9.CB9_QTESEP - CB9_XQTDTR) > 0 AND CB9.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)


	If (cAliasTmp)->(!Eof())
		lRet := .T.
	EndIf

Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} NSerLocal
Valida se a troca de Numero de s�rie est� sendo realizada dentro do mesmo armaz�m

@param cProd,cLocal,cNumSer
@author jose.eulalio
@since 17/07/2018
/*/
// -------------------------------------------------------------------------------------
Static Function NSerLocal(cProd,cLocal,cNumSerNew,cEndNew)
	Local lRet			:= .T.
	Local cAliasNSer	:= GetNextAlias()

	BeginSQL Alias cAliasNSer

SELECT 
	R_E_C_N_O_ AS REG, 
	BF_LOCALIZ AS ENDNEW	
FROM
	%table:SBF%
WHERE
	BF_FILIAL = %xFilial:SBF% AND
	BF_PRODUTO = %Exp:cProd% AND
	BF_LOCAL = %Exp:cLocal% AND
	BF_NUMSERI = %Exp:cNumSerNew% AND
	%notDel%
	EndSQL

	If lRet := Select(cAliasNSer) .And. (cAliasNSer)->REG > 0
		cEndNew := (cAliasNSer)->ENDNEW
	EndIf

	(cAliasNSer)->(DbCloseArea())

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � FimProc166 � Autor � ACD                 � Data � 22/05/19 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Aciona a fun��o de Finaliza o processo de separacao        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FimProc166(lApp,cOrdSep)
	FimProcess(lApp ,cOrdSep,cCodTrf,nOpc)
Return

//Funcoes para trazer a consulta em tela
Static Function DXSolCB7(nOpc,bBlcVld)
	Local cPedido,cNota,cSerie,cOP
	Local aTela:= VtSave()
	IF !Type("lVT100B") == "L"
		Private lVT100B := .F.
	EndIf
	If nOpc == 0
		Return Eval(bBlcVld)
	ElseIf nOpc ==1  // Embarque de Quantidade para Produ��o
		cOrdSep := Space(TamSX3("CB7_ORDSEP")[1])
		@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,2,0),0 VTSay "Informe a OS:"
		@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,3,1),0 VTGet cOrdSep PICT "@!" F3 "ZD1"  Valid Eval(bBlcVld)
		VTRead
	ElseIf nOpc ==2 // Recebimento pela Produ��o
		cOrdSep := Space(TamSX3("CB7_ORDSEP")[1])
		@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,2,0),0 VTSay "OS Recebimento:"
		@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,3,1),0 VTGet cOrdSep PICT "@!" F3 "ZD2"  Valid Eval(bBlcVld)
		VTRead
	ElseIf nOpc ==4 // por Nota fiscal
		cCodTrf := Space(TamSX3("CB7_ORDSEP")[1])
		@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,2,0),0 VTSay "OS Recebimento:"
		@ If(VTModelo()=="RF" .or. lVT100B /*GetMv("MV_RF4X20")*/,3,1),0 VTGet cCodTrf PICT "@!" F3 "ZD3"  Valid Eval(bBlcVld)
		VTRead
	ElseIf nOpc ==5 // por OP
		cOP:= Space(13)
		If lVT100B // GetMv("MV_RF4X20")
			@ 1,0 VTSay STR0024
			@ 2,0 VTSay STR0025
		ElseIf VTModelo()=="RF"
			@ 2,0 VTSay STR0024
			@ 3,0 VTSay STR0025
		Else
			@ 0,0 VTSay STR0026
		EndIf
		@ IIf(lVT100B /*GetMv("MV_RF4X20")*/,3,If(VTModelo()=="RF",4,1)),0 VTGet cOP Pict "@!" F3 "SC2" Valid (VldGet(cOp) .and. DXSelCB7(3,cOP) .and. Eval(bBlcVld) )
		VTRead
	EndIf
	VTRestore(,,,,aTela)
	If VTLastKey() == 27
		Return .f.
	EndIf
Return .t.


/*
nModo 
1=Pedido
2=Nota Fiscal Saida
3=OP
*/

Static Function DXSelCB7(nModo,cChave,lSerie,cNota,cSerie)
	Local aOrdSep:={}
	Local aCab
	Local aSize
	Local nPos
	Local aTela

	Default lSerie := .F.

	DbSelectArea("CB7")
	CB7->(DbSetOrder(1))
	DbSelectArea("CB8")

	If lSerie
		CBMULTDOC("SF2",cNota,@cSerie)
	EndIf


	If nModo == 1 // pedido
		CB8->(DbSetOrder(2))
		CB8->(DbSeek(xFilial("CB8")+cChave))
		bBlock:={|| CB8->(CB8_FILIAL+CB8_PEDIDO) == xFilial("CB8")+cChave}
	ElseIf nModo == 2
		CB8->(DbSetOrder(5))
		CB8->(DbSeek(xFilial("CB8")+cChave))
		bBlock:={|| CB8->(CB8_FILIAL+CB8_NOTA+CB8_SERIE) == xFilial("CB8")+cNota+cSerie}
	ElseIf nModo == 3
		CB8->(DbSetOrder(6))
		CB8->(DbSeek(xFilial("CB8")+cChave))
		bBlock:={|| CB8->(CB8_FILIAL+AllTrim(CB8_OP)) == xFilial("CB8")+AllTrim(cChave)}
	EndIf
	While ! CB8->(Eof()) .and. eval(bBlock)
		If CB8->CB8_TIPSEP=='1' // PRE-SEPARACAO
			CB8->(DbSkip())
			Loop
		EndIf
		If nModo==1
			If Ascan(aOrdSep,{|x| x[1]+x[3] == CB8->(CB8_ORDSEP+CB8_PEDIDO)}) == 0
				CB8->(aadd(aOrdSep,{CB8_ORDSEP,CB8_LOCAL,CB8_PEDIDO,CB7->CB7_CODOPE}))
			EndIf
		ElseIf nModo==2
			If Ascan(aOrdSep,{|x| x[1]+x[3]+x[4] == CB8->(CB8_ORDSEP+CB8_NOTA+CB8_SERIE)}) == 0
				CB8->(aadd(aOrdSep,{CB8_ORDSEP,CB8_LOCAL,CB8_NOTA,CB8_SERIE,CB7->CB7_CODOPE}))
			EndIf
		ElseIf nModo==3
			If Ascan(aOrdSep,{|x| x[1]+x[3] == CB8->(CB8_ORDSEP+CB8_OP)}) == 0
				CB8->(aadd(aOrdSep,{CB8_ORDSEP,CB8_LOCAL,CB8_OP,CB7->CB7_CODOPE}))
			EndIf
		EndIf
		CB8->(DbSkip())
	Enddo

	If Empty(aOrdSep)
		VtAlert(STR0042,STR0017,.t.,4000,3)  //### "Ordem de separa  o n o encontrada","Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	aOrdSep := aSort(aOrdSep,,,{|x,y| x[1] < y[1]})
	If len(aOrdSep) == 1 .and. ! Empty(cChave)
		cOrdSep:= aOrdSep[1,1]
		Return .T.
	EndIf
	aTela := VTSave()
	VtClear
	If nModo ==1
		acab :={STR0028,STR0029,STR0030,STR0031} //"Ord.Sep","Arm","PEDIDO","Operador"
		aSize   := {7,3,7,6}
	ElseIf nModo==2
		acab :={STR0028,STR0029,STR0035,STR0032,STR0031} //"Ord.Sep","Arm","Nota","Serie","Operador"
		aSize   := {7,3,6,4,6}
	ElseIf nModo==3
		acab :={STR0028,STR0029,STR0034,STR0031} //"Ord.Sep","Arm","O.P.","Operador"
		aSize   := {7,3,13,6}
	EndIF

	nPos := 1
	npos := VTaBrowse(,,,,aCab,aOrdSep,aSize,,nPos)
	VtRestore(,,,,aTela)
	If VtLastkey() == 27
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	cOrdSep:=aOrdSep[nPos,1]
	VtKeyboard(Chr(13))  // zera o get
Return .T.




