#INCLUDE "totvs.ch"
#INCLUDE "parmtype.ch"
 /*/{Protheus.doc} DUXFAT02
(long_description)
@type  Function
@author Mayara Dias
@since 08/03/2023
@version version
@see (links_or_references)
    /*/
User Function DUXFAT02()
	Local lExistePedido := .F.
	Local cQuery    := ""
	Local aAreaSC5  := SC5->(Getarea())
	local cAlias	:= getNextAlias()
	DbSelectarea( aAreaSC5 )
	cQuery:= "SELECT * FROM SC5010 SC5"+ CRLF
	cQuery += "	WHERE 1=1 " + CRLF
	cQuery += " AND C5_ZZNUMPJ <> '' " + CRLF
	cQuery += "	AND SC5.D_E_L_E_T_ 	= ''" + CRLF
	cQuery += "	AND SC5.C5_FILIAL 	= '"+xFilial("SC5")+"'" + CRLF
	// Executa a query SQL para verificar se o pedido já existe na tabela de pedidos de venda
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)
	DbSelectArea(cAlias)
	While!(cAlias)->(Eof())
		lExistePedido:= (((ALLTRIM(cAlias))->C5_ZZNUMPJ) == M->C5_ZZNUMPJ)
		If lExistePedido
			EXIT
		EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
	If lExistePedido
		If !IsBlind()
			Alert("DUXFAT02 - O Número do Pedido de venda informado no campo PEDIDO PJ [C5_ZZNUMPJ] já na existe na base de dados")
			Return .F.
		Else
			Conout( "DUXFAT02 - O Número do Pedido de venda informado no campo PEDIDO PJ [C5_ZZNUMPJ] já na existe na base de dados")
			Aviso("DUXFAT02","O Número do Pedido de venda informado no campo PEDIDO PJ [C5_ZZNUMPJ] já na existe na base de dados",{})
			Return .F.
		EndIf
	Else
		Return .T.
	EndIf
Return
