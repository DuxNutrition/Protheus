#include 'totvs.ch'
#include 'tbiconn.ch'
/*/{Protheus.doc} DUXIMPCP
	
	Importação de Títulos a Pagar a partir de arquivo .CSV
	
/*/
User Function DUXIMPCP()

Local nOpcA		:= 0
Local cPerg		:= 'DUXIMPCP'

Private cCadastro	:= 'Importação Títulos a Pagar'
Private nRegImp		:= 0
Private nRegErro	:= 0
Private nLidos      := 0

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01		, cDef02			, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Local ou Arquivo CSV:"	, "mv_par01", "mv_ch1"	, "C"		, 99						, 0			, "F"		,               	, 			, 			, "56"			,					,			,			,			,		, 			)

FormBatch( cCadastro, ;
            {'Este programa vai importar os Títulos a Pagar de arquivo .CSV', ;
            ' Grava LOG do resultado no diretório C:\TEMP\DUXIMPCP... na máquina onde executou.' }, ;
            {{ 5, .T., {|o| Pergunte( cPerg, .T. ) }}, ;
            { 1, .T., {|o| nOpcA:=1, If( gpconfOK(), FechaBatch(), nOpcA:=0 ) } }, ;
            { 2, .T., {|o| FechaBatch() }}} )

If nOpcA == 1
	
	FWMsgRun(, {|oSay| U_DUIMPCP( MV_PAR01, oSay ) }, cCadastro, 'Importando Títulos a Pagar...' )
	
	Aviso(  cCadastro, ;
			'Títulos Lidos na Planilha   : ' + Transform( nLidos,  '@E 999,999' ) + Chr( 10 ) + ;
			'Títulos a Receber importados: ' + Transform( nRegImp, '@E 999,999' ) + Chr( 10 ) + ;
			'Falhas na importação: ' + Transform( nRegErro, '@E 999,999' ), { 'Ok' } )
EndIf

Return

/*/{Protheus.doc} DUIMPCP
	
	Importação de Títulos a Pagar a partir de arquivo CSV - Processamento
	
/*/
User Function DUIMPCP( cPathOrig, oSay )

Local nHdl, cLine
Local aLine     := {}
Local aLog      := {}
Local aLogE     := {}
Local aLogTmp   := {} 
Local cLogTmp   := ''
Local aRotAuto	:= {}
Local lOk
Local cNum     := ""
Local cParcela := ""
Local cTipo    := ""
Local cFornece := ""
Local cLoja    := ""
Local cCNPJ    := ""
Local cConta   := ""
Local cCtaPlan := ""
Local cNaturez := ""
Local nValor   := 0
Local nSaldo   := 0

Private lMsHelpAuto 	:= .T.	// Habilita a captura das mensagens de erro
Private lAutoErrNoFile	:= .T.  //.F.	// Desabilita a geração do arquivo de log padrão do sistema
Private lMsErroAuto 	:= .F.	// Indica de se houve erro não fatal durante a execução

nHdl	:= FT_fUse( cPathOrig )

If nHdl == -1
        
    msgstop('Falha na abertura do arquivo'+cPathOrig)

	return
EndIf

ProcRegua( FT_fLastRec() )	// Retorna o número de linhas do arquivo

FT_fGoTop()

FT_fSkip()      // cabeçalho

While !FT_fEOF() 
	
	IncProc()

	nLidos ++
	
	cLine  := FT_fReadLn() // Retorna a linha corrente

	aLine	:= CI_ListAsArray( cLine, ';' )
	
	If Len( aLine ) < 2
		Exit
	EndIf

	DbSetOrder(1)
			
	cNum    	:= PadR( aLine[ 01 ],Len(SE2->E2_NUM) )
	
	If     Alltrim(aLine[03]) = 'PCC'
		cParcela := '1'
	elseif Alltrim(aLine[03]) = 'IRRF'
		cParcela := '2'
	elseif Alltrim(aLine[03]) = 'ISS'
		cParcela := '3'
	elseif Alltrim(aLine[03]) = 'INSS'
		cParcela := '4'
	else		
		cParcela   	:= PadR( aLine[ 02 ],Len(SE2->E2_PARCELA) )
	ENDIF

    nValor      := Val(StrTran(StrTran( aLine[ 11 ] ,".",""),",","."))
    nSaldo      := Val(StrTran(StrTran( aLine[ 12 ] ,".",""),",","."))
	nSaldo      := nValor - nSaldo 
	cCtaPlan    := StrTran(Substr(aLine[06],1,12) ,".","")

	If      cCtaPlan $ '21101001,21101002,21101004,21101005,21101006,21102001,21102002,21102003,21102004,21104002,21104003,21104008'
		    cConta := '21101001'
	ElseIf  cCtaPlan = '21104005'
		    cConta  := '21104003'
	ElseIf  cCtaPlan = '21104004'
		    cConta  := '21104005'
	ElseIf  cCtaPlan = '21104006'
		    cConta  := '21104006'
	ElseIf  cCtaPlan = '21303001'
		    cConta  := '21108010'
	ElseIf  cCtaPlan = '21303002'
		    cConta  := '21108011'
	ElseIf  cCtaPlan = '21303003'
		    cConta  := '21108012'
	ElseIf  cCtaPlan = '21303004'
		    cConta  := '21108013'
	ElseIf  cCtaPlan = '21302007,21109001,21302008,21109001,21302017,21109001,21302018'
		    cConta  := '21109001'
	ElseIf  cCtaPlan = '21302001,21302002'
		    cConta  := '21109002'
	ElseIf  cCtaPlan = '21302005,21302006,21302011'
		    cConta  := '21109003'
	ElseIf  cCtaPlan = '21109004,21302003,21302004,21302012,21302015,21302016'
		    cConta  := '21109004'
	ElseIf  cCtaPlan = '21302009,21302014'
		    cConta  := '21109005'
	ElseIf  cCtaPlan = '21108001'
		    cConta  := '21302001'
	ElseIf  cCtaPlan = '21104007'
		    cConta  := '21101001'
