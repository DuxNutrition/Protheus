#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*{Protheus.doc} ZESTF001
Função para bloquear lote do produto conforme o prazo de dias de vencimento.
@author Jedielson Rodrigues
@since 17/06/2024
@history 
@version 1.0
@database MSSQL
*/

User Function ZESTF001()

Local cQry 			:= " " 
Local _aAreaSB8 	:= SB8->(GetArea())
Local _aAreaSDD 	:= SDD->(GetArea())
Local aProdBlq  	:= {}
Local aItemBloq  	:= {}
Local aItemErro		:= {}
Local aAnexos		:= {}

Local cEMail	    := SuperGetMv("DUX_EST003",.F.,"jedielson.rodrigues@duxnutrition.com")
Local cSubject      := "Lotes bloqueados proximo ao vencimento.!"
Local cMsg          := " "
Local cMensagem 	:= " "
Local cRotina       := "ZESTF001"
Local lRet 			:= .T.
Local cProd     	:= " "
Local nQuant    	:= 0
Local cLotectl  	:= " "
Local cDocSDD   	:= SuperGetMv("DUX_EST001",.F.,"BLOC01")
Local cTipo         := " "
Local cLocal        := " "
Local cBloctipo     := SuperGetMv("DUX_EST002",.F.,"PA#ME")
Local cBlocLoc    	:= SuperGetMv("DUX_EST004",.F.,"QA05#PR01")
Local nDiasVenc   	:= 0
Local _dDtValid 	:= CtoD( "" )
Local _dTLotVal   	:= CtoD( "" )
Local cAliTempSB8   := GetNextAlias()
Local _cErro        := " "
Local cDelArq		:= " "
Local _nPos         := 0

// Descrição dos Itens Bloqueados

Local cDescItem1 := "Produto"
Local cDescItem2 := "Quantidade"
Local cDescItem3 := "Lote"
Local cDescItem4 := "Local"
Local cDescItem5 := "Validade"
Local cDescItem6 := "Status"
Local cDescItem7 := "Documento"
Local cDescItem8 := "Motivo do Bloqueio"
Local cStatus  	 := "Bloqueado"

// Descrição dos Itens com Erros

Local cDescErro1 := "Produto | Quantidade | Lote | Local"
Local cDescErro2 := "Erro"

// Margem dos Itens Bloqueados

Local nMarg01      := 5
Local nMarg02      := 45
Local nMarg03      := 95
Local nMarg04      := 162
Local nMarg05      := 210
Local nMarg06      := 270
Local nMarg07      := 333
Local nMarg08      := 395

// Margem dos Erros dos Itens

Local nMarErro1     := 5
Local nMarErro2     := 200

Local _aError       := {}
Local aErroPrint	:= {}
Local aDescItens    := {}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.

