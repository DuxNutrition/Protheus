#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} 
Função para bloquear lote do produto conforme o prazo de dias de vencimento.
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
Local cSubject      := "Lotes bloqueados próximo ao vencimento.!"
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

Local cDescItem1 := "Produto"
Local cDescItem2 := "Quantidade"
Local cDescItem3 := "Lote"
Local cDescItem4 := "Local"
Local cDescItem5 := "Validade"
Local cDescItem6 := "Quantidade"
Local cDescItem7 := "Documento"
Local cDescItem8 := "Motivo do Bloqueio"
Local cStatus  := "Bloqueado"

Local nMarg01      := 5
Local nMarg02      := 59
Local nMarg03      := 119
Local nMarg04      := 162
Local nMarg05      := 210
Local nMarg06      := 279
Local nMarg07      := 333
Local nMarg08      := 400

Local _aError       := {}
Local aErroPrint	:= {}
Local aDescItens    := {}
Local aMargItens    := {}

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.

Default cDocSDD     := HS_VSxeNum("SDD", "M->DD_DOC", 1)
Default cNumLote    := Space(Len(SDD->DD_NUMLOTE))

	If Select((cAliTempSB8)) > 0
		(cAliTempSB8)->(dbCloseArea())
	EndIf

    cQry := " SELECT B8_PRODUTO,(B8_SALDO - B8_EMPENHO - B8_QACLASS) AS B8_SALDO,B8_LOCAL,B8_LOTECTL,B8_DTVALID,B1_TIPO,B1_XPRVAL,B1_RASTRO "+CRLF 
    cQry +=	" FROM "+ RetSqlName("SB8")+" B8 WITH(NOLOCK) "+CRLF
	cQry +=	" INNER JOIN "+ RetSqlName("SB1")+" B1 WITH(NOLOCK) "+CRLF
	cQry +=	" ON B1.B1_FILIAL = '"+FwXFILIAL("SB1")+"' "+CRLF
	cQry +=	" AND B1.B1_COD = B8.B8_PRODUTO "+CRLF
	cQry +=	" AND B1.B1_MSBLQL = '2' "+CRLF
	cQry +=	" AND B1.D_E_L_E_T_ = ' ' "+CRLF
	cQry +=	" WHERE 1=1 "+CRLF
    cQry +=	" AND B8_FILIAL = '"+FwXFILIAL("SB8")+"' "+CRLF
	//cQry +=	" AND B8_PRODUTO IN ('410204001','410709023','410713018','410713023','430213019','410722022','410722015','410713023','410713023') "+CRLF
    cQry +=	" AND (B8_SALDO - B8_EMPENHO - B8_QACLASS) > 0 "+CRLF
    cQry +=	" AND B8.D_E_L_E_T_ = ' ' "+CRLF
    cQry +=	" ORDER BY B8_FILIAL,B8_PRODUTO "+CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry),cAliTempSB8 := GetNextAlias(),.T.,.T.) 

	(cAliTempSB8)->(dbGoTop())

	While !(cAliTempSB8)->(Eof())

		nDiasVenc := (cAliTempSB8)->B1_XPRVAL
		cTipo 	  := (cAliTempSB8)->B1_TIPO 
		_dDtValid := (dDataBase + nDiasVenc) 
		_dTLotVal := StoD((cAliTempSB8)->B8_DTVALID)

		If _dDtValid > _dTLotVal .AND. cTipo $ cBloctipo

			If (cAliTempSB8)->B1_RASTRO == "L"

				cDocSDD := GetMv("DUX_EST001")
				PutMv("DUX_EST001",Soma1(cDocSDD),6)

				lMsErroAuto := .F.

				aProdBlq := {}

					aadd(aProdBlq ,{"DD_DOC"		,cDocSDD							,NIL})
					aadd(aProdBlq ,{"DD_PRODUTO"	,(cAliTempSB8)->B8_PRODUTO			,NIL})
					aadd(aProdBlq ,{"DD_LOCAL"		,(cAliTempSB8)->B8_LOCAL 			,NIL}) 
					aadd(aProdBlq ,{"DD_LOTECTL"	,(cAliTempSB8)->B8_LOTECTL			,NIL})
					aadd(aProdBlq ,{"DD_NUMLOTE"	,cNumLote							,NIL})     
					aadd(aProdBlq ,{"DD_QUANT"		,ROUND((cAliTempSB8)->B8_SALDO,7)	,NIL})                       	   
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
						Aadd(aItemErro,{ALLTRIM((cAliTempSB8)->B8_PRODUTO),ROUND((cAliTempSB8)->B8_SALDO,7),ALLTRIM((cAliTempSB8)->B8_LOTECTL),(cAliTempSB8)->B8_LOCAL,aErroPrint})
					Else
						cProd    := ALLTRIM((cAliTempSB8)->B8_PRODUTO)
						nQuant   := ROUND((cAliTempSB8)->B8_SALDO,7)
						cLotectl := ALLTRIM((cAliTempSB8)->B8_LOTECTL)
						cLocal   := (cAliTempSB8)->B8_LOCAL
						Aadd(aItemBloq,{nMarg01,cProd})
						Aadd(aItemBloq,{nMarg02,Transform(nQuant , "@E 9,999,999.999999")})
						Aadd(aItemBloq,{nMarg03,cLocal})
						Aadd(aItemBloq,{nMarg04,nMarg01cLotectl})
						Aadd(aItemBloq,{nMarg05,Transform(_dTLotVal, "@D 99/99/9999")})
						Aadd(aItemBloq,{nMarg06,cStatus})
						Aadd(aItemBloq,{nMarg07,cDocSDD})
						Aadd(aItemBloq,{nMarg08,""+ccValTochar(nDiasVenc)+" dia(s) próximo ao vencimento"})
					Endif  
			Else

				cMsg := "Produto não foi bloqueado por que o campo 'RASTRO' não está com Lote na aba 'C.Q' " 
				Aadd(aRastErro,{ALLTRIM((cAliTempSB8)->B8_PRODUTO),ROUND((cAliTempSB8)->B8_SALDO,7),ALLTRIM((cAliTempSB8)->B8_LOTECTL),(cAliTempSB8)->B8_LOCAL,cMsg})
			
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
		//cMensagem := CabecErro(aItemErro,aRastErro)
		//U_ZGENMAIL(cSubject,cMensagem,cEMail, ,.F.,cRotina)
		//ZItensImpre()
		//U_ZGENPDF2(aItemErro,aRastErro,cSubject,cRotina)
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
cMensagem += '  		<td width="12%"><Font Size = "2" face = "arial"><b>'+ "Armazém"+'</b></font></td> '
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
	cMensagem += '  		<td width="60%" bgcolor="#ffffff"><Font Size = "2" face = "arial">'+ aItemBloq[nI][7] + ' dia(s) próximo ao vencimento'+'</font></td> '
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
		cMensagem += '	<Font Size="2" face="arial"><b>Armazém: </b>'+ aItemErro[nY][4] + '</font> '
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
		cMensagem += '	<Font Size="2" face="arial"><b>Armazém: </b>'+ aRastErro[nJ][4] + '</font> '
		cMensagem += '	<br> '
		cMensagem += '	<br> '
		cMensagem += '	<p>'+ Alltrim(aRastErro[nJ][5]) + '</p> '
		cMensagem += '	<hr> '
		cMensagem += '</div> '
	Next nJ
Endif
	
Return (cMensagem)














