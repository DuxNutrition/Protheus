#include 'rwmake.ch'
#Define CRLF Chr(10) + Chr(13)
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Descrição: Altera vendedor no Cadastro de Clientes             ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function DUXALTVE()

Local aParamBox := {}
Local aRet      := {}
Local cArq01    := SPACE(200)

Private cCadastro	:= 'Alteração do vendedor em Clientes'
Private cArqTxt1

/*----------- ordem dos campos do arquivo a ser importado
cnpj  14
CodigoVendedor  5
--------------------------------------------------------*/

aAdd(aParamBox,{6,"Arquivo Vendedores(CSV) " , cArq01      ,"","","",50,.F.,"Todos os arquivos (.csv) |*.csv*"})

if  ParamBox( aParamBox, "Importando informações ", @aRet,,,,,,,,.f.,.f. )
        oRegua := MsNewProcess():New({|| ProcIMP(aRet) },"Processando","",.T.)
        oRegua:Activate()
    endif

RETURN

Static Function ProcImp(aParam)
	
	Local cArqTxt1 := AllTrim(aParam[1])
	
	If !Empty( cArqTxt1 ) .and. !File( cArqTxt1 )
		
		MsgStop( 'O arquivo a ser importado nao foi localizado!', cCadastro )
		Return
	EndIf
	
	If !Empty( cArqTxt1 )
		
		Processa( {|| AlteraVend(cArqTxt1) }, cCadastro, 'Importando Produtos...' )
	EndIf

Return

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Descrição: Importa Informações                                          ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function AlteraVend(cArqTxt1)

Local nHdl
Local cLine, aLine

Local nRegImp	:= 0
Local nErros	:= 0

Private cLog		:= ""
Private lMsHelpAuto	:= .t.
Private lMsErroAuto := .f.

// Abre o arquivo
nHdl	:= FT_fUse( cArqTxt1 )

If nHdl == -1
	
	If !IsBlind()
		
		MsgStop( 'O arquivo de nome ' + AllTrim( cArqTxt1 ) + ' não pode ser aberto! Verifique os parâmetros.', cCadastro )
	EndIf
	
	Return
EndIf

// Posiciona na primeira linha

ProcRegua( FT_fLastRec() )	// Retorna o número de linhas do arquivo

FT_fGoTop()
FT_fSkip()

While !FT_fEOF() 
	
	IncProc()
	
	cLine  := FT_fReadLn() // Retorna a linha corrente

	// carrega linha do arquivo em um array
	aLine	:= CI_ListAsArray( cLine, ';' )
	
	If Len( aLine ) < 2
		
		Exit
	EndIf

	DbSetOrder(1)
			
	cCGC    	:= PadR( aLine[ 1 ], 14 )
	cVend   	:= PadR( aLine[ 2 ], 6 )
	dbselectArea("SA3")
	DbSetOrder(1)
    If !SA3->( dbseek(xFilial("SA3") + cVend , .f.)) 
		msgstop("Vendedor Não cadastrado "+cVend)
		nErros ++
		FT_fSkip()
		Loop
	ENDIF

	lImp		:= .t.

    // Testa se existe o produto e altera

	dbselectArea("SA1")
	DbSetOrder(3)
    If SA1->( dbseek(xFilial("SA1") + cCGC , .f.)) 
        While !EOF() .and. SA1->A1_CGC == cCGC 
			If SA1->(!RecLock( 'SA1', .f. ) )
				Help("  ",1,"REGNLOCK")
			Else
				// campos a serem alterados 
				SA1->A1_VEND	:= cVend
				SA1->( MsUnlock() )
				nRegImp ++
			Endif
			SA1->(dbSkip())
		End
    Else
		//cLog += aLine[1] + Space( 1 ) + aLine[2] + Space( 2 ) + aLine[2] + Space( 2 ) + 'Não existe o cliente' + CHR(13) + CHR(10)
		msgstop("Cliente Não cadastrado "+cCGC)
		nErros ++
		FT_fSkip()
		Loop
	ENDIF

	// Pula para próxima linha

	FT_fSkip()
	
End

// Fecha o Arquivo
FT_fUse()

ApMsgInfo('Clientes Alterados : ' + Transform( nRegImp, '@E 9999,999' )+' Erros: ' + Transform( nErros, '@E 9999,999' ),cCadastro)

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
