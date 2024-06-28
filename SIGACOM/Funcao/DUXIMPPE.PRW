#include 'rwmake.ch'
#Define CRLF Chr(10) + Chr(13)
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Descri��o: Carga de informa�oes para o Cadastro de Pessoas              ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function DUXIMPPE()

Local aParamBox := {}
Local aRet      := {}
Local cArq01    := SPACE(200)

Private cCadastro	:= 'Importa��o do Cadastro de Pessoas'
Private cArqTxt1

aAdd(aParamBox,{6,"Arquivo de Pessoas  " , cArq01      ,"","","",50,.F.,"Todos os arquivos (.csv) |*.csv*"})

if  ParamBox( aParamBox, "Importando cadastro de Pessoas ", @aRet,,,,,,,,.f.,.f. )
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
		
		Processa( {|| DUXIMP(cArqTxt1) }, cCadastro, 'Importando Cad Pessoas ...' )
	EndIf

Return

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Descri��o: Importa Registros                                            ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
Static Function DUXIMP(cArqTxt1)

Local nHdl
Local cLine, aLine
Local cFornece := ""
Local cLoja    := ""
Local cCIC    := ""
//Local cCCNet   := ""
Local cCCPro   := ""
Local nRegImp	:= 0
Local nErros	:= 0
//Local nx
Local aAllusers := FWSFALLUSERS()   //busca usuarios e coloca no Array
Local cCodUsu   := ""

Private cLog		:= ""
Private lMsHelpAuto	:= .t.
Private lMsErroAuto := .f.

cLog += 'Codigo                                       Ocorrencia                Nome        '  + CHR(13) + CHR(10)
cLog +=  Replicate( '-', 110 )  + CHR(13) + CHR(10)

// Abre o arquivo
nHdl	:= FT_fUse( cArqTxt1 )

If nHdl == -1
	
	If !IsBlind()
		
		MsgStop( 'O arquivo de nome ' + AllTrim( cArqTxt1 ) + ' nao pode ser aberto! Verifique os parametros.', cCadastro )
	EndIf
	
	Return
EndIf

ProcRegua( FT_fLastRec() )	// Retorna o número de linhas do arquivo

// Posiciona na primeira linha
FT_fGoTop()
FT_fSkip()      // cabe�alho

While !FT_fEOF() 
	
	IncProc()
	
	cLine  := FT_fReadLn() // Retorna a linha corrente

	// carrega linha do arquivo em um array
	aLine	:= CI_ListAsArray( cLine, ';' )
	
	If Len( aLine ) < 2
		
		Exit
	EndIf

	DbSetOrder(1)
			
	lImp		:= .t.

/*---------------------------------------------------- layout do arquivo csv
Ordem	Campo	Descri��o	      Tamanho	Classifica��o
001	RD0_FILIAL	Filial	                2	Obrigatorio
002	RD0_CODIGO	Codigo do Participante  6    Obrigatorio
003	RD0_NOME	Nome Participante	   30	Obrigatorio
004	RD0_TIPO	Tipo	                1	Obrigatorio
005	RD0_DTNASC	Data de Nascimento	    8	Obrigatorio
006	RD0_CIC	    Codigo CPF          	11	Opcional
007	RD0_CC	    Codigo Centro de Custo	9	Opcional
008	RD0_EMAIL	Email Usuario       	x   Obrigatorio
009	RD0_PERMAD	Permite Adiantamento    1	Obrigatorio
010	RD0_APROPC	Aprovador	            6	Obrigatorio
011	RD0_APSUBS	Substituto	            6	Opcional
012	RD0_USRPRE	Subst. Prest. Cta.	    6	Opcional
013	RD0_EMPATU	Empresa de atuação	    2	Obrigatorio
014	RD0_FILATU	Filial de atuação	    2	Obrigatorio
*/

	//--------------------------------------- busca codigo fornecedor e loja
	cCIC := PadR( aLine[ 06 ], 11 )
	
 	dbselectArea("SA2")
	DbSetOrder(3)
    If SA2->( dbseek(xFilial("SA2") + cCIC, .f.)) 

		cFornece := A2_COD
		cLoja    := A2_LOJA
    Else
		cLog += Padr(aLine[06],45) + Space( 2 ) +' CPF/CNPJ N�o encontrado ' + aLine[03] +CHR(13) + CHR(10)
		nErros ++
		FT_fSkip()
		Loop
	ENDIF

	//--------------------------------------- busca codigo usuario
	cEmailUsu := Alltrim(aLine[ 08 ])
	
	nPos      := aScan( aAllusers, { |x| x[ 5 ] == cEmailUsu } )
	If nPos > 1
		cCodUsu   := aAllusers[ nPos, 2 ]
	else
		cLog += Padr(aLine[08],45) + Space( 2 ) +' Email N�o encontrado    ' + aLine[03] + CHR(13) + CHR(10)
		nErros ++
		FT_fSkip()
		Loop
	ENDIF

/*
[n][1] Id da tabela de usu�rios (r_e_c_n_o_)
[n][2] Id do usu�rio
[n][3] Login do Usu�rio
[n][4] Nome do usu�rio
[n][5] email do usu�rio
[n][6] departamento do usu�rio
[n][7] cargo do usu�rio
*/
	//--------------------------------------- busca centro de custo
	cCCPro := PadR( aLine[ 07 ], 9 )
	
   // Testa se existe o registro

	dbselectArea("RD0")
	DbSetOrder(1)
	If !RD0->(dbSeek(xFilial("RD0")+PadR( aLine[ 2 ], 6 )))

		Reclock("RD0",.T.)
			RD0->RD0_FILIAL	:= xFilial("RDO")
			RD0->RD0_CODIGO	:= PadR( aLine[ 2 ], 6 )
			RD0->RD0_NOME 	:= PadR( aLine[ 3 ],30 )
			RD0->RD0_TIPO	:= PadR( aLine[ 4 ], 1 )
			RD0->RD0_DTNASC := CTOD( aLine[ 5 ] )
			RD0->RD0_CC	    := cCCPro
			RD0->RD0_USER	:= cCodUsu
			RD0->RD0_EMAIL	:= cEmailUsu
			RD0->RD0_CIC 	:= cCIC
	 		RD0->RD0_PERMAD	:= PadR( aLine[ 9 ], 1 )
			RD0->RD0_APROPC	:= PadR( aLine[ 10 ], 6 )
			RD0->RD0_APSUBS	:= PadR( aLine[ 11], 6 )
			RD0->RD0_USRPRE	:= PadR( aLine[ 12], 6 )
			RD0->RD0_FORNEC	:= cFornece
			RD0->RD0_LOJA	:= cLoja
			RD0->RD0_EMPATU	:= PadR( aLine[ 13], 2 )
			RD0->RD0_FILATU	:= PadR( aLine[ 14], 2 )
			RD0->RD0_MSBLQL	:= "2"
				
		RD0->(MsUnlock())
		nRegImp ++

    Else
		cLog += aLine[2] + Space( 2 ) + aLine[3] + Space( 2 ) + 'Pessoa j� existe' + CHR(13) + CHR(10)
		nErros ++
		FT_fSkip()
		Loop
	ENDIF

	// Pula para proxima linha

	FT_fSkip()
	
End

// Fecha o Arquivo
FT_fUse()

ApMsgInfo('Pessoas importadas : ' + Transform( nRegImp, '@E 9999,999' )+' Erros: ' + Transform( nErros, '@E 9999,999' ),cCadastro)

Memowrite("C:\TEMP\Log_ImpPessoas.txt", cLog)

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
