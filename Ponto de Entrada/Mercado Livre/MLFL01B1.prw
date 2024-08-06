#INCLUDE 'TOTVS.CH'

/*
=====================================================================================
Programa.:              MLFL01B1
Autor....:              Atos
Data.....:              N�o H�
Descricao / Objetivo:   N�o H�
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

User Function MLFL01B1()

    Local   cProduto := PARAMIXB

	SB1->(DBSelectArea("SB1"))
	SB1->(DBSetOrder(14))
	If SB1->(DBSeek(xFilial("SB1") + cProduto))
	   //Verifica se encontra o produto com o codigo antigo
	   cProduto := Alltrim(SB1->B1_COD)
	   cDescPrd := SB1->B1_DESC
	EndIf

Return(cProduto)
