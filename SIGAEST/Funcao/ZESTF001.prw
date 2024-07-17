#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} 
Fun��o para bloquear lote do produto conforme o prazo de dias de vencimento.
@author Jedielson Rodrigues
@since 17/06/2024
@history 
@version P11,P12
@database MSSQL

/*/

User Function ZESTF001()

Local cQry 			:= " " 
Local _aAreaSB8 	:= SB8->(GetArea())
Local _aAreaSDD 	:= SDD->(GetArea())
Local aProdBlq  	:= {}
Local aItemBloq  	:= {}
Local aItemErro		:= {}
Local aRastErro		:= {}

Local cEMail	    := SuperGetMv("DUX_EST003",.F.,"jedielson.rodrigues@duxnutrition.com")
Local cSubject      := "Lotes bloqueados pr�ximo ao vencimento.!"
Local cMsg          := " "
Local cMensagem 	:= " "
Local cRotina       := "ZESTF001"
Local lRet 			:= .T.
Local cProd     	:= " "
Local nQuant    	:= 0
Local cLotectl  	:= " "
Local cDocSDD   	:= SuperGetMv("DUX_EST001",.F.,"BLOC01")
Local cTipo         := " "
Local cBloctipo     := SuperGetMv("DUX_EST002",.F.,"PA#ME")
Local nDiasVenc   	:= 0
Local _dDtValid 	:= CtoD( "" )
Local _dTLotVal   	:= CtoD( "" )
Local cAliTempSB8   := GetNextAlias()
Local _cErro        := " "
Local _nPos         := 0

// Descri��o dos Itens Bloqueados

Local cDescItem1 := "Produto"
Local cDescItem2 := "Quantidade"
Local cDescItem3 := "Lote"
Local cDescItem4 := "Local"
Local cDescItem5 := "Validade"
Local cDescItem6 := "Status"
Local cDescItem7 := "Documento"
Local cDescItem8 := "Motivo do Bloqueio"
Local cStatus  	 := "Bloqueado"

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
Local nMarErro2     := 90
Local nMarErro3     := 110
Local nMarErro4     := 200
Local nMarErro5     := 230
Local nMarErro6     := 300
Local nMarErro7     := 330


//Local nMarErro7     := 5
//Local nMarErro8     := 5

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
    cQry += "            AND SB1.B1_MSBLQL = '2' "+CRLF 
    cQry += "            AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQry += "     WHERE SB8.B8_FILIAL = '"+FwXFILIAL("SB8")+"' "+CRLF 
    cQry += "     AND (SB8.B8_SALDO - SB8.B8_EMPENHO - SB8.B8_QACLASS) > 0 "+CRLF 
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

		If _dDtValid > _dTLotVal .AND. cTipo $ cBloctipo

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
							cLocal   := (cAliTempSB8)->B8_LOCAL

							Aadd(aItemErro,{FwCutOff(cProd, .T.),;
											ALLTRIM(Transform(nQuant , "@E 9,999,999.999999")),;
											FwCutOff(cLotectl, .T.),;
											FwCutOff(cLocal, .T.),;
											FwCutOff(aErroPrint, .T.)})
						Else
							cProd    := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
							nQuant   := ROUND((cAliTempSB8)->SALDO_BLOQ,7)
							cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)
							cLocal   := (cAliTempSB8)->B8_LOCAL

							Aadd(aItemBloq,{FwCutOff(cProd, .T.),;
											ALLTRIM(Transform(nQuant , "@E 9,999,999.999999")),;
											FwCutOff(cLotectl, .T.),;
											FwCutOff(cLocal, .T.),;
											Transform(_dTLotVal, "@D 99/99/9999"),;
											FwCutOff(cStatus, .T.),;
											FwCutOff(cDocSDD, .T.),;
											FwCutOff(ALLTRIM(""+cValTochar(nDiasVenc)+" dia(s) pr�ximo ao vencimento"), .T.)})
											
						Endif 
				Else
							
							cProd    := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
							nQuant   := ROUND((cAliTempSB8)->QTDE_SB8,7) 
							cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)
							cLocal   := (cAliTempSB8)->B8_LOCAL
							
							cMsg := "Lote n�o foi bloqueado por falta de Saldo. " 
							Aadd(aRastErro,{"Produto: " +FwCutOff(cProd, .T.)+ " ",; 
											" | ",;
											"Quantidade:" +ALLTRIM(Transform(nQuant , "@E 9,999,999.999999"))+ " ",;
											" | ",;
											"Lote: " +FwCutOff(cLotectl, .T.)+ " ",;
											" | ",;
											"Local: " +FwCutOff(cLocal, .T.)+ " ",;
											FwCutOff(cMsg, .T.)})

				Endif 
			Else

				cProd 	 := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
				nQuant   := ROUND((cAliTempSB8)->QTDE_SB8,7)
				cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)
				cLocal   := (cAliTempSB8)->B8_LOCAL

				cMsg := "Produto n�o foi bloqueado por que o campo 'RASTRO' n�o est� com Lote na aba 'C.Q' " 
				Aadd(aRastErro,{FwCutOff(cProd, .T.),;
								ALLTRIM(Transform(nQuant , "@E 9,999,999.999999")),;
								FwCutOff(cLotectl, .T.),;
								FwCutOff(cLocal, .T.),;
								FwCutOff(cMsg, .T.)})
			
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
		
		U_ZGENPDF1(aDescItens,aItemBloq,cSubject,cRotina)

	Endif

	IF Len(aItemErro) > 0 .OR. Len(aRastErro) > 0

		aDescItens := {}

		Aadd(aDescItens,{nMarErro1})
		Aadd(aDescItens,{nMarErro2})
		Aadd(aDescItens,{nMarErro3})
		Aadd(aDescItens,{nMarErro4})
		Aadd(aDescItens,{nMarErro5})
		Aadd(aDescItens,{nMarErro6})
		Aadd(aDescItens,{nMarErro7})
		//Aadd(aDescItens,{nMarErro8,cDescErro8})
		
		U_ZGENPDF2(aDescItens,aItemErro,aRastErro,cSubject,cRotina)

		//U_ZGENMAIL(cSubject,cMensagem,cEMail, ,.F.,cRotina)
	
	Endif

	aProdBlq := {}  //Limpo Array com linha..!
 
(cAliTempSB8)->(dbCloseArea())

RestArea(_aAreaSB8)
RestArea(_aAreaSDD)

Return (lRet)

Static Function CabecRel(aItemBloq)

Local cMensagem 	    := " "
Local nI	     	    := 0

cMensagem += '	<table width="1000" border="1" cellpadding="2" cellspacing="0" style="border-collapse: collapse"  id="AutoNumber1"> '
cMensagem += ' 		<tr> '
cMensagem += '  		<td width="12%"><Font Size = "2" face = "arial"><b>'+ "Produto"+'</b></font></td> '
cMensagem += '  		<td width="10%"><Font Size = "2" face = "arial"><b>'+ "Quantidade"+'</b></font></td> '
cMensagem += '  		<td width="12%"><Font Size = "2" face = "arial"><b>'+ "Lote"+'</b></font></td> '
cMensagem += '  		<td width="12%"><Font Size = "2" face = "arial"><b>'+ "Armaz�m"+'</b></font></td> '
cMensagem += '  		<td width="12%"><Font Size = "2" face = "arial"><b>'+ "Validade"+'</b></font></td> '
cMensagem += '  		<td width="10%"><Font Size = "2" face = "arial"><b>'+ "Status"+'</b></font></td> '
cMensagem += '  		<td width="10%"><Font Size = "2" face = "arial"><b>'+ "Documento"+'</b></font></td> '
cMensagem += '  		<td width="60%"><Font Size = "2" face = "arial"><b>'+ "Motivo do Bloqueio"+'</b></font></td> '
cMensagem += ' 		</tr> '
cMensagem += ' </table> ' 
For nI:= 1 To Len( aItemBloq )
	cMensagem += '	<table width="1000" border="1" cellpadding="2" cellspacing="0" style="border-collapse: collapse"  id="AutoNumber1"> '
	cMensagem += '		<tr> ' 
	cMensagem += '  		<td width="12%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ aItemBloq[nI][1] + '</font></td> ' 
	cMensagem += '  		<td width="10%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ Transform(aItemBloq[nI][2] , "@E 9,999,999.999999")   +'</font></td> ' 
	cMensagem += '  		<td width="12%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ aItemBloq[nI][3] + '</font></td> ' 
	cMensagem += '  		<td width="12%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ aItemBloq[nI][4] + '</font></td> ' 
	cMensagem += '  		<td width="12%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ Transform(aItemBloq[nI][5], "@D 99/99/9999") +'</font></td> ' 
	cMensagem += '  		<td width="10%" bgcolor="#ffffff"><Font Size = "2" face = "arial">Bloqueado</font></td> ' 
	cMensagem += '  		<td width="10%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ aItemBloq[nI][6] + '</font></td> '
	cMensagem += '  		<td width="60%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ aItemBloq[nI][7] + ' dia(s) pr�ximo ao vencimento'+'</font></td> '
	cMensagem += '		</tr> ' 
	cMensagem += '	</table> ' 
Next nI

Return (cMensagem)

Static Function CabecErro(aItemErro,aRastErro)

Local cMensagem 	    := " "
Local nY	     	    := 0
Local nJ                := 0

If  Len( aItemErro ) > 0
	For nY:= 1 To Len( aItemErro )
		cMensagem += '<div style="text-align: left; max-width: 545px;"> '
		cMensagem += '	<Font Size="2" face="arial"><b>Produto: </b>'+ aItemErro[nY][1] + '</font> &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;&nbsp; '
		cMensagem += '	<Font Size="2" face="arial"><b>Quantidade: </b>'+ Transform(aItemErro[nY][2] , "@E 9,999,999.999999")   +'</font> &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;&nbsp; '
		cMensagem += '	<Font Size="2" face="arial"><b>Lote: </b>'+ aItemErro[nY][3] + '</font> &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;&nbsp; '
		cMensagem += '	<Font Size="2" face="arial"><b>Armaz�m: </b>'+ aItemErro[nY][4] + '</font> '
		cMensagem += '	<br> '
		cMensagem += '	<br> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][1][1]) + '</p> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][2][1]) + '</p> '
		cMensagem += '	<hr> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][3][1]) + '</p> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][4][1]) + '</p> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][5][1]) + '</p> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][6][1]) + '</p> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][7][1]) + '</p> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][8][1]) + '</p> '
		cMensagem += '	<p>'+ Alltrim(aItemErro[nY][5][9][1]) + '</p> '
		cMensagem += '	<hr> '
		cMensagem += '</div> '
	Next nI
Endif

If Len(aRastErro) > 0 
	For nJ:= 1 To Len( aRastErro )
		cMensagem += '<div style="text-align: left; max-width: 545px;"> '
		cMensagem += '	<Font Size="2" face="arial"><b>Produto: </b>'+ aRastErro[nJ][1] + '</font> &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;&nbsp; '
		cMensagem += '	<Font Size="2" face="arial"><b>Quantidade: </b>'+ Transform(aRastErro[nJ][2] , "@E 9,999,999.999999")   +'</font> &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;&nbsp; '
		cMensagem += '	<Font Size="2" face="arial"><b>Lote: </b>'+ aRastErro[nJ][3] + '</font> &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;&nbsp;&nbsp; '
		cMensagem += '	<Font Size="2" face="arial"><b>Armaz�m: </b>'+ aRastErro[nJ][4] + '</font> '
		cMensagem += '	<br> '
		cMensagem += '	<br> '
		cMensagem += '	<p>'+ Alltrim(aRastErro[nJ][5]) + '</p> '
		cMensagem += '	<hr> '
		cMensagem += '</div> '
	Next nJ
Endif
	
Return (cMensagem)














