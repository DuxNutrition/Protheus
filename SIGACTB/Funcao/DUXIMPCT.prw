#include 'totvs.ch'
#include 'tbiconn.ch'
/*/{Protheus.doc} DUXIMPCT
	
	Importação de Movimentos da Contabilidade
	
	@type  Function
	@author Marlovani
	@since 25/03/2023
	@version P12
/*/
User Function DUXIMPCT()

Local nOpcA		:= 0
Local cPerg		:= 'DUXIMPCT'

Private cCadastro	:= 'Importação Lançamentos Contábeis'
Private nMov		:= 0
Private nLidos   	:= 0
Private nRegImp		:= 0
Private nRegErro	:= 0 

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01		, cDef02			, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Arquivo a ser importado:", "mv_par01", "mv_ch1"	, "C"		, 99						, 0			, "F"		,               	, 			, 			, 			,					,			,			,			,		, 			)
//u_PutSX1( cPerg	, "02"	, "Arquivo DE/PARA Contas :", "mv_par02", "mv_ch2"	, "C"		, 99						, 0			, "F"		,               	, 			, 			, 			,					,			,			,			,		, 			)
//u_PutSX1( cPerg	, "03"	, "Arquivo DE/PARA C.Custo:", "mv_par03", "mv_ch3"	, "C"		, 99						, 0			, "F"		,               	, 			, 			, 			,					,			,			,			,		, 			)

FormBatch( cCadastro, ;
            {'Este programa vai importar o arquivo com lançamentos contábeis'}, ;
            {{ 5, .T., {|o| Pergunte( cPerg, .T. ) }}, ;
            { 1, .T., {|o| nOpcA:=1, If( gpconfOK(), FechaBatch(), nOpcA:=0 ) } }, ;
            { 2, .T., {|o| FechaBatch() }}} )

If nOpcA == 1 
	
	FWMsgRun(, {|oSay| U_IMPCTRun( MV_PAR01, MV_PAR02, MV_PAR03, oSay ) }, cCadastro, 'Importando Movimentos ...' )
	
	Aviso(  cCadastro, ;
			'Movimentos planilha      : ' + Transform( nLidos , '@E 999,999' ) + Chr( 10 ) + ;
			'Movimentos nos Lotes     : ' + Transform( nMov   , '@E 999,999' ) + Chr( 10 ) + ;
			'Lotes contabilizados     : ' + Transform( nRegImp, '@E 999,999' ) + Chr( 10 ) + ;
			'Lotes c/Erros            : ' + Transform( nRegErro,'@E 999,999' ), { 'Ok' } )
EndIf

Return


/*/{Protheus.doc} IMPCTRun----------------------------------------------------------
	
	Importação de Movimentos da Contabilidade - Processamento
	
/----------------------------------------------------------------------------------*/

User Function IMPCTRun( cPathOrig, cContas, cCCustos, oSay )

Local nHdl
Local aLine   := {}
Local aLogE   := {}
Local aLogTmp, cLogTmp
Local aCab 	  := {}
Local lOk
Local lNovoArq:= .T.

Local dDataMov := ""
Local dDataAnt := CTOD("01/01/1900")
Local cContaD  := ""
Local cContaC  := ""
Local cDC	   := ""
Local cCLVLDB  := ""
Local cCLVLCR  := ""
Local cItemD   := ""
Local cItemC   := ""
Local cCCustoD := ""
Local cCCustoC := ""

Private lMsHelpAuto 	:= .T.	// Habilita a captura das mensagens de erro
Private lAutoErrNoFile	:= .T.  //.F.	// Desabilita a geração do arquivo de log padrão do sistema
Private lMsErroAuto 	:= .F.	// Indica de se houve erro não fatal durante a execução

