#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa � ZFATF007       �Autor� Allan Rabelo    � Data � 01/10/2024             ���
������������������������������������������������������������������������������������͹��
���Desc.    � Denomina��o de XML PARCE e Valida��o de SA1                            ���
���         �                                                                        ���
������������������������������������������������������������������������������������͹��
���Parametr.� @ExpC1=XML da ZFR                                                      ���
���         � @ExpC2= Numero do pedido                                               ���
���         � @ExpC3= Numero do ID      
���           @ExpC4= RecnoZFR                                                       ���
������������������������������������������������������������������������������������͹��
���Retorno  � Retorno l�gico                                                         ���
���         � cccccccccc                                                             ���
������������������������������������������������������������������������������������͹��
���Uso      � Dux                                                                  ���
������������������������������������������������������������������������������������͹��
���                 ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                 ���
������������������������������������������������������������������������������������͹��
���  Programador  �  Data   � Motivo da Alteracao                                    ���
������������������������������������������������������������������������������������͹��
���               �         �                                                        ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/ 
User Function ZFATF007(cId, cNumPed, lJob)

	Local cError   	:= ""
	Local cWarning 	:= ""
	Local oXml     	:= NIL
	Local cCnpj    	:= ""
	Local cChave   	:= ""

	Default cId 	:= ""
	Default cNumPed	:= ""
	Default lJob	:= .F.

	If lJob
		ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR007] - Inicio Processamento")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT"
	EndIf

	DbSelectArea("ZFR")
	ZFR->(DBSetOrder(2))
	If ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))
		If AllTrim(ZFR->ZFR_STATUS) == "30"

			oXml := XmlParser( ZFR->ZFR_XML, "_", @cError, @cWarning )
			If (oXml == NIL )
				RecLock("ZFR",.F.)
					ZFR->ZFR_ERROR := ("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
					ZFR->ZFR_STERRO := "40"
				ZFR->(MsUnlock())
			Else
   				If !Empty(oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:Text)
					cCnpj :=  oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:Text
					cChave :=  oXml:_NFEPROC:_NFE:_INFNFE:_ID:Text
					
					If ValCnpj(cCnpj)
						If lJob
							ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZFATF007] - Processando a escrituracao da invoice: " + Alltrim(ZFR->ZFR_INVOIC))
							u_ZFATF008(@oXml, ZFR->ZFR_ID, ZFR->ZFR_PEDIDO)
						Else
							FWMsgRun(,{|| U_ZFATF008(@oXml, ZFR->ZFR_ID, ZFR->ZFR_PEDIDO) },,"Processando a escrituracao da invoice: " + AllTrim(ZFR->ZFR_INVOIC) + ", aguarde...")
						EndIf
					Else 
						RecLock("ZFR",.F.)
							ZFR->ZFR_ERROR := ("Falha - CNPJ N�O ENCONTRADO : "+cError+" / "+cWarning)
							ZFR->ZFR_STERRO := "40"
						ZFR->(MsUnlock())
			
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		If lJob
			ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR007] - Nao encontrado registro par grava��o R_E_C_N_O_: " + Alltrim(cRecZFR))
		Else
			ApMsgInfo( "N�o encontrado registro par grava��o R_E_C_N_O_: " + Alltrim(cRecZFR), '[ZWSR006]' )
		EndIf
	EndIf
	
	If lJob
		ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"] [ZWSR007] - Fim Processamento")
		RESET ENVIRONMENT
	Endif

Return()

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  � ValCnpj � Autor � Allan Rabelo � Data �    25/09/2024      ���
//�������������������������������������������������������������������������͹��
//���Descricao � Validar CLIENTES com CNPJ                                  ���
//���          �                                                            ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������


Static Function ValCnpj(cCnpj)

	Local cQrySA1	:= ""
	Local cAlsSA1 	:= GetNextAlias()
	Local lRet		:= .F.

	cQrySA1 := " SELECT * FROM "+RetSqlName("SA1")+" AS SA1 " 	+ CRLF
	cQrySA1 += " WHERE SA1.A1_FILIAL = '  '  "					+ CRLF
	cQrySA1 += " AND SA1.A1_CGC = '"+cCnpj+"' "					+ CRLF
	cQrySA1 += " AND SA1.D_E_L_E_T_ <> '*'  "					+ CRLF

	If Select( (cAlsSA1) ) > 0
		(cAlsSA1)->(DbCloseArea())
	EndIf

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQrySA1), cAlsSA1, .T., .T. )
	
	DbSelectArea((cAlsSA1))
	(cAlsSA1)->(dbGoTop())
	If (cAlsSA1)->(!Eof())
		lRet := .T.
	EndIf

Return(lRet)
