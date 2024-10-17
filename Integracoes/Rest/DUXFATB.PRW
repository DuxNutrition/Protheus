#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ DuxFatB       ºAutor³ Allan Rabelo    º Data ³ 01/10/2024             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Tela de comparação de SC9 com XML da ZFR                               º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametr.³ @ExpC1=XML                         @ExpC4= Recno                       º±±
±±º         ³ @ExpC2=Numero pedido               @ExpC5= Cnpj                        º±±
±±º         ³ @ExpC3=Numero ID                   @ExpC6= Chave                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ Retorno lógico                                                         º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Dux                                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                 ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Programador  ³  Data   ³ Motivo da Alteracao                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º               ³         ³                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 


User Function DuxFatB(aXml,cNumPed,cNumId,cRecno,cCnpj,cChave)
	Local _aArea 	:= GetArea()
	Local _aAreaSC5	:= SC5->( GetArea() )
	Local _aAreaSC6	:= SC6->( GetArea() )
	Local lRet		:= .T.
	Local nPrecVen := 0
	Local oXmlItens :=  aXml:_NFEPROC:_NFE:_INFNFE:_DET
	Local aXmlItens := {}
	Local nCont := 0
	Local cQuery := ""
	Local aDados := {}
	Local aItFat  := {}
	Local cNotaNum := ""
	Local cDoc := ""
	Local cSerie  := SuperGetMv("DX_FATS",.F.,"TST")
	Local cTipoNF := SuperGetMv("DX_FTIPO",.F.,"SPED")
	Local aHeader := {}
	Local cQryHead := ""
	Local nValMar := 0
	Local cAliasHD := GetNextAlias()
	Local _aPvlNfs := {}
	Local _cNota

	Private _DxFtC
	Private _DxNfc 
	Private _DxChv := Substr(aXml:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4)

	if (Valtype(aXml:_NFEPROC:_NFE:_INFNFE:_DET) <> "A")
		aadd(aXmlItens, aXml:_NFEPROC:_NFE:_INFNFE:_DET )
	else
		for nCont = 1 To Len (oXmlItens)
			aadd(aXmlItens,aXml:_NFEPROC:_NFE:_INFNFE:_DET[nCont])
		next
	endif
	SC5->( DBSetOrder( 1 ) )

	Begin Transaction
		If SC5->( DBSeek( xFilial( "SC5" ) + cNumPed ) )
			For nCont := 1 To Len(aXmlItens)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona Itens do Pedido de Venda                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := " SELECT                                       "
				cQuery += " SC9.R_E_C_N_O_                   AS RECSC9 , "
				cQuery += " SUBSTRING(ZFR.ZFR_CHAVE,25,9)    AS NOTAX,   "
				cQuery += " SA1.A1_COD      AS                  CODCLIX, "
				cQuery += " SA1.A1_LOJA     AS                  LOJACLIX,"
				cQuery += " CONVERT(DATE,SUBSTRING(ZFR.ZFR_EMISSA,1,10),23) AS EMISSX, "
				cQuery += " SC9.C9_ITEM     AS                  ITEMX,   "
				cQuery += " SC6.C6_CF       AS                  CFOPX,   "
				cQuery += " SC9.C9_PRODUTO  AS                  PRODx,   "
				cQuery += " SB1.B1_UM       AS                  UMX,     "
				cQuery += " SC9.C9_PEDIDO   AS                  PEDSC9,  "
				cQuery += " SC9.C9_QTDLIB   AS                  QTDX,    "
				cQuery += " SC9.C9_PRCVEN   AS                  PRCX,    "
				cQuery += " SC9.C9_QTDLIB * SC9.C9_PRCVEN  AS   TOTALX,  "
				cQuery += " SC6.C6_PRUNIT   AS                  PRCUNX,  "
				cQuery += " SC6.C6_LOCAL    AS                  LOCALX,  "
				cQuery += " SC6.C6_TES      AS                  TESX,    "
				cQuery += " SC5.R_E_C_N_O_  AS                  RECSC5,  "
				cQuery += " SC6.R_E_C_N_O_  AS                  RECSC6,  "
				cQuery += " SB1.R_E_C_N_O_  AS                  RECSB1,  "
				cQuery += " SC5.R_E_C_N_O_  AS                  RECSC5,  "
				cQuery += " SF4.R_E_C_N_O_  AS                  RECSF4,  "
				cQuery += " SB2.R_E_C_N_O_  AS                  RECSB2,  "
				cQuery += " SE4.R_E_C_N_O_  AS                  RECSE4,  "
				cQuery += " SC9.C9_SEQUEN   AS                  SEQX     "
				cQuery += " FROM "+RetSqlName("SC9")+" AS SC9 "
				cQuery += " LEFT JOIN "+RetSqlName("SC5")+" AS SC5 ON SC5.C5_FILIAL = SC9.C9_FILIAL AND  SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.D_E_L_E_T_ = ''  "
				cQuery += " LEFT JOIN "+RetSqlName("SC6")+" AS SC6 ON SC9.C9_FILIAL = SC6.C6_FILIAL AND  SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_PRODUTO = SC6.C6_PRODUTO  "
				cQuery += " AND  SC6.D_E_L_E_T_ = '' "
				cQuery += " LEFT JOIN "+RetSqlName("SF4")+" AS SF4 ON SF4.F4_CODIGO = SC6.C6_TES AND SF4.D_E_L_E_T_ = ''  "
				cQuery += " LEFT JOIN "+RetSqlName("ZFR")+" AS ZFR ON ZFR.ZFR_PEDIDO  = SC6.C6_NUM "
				cQuery += " AND ZFR.ZFR_FILIAL = SC6.C6_FILIAL  AND ZFR.D_E_L_E_T_ = '' "
				cQuery += " LEFT JOIN "+RetSqlName("SA1")+" AS SA1 ON SA1.A1_FILIAL = SC6.C6_FILIAL AND  SA1.A1_COD = SC6.C6_CLI "
				cQuery += " AND SA1.A1_LOJA = SC6.C6_LOJA  AND SA1.D_E_L_E_T_ = '' "
				cQuery += " LEFT JOIN "+RetSqlName("SB1")+" AS SB1 ON SB1.B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_ = ''  "
				cQuery += " LEFT JOIN "+RetSqlName("SE4")+" AS SE4 ON SE4.E4_CODIGO = SC5.C5_CONDPAG AND SE4.D_E_L_E_T_ = '' "
				cQuery += " AND SE4.D_E_L_E_T_ = ''   "
				cQuery += " LEFT JOIN "+RetSqlName("SB2")+" AS SB2 ON SB2.B2_COD = SC6.C6_PRODUTO "
				cQuery += " AND SC6.C6_FILIAL = SB2.B2_FILIAL  AND SC6.C6_LOCAL = SB2.B2_LOCAL    "
				cQuery += " WHERE SC9.D_E_L_E_T_ = ''  "
				cQuery += " AND "
				cQuery += " SC9.C9_PRODUTO = '"+Alltrim(aXmLItens[nCont]:_prod:_cprod:text)+"' "
				cQuery += " AND "
				cQuery += " SC9.C9_QTDLIB = "+cValToChar(GetDToVal(aXmLItens[nCont]:_prod:_qcom:text))+" "
				cQuery += " AND "
				cQuery += " SC9.C9_PRCVEN = "+cValToChar(GetDToVal(aXmLItens[nCont]:_prod:_vuncom:text))+" "
				cQuery += " AND "
				cQuery += " SC9.C9_BLCRED = '' "
				cQuery += " AND "
				cQuery += " SC9.C9_BLEST = ''  "
				cQuery += " AND "
				cQuery += " SC9.C9_FILIAL = '"+cFilAnt+"'  "
				cQuery += " AND "
				cQuery += " SB1.B1_MSBLQL = '2' " //1 = SIM, BLOQUEADO | 2= NÃO BLOQUEADO
				cQuery += " ORDER BY SC9.C9_PRODUTO "
				
				TcQuery cQuery New Alias (cAliasHD)

				if (cAliasHD)->(!Eof())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta Array de itens com base na query acima                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
				else
					lRet := .F.
					
				endif
			next
			

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

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Envio para execauto de inclusão de pedidos                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			if !Empty(_aPvlNfs) .and. lRet == .T.
				_cNota := MaPvlNfs( _aPvlNfs, cSerie, _lMostraCtb, _lAglutCtb, _lCtbOnLine, _lCtbCusto, _lReajuste, _nCalAcrs, _nArredPrcLis, _lAtuSA7, _lECF, _cEmbExp )
				if !empty(_cNota)
					DbSelectArea("ZFR")
					ZFR->( DBSetOrder( 2 ) )
					IF  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cNumId,TamSX3("ZFR_ID")[1]))))
						RecLock("ZFR",.F.)
						ZFR->ZFR_STATUS := "40"
						ZFR->(MsUnlock())
						ZFR->(dbCloseArea())
					endif
				endif
			else
				DbSelectArea("ZFR")
				ZFR->( DBSetOrder( 2 ) )
				IF  (ZFR->(DbSeek(xFilial("ZFR")+PADR(cNumId,TamSX3("ZFR_ID")[1]))))
					RecLock("ZFR",.F.)
					ZFR->ZFR_ERROR := "Erro ao montar estrutura de NOTA, causas possíveis, LIBERACAO DE PEDIDO "
					ZFR->ZFR_STERRO := "40"
					ZFR->ZFR_STATUS := "99"
					ZFR->(MsUnlock())
					ZFR->(dbCloseArea())
				endif
			endif
		endif
	End Transaction
Return()

