#include 'rwmake.ch'
#Define CRLF Chr(10) + Chr(13)
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Descrição: Altera Campos no Cadastro de Produtos                        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function DUXIMPPR()

Local aParamBox := {}
Local aRet      := {}
Local cArq01    := SPACE(200)

Private cCadastro	:= 'Alteração do Cadastro de Produtos'
Private cArqTxt1

/*----------- ordem dos campos do arquivo a ser importado
•	B1_COD      15 C
•	B1_PESO     11 N
•	B1_PESBRU   11 N 
•	B5_ALTURA   09 N
•	B5_ECCOMP   10 N
•	B5_ECLARGU  10 N
•	B5_ECPESOE  10 N
--------------------------------------------------------*/

aAdd(aParamBox,{6,"Arquivo c/Campos Produtos(CSV) " , cArq01      ,"","","",70,.F.,"Todos os arquivos (.csv) |*.csv*"})

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
		
		Processa( {|| AlteraProd(cArqTxt1) }, cCadastro, 'Importando Produtos...' )
	EndIf

Return

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Descrição: Importa Informações                                          ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function AlteraProd(cArqTxt1)

Local nHdl
Local cLine, aLine

Local nRegImp	:= 0
Local nErros	:= 0
Local cCodigo
Local nPeso,nPesBru,nAltura,nEcComp,nEcLargu,nEcPesoE
Local lOk

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

	cCodigo  := PadR( aLine[ 1 ], 15 )
	nPeso    := StrTran(aLine[ 2 ],',','.')
	nPesBru  := StrTran(aLine[ 3 ],',','.')
	nEcPesoE := StrTran(aLine[ 4 ],',','.')
	nAltura  := StrTran(aLine[ 5 ],',','.')
	nEcLargu := StrTran(aLine[ 6 ],',','.')
	nEcComp  := StrTran(aLine[ 7 ],',','.')
	
	lOk		:= .F.

    // Testa se existe o produto e altera

	dbselectArea("SB1")
	DbSetOrder(1)
    If SB1->( dbseek(xFilial("SB1") + cCodigo , .f.)) 

		If SB1->(!RecLock( 'SB1', .f. ) )
				Help("  ",1,"REGNLOCK")
		Else
			// campos a serem alterados 
			SB1->B1_PESO	:= Val(nPeso)
			SB1->B1_PESBRU	:= Val(nPesBru)
			SB1->( MsUnlock() )
			nRegImp ++
		Endif
		lOK := .T.
    Else
		//cLog += aLine[1] + Space( 1 ) + aLine[2] + Space( 2 ) + aLine[2] + Space( 2 ) + 'Não existe o cliente' + CHR(13) + CHR(10)
		msgstop("Produto Não cadastrado "+cCodigo)
		nErros ++
		FT_fSkip()
		Loop
	ENDIF

	If  lOk
//msgstop("passo 01")
		dbselectArea("SB5")
		DbSetOrder(1)
		If SB5->( dbseek(xFilial("SB5") + cCodigo , .f.)) 

			If SB5->(!RecLock( 'SB5', .f. ) )
					Help("  ",1,"REGNLOCK")
			Else
				// campos a serem alterados 
				SB5->B5_ALTURA	:= Val(nAltura)
				SB5->B5_ECCOMP	:= Val(nEcComp)
				SB5->B5_ECLARGU	:= Val(nEcLargu)
				SB5->B5_ECPESOE	:= Val(nEcPesoE)
				SB5->( MsUnlock() )
				//nRegImp ++
			Endif

		Else
//msgstop("passo 02")
            If  SB5->(RecLock("SB5",.T.))
//msgstop("passo 03")

                //AvReplace("SB1","SB5")
                SB5->B5_FILIAL  := xFilial("SB5")
                SB5->B5_COD     := SB1->B1_COD
				SB5->B5_CEME	:= SB1->B1_DESC
				SB5->B5_ALTURA	:= Val(nAltura)
				SB5->B5_ECCOMP	:= Val(nEcComp)
				SB5->B5_ECLARGU	:= Val(nEcLargu)
				SB5->B5_ECPESOE	:= Val(nEcPesoE)
				SB5->( MsUnlock() )

            EndIf             

			//cLog += aLine[1] + Space( 1 ) + aLine[2] + Space( 2 ) + aLine[2] + Space( 2 ) + 'Não existe o cliente' + CHR(13) + CHR(10)
			//msgstop("Produto Complementar Não cadastrado "+cCodigo)
			//nErros ++
			//FT_fSkip()
			//Loop
		ENDIF
	Endif
	// Pula para próxima linha

	FT_fSkip()
	
End

// Fecha o Arquivo
FT_fUse()

ApMsgInfo('Produtos Alterados : ' + Transform( nRegImp, '@E 9999,999' )+' Erros: ' + Transform( nErros, '@E 9999,999' ),cCadastro)

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