//----------------------------------------- Le arquivo de movimentos
nHdl	:= FT_fUse( cPathOrig )
If nHdl == -1
    msgstop('Falha na abertura do arquivo '+cPathOrig)
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
	
    dDataMov := CTOD(AllTrim( aLine[02] ) )

	If dDataMov <> dDataAnt
	
		If  !lNovoArq
			// Grava Movimento Contabil da Filial em um Lote Contabil
			lMsErroAuto		:= .F.

			MSExecAuto( {|x,y,z| CTBA102(x,y,z)}, aCab, aItens, 3 )
							
			If lMsErroAuto
					//MostraErro()			
					aLogTmp := GetAutoGRLog()
					cLogTmp := ''
					aEval( aLogTmp, { |x| cLogTmp += x + chr(10) } )
					aAdd( aLogE, {"" ,"" , 'Erro na rotina automática: ' + cLogTmp } )
					nRegErro    ++
					lOk     := .F.
			Else
					nRegImp     ++
			EndIf
		ENDIF

		aCab	:= {{ 'DDATALANC'	, dDataMov      				, NIL },;
					{ 'CLOTE'		, 'IMPORT'                      , NIL },;  
					{ 'CSUBLOTE'	, '001'							, NIL },;
					{ 'CPADRAO'		, ''							, NIL },;
					{ 'NTOTINF'		, 0								, NIL },;
					{ 'NTOTINFLOT'	, 0								, NIL }}
						
		aItens		:= {}
		cLinha		:= '000'

		dDataAnt := dDataMov
		lNovoArq := .F.

	EndIf

	If  aLine[03] == '1' 

		cContaD	:= Padr(Alltrim(aLine[04]),Len(CT2->CT2_DEBITO) )
		cContaC	:= ''
		cDC		:= Alltrim(aLine[03])
		cCCustoD:= Padr(Alltrim(aLine[08]),Len(CT2->CT2_CCD) )
		cCCustoC:= ''
		cHist   := Padr(Alltrim(aLine[07]),Len(CT2->CT2_HIST) )
		nValor  := Val(StrTran(StrTran( aLine[ 06 ] ,".",""),",","."))
		cCLVLDB := Padr(Alltrim(aLine[12]),Len(CT2->CT2_CLVLDB) )
		cCLVLCR := ' '
		cItemD  := Padr(Alltrim(aLine[10]),Len(CT2->CT2_ITEMD) )
		cItemC  := ' '
	Else 
		cContaC	:= Padr(Alltrim(aLine[05]),Len(CT2->CT2_CREDIT) )
		cContaD	:= ''
		cDC		:= Alltrim(aLine[03])
		cCCustoC:= Padr(Alltrim(aLine[09]),Len(CT2->CT2_CCC) )
		cCCustoD:= ''
		cHist   := Padr(Alltrim(aLine[07]),Len(CT2->CT2_HIST) )
		nValor  := Val(StrTran(StrTran( aLine[ 06 ] ,".",""),",","."))
		cCLVLCR := Padr(Alltrim(aLine[13]),Len(CT2->CT2_CLVLCR) )
		cCLVLDB := ' '
		cItemC  := Padr(Alltrim(aLine[11]),Len(CT2->CT2_ITEMC) )
		cItemD  := ' '
	EndIf

	aAdd( aItens, { { 'CT2_LINHA'	, cLinha := Soma1( cLinha )		, NIL },;
					{ 'CT2_DC'		, cDC							, NIL },;
					{ 'CT2_DEBITO'	, cContaD						, NIL },;
					{ 'CT2_CREDIT'	, cContaC						, NIL },;
					{ 'CT2_CCD'		, cCCustoD						, NIL },;
					{ 'CT2_CCC'		, cCCustoC						, NIL },;
					{ 'CT2_ITEMD'	, cItemD						, NIL },;
					{ 'CT2_ITEMC'	, cItemC						, NIL },;
					{ 'CT2_CLVLDB'	, cCLVLDB						, NIL },;
					{ 'CT2_CLVLCR'	, cCLVLCR						, NIL },;
					{ 'CT2_VALOR'	, nValor						, NIL },;
					{ 'CT2_HIST'	, cHist							, NIL },;
					{ 'CT2_ORIGEM'	, 'IMPORTACAO INICIAL' 	, NIL } } )
		
    FT_fSkip()

	nMov ++

End

// Grava Ultimo Lote Contabil
lMsErroAuto		:= .F.

MSExecAuto( {|x,y,z| CTBA102(x,y,z)}, aCab, aItens, 3 )
							
If lMsErroAuto
	//MostraErro()			
	aLogTmp := GetAutoGRLog()
	cLogTmp := ''
	aEval( aLogTmp, { |x| cLogTmp += x + chr(10) } )
	aAdd( aLogE, {"" ,"" , 'Erro na rotina automática: ' + cLogTmp } )
	nRegErro    ++
	lOk     := .F.
Else
	nRegImp     ++
EndIf

FT_fUse()
			
If ( nRegImp + nRegErro ) > 0
	
	IMPCTLog(aLogE )
EndIf

Return

//----------------------------------------- Gera Log
Static Function IMPCTLog(aLogE )

Local cHtml
Local nI
Local nTotal := 0
Local nQtde  := 0

cHtml := '<html>'	+ CRLF

cHtml += '<head>'	+ CRLF
cHtml += '<title>Importação Contabilidade</title>' + CRLF
cHtml += '</head>' + CRLF

cHtml += '<body bgcolor=white text=black >' + CRLF
cHtml += '<h2>Importação Contabilidade</h2>' + CRLF

nQtde  := 0
nTotal := 0
If Len( aLogE) > 0

	cHtml += '<br>Os seguintes erros foram gerados:</a><br>' + CRLF

	cHtml += '<br><table>' + CRLF
	cHtml += '<table border=2>' + CRLF
	cHtml += '<tr bgcolor="#99CCFF" >' + ;
					'<th> Linha </th>' + ;
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

MemoWrite( 'C:\TEMP\DUXIMPCT_' + DtoS( Date() ) + '_' + StrTran( Time(), ':', '' ) + '.html', cHtml )

Return

//---------------------------------------------------------------separa arquivo CSV
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
