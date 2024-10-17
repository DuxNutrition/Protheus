#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa � DuxFatA       �Autor� Allan Rabelo    � Data � 01/10/2024             ���
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


User Function DuxFatA(cXml,cNumPed,cNumId,cRecno)
	Local cError   := ""
	Local cWarning := ""
	Local oXml     := NIL
	Local lRet     := .F.
	Local cCnpj    := ""
	Local cChave   := ""
    
    //���������������������������������������������������������������������������Ŀ
    //�  Quebro XML                                                              �
    //�����������������������������������������������������������������������������
	oXml := XmlParser( cXml, "_", @cError, @cWarning )
	If (oXml == NIL )
		DbSelectArea("ZFR")
		ZFR->(dbgoto(cRecno))
		RecLock("ZFR",.F.)
		ZFR->ZFR_ERROR := ("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
		ZFR->ZFR_STERRO := "40"
		ZFR->(MsUnlock())
		Return
	else
    //���������������������������������������������������������������������������Ŀ
    //�  Envio para valida��o de CNPj e para FATURAMENTO                          �
    //�����������������������������������������������������������������������������
		if !Empty(oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:Text)
			cCnpj :=  oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:Text
			cChave :=  oXml:_NFEPROC:_NFE:_INFNFE:_ID:Text
			if ValCnpj(cCnpj)
				lRet := .T.
				u_DuxFatB(@oXml,cNumPed,cNumId,cRecno,cCnpj,cChave)
			else 
				DbSelectArea("ZFR")
				ZFR->(dbgoto(cRecno))
				RecLock("ZFR",.F.)
				ZFR->ZFR_ERROR := ("Falha - CNPJ N�O ENCONTRADO : "+cError+" / "+cWarning)
				ZFR->ZFR_STERRO := "40"
				ZFR->(MsUnlock())
				Return
			endif
		endif
	Endif

Return(lRet)

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
	Local cQuery := ""
	Local lRet := .F.
    Local cAlias := GetNextAlias()

	cQuery := " SELECT SA1.R_E_C_N_O_ AS RECNO "
	cQuery += " FROM "+RetSqlName("SA1")+" AS SA1 "
	cQuery += " WHERE SA1.D_E_L_E_T_ = ''  "
	cQuery += " AND "
	cQuery += " SA1.A1_CGC = '"+cCnpj+"' "


	TcQuery cQuery New Alias (cAlias)

	if (cAlias)->(!Eof())
		lRet := .T.
	endif

Return(lRet)