//		    cConta  := '21104'
	Else
		    cConta := ' '
	Endif
	
	
	If  aLine[07] <> 'INSS'
		cCNPJ       := StrZero( Val(aLine[ 07 ]),Len(SA2->A2_CGC))
	
		dbselectArea("SA2")
		DbSetOrder(3)
		If SA2->( dbseek(xFilial("SA2") + cCNPJ, .f.)) 
			cFornece := A2_COD
			cLoja    := A2_LOJA
			cNaturez := A2_NATUREZ
		Else
			cLogtmp = ('Não existe o Fornecedor ' + cCNPJ +" "+ aLine[08] + CHR(13) + CHR(10))
			aAdd( aLogE, { cNum, cvaltochar(nValor), cLogTmp } )
			nRegErro ++
			FT_fSkip()
			Loop
		ENDIF
	else
		cFornece := '000005'
		cLoja    := '0000'
		cNaturez := '50604'
		cCNPJ    := ' '
	Endif

	If  aLine[04] = '' 
		cTipo := 'DP'
	Else	
		cTipo := aLine[04]
	Endif

	aRotAuto    := {}

    SE2->( dbSetOrder( 1 ) )
    While SE2->( dbSeek( '01' + 'IMP' + cNum + cParcela + cTipo + cFornece + cLoja, .F. ) )
          aAdd( aLogE, { cNum, cvaltochar(nValor), 'Titulo já está cadastrado '} )
    End
	
	aAdd( aRotAuto, { 'E2_FILIAL'	, '01'  			                , Nil } )
	aAdd( aRotAuto, { 'E2_PREFIXO'	, 'IMP' 			                , Nil } )
	aAdd( aRotAuto, { 'E2_NUM'		, cNum			                    , Nil } )
	aAdd( aRotAuto, { 'E2_PARCELA'	, cParcela   	                    , Nil } )
	aAdd( aRotAuto, { 'E2_TIPO'		, cTipo 	                     	, Nil } )
	aAdd( aRotAuto, { 'E2_NATUREZ'	, cNaturez                 			, Nil } )
	aAdd( aRotAuto, { 'E2_FORNECE'	, cFornece			                , Nil } )
	aAdd( aRotAuto, { 'E2_LOJA'		, cLoja                 			, Nil } )
	aAdd( aRotAuto, { 'E2_EMISSAO'	, CToD( Alltrim(aLine[ 09 ] ))      , Nil } )
	aAdd( aRotAuto, { 'E2_VENCTO'	, CToD( Alltrim(aLine[ 10 ] ))      , Nil } )
	aAdd( aRotAuto, { 'E2_VALOR'	, nValor							, Nil } )
	aAdd( aRotAuto, { 'E2_SALDO'	, nSaldo							, Nil } )
	aAdd( aRotAuto, { 'E2_HIST'		, aLine[13]							, Nil } )
	aAdd( aRotAuto, { 'E2_CONTAD'	, cConta	 						, Nil } )
	aAdd( aRotAuto, { 'E2_CCUSTO'	, ' '   							, Nil } )

    lMsErroAuto	:= .F.

	MSExecAuto( { |x,y,z| FINA050( x, y, z )}, aRotAuto,, 3 )
		
	If lMsErroAuto
			
//        MostraErro()
			
		aLogTmp := GetAutoGRLog()
        cLogTmp := ''
		aEval( aLogTmp, { |x| cLogTmp += x + chr(10) } )

        aAdd( aLogE, { cNum, cvaltochar(nValor), 'Erro na rotina automática: ' + cLogTmp } )

        nRegErro    ++
        lOk     := .F.
    Else
        aAdd( aLog, { cNum, cvaltochar(nValor), 'Título incluído com sucesso' } )

        nRegImp     ++
	EndIf

    FT_fSkip()

End

FT_fUse()

If ( nRegImp + nRegErro ) > 0
	
	DUIMPLog( aLog,aLogE )
EndIf

Return

//----------------------------------------- Gera Log
Static Function DUIMPLog( aLog,aLogE )

Local cHtml
Local nI
Local nTotal := 0
Local nQtde  := 0

cHtml := '<html>'	+ CRLF

cHtml += '<head>'	+ CRLF
cHtml += '<title>Importação Titulos a Pagar </title>' + CRLF
cHtml += '</head>' + CRLF

cHtml += '<body bgcolor=white text=black >' + CRLF
cHtml += '<h2>Importação Titulos a Pagar </h2>' + CRLF

If Len( aLog ) > 0

	cHtml += '<br>Os seguintes Títulos a Pagar foram incluídos no sistema Protheus:</a><br>' + CRLF

	cHtml += '<br><table>' + CRLF
	cHtml += '<table border=2>' + CRLF
	cHtml += '<tr bgcolor="#99CCFF" >' + ;
					'<th> Titulo </th>' + ;
					'<th> Valor </th>' + ;
					'<th> Log </th></tr>' + CRLF
	

	For nI := 1 to Len( aLog )

//		cHtml += '<tr><td>' + aLog[ nI, 1 ] + ;
//				 '</td><td align="right" >' + Transform(aLog[ nI, 2 ],'@E 999,999,999.99' ) + ;
//				 '</td><td>' + aLog[ nI, 3 ] + '</td> </tr>' + CRLF
		nTotal += Val(aLog[nI,2])
		nQtde  ++
	Next nI

	cHtml += '<tr><td>' + 'INCLUÍDOS ' + ;
			 '</td><td align="right" >' + Transform( nTotal, '@E 999,999,999.99' ) + ;
			 '</td><td>' + 'Qtde. ' + Transform( nQtde, '@E 999,999' ) + '</td> </tr>' + CRLF
	
	cHtml += '</table>' + CRLF
EndIf

nQtde  := 0
nTotal := 0
If Len( aLogE) > 0

	cHtml += '<br>Os seguintes erros foram gerados:</a><br>' + CRLF

	cHtml += '<br><table>' + CRLF
	cHtml += '<table border=2>' + CRLF
	cHtml += '<tr bgcolor="#99CCFF" >' + ;
					'<th> Titulo </th>' + ;
					'<th> Valor </th>' + ;
					'<th> Log </th></tr>' + CRLF
	
	For nI := 1 to Len( aLogE)

		cHtml += '<tr><td>' + aLogE[ nI, 1 ] + ;
				 '</td><td align="right" >' + aLogE[ nI, 2 ] + ;
				 '</td><td>' + aLogE[ nI, 3 ] + '</td> </tr>' + CRLF
		nTotal += Val(aLogE[nI,2])
		nQtde  ++
	Next nI

	cHtml += '<tr><td>' + 'TOTAL ' + ;
			 '</td><td align="right" >' + Transform( nTotal, '@E 999,999,999.99' ) + ;
			 '</td><td>' + 'Qtde. ' + Transform( nQtde, '@E 999,999' ) + '</td> </tr>' + CRLF
	
	cHtml += '</table>' + CRLF
EndIf

If nRegErro > 0
	
	cHtml += '<br>A integração teve ' + AllTrim( Str( nRegErro ) ) + ' erro' + If( nRegErro > 1, 's', '' ) + '.</a><br>' + CRLF
EndIf
cHtml += '<br> Processado em ' + DtoC( dDataBase ) + ' às ' + Time() + ' h por ' + AllTrim( cUserName ) + ' </a>' + CRLF
cHtml += '<br> </a>' + CRLF
cHtml += '</body></html>' + CRLF

MemoWrite( 'C:\TEMP\DUXIMPCP_' + DtoS( Date() ) + '_' + StrTran( Time(), ':', '' ) + '.html', cHtml )

Return

Static Function CI_ListAsArray( cList, cDelimiter, nTamArr )

Local nPos            // Position of cDelimiter in cList
Local aList:={}

// Loop while there are more items to extract
While ( nPos := AT( cDelimiter, cList ) ) <> 0
	
	// Add the item to aList and remove it from cList
	aAdd( aList, SubStr( cList, 1, nPos - 1 ) )
	cList := SubStr( cList, nPos + 1 )
End
aAdd( aList, cList )                         // Add final element

Return( aList )