Default cDocSDD     := HS_VSxeNum("SDD", "M->DD_DOC", 1)
Default cNumLote    := Space(Len(SDD->DD_NUMLOTE))

	If Select((cAliTempSB8)) > 0
		(cAliTempSB8)->(dbCloseArea())
	EndIf

	cQry := " SELECT * FROM "+CRLF
    cQry += "		( "+CRLF
    cQry += "	SELECT      SB8.B8_FILIAL "+CRLF
    cQry += "   	,SB8.B8_PRODUTO "+CRLF
    cQry += "   	,(SB8.B8_SALDO - SB8.B8_EMPENHO - SB8.B8_QACLASS) AS QTDE_SB8 "+CRLF
    cQry += "   	,ISNULL ( SDD.QTDE_SDD, 0) AS QTDE_SDD "+CRLF
    cQry += "   	,(SB8.B8_SALDO - SB8.B8_EMPENHO - SB8.B8_QACLASS) - ISNULL ( SDD.QTDE_SDD, 0) AS SALDO_BLOQ "+CRLF
    cQry += "   	,SB8.B8_LOCAL "+CRLF
    cQry += "   	,SB8.B8_LOTECTL "+CRLF
    cQry += "   	,SB8.B8_DTVALID "+CRLF
    cQry += "   	,SB1.B1_TIPO "+CRLF
    cQry += "   	,SB1.B1_XPRVAL "+CRLF
    cQry += "   	,SB1.B1_RASTRO "+CRLF 
    cQry += "    FROM "+ RetSqlName("SB8")+" SB8 WITH(NOLOCK) "+CRLF 
    cQry += "    	LEFT JOIN ( "+CRLF
    cQry += "                     SELECT DD_FILIAL, DD_PRODUTO, DD_LOTECTL, DD_LOCAL, SUM(DD_SALDO) QTDE_SDD FROM "+ RetSqlName("SDD")+" WITH(NOLOCK) "+CRLF
    cQry += "                     WHERE D_E_L_E_T_ = ' ' "+CRLF
    cQry += "                     GROUP BY DD_FILIAL, DD_PRODUTO, DD_LOTECTL, DD_LOCAL "+CRLF
    cQry += "                  ) SDD "+CRLF
    cQry += "			ON SB8.B8_FILIAL = SDD.DD_FILIAL "+CRLF
    cQry += "           AND SB8.B8_PRODUTO = SDD.DD_PRODUTO "+CRLF
    cQry += "           AND SB8.B8_LOTECTL = SDD.DD_LOTECTL "+CRLF
    cQry += "       	AND SB8.B8_LOCAL = SDD.DD_LOCAL "+CRLF
    cQry += "       INNER JOIN "+ RetSqlName("SB1")+" SB1 WITH(NOLOCK) "+CRLF 
    cQry += "            ON SB1.B1_FILIAL = ' ' "+CRLF 
    cQry += "            AND SB1.B1_COD = SB8.B8_PRODUTO "+CRLF
    //cQry += "            AND SB1.B1_MSBLQL = '2' "+CRLF 
    cQry += "            AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQry += "     WHERE SB8.B8_FILIAL = '"+FwXFILIAL("SB8")+"' "+CRLF 
    cQry += "     AND (SB8.B8_SALDO - SB8.B8_EMPENHO - SB8.B8_QACLASS) > 0 "+CRLF 
	//cQry += "     AND SB8.B8_PRODUTO = '410709023' "+CRLF 
    cQry += "     AND SB8.D_E_L_E_T_ = ' ' "+CRLF 
    cQry += " )TMP "+CRLF
	cQry += " ORDER BY TMP.B8_FILIAL, TMP.B8_PRODUTO "+CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry),cAliTempSB8 := GetNextAlias(),.T.,.T.) 

	(cAliTempSB8)->(dbGoTop())

	While !(cAliTempSB8)->(Eof())

		nDiasVenc := (cAliTempSB8)->B1_XPRVAL
		cTipo 	  := (cAliTempSB8)->B1_TIPO 
		_dDtValid := (dDataBase + nDiasVenc) 
		_dTLotVal := StoD((cAliTempSB8)->B8_DTVALID)
		cLocal    := (cAliTempSB8)->B8_LOCAL


		If _dDtValid > _dTLotVal .AND. cTipo $ cBloctipo .AND. cLocal $ cBlocLoc

			If (cAliTempSB8)->B1_RASTRO == "L"

				If (cAliTempSB8)->SALDO_BLOQ > 0

					cDocSDD := GetMv("DUX_EST001")
					PutMv("DUX_EST001",Soma1(cDocSDD),6)

					lMsErroAuto := .F.

					aProdBlq := {}

						aadd(aProdBlq ,{"DD_DOC"		,cDocSDD							,NIL})
						aadd(aProdBlq ,{"DD_PRODUTO"	,(cAliTempSB8)->B8_PRODUTO			,NIL})
						aadd(aProdBlq ,{"DD_LOCAL"		,(cAliTempSB8)->B8_LOCAL 			,NIL}) 
						aadd(aProdBlq ,{"DD_LOTECTL"	,(cAliTempSB8)->B8_LOTECTL			,NIL})
						aadd(aProdBlq ,{"DD_NUMLOTE"	,cNumLote							,NIL})     
						aadd(aProdBlq ,{"DD_QUANT"		,ROUND((cAliTempSB8)->SALDO_BLOQ,7)	,NIL})                       	   
						aadd(aProdBlq ,{"DD_MOTIVO"		,"VV" 	   							,NIL})  	
									
						MSExecAuto({|x,y| Mata275(x,y)},aProdBlq,3)  
						
						If lMsErroAuto
							_cErro := " " + CRLF
							// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
							_aError := GetAutoGRLog()
							For _nPos := 1 To Len(_aError)
								If !Empty((AllTrim(_aError[_nPos])))    
									Aadd(aErroPrint,{_aError[_nPos]})
								EndIf       
							Next _nPos 

							cProd    := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
							nQuant   := ROUND((cAliTempSB8)->SALDO_BLOQ,7)
							cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)
							cMsg     := SUBSTR(ALLTRIM(FwCutOff(aErroPrint[1][1], .T.)),1,100)
					
							Aadd(aItemErro,{ALLTRIM(FwCutOff(cProd, .T.)) + " | " + ALLTRIM(Transform(nQuant , "@E 9,999,999.999999"))+ " | " + ALLTRIM(FwCutOff(cLotectl, .T.))+ " | " +ALLTRIM(FwCutOff(cLocal, .T.))+ " ",;
											cMsg})



						Else
							cProd    := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
							nQuant   := ROUND((cAliTempSB8)->SALDO_BLOQ,7)
							cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)
							
							Aadd(aItemBloq,{FwCutOff(cProd, .T.),;
											ALLTRIM(Transform(nQuant , "@E 9,999,999.999999")),;
											FwCutOff(cLotectl, .T.),;
											FwCutOff(cLocal, .T.),;
											Transform(_dTLotVal, "@D 99/99/9999"),;
											FwCutOff(cStatus, .T.),;
											FwCutOff(cDocSDD, .T.),;
											FwCutOff(ALLTRIM(""+cValTochar(nDiasVenc)+" dia(s) próximo ao vencimento"), .T.)})
											
						Endif 
				Else
							
							cProd    := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
							nQuant   := ROUND((cAliTempSB8)->QTDE_SB8,7) 
							cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)
							
							cMsg := "Lote não foi bloqueado por falta de Saldo." 
						    Aadd(aItemErro,{ALLTRIM(FwCutOff(cProd, .T.)) + " | " + ALLTRIM(Transform(nQuant , "@E 9,999,999.999999"))+ " | " + ALLTRIM(FwCutOff(cLotectl, .T.))+ " | " +ALLTRIM(FwCutOff(cLocal, .T.))+ " ",;
											cMsg})

				Endif 
			Else

				cProd 	 := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
				nQuant   := ROUND((cAliTempSB8)->QTDE_SB8,7)
				cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)

				cMsg := "Produto não foi bloqueado por que o campo 'RASTRO' não está com Lote na aba 'C.Q'" 
				Aadd(aItemErro,{ALLTRIM(FwCutOff(cProd, .T.)) + " | " + ALLTRIM(Transform(nQuant , "@E 9,999,999.999999"))+ " | " + ALLTRIM(FwCutOff(cLotectl, .T.))+ " | " +ALLTRIM(FwCutOff(cLocal, .T.))+ " ",;
											cMsg})
			
			Endif

		Endif

		(cAliTempSB8)->(DbSkip())
	EndDo 

	If Len(aItemBloq) > 0

		Aadd(aDescItens,{nMarg01,cDescItem1})
		Aadd(aDescItens,{nMarg02,cDescItem2})
		Aadd(aDescItens,{nMarg03,cDescItem3})
		Aadd(aDescItens,{nMarg04,cDescItem4})
		Aadd(aDescItens,{nMarg05,cDescItem5})
		Aadd(aDescItens,{nMarg06,cDescItem6})
		Aadd(aDescItens,{nMarg07,cDescItem7})
		Aadd(aDescItens,{nMarg08,cDescItem8})
		

		aAnexos := U_ZGENPDF(aDescItens,aItemBloq,cSubject,cRotina)
		U_ZGENMAIL(FwCutOff(cSubject, .T.),cMensagem,cEMail,aAnexos,.F.,cRotina)
		If Len(aAnexos) > 0
			cDelArq := aAnexos[1]
			fErase(cDelArq)
		Endif

	Endif

	IF Len(aItemErro) > 0 

		aDescItens := {}

		Aadd(aDescItens,{nMarErro1,cDescErro1})
		Aadd(aDescItens,{nMarErro2,cDescErro2})
		
		aAnexos := U_ZGENPDF(aDescItens,aItemErro,cSubject,cRotina)
		U_ZGENMAIL(FwCutOff(cSubject+" Erro", .T.),cMensagem,cEMail,aAnexos,.F.,cRotina)
		If Len(aAnexos) > 0
			cDelArq := aAnexos[1]
			fErase(cDelArq)
		Endif
	
	Endif

	aProdBlq := {}  //Limpo Array com linha..!
 
(cAliTempSB8)->(dbCloseArea())

RestArea(_aAreaSB8)
RestArea(_aAreaSDD)

Return (lRet)












