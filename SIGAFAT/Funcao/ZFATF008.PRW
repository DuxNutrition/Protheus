#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} ZFATF007
Faz a geração da nota fiscal no Protheus
@type function
@version 12.1.2310
@author Dux | Allan Rabelo
@since 21/10/2024
@param cId, character, Id VTex
@param cPedido, character, Pedido Protheus
@param lJob, logical, Executa via Job
/*/
User Function ZFATF008(aXml,cId, cNumPed)
	
	Local lRet			:= .T.
	Local oXmlItens 	:=  aXml:_NFEPROC:_NFE:_INFNFE:_DET
	Local aXmlItens 	:= {}
	Local nCont 		:= 0
	Local cQuery 		:= ""
	Local aDados 		:= {}
	Local cSerie  		:= AllTrim( SuperGetMv("DUX_FAT003"	,.F.	,"DUX"))
	//Local cTipoNF 		:= AllTrim( SuperGetMv("DUX_FAT004"	,.F.	,"SPED"))
	Local lVldImp		:= SuperGetMV("DUX_FAT005",.F.,.T.) 
	Local cAliasHD 		:= GetNextAlias()
	Local _aPvlNfs 		:= {}
	Local cMsgErro		:= ""
	Local cXPedLv		:= ""
	Local cMsgImp		:= ""
	Local _cNota

	Private _DxFtC
	Private _DxNfc 
	Private _DxChv := Substr(aXml:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4)

	If (Valtype(aXml:_NFEPROC:_NFE:_INFNFE:_DET) <> "A")
		aadd(aXmlItens, aXml:_NFEPROC:_NFE:_INFNFE:_DET )
	Else
		For nCont = 1 To Len (oXmlItens)
			aadd(aXmlItens,aXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont])
		Next
	EndIf

	SC5->( DBSetOrder( 1 ) )
	nCont 	:= 0
	cXPedLv := ""

	If SC5->( DBSeek( xFilial( "SC5" ) + cNumPed ) )

		cXPedLv 	:= SC5->C5_XPEDLV
		_aPvlNfs	:= {}

		For nCont := 1 To Len(aXmlItens)
			
			If Select( (cAliasHD) ) > 0
				(cAliasHD)->(DbCloseArea())
			EndIf

			cQuery := " "
			cQuery := " SELECT "																				+ CRLF
			cQuery += " 	 SC9.R_E_C_N_O_                   								AS RECSC9 " 		+ CRLF
			cQuery += " 	,CONVERT(DATE,SUBSTRING(ZFR.ZFR_EMISSA,1,10),23) 				AS DT_EMISSAO_IC "	+ CRLF
			cQuery += " 	,SC9.C9_ITEM     												AS C9_ITEM "		+ CRLF
			cQuery += " 	,SC9.C9_PRODUTO  												AS C9_PRODUTO "		+ CRLF
			cQuery += " 	,SC9.C9_PEDIDO   												AS C9_PEDIDO "		+ CRLF
			cQuery += " 	,SC9.C9_QTDLIB   												AS C9_QTDLIB "		+ CRLF
			cQuery += " 	,SC9.C9_PRCVEN   												AS C9_PRCVEN "		+ CRLF
			cQuery += " 	,SC9.C9_BLEST   												AS C9_BLEST "		+ CRLF
			cQuery += " 	,SC9.C9_BLCRED   												AS C9_BLCRED "		+ CRLF
			cQuery += " 	,SC5.R_E_C_N_O_  												AS RECSC5 "			+ CRLF
			cQuery += " 	,SC6.R_E_C_N_O_  												AS RECSC6 "			+ CRLF
			cQuery += " 	,SB1.R_E_C_N_O_  												AS RECSB1 "			+ CRLF
			cQuery += " 	,SF4.R_E_C_N_O_  												AS RECSF4 "			+ CRLF
			cQuery += " 	,SB2.R_E_C_N_O_  												AS RECSB2 "			+ CRLF
			cQuery += " 	,SE4.R_E_C_N_O_  												AS RECSE4 "			+ CRLF
			cQuery += " 	,ZFR.R_E_C_N_O_  												AS RECZFR "			+ CRLF
			cQuery += " 	,SC9.C9_SEQUEN   												AS C9_SEQUEN "		+ CRLF
			cQuery += " FROM "+RetSqlName("SC9")+" AS SC9 "														+ CRLF			
			cQuery += " 	INNER JOIN "+RetSqlName("SC5")+" AS SC5 "											+ CRLF 
			cQuery += " 		ON 	SC5.C5_FILIAL = SC9.C9_FILIAL " 											+ CRLF
			cQuery += " 		AND SC5.C5_NUM = SC9.C9_PEDIDO " 												+ CRLF
			cQuery += " 		AND SC5.D_E_L_E_T_ <> '*'  "													+ CRLF
			cQuery += " 	INNER JOIN "+RetSqlName("SC6")+" AS SC6 "											+ CRLF
			cQuery += " 		ON 	SC6.C6_FILIAL = SC9.C9_FILIAL " 											+ CRLF
			cQuery += " 		AND SC6.C6_NUM = SC9.C9_PEDIDO "												+ CRLF
			cQuery += " 		AND SC6.C6_ITEM = SC9.C9_ITEM "													+ CRLF
			cQuery += " 		AND SC6.C6_PRODUTO = SC9.C9_PRODUTO  "											+ CRLF
			cQuery += " 		AND SC6.D_E_L_E_T_ <> '*' "														+ CRLF
			cQuery += " 	INNER JOIN "+RetSqlName("SF4")+" AS SF4 "											+ CRLF
			cQuery += "			ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' "									+ CRLF
			cQuery += "			AND SF4.F4_CODIGO = SC6.C6_TES "												+ CRLF
			cQuery += "			AND SF4.D_E_L_E_T_ <> '*'  "													+ CRLF
			cQuery += " 	INNER JOIN "+RetSqlName("ZFR")+" AS ZFR "											+ CRLF
			cQuery += " 		ON ZFR.ZFR_FILIAL = '" + FWxFilial('ZFR') + "' "								+ CRLF
			cQuery += " 		AND ZFR.ZFR_PEDIDO  = SC6.C6_NUM "												+ CRLF
			cQuery += " 		AND RTRIM(ZFR.ZFR_STATUS) IN ('30','99') "										+ CRLF
			cQuery += " 		AND RTRIM(ZFR.ZFR_STATIN) = 'authorized' "										+ CRLF
			cQuery += " 		AND ZFR.D_E_L_E_T_ <> '*' "														+ CRLF
			cQuery += " 	INNER JOIN "+RetSqlName("SB1")+" AS SB1 "											+ CRLF
			cQuery += "			ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "									+ CRLF
			cQuery += "			AND SB1.B1_COD = SC6.C6_PRODUTO " 												+ CRLF
			cQuery += " 		AND SB1.B1_MSBLQL = '2' "														+ CRLF
			cQuery += "			AND SB1.D_E_L_E_T_ <> '*'  "													+ CRLF
			cQuery += " 	INNER JOIN "+RetSqlName("SE4")+" AS SE4 "											+ CRLF
			cQuery += "			ON SE4.E4_FILIAL = '" + FWxFilial('SE4') + "' "									+ CRLF
			cQuery += "			AND SE4.E4_CODIGO = SC5.C5_CONDPAG "											+ CRLF
			cQuery += "			AND SE4.D_E_L_E_T_ <> '*' "														+ CRLF
			cQuery += " 	INNER JOIN "+RetSqlName("SB2")+" AS SB2 "											+ CRLF
			cQuery += "			ON SB2.B2_FILIAL = '" + FWxFilial('SB2') + "' "									+ CRLF
			cQuery += "			AND SB2.B2_COD = SC6.C6_PRODUTO "												+ CRLF
			cQuery += "			AND SB2.B2_LOCAL = SC6.C6_LOCAL "												+ CRLF
			cQuery += "			AND SB2.D_E_L_E_T_ <> '*' "														+ CRLF
			cQuery += " WHERE SC9.C9_FILIAL = '" + FWxFilial('SC9') + "' "										+ CRLF
			cQuery += " AND SC9.C9_PEDIDO = '"+SC5->C5_NUM+"' "													+ CRLF
			cQuery += " AND SC9.C9_PRODUTO = '"+Alltrim(aXmLItens[nCont]:_prod:_cprod:text)+"' "				+ CRLF
			cQuery += " AND SC9.C9_ITEM = '"+PadL(Alltrim(aXmLItens[nCont]:_nitem:text), 2, '0')+"' "			+ CRLF
			cQuery += " AND SC9.C9_QTDLIB = "+cValToChar(GetDToVal(aXmLItens[nCont]:_prod:_qcom:text))+" "		+ CRLF
			//cQuery += " AND SC9.C9_PRCVEN = "+cValToChar(GetDToVal(aXmLItens[nCont]:_prod:_vuncom:text))+""	+ CRLF
			//cQuery += " AND SC9.C9_BLCRED = '' "															+ CRLF
			//cQuery += " AND SC9.C9_BLEST = ''  "															+ CRLF
			cQuery += " AND SC9.D_E_L_E_T_ <> '*' "																+ CRLF
			cQuery += " ORDER BY SC9.C9_PRODUTO, SC9.C9_ITEM "													+ CRLF
			
			// Executa a consulta.
			DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasHD, .T., .T. )
			
			DbSelectArea((cAliasHD))
			(cAliasHD)->(dbGoTop())
			If (cAliasHD)->(!Eof())

				If !Empty((cAliasHD)->C9_BLEST)
					cMsgErro += "Item: " + AllTrim((cAliasHD)->C9_PRODUTO) + " | Problema de estoque na liberacao do Pedido de Venda" + CRLF
					lRet 	:= .F.
				EndIf

				If !Empty((cAliasHD)->C9_BLCRED)
					cMsgErro += "Item: " + AllTrim((cAliasHD)->C9_PRODUTO) + " | Problema de credito na liberacao do Pedido de Venda" + CRLF
					lRet := .F.
				EndIf

				/*If (cAliasHD)->C9_QTDLIB <> GetDToVal(aXmLItens[nCont]:_prod:_qcom:text)
					cMsgErro += "Item: " + AllTrim((cAliasHD)->C9_PRODUTO) + " | Quantidade divergente entre Pedido Protheus ( " + AllTrim(cValToChar((cAliasHD)->C9_QTDLIB)) + " ) e XML InfraCommerce ( " + AllTrim(cValToChar(GetDToVal(aXmLItens[nCont]:_prod:_qcom:text))) + " )" + CRLF
					lRet := .F.
				EndIf*/
				
				If Round((cAliasHD)->C9_PRCVEN,2) <> Round(GetDToVal(aXmLItens[nCont]:_prod:_vuncom:text),2)
					cMsgErro += "Item: " + AllTrim((cAliasHD)->C9_PRODUTO) + " | Preco divergente entre Pedido Protheus ( R$ " + AllTrim(cValToChar(Round((cAliasHD)->C9_PRCVEN,2))) + " ) e XML InfraCommerce ( R$ " + AllTrim(cValToChar(Round(GetDToVal(aXmLItens[nCont]:_prod:_vuncom:text),2))) + " )" + CRLF
					lRet := .F.
				EndIf

				If lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta Array de itens com base na query acima                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aDados := {}
					aadd( aDados,	(cAliasHD)->C9_PEDIDO	)
					aadd( aDados,	(cAliasHD)->C9_ITEM		)
					aadd( aDados,	(cAliasHD)->C9_SEQUEN	)
					aadd( aDados,	(cAliasHD)->C9_QTDLIB	)
					aadd( aDados,	(cAliasHD)->C9_PRCVEN	)
					aadd( aDados,	(cAliasHD)->C9_PRODUTO	)
					aadd( aDados,	.F.						)
					aadd( aDados,	(cAliasHD)->RECSC9		)
					aadd( aDados,	(cAliasHD)->RECSC5		)
					aadd( aDados,	(cAliasHD)->RECSC6		)
					aadd( aDados,	(cAliasHD)->RECSE4		)
					aadd( aDados,	(cAliasHD)->RECSB1		)
					aadd( aDados,	(cAliasHD)->RECSB2		)
					aadd( aDados,	(cAliasHD)->RECSF4		)

					_DxFtC := (cAliasHD)->DT_EMISSAO_IC
					_DxNfc := PadL(aXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT,9, '0')
					
					aadd(_aPvlNfs,aDados)
				EndIf
			Else
				cMsgErro += "Item: " + Alltrim(aXmLItens[nCont]:_prod:_cprod:text) + " | Nao encontrado o item para liberado nos Pedidos de Venda do Protheus" + CRLF
				lRet := .F.
			EndIf
		Next
						
		If lRet .And. !Empty(_aPvlNfs)

			Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Prepara ambiente para geracao da Nota Fiscal                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MV_PAR01 := 2           // Mostra Lan‡.Contab ?  Sim/Nao
				MV_PAR02 := 2           // Aglut. Lan‡amentos ?  Sim/Nao
				MV_PAR03 := 2           // Lan‡.Contab.On-Line?  Sim/Nao
				MV_PAR04 := 2           // Contb.Custo On-Line?  Sim/Nao
				MV_PAR05 := 2           // Reaj. na mesma N.F.?  Sim/Nao
				MV_PAR06 := 0           // Taxa deflacao ICMS ?  Numerico
				MV_PAR07 := 3           // Metodo calc.acr.fin?  Taxa defl/Dif.lista/% Acrs.ped
				MV_PAR08 := 3           // Arred.prc unit vist?  Sempre/Nunca/Consumid.final
				MV_PAR09 := Space( 04 ) // Agreg. liberac. de ?  Caracter
				MV_PAR10 := 'ZZZZ'      // Agreg. liberac. ate?  Caracter
				MV_PAR11 := 2           // Aglut.Ped. Iguais  ?  Sim/Nao
				MV_PAR12 := 0           // Valor Minimo p/fatu?
				MV_PAR13 := Space( 06 ) // Transportadora de  ?
				MV_PAR14 := 'ZZZZZZ'    // Transportadora ate ?
				MV_PAR15 := 2           // Atualiza Cli.X Prod?  Sim/Nao
				MV_PAR16 := 1           // Emitir             ?  Nota/Cupom Fiscal

				_lMostraCtb  	:= .F.
				_lAglutCtb   	:= .T.
				_lCtbOnLine  	:= .F.
				_lCtbCusto   	:= .F.
				_lReajuste   	:= .F.
				_nCalAcrs    	:= 1
				_nArredPrcLis	:= 0
				_lAtuSA7     	:= .F.
				_lECF        	:= .F.

				//Gera nota Fiscal.
				_cNota		:= ""
				_cNota		:= MaPvlNfs( _aPvlNfs, cSerie, _lMostraCtb	,_lAglutCtb	, _lCtbOnLine	, _lCtbCusto, _lReajuste, _nCalAcrs	, _nArredPrcLis	, _lAtuSA7	, _lECF, )
				_aPvlNfs	:= {}

				//Valida os impostos.
				If lVldImp
					cMsgImp	:= ""
					cMsgImp := ZValidaImp( aXml )
				EndIf

				If !Empty(cMsgImp) //Erro no calculo de impostos
					
					//Disarma a transação e estorna a nota fiscal.
					Disarmtransaction()

					//Grava o erro na ZFR
					DbSelectArea("ZFR")
					ZFR->( DBSetOrder( 2 ) )
					IF  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
						RecLock("ZFR",.F.)
							ZFR->ZFR_ERROR := cMsgImp
							ZFR->ZFR_STERRO := "40"
							ZFR->ZFR_STATUS := "99"
						ZFR->(MsUnlock())
					EndIf
				Else
					If !Empty(_cNota)
						DbSelectArea("ZFR")
						ZFR->( DBSetOrder( 2 ) )
						If  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
							RecLock("ZFR",.F.)
								ZFR->ZFR_STATUS	:= "40"
								ZFR->ZFR_DTERP	:= Date()
								ZFR->ZFR_HRERP	:= Time()
								ZFR->ZFR_NFERP	:= _cNota
								ZFR->ZFR_SERERP	:= cSerie
								ZFR->ZFR_XPEDLV := cXPedLv
							ZFR->(MsUnlock())
							ZFR->(dbCloseArea())
						EndIf
					Else
						DbSelectArea("ZFR")
						ZFR->( DBSetOrder( 2 ) )
						IF  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
							RecLock("ZFR",.F.)
								ZFR->ZFR_ERROR 	:= "Erro na rotina automatica de geracao da nota fiscal no Protheus"
								ZFR->ZFR_STERRO := "40"
								ZFR->ZFR_STATUS := "99"
							ZFR->(MsUnlock())
						EndIf
					EndIf
				EndIf
			End Transaction
		Else
			DbSelectArea("ZFR")
			ZFR->( DBSetOrder( 2 ) )
			IF  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
				RecLock("ZFR",.F.)
					ZFR->ZFR_ERROR := cMsgErro
					ZFR->ZFR_STERRO := "40"
					ZFR->ZFR_STATUS := "99"
				ZFR->(MsUnlock())
			EndIf
		EndIf
	EndIf
	
