#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออออออออหอออออัออออออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma ณ ZFATF008       บAutorณ Allan Rabelo    บ Data ณ 01/10/2024             บฑฑ
ฑฑฬอออออออออุอออออออออออออออออสอออออฯออออออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.    ณ Tela de compara็ใo de SC9 com XML da ZFR                               บฑฑ
ฑฑบ         ณ                                                                        บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametr.ณ @ExpC1=XML                         @ExpC4= Recno                       บฑฑ
ฑฑบ         ณ @ExpC2=Numero pedido               @ExpC5= Cnpj                        บฑฑ
ฑฑบ         ณ @ExpC3=Numero ID                   @ExpC6= Chave                       บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno  ณ Retorno l๓gico                                                         บฑฑ
ฑฑบ         ณ                                                                        บฑฑ
ฑฑฬอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ Dux                                                                    บฑฑ
ฑฑฬอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                 ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                 บฑฑ
ฑฑฬอออออออออออออออัอออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Programador  ณ  Data   ณ Motivo da Alteracao                                    บฑฑ
ฑฑฬอออออออออออออออุอออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ               ณ         ณ                                                        บฑฑ
ฑฑศอออออออออออออออฯอออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 


User Function ZFATF008(aXml,cId, cNumPed)
	
	Local lRet			:= .T.
	Local oXmlItens 	:=  aXml:_NFEPROC:_NFE:_INFNFE:_DET
	Local aXmlItens 	:= {}
	Local nCont 		:= 0
	Local cQuery 		:= ""
	Local aDados 		:= {}
	Local cSerie  		:= AllTrim( SuperGetMv("DUX_FAT003"	,.F.	,"DUX"))
	//Local cTipoNF 		:= AllTrim( SuperGetMv("DUX_FAT004"	,.F.	,"SPED"))
	Local cAliasHD 		:= GetNextAlias()
	Local _aPvlNfs 		:= {}
	Local cMsgErro		:= ""
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
	nCont := 0

	Begin Transaction
		If SC5->( DBSeek( xFilial( "SC5" ) + cNumPed ) )
			For nCont := 1 To Len(aXmlItens)
				
				If Select( (cAliasHD) ) > 0
					(cAliasHD)->(DbCloseArea())
				EndIf

				cQuery := " "
				cQuery := " SELECT "																			+ CRLF
				cQuery += " 	 SC9.R_E_C_N_O_                   								AS RECSC9 " 	+ CRLF
				cQuery += " 	,SUBSTRING(ZFR.ZFR_CHAVE,25,9)    								AS NOTAX "		+ CRLF
				cQuery += " 	,SA1.A1_COD      												AS CODCLIX "	+ CRLF	
				cQuery += " 	,SA1.A1_LOJA     												AS LOJACLIX "	+ CRLF
				cQuery += " 	,CONVERT(DATE,SUBSTRING(ZFR.ZFR_EMISSA,1,10),23) 				AS EMISSX "		+ CRLF
				cQuery += " 	,SC9.C9_ITEM     												AS ITEMX "		+ CRLF
				cQuery += " 	,SC6.C6_CF       												AS CFOPX "		+ CRLF
				cQuery += " 	,SC9.C9_PRODUTO  												AS PRODX "		+ CRLF
				cQuery += " 	,SB1.B1_UM       												AS UMX "		+ CRLF
				cQuery += " 	,SC9.C9_PEDIDO   												AS PEDSC9 "		+ CRLF
				cQuery += " 	,SC9.C9_QTDLIB   												AS QTDX "		+ CRLF
				cQuery += " 	,SC9.C9_PRCVEN   												AS PRCX "		+ CRLF
				cQuery += " 	,SC9.C9_QTDLIB * SC9.C9_PRCVEN  								AS TOTALX "		+ CRLF
				cQuery += " 	,SC9.C9_BLEST   												AS ESTSC9 "		+ CRLF
				cQuery += " 	,SC9.C9_BLCRED   												AS CRESC9 "		+ CRLF
				cQuery += " 	,SC6.C6_PRUNIT   												AS PRCUNX "		+ CRLF
				cQuery += " 	,SC6.C6_LOCAL    												AS LOCALX "		+ CRLF
				cQuery += " 	,SC6.C6_TES      												AS TESX "		+ CRLF
				cQuery += " 	,SC5.R_E_C_N_O_  												AS RECSC5 "		+ CRLF
				cQuery += " 	,SC6.R_E_C_N_O_  												AS RECSC6 "		+ CRLF
				cQuery += " 	,SB1.R_E_C_N_O_  												AS RECSB1 "		+ CRLF
				cQuery += " 	,SC5.R_E_C_N_O_  												AS RECSC5 "		+ CRLF
				cQuery += " 	,SF4.R_E_C_N_O_  												AS RECSF4 "		+ CRLF
				cQuery += " 	,SB2.R_E_C_N_O_  												AS RECSB2 "		+ CRLF
				cQuery += " 	,SE4.R_E_C_N_O_  												AS RECSE4 "		+ CRLF
				cQuery += " 	,SC9.C9_SEQUEN   												AS SEQX "		+ CRLF
				cQuery += " FROM "+RetSqlName("SC9")+" AS SC9 "													+ CRLF			
				cQuery += " 	LEFT JOIN "+RetSqlName("SC5")+" AS SC5 "										+ CRLF 
				cQuery += " 		ON 	SC5.C5_FILIAL = SC9.C9_FILIAL " 										+ CRLF
				cQuery += " 		AND SC5.C5_NUM = SC9.C9_PEDIDO " 											+ CRLF
				cQuery += " 		AND SC5.D_E_L_E_T_ = ''  "													+ CRLF
				cQuery += " 	LEFT JOIN "+RetSqlName("SC6")+" AS SC6 "										+ CRLF
				cQuery += " 		ON 	SC6.C6_FILIAL = SC9.C9_FILIAL " 										+ CRLF
				cQuery += " 		AND SC6.C6_NUM = SC9.C9_PEDIDO "											+ CRLF
				cQuery += " 		AND SC6.C6_ITEM = SC9.C9_ITEM "												+ CRLF
				cQuery += " 		AND SC6.C6_PRODUTO = SC9.C9_PRODUTO  "										+ CRLF
				cQuery += " 		AND SC6.D_E_L_E_T_ = '' "													+ CRLF
				cQuery += " 	LEFT JOIN "+RetSqlName("SF4")+" AS SF4 "										+ CRLF
				cQuery += "			ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' "								+ CRLF
				cQuery += "			AND SF4.F4_CODIGO = SC6.C6_TES "											+ CRLF
				cQuery += "			AND SF4.D_E_L_E_T_ = ''  "													+ CRLF
				cQuery += " 	LEFT JOIN "+RetSqlName("ZFR")+" AS ZFR "										+ CRLF
				cQuery += " 		ON ZFR.ZFR_FILIAL = '" + FWxFilial('ZFR') + "' "							+ CRLF
				cQuery += " 		AND ZFR.ZFR_PEDIDO  = SC6.C6_NUM "											+ CRLF
				cQuery += " 		AND ZFR.D_E_L_E_T_ = '' "													+ CRLF
				cQuery += " 	LEFT JOIN "+RetSqlName("SA1")+" AS SA1 "										+ CRLF
				cQuery += "			ON SA1.A1_FILIAL = '" + FWxFilial('SA1') + "' "								+ CRLF	
				cQuery += " 		AND  SA1.A1_COD = SC6.C6_CLI "												+ CRLF
				cQuery += " 		AND SA1.A1_LOJA = SC6.C6_LOJA "  											+ CRLF
				cQuery += "			AND SA1.D_E_L_E_T_ = '' "													+ CRLF
				cQuery += " 	LEFT JOIN "+RetSqlName("SB1")+" AS SB1 "										+ CRLF
				cQuery += "			ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "								+ CRLF
				cQuery += "			AND SB1.B1_COD = SC6.C6_PRODUTO " 											+ CRLF
				cQuery += " 		AND SB1.B1_MSBLQL = '2' "													+ CRLF
				cQuery += "			AND SB1.D_E_L_E_T_ = ''  "													+ CRLF
				cQuery += " 	LEFT JOIN "+RetSqlName("SE4")+" AS SE4 "										+ CRLF
				cQuery += "			ON SE4.E4_FILIAL = '" + FWxFilial('SE4') + "' "								+ CRLF
				cQuery += "			AND SE4.E4_CODIGO = SC5.C5_CONDPAG "										+ CRLF
				cQuery += "			AND SE4.D_E_L_E_T_ = '' "													+ CRLF
				cQuery += " 	LEFT JOIN "+RetSqlName("SB2")+" AS SB2 "										+ CRLF
				cQuery += "			ON SB2.B2_FILIAL = '" + FWxFilial('SB2') + "' "								+ CRLF
				cQuery += "			AND SB2.B2_COD = SC6.C6_PRODUTO "											+ CRLF
				cQuery += "			AND SB2.B2_LOCAL = SC6.C6_LOCAL "											+ CRLF
				cQuery += "			AND SB2.D_E_L_E_T_ = '' "													+ CRLF
				cQuery += " WHERE SC9.C9_FILIAL = '" + FWxFilial('SC9') + "' "									+ CRLF
				cQuery += " AND SC9.C9_PEDIDO = '"+SC5->C5_NUM+"' "												+ CRLF
				cQuery += " AND SC9.C9_PRODUTO = '"+Alltrim(aXmLItens[nCont]:_prod:_cprod:text)+"' "			+ CRLF
				cQuery += " AND SC9.C9_QTDLIB = "+cValToChar(GetDToVal(aXmLItens[nCont]:_prod:_qcom:text))+" "	+ CRLF
				cQuery += " AND SC9.C9_PRCVEN = "+cValToChar(GetDToVal(aXmLItens[nCont]:_prod:_vuncom:text))+""	+ CRLF
				//cQuery += " AND SC9.C9_BLCRED = '' "															+ CRLF
				//cQuery += " AND SC9.C9_BLEST = ''  "															+ CRLF
				cQuery += " AND SC9.D_E_L_E_T_ = ''  "															+ CRLF
				cQuery += " ORDER BY SC9.C9_PRODUTO "															+ CRLF
				
				// Executa a consulta.
				DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasHD, .T., .T. )
				
				DbSelectArea((cAliasHD))
				(cAliasHD)->(dbGoTop())
				If (cAliasHD)->(!Eof())

					If !Empty((cAliasHD)->ESTSC9)
						cMsgErro := "Item: " + AllTrim((cAliasHD)->PRODX) + " com problema de estoque"
						lRet := .F.
					ElseIf !Empty((cAliasHD)->CRESC9)
						cMsgErro := "Item: " + AllTrim((cAliasHD)->PRODX) + " com problema de cr้dito"
						lRet := .F.
					Else

					
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Monta Array de itens com base na query acima                              ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						aDados := {}
						aadd(aDados,(cAliasHD)->(PEDSC9))
						aadd(aDados,(cAliasHD)->(ITEMX))
						aadd(aDados,(cAliasHD)->(SEQX))
						aadd(aDados,(cAliasHD)->(QTDX))
						aadd(aDados,(cAliasHD)->(PRCX))
						aadd(aDados,(cAliasHD)->(PRODx))
						aadd(aDados,.F.)
						aadd(aDados,(cAliasHD)->(RECSC9))
						aadd(aDados,(cAliasHD)->(RECSC5))
						aadd(aDados,(cAliasHD)->(RECSC6))
						aadd(aDados,(cAliasHD)->(RECSE4))
						aadd(aDados,(cAliasHD)->(RECSB1))
						aadd(aDados,(cAliasHD)->(RECSB2))
						aadd(aDados,(cAliasHD)->(RECSF4))

						_DxFtC := (cAliasHD)->(EMISSX)
						_DxNfc := PadL(aXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT,9, '0')
						
						aadd(_aPvlNfs,aDados)

						(cAliasHD)->(dbCloseArea())
					EndIf
				Else
					lRet := .F.
				EndIf
			Next
			
			If lRet
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Prepara ambiente para geracao da Nota Fiscal                              ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				MV_PAR01 := 2           // Mostra Lan.Contab ?  Sim/Nao
				MV_PAR02 := 2           // Aglut. Lanamentos ?  Sim/Nao
				MV_PAR03 := 2           // Lan.Contab.On-Line?  Sim/Nao
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

				_lMostraCtb  	:= ( MV_PAR01 == 2 )
				_lAglutCtb   	:= ( MV_PAR02 == 2 )
				_lCtbOnLine  	:= ( MV_PAR03 == 1 )
				_lCtbCusto   	:= ( MV_PAR04 == 1 )
				_lReajuste   	:= ( MV_PAR05 == 1 )
				_nCalAcrs    	:= 1
				_nArredPrcLis	:= 1
				_lAtuSA7     	:= .F.
				_lECF        	:= .F.
				_cEmbExp		:= " "

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ  Envio para execauto de inclusใo de pedidos                               ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				If !Empty(_aPvlNfs)
					_cNota := MaPvlNfs( _aPvlNfs, cSerie, _lMostraCtb, _lAglutCtb, _lCtbOnLine, _lCtbCusto, _lReajuste, _nCalAcrs, _nArredPrcLis, _lAtuSA7, _lECF, _cEmbExp )
					If !Empty(_cNota)
						DbSelectArea("ZFR")
						ZFR->( DBSetOrder( 2 ) )
						If  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
							RecLock("ZFR",.F.)
								ZFR->ZFR_STATUS := "40"
							ZFR->(MsUnlock())
							ZFR->(dbCloseArea())
						EndIf
					Else
						DbSelectArea("ZFR")
						ZFR->( DBSetOrder( 2 ) )
						IF  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
							RecLock("ZFR",.F.)
								ZFR->ZFR_ERROR := "Erro para escriturar a nota fiscal"
								ZFR->ZFR_STERRO := "40"
								ZFR->ZFR_STATUS := "99"
							ZFR->(MsUnlock())
						EndIf
					EndIf
				Else
					DbSelectArea("ZFR")
					ZFR->( DBSetOrder( 2 ) )
					IF  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1]))))
						RecLock("ZFR",.F.)
							ZFR->ZFR_ERROR := "Erro ao montar estrutura de NOTA, causas possํveis, LIBERACAO DE PEDIDO "
							ZFR->ZFR_STERRO := "40"
							ZFR->ZFR_STATUS := "99"
						ZFR->(MsUnlock())
					EndIf
				EndIf
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
	End Transaction
Return()

