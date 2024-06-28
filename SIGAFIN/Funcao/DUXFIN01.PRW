#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define nE5DATA		1
#define nE5BANCO	2
#define nE5AGENCIA	3
#define nE5CONTA	4
#define nE5NATUREZ	5
#define nE5HISTOR	6
#define nE5VALOR	7
#define nE5CCD		8

/*/{Protheus.doc} DUXFIN01
	Importa CSV noo layout:
	Data;Banco ;Agencia;Conta Corrente;Natureza;Historico ;Valor ;Centro de Custo
	Inclui o conteúdo via rotina automática FINA100

	@type  Function
	@author Geeker
	@since 21/02/2023
/*/
user function DUXFIN01()
	local aAreaX	:= getArea()
	local aAreaSE5	:= SE5->( getArea() )
	local aMvPar	:= {}
	local nX		:= 0

	for nX := 1 to 60
		aadd( aMvPar, &( "MV_PAR" + strZero( nX, 2, 0 ) ) )
	next nX

	if getParam()
		fwMsgRun( , { || impArq() } , "Processando" , "Por favor, aguarde. Importando arquivo..." )
	endif

	for nX := 1 to len( aMvPar )
		&( "MV_PAR" + strZero( nX, 2, 0 ) ) := aMvPar[ nX ]
	next nX

	restArea( aAreaSE5 )
	restArea( aAreaX )
return

//---------------------------------------------------------------------------------------------
static function impArq()
	local nI				:= 0
	local cLinha			:= ""
	local aLinha			:= {}
	local lFirst			:= .T.
	local aSE5				:= {}
	local cLog				:= ""
	local aErro				:= {}
	local nTotLinha			:= 0
	local nLinhaAtua		:= 0
	local cDirLog			:= getTempPath()
	local cArqLog			:= "DUXFIN01" + fwTimeStamp() + ".log"

	private lMsHelpAuto		:= .T.
	private lMsErroAuto		:= .F.
	private lAutoErrNoFile	:= .T.

	FT_FUSE( MV_PAR01 )
	FT_FGOTOP()

	nTotLinha := FT_FLASTREC()

	FT_FGOTOP()

	while !FT_FEOF()
		nLinhaAtua++

		cLinha := ""
		cLinha := FT_FREADLN()
		if lFirst
			lFirst := .F.
		else
			aLinha := {}
			aLinha := strTokArr2( cLinha , ";" )

			if len( aLinha ) == 8
				/*
				E5_DATA    = COLUNA1
				E5_MOEDA   = M1
				E5_VALOR   = COLUNA7
				E5_NATUREZ = COLUNA5
				E5_BANCO   = COLUNA2
				E5_AGENCIA = COLUNA3
				E5_CONTA   = COLUNA4
				E5_HISTOR  = COLUNA6
				E5_CCD     = COLUNA8
				*/

				aSE5 := {}
				aadd( aSE5 , { "E5_DATA"	, cToD( aLinha[ nE5DATA ] ) 									, nil } )
				aadd( aSE5 , { "E5_VALOR"	, val( allTrim( strTran( aLinha[ nE5VALOR ] , "," , "." ) ) )	, nil } )
				aadd( aSE5 , { "E5_NATUREZ"	, allTrim( aLinha[ nE5NATUREZ ] )								, nil } )
				aadd( aSE5 , { "E5_BANCO"	, allTrim( aLinha[ nE5BANCO ] )									, nil } )
				aadd( aSE5 , { "E5_AGENCIA"	, allTrim( aLinha[ nE5AGENCIA ] )								, nil } )
				aadd( aSE5 , { "E5_CONTA"	, allTrim( aLinha[ nE5CONTA ] )									, nil } )
				aadd( aSE5 , { "E5_MOEDA"	, "M1" 															, nil } )
				aadd( aSE5 , { "E5_HISTOR"	, allTrim( aLinha[ nE5HISTOR ] ) 								, nil } )
				aadd( aSE5 , { "E5_CCD"		, allTrim( aLinha[ nE5CCD ] ) 									, nil } )
				aadd( aSE5 , { "E5_ITEMD"	, xFilial( "SE5" ) 												, nil } )
				aadd( aSE5 , { "E5_ITEMC"	, xFilial( "SE5" ) 												, nil } )

				aSE5 := fwVetByDic( aSE5 /*aVetor*/ , "SE5" /*cTable*/ , .F. /*lItens*/ )

				lMsHelpAuto		:= .T.
				lMsErroAuto		:= .F.
				lAutoErrNoFile	:= .T.

				BEGIN TRANSACTION
					msExecAuto( { | x , y , z | fina100( x , y , z ) } , 0 , aSE5 , 3 )

					if lMsErroAuto
						DISARMTRANSACTION()

						aErro := {}
						aErro := getAutoGRLog() // Retorna erro em array

						cLog += "Linha " + allTrim( str ( nLinhaAtua ) ) + " do arquivo não foi importada. Erro gerado: " + CRLF + CRLF

						for nI := 1 to len(aErro)
							cLog += aErro[ nI ] + CRLF
						next nI

						cLog += "-------------------------------------------------------------------------" + CRLF

						cLog += CRLF
					endif
				END TRANSACTION
			endif
		endif

		FT_FSKIP()
	enddo

	//Se tiver log, mostra ele
	if !empty( cLog )
		memoWrite( cDirLog + cArqLog , cLog )
		shellExecute( "OPEN" , cArqLog , "" , cDirLog , 1 )
	else
		msgInfo( "Arquivo importado com sucesso!" , "Sucesso" )
	endif

	FT_FUSE()
return

//---------------------------------------------------------------------------------------------
static function getParam()
	local aRet			:= {}
	local aParambox		:= {}

	aadd( aParambox , { 6 , "Arquivo CSV" , space(100) , "@!"	, ""	, ""	, 070, .T., "Arquivos .CSV |*.CSV" , GetTempPath() , GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE } )

return paramBox(aParambox, "Importa CSV"	, @aRet, , , .T. /*lCentered*/ , 0 , 0 , , "DUXFIN01" /*cLoad*/ , .T. /*lCanSave*/ , .T. /*lUserSave*/ )