Return()

/*/{Protheus.doc} ZValidaImp
Valida os impostos da nota fiscal após o faturamento
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 22/10/2024
@param aXml, array, xml
@return character, msgn de erro
/*/
Static Function ZValidaImp( aXml )

Local cMsgn		:= ""
Local nTotal	:= GetDToVal(aXml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT:_VORIG:TEXT)
Local nCofins	:= GetDToVal(aXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VCOFINS:TEXT)
Local nIcms 	:= GetDToVal(aXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)
Local nIpi  	:= GetDToVal(aXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT)
Local nPis  	:= GetDToVal(aXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPIS:TEXT)
Local nFrete  	:= GetDToVal(aXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)
Local nSeguro  	:= GetDToVal(aXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT)

/* OBSERVAÇÃO PARA O ARREDONDAMENTO DOS IMPOSTOS.
SISTEMA DA INFRACOMMERCE ARREDONDA A 2a CASA DECIMAL, DESSA FORMA ESTAREMOS
USANDO O NoRound(nImposto,1) PARA CONSIDERAR SOMENTE A 1a CASA DECIMAL */

//Valida icms total
If ( nTotal <> SF2->F2_VALBRUT )
	
	cMsgn += "Total da nota fiscal divergente entre escriturado ( R$ " + AllTrim(cValToChar(SF2->F2_VALBRUT)) + " )  e XML InfraCommerce ( R$ " + AllTrim(cValToChar(nTotal)) + " )." + CRLF
	
