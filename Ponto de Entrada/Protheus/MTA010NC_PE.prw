#INCLUDE "PROTHEUS.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA010NC  �Autor  � Rafael Yera Barchi � Data �  14/04/2016 ���
�������������������������������������������������������������������������͹��
���Descricao �Ponto de Entrada para adicionar campos que n�o devem ser    ���
���          �copiados na rotina C�pia de Produtos (MATA010).             ���
�������������������������������������������������������������������������͹��
���Uso       �Espec�fico Suprinform - SIGACOM							  ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Manutencao�               �                     � Data �               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MTA010NC()
	
	Local aCpoNot := {}
	
	
	// Integra��o Protheus x VTEX - Atos Data Consultoria
	If ExistBlock("ADMTA010NC")
		If ValType(aCpoNot := ExecBlock("ADMTA010NC", .F., .F.)) <> "A"
			aCpoNot   := {}
		EndIf
	EndIf
	
Return (aCpoNot)