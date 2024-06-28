#include 'totvs.ch'
#include 'tbiconn.ch'
/*/{Protheus.doc} DUXIMPCR
	
	Importação de Títulos a Receber a partir de arquivo .CSV
	
/*/
User Function DUXIMPCR()

Local nOpcA		:= 0
Local cPerg		:= 'DUXIMPCR'

Private cCadastro	:= 'Importação Títulos a Receber'
Private nRegImp		:= 0
Private nRegErro	:= 0 
Private nLidos      := 0

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01		, cDef02			, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
//u_PutSX1( cPerg	, "01"	, "Local ou Arquivo CSV:"	, "mv_par01", "mv_ch1"	, "C"		, 99						, 0			, "F"		,               	, 			, 			, "56"			,					,			,			,			,		, 			)

FormBatch( cCadastro, ;
            {'Este programa vai importar os Títulos a Receber de arquivo .CSV.', ;
            ' Grava LOG do resultado no diretório C:\TEMP\DUXIMPCR... na máquina onde executou.' }, ;
            {{ 5, .T., {|o| Pergunte( cPerg, .T. ) }}, ;
            { 1, .T., {|o| nOpcA:=1, If( gpconfOK(), FechaBatch(), nOpcA:=0 ) } }, ;
            { 2, .T., {|o| FechaBatch() }}} )

If nOpcA == 1
	
	FWMsgRun(, {|oSay| U_DUIMPRun( MV_PAR01, oSay ) }, cCadastro, 'Importando Títulos a Receber...' )
	
	Aviso(  cCadastro, ;
			'Títulos Lidos na Planilha   : ' + Transform( nLidos,  '@E 999,999' ) + Chr( 10 ) + ;
			'Títulos a Receber importados: ' + Transform( nRegImp, '@E 999,999' ) + Chr( 10 ) + ;
			'Falhas na importação        : ' + Transform( nRegErro,'@E 999,999' ), { 'Ok' } )
EndIf

Return

/*/{Protheus.doc} DUIMPRun
	
	Importação de Títulos a Receber a partir de arquivo CSV - Processamento
	
/*/
User Function DUIMPRun( cPathOrig, oSay )

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
Local cCliente := ""
Local cLoja    := ""
Local cCNPJ    := ""
Local cBanco   := ""
Local cNaturez := ""
Local nValor   := 0

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
			
	cNum    	:= PadR( aLine[ 16 ],Len(SE1->E1_NUM) )
	cParcela   	:= PadR( aLine[ 17 ],Len(SE1->E1_PARCELA) )
	cCNPJ       := StrZero( Val(aLine[ 02 ]),Len(SA1->A1_CGC))
    nValor      := Val(StrTran(StrTran( aLine[ 06 ] ,".",""),",","."))

	If      aLine[ 11 ] = 'ABC'
		    cBanco := '246'
	ElseIf  aLine[ 11 ] = 'Banco do Brasil'
		    cBanco := '001'
	ElseIf  aLine[ 11 ] = 'Banco Fibra'
		    cBanco := '224'
	ElseIf  aLine[ 11 ] = 'Bocom'
		    cBanco := '107'
	ElseIf  aLine[ 11 ] = 'Bradesco'
		    cBanco := '237'
	ElseIf  aLine[ 11 ] = 'BS2'
		    cBanco := '218'
	ElseIf  aLine[ 11 ] = 'C6'
		    cBanco := '336'
	ElseIf  aLine[ 11 ] = 'Caixa'
		    cBanco := '104'
	ElseIf  aLine[ 11 ] = 'Daycoval'
		    cBanco := '707'
	ElseIf  aLine[ 11 ] = 'Industrial'
		    cBanco := '604'
	ElseIf  aLine[ 11 ] $ 'Itau/Itaú/Itaú 1/Itaú 2'
		    cBanco := '341'
	ElseIf  aLine[ 11 ] = 'Pine'
		    cBanco := '643'
	ElseIf  aLine[ 11 ] $ 'Safra/Safra 2'
		    cBanco := '422'
	ElseIf  aLine[ 11 ] = 'Santander'
		    cBanco := '033'
	ElseIf  aLine[ 11 ] = 'Votorantim'
		    cBanco := '655'
	Else
		    cBanco := ' '
	Endif
	
	dbselectArea("SA1")
	DbSetOrder(3)
    If SA1->( dbseek(xFilial("SA1") + cCNPJ, .f.)) 

		cCliente := A1_COD
		cLoja    := A1_LOJA
		cNaturez := A1_NATUREZ
    Else
		cLogtmp := ('Não existe o cliente ' + cCNPJ + CHR(13) + CHR(10))
        aAdd( aLogE, { cNum, cvaltochar(nValor), 'Erro no cliente da planilha : ' + cLogTmp } )
        nRegErro    ++
		FT_fSkip()
		Loop
	ENDIF

	aRotAuto    := {}

    SE1->( dbSetOrder( 1 ) )
    While SE1->( dbSeek( xFilial( "SE1" ) + 'IMP' + cNum + cParcela + 'NF' + cCliente + cLoja, .F. ) )
//       cParcela := Soma1( cParcela )
		cLogtmp := ('Título já existe ' + CHR(13) + CHR(10))
        aAdd( aLogE, { cNum, cvaltochar(nValor), 'Erro na planilha origem : ' + cLogTmp } )
        nRegErro    ++
		FT_fSkip()
		Loop
    End

	aAdd( aRotAuto, { 'E1_FILIAL'	, '01'  			                , Nil } )
	aAdd( aRotAuto, { 'E1_PREFIXO'	, 'IMP' 			                , Nil } )
	aAdd( aRotAuto, { 'E1_NUM'		, cNum			                    , Nil } )
	aAdd( aRotAuto, { 'E1_PARCELA'	, cParcela   	                    , Nil } )
	aAdd( aRotAuto, { 'E1_TIPO'		, 'NF '		                     	, Nil } )
	aAdd( aRotAuto, { 'E1_NATUREZ'	, cNaturez                 			, Nil } )
	aAdd( aRotAuto, { 'E1_CLIENTE'	, cCliente			                , Nil } )
	aAdd( aRotAuto, { 'E1_LOJA'		, cLoja                 			, Nil } )
	aAdd( aRotAuto, { 'E1_EMISSAO'	, CToD( Alltrim(aLine[ 04 ] ))      , Nil } )
	aAdd( aRotAuto, { 'E1_VENCTO'	, CToD( Alltrim(aLine[ 05 ] ))      , Nil } )
	aAdd( aRotAuto, { 'E1_VENCTOORI', CToD( Alltrim(aLine[ 05 ] ))  	, Nil } )
	aAdd( aRotAuto, { 'E1_VALOR'	, nValor							, Nil } )
	aAdd( aRotAuto, { 'E1_HIST'		, ' '								, Nil } )
	aAdd( aRotAuto, { 'E1_PORTADO'	, cBanco      						, Nil } )
	aAdd( aRotAuto, { 'E1_NUMBCO'	, ' ' 								, Nil } )
	aAdd( aRotAuto, { 'E1_CREDIT'	, '31101001' 						, Nil } )
	aAdd( aRotAuto, { 'E1_CLVLCR'	, '0190' 							, Nil } )

    lMsErroAuto	:= .F.

	MSExecAuto( { |x,y| FINA040( x, y )}, aRotAuto, 3 )
		
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
cHtml += '<title>Importação Titulos a Receber</title>' + CRLF
cHtml += '</head>' + CRLF

cHtml += '<body bgcolor=white text=black >' + CRLF
cHtml += '<h2>Importação Titulos a Receber</h2>' + CRLF

If Len( aLog ) > 0

	cHtml += '<br>Os seguintes Títulos a Receber foram incluídos no sistema Protheus:</a><br>' + CRLF

	cHtml += '<br><table>' + CRLF
	cHtml += '<table border=2>' + CRLF
	cHtml += '<tr bgcolor="#99CCFF" >' + ;
					'<th> Titulo </th>' + ;
					'<th> Valor </th>' + ;
					'<th> Log </th></tr>' + CRLF
	
	For nI := 1 to Len( aLog )

		cHtml += '<tr><td>' + aLog[ nI, 1 ] + ;
				 '</td><td align="right" >' + aLog[ nI, 2 ] + ;
				 '</td><td>' + aLog[ nI, 3 ] + '</td> </tr>' + CRLF
		nTotal += Val(aLog[nI,2])
		nQtde  ++
	Next

	cHtml += '<tr><td>' + 'TOTAL ' + ;
			 '</td><td align="right" >' + Transform( nTotal, '@E 999,999,999.99' ) + ;
			 '</td><td>' + 'Importados = ' + Transform( nQtde, '@E 999,999' ) + '</td> </tr>' + CRLF
	
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
	Next

	cHtml += '<tr><td>' + 'TOTAL ' + ;
			 '</td><td align="right" >' + Transform( nTotal, '@E 999,999,999.99' ) + ;
			 '</td><td>' +'Erros = ' + Transform( nQtde, '@E 999,999' ) + '</td> </tr>' + CRLF
	
	cHtml += '</table>' + CRLF
EndIf

If nRegErro > 0
	
	cHtml += '<br>A integração teve ' + AllTrim( Str( nRegErro ) ) + ' erro' + If( nRegErro > 1, 's', '' ) + '.</a><br>' + CRLF
EndIf
cHtml += '<br> Processado em ' + DtoC( dDataBase ) + ' às ' + Time() + ' h por ' + AllTrim( cUserName ) + ' </a>' + CRLF
cHtml += '<br> </a>' + CRLF
cHtml += '</body></html>' + CRLF

MemoWrite( 'C:\TEMP\DUXIMPCR_' + DtoS( Date() ) + '_' + StrTran( Time(), ':', '' ) + '.html', cHtml )

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