EndIf

//Valida icms total
If ( NoRound(nIcms,1) <> NoRound(SF2->F2_VALICM,1) )
	
	cMsgn += "Valor do icms divergente entre escriturado ( R$ " + AllTrim(cValToChar(SF2->F2_VALICM)) + " )  e XML InfraCommerce ( R$ " + AllTrim(cValToChar(nIcms)) + " )." + CRLF
	
EndIf

//Valida ipi total
If ( NoRound(nIpi,1) <> NoRound(SF2->F2_VALIPI,1) )

	cMsgn += "Valor do ipi divergente entre escriturado ( R$ " + AllTrim(cValToChar(SF2->F2_VALIPI)) + " )  e XML InfraCommerce ( R$ " + AllTrim(cValToChar(nIpi)) + " )." + CRLF

endif

//Valida pis total
If ( NoRound(nPis,1) <> NoRound(SF2->F2_VALIMP6,1) )

	cMsgn += "Valor do pis divergente entre escriturado ( R$ " + AllTrim(cValToChar(SF2->F2_VALIMP6)) + " )  e XML InfraCommerce ( R$ " + AllTrim(cValToChar(nPis)) + " )." + CRLF

EndIf

//Valida cofins total
If ( NoRound(nCofins,1) <> NoRound(SF2->F2_VALIMP5,1) )

	cMsgn += "Valor do cofins divergente entre escriturado ( R$ " + AllTrim(cValToChar(SF2->F2_VALIMP5)) + " )  e XML InfraCommerce ( R$ " + AllTrim(cValToChar(nCofins)) + " )." + CRLF

Endif

//Valida frete total
If ( nFrete <> SF2->F2_FRETE )

	cMsgn += "Valor do frete divergente entre escriturado ( R$ " + AllTrim(cValToChar(SF2->F2_FRETE)) + " ) e XML InfraCommerce ( R$ " + AllTrim(cValToChar(nFrete)) + " )." + CRLF

EndIf

//Valida seguro total
If ( nSeguro <> SF2->F2_SEGURO )

		cMsgn += "Valor do seguro divergente entre escriturado ( R$ " + AllTrim(cValToChar(SF2->F2_SEGURO)) + " ) e XML InfraCommerceo ( R$ " + AllTrim(cValToChar(nSeguro)) + " )." + CRLF

EndIf

Return(cMsgn)

