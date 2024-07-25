//Bibliotecas
#INCLUDE 	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"PROTHEUS.CH"
#INCLUDE 	"TBICONN.CH"
#INCLUDE 	"PARMTYPE.CH"

#Define STRPARAME  OemToAnsi("Parâmetros de processamento")
#Define STRMSGDIR  OemToAnsi("Deseja utilizar diretorio padrão?")
#Define STRPROCESS OemToAnsi("Processando Arquivo ")
#Define STRTITULO  OemToAnsi("Importação de Pedido de Vendas - Ploomes")

/*/{Protheus.doc} DXIMPPED
Função para importar pedidos de vendas gerados pelo CRM Ploomes via txt
@author Abel Ribeiro
@since 22/02/2024
@version 1.0
@type function
/*/

User Function DXIMPPED()

	Local aArea     := GetArea()
	Local aBotoes	:= {}

	Local aSays	    := {}
	Local lOk		:= .T.
	Local nOpc	    := 0
	Local lEnd      := .F.
	Local cFunction	:= "ADPVZTQ"
	Local cGlbName 	:= ""

	Private cArqOri  := ""
	Private cCadastro:= STRTITULO
	Private oProcess := Nil
	Private cPasta   := ""
	Private	lSchedule:= .F.
	Private cDirIni  := ""
	Private cDirProc := ""
	Private cTIPARQ  := ".TXT"
	Private _lManual := .f.



	lSchedule        := FWGetRunSchedule()

    cGlbName 	:= "VTX_"+cFunction+cFilAnt

	If !LockByName(cGlbName,.F.,.F.,.T.)
		IF lSchedule
			MsgAlert("Rotina "+cGlbName+"está sendo executada por outro usuário.")
		Else
			ConOut("Rotina "+cGlbName+"está sendo executada por outro usuário.")
		EndIF
		Return
	EndIf

	ValidPerg()


    /*########################
    ## Monta tela principal ##
    #######################*/

	cObs := "Essa rotina tem a finalidade de importar todos os arquivos TXT, gerados pelo CRM Ploomes"
    IF !lSchedule
               
        aAdd( aSays,OemToAnsi(" Este programa ira processar efetuar a importação do "))
	    aAdd( aSays,OemToAnsi(" arquivo txt de vendas gerados pelo Ploomes. "))
	    aAdd( aBotoes, { 1, .T., { || Iif(lOk,(nOpc := 1,FechaBatch()),) } } )
	    aAdd( aBotoes, { 2, .T., { || nOpc:= 2, FechaBatch() } } )
	    aAdd( aBotoes, { 5, .T., { || cPasta := cGetFile('Arquivo *|*.txt','Selecione uma pasta para salvar o arquivo',0,'C:\',.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)} } )

        FormBatch( cCadastro, aSays, aBotoes, , 200,350 )
		
	    If nOpc == 1 
            IF !EMPTY(cPASTA)
			   oProcess := MsNewProcess():New( {|lEnd| Importa(cPasta,@lEnd, Directory(cPasta +  "*.TXT","D",,,1),.T.) } , STRPROCESS,  STRTITULO , .T. )
			   oProcess:Activate()
            Else
               FWALERTINFO("Nenhuma pasta foi Selecionada. Selecione uma pasta para continuar. ","INFO")
               Return
            Endif   
		Endif
	Else
        cDirIni  := SupergetMV("AD_DIRPED",,"\Arquivos b2b\")
        cDirProc := SupergetMV("AD_DIRPRC",,"\Arquivos b2b\processados\")

		Importa(cDirIni, @lEnd, Directory(cDirIni +  "*.TXT","D",,,1), _lManual)
	EndIF


	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

    UnLockByName(cGlbName,.F.,.F.,.T.)

   
    RestArea(aArea)
Return

/*--------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--- Funcao   - Importa        - Autor -Abel Ribeiro         - Data - 14/05/2018 ---
---------------------------------------------------------------------------------------------
---Descricao - Efetua a leitura de arquivos XML.													---
---          -              																		---
---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------*/
Static Function Importa(cDir , lEnd, aArquivos, _lManual)
Local nI		:= 0
Local nTotal	:= Len(aArquivos)
Local aArea      := GETAREA()

Private cCliente := ""
Private cLoja    := ""

Private nLinhaAtu:= 0    
PRivate cCondPAg := ""
PRivate cTransp := ""
PRivate cVend   := ""
PRivate cTpFrete:= ""
Private cTPPED  := ""
Private cNaturez:= ""
Private nQTDE   := 0
PRivate nPreUnit:= 0
Private nPesoBrut:= 0
Private nPesoLiq := 0
Private nVolumes := 0
PRivate cMensNota:= ""
Private nItem    := 0
Private nValtot  := 0 
PRivate nQTDLIB  := 0
Private nTPoper  := ""
Private cProduto := ""
Private cItemCC  := "PLOOMES"
Private cPEDLV   := ""
Private cARMZ    := ""
Private cTESPAD  := SUPERGETMV("AD_TESPAD",,"501")   //Tes padrão utlizada na Importação de Pedidos Ploomes
Private lRet     := .T.
Default aArquivos:=""

	//Define tamanho da Regua1 de Processamento - Apenas Rotina manual
    
    IF !lSchedule
		oProcess:SetRegua1(Len(aArquivos))
	EndIF

	//Verifica se Existem arquivos no diretorio
	If nTotal == 0
		Return Nil
	Endif
	//Efetua a leitura de TODOS arquivos do diretorio
    
	For nI := 1 To Len(aArquivos)
            cArqOri := aArquivos[nI,1]
            //Limpa Arrays

            nValtot:= 0

            //Incrementa Regua de Processamento - Apenas Rotina manual
            IF !lSchedule
               oProcess:IncRegua1(STRPROCESS + CValtoChar(nI) + "/" + CValtoChar(nTotal))
            Endif

            IF !lSchedule
				oProcess:SetRegua2(2)
				oProcess:IncRegua2("Processando " + cValToChar(nI) + " de " + cValToChar(Len(aArquivos)))
            ENDIF
        
            //Definindo o arquivo a ser lido

            oArquivo := FWFileReader():New(cDir + cArqOri)
            
            //Se o arquivo pode ser aberto
            If (oArquivo:Open())

                //Se não for fim do arquivo
                If ! (oArquivo:EoF())
        
                    //Definindo o tamanho da régua
                    aLinhas := oArquivo:GetAllLines()
                    nTotLinhas := Len(aLinhas)
                    ProcRegua(nTotLinhas)
                    
                    //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
                    oArquivo:Close()
                    oArquivo := FWFileReader():New(cDir + cArqOri)
                    oArquivo:Open()
        
                //Enquanto tiver linhas
                            
                    While (oArquivo:HasLine())

                        //Incrementa na tela a mensagem
                        nLinhaAtu++
                         IF !lSchedule
                            IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                         Else
                            FWLogMsg("INFO", , "Processando Arquivo " + cDir + cArqOri, AllTrim(FunName()), "", "01", FWTIMESTAMP(2), 0, 0, {})
                         ENDIF

                        //Pegando a linha atual e transformando em array
                        cLinAtu := oArquivo:GetLine()

                        //Tratamento para Colocar spaços nas colunas que nao tem dado
                        cLinAtu := STRTRAN(cLinAtu,";;;","; ; ;")
                        cLinAtu := STRTRAN(cLinAtu,";;","; ;")
                        
                        aLinha  := StrTokArr(cLinAtu, ";")
                    
                        //Se for o cabeçalho (encontrar o texto "Código" na linha atual)
                        DbSelectArea('SA1')
                                            
                        If "SC5" $ cLinAtu

                            cTPPED   := aLinha[02]
                            cCliente := aLinha[03]  + SPACE(09-LEN(RTRIM(aLinha[03]) ))
                            cLoja    := aLinha[04]
                            cTransp  := aLinha[05]
                            cNaturez := aLinha[06]
                            cCondPAg := aLinha[07] 
                            cTabPRC  := aLinha[08]
                            cVend    := aLINHA[09]
                            cTpFrete := aLinha[10]
                            cMensNota:= aLinha[11] 
                            cPedLV   := aLinha[12]
                            
                            lRet := GrvZTQ("LISTA",cDir + cArqOri,cPEDLV)
                            
                        ELSEIF "SC6" $ cLinAtu
                             
                                cItem    := aLinha[02]
                                cProduto := aLinha[03] + SPACE(15-LEN(RTRIM(aLinha[03]) ))
                                nQtde    := VAL(aLINHA[04])
                                nPreUnit := IF( Val( aLinha[05]) <> 0, Val(strtran(aLinha[05],",",".")), 0.00 ) 
                                nTpOper  := VAL(aLINHA[06])
                                nQTDlib  := aLinha[08]
                                cARMZ    := aLinha[09]

                                nValtot  += (nPreUnit * nQtde)
                                GrvZTS(cPEDLV,cItem,cPRODUTO,nPreUNIT,nQtde,nTpOper)

                        EndIf
                    EndDo

                    /*Regrava Valor do Total do Pedido*/
                    IF lRet
                       ZTQ->(dbSelectArea("ZTQ"))
                       ZTQ->(dbSetOrder(2))
                        IF ZTQ->(dbSeek(xFilial("ZTQ")+cPEDLV)) 
                          ZTQ->(RecLock("ZTQ",.F.))
                          ZTQ->ZTQ_VALOR := nValtot
                          ZTQ->ZTQ_INTZTS:= "1"
                          ZTQ->(MSUnlock())
                        Endif

                       
                    Endif    
                ENDIF
            Else
                IF !lSchedule
                    FwAlertError("Arquivo não pode ser aberto!", "Atenção")
                Else
                    FWLogMsg("WARN", , "Não Foi possivel Abrir o Arquivo"+cDir + cArqOri, AllTrim(FunName()), "", "01",cDir + cArqOri+" ------> Fim", 0, 0, {})
                Endif
            EndIf
               
            oArquivo:Close()
            IF lRet
               //efetua cópia pra o diretorio de Arquivos Processados
                __copyfile(cDir+cArqOri,cDirProc+cArqOri)
                //Efetua a Exclusão do Arquivo Processado           
                If FErase(cDir+cArqOri) == -1
                   IF lSchedule
                      FWLogMsg("INFO", , "Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()), AllTrim(FunName()), "", "01", FWTIMESTAMP(2), 0, 0, {})
                   EndIf
                Endif  
                
            Endif   
        RestArea(aArea)
    Next
    IF lRet
       IF  !lSchedule   
           FWALERTSuccess("Arquivo(s) Importados com sucesso","OK")
       Else
           FWLogMsg("INFO", , "Arquivo Importado Com Sucesso... " + cDir + cArqOri, AllTrim(FunName()), "", "01", FWTIMESTAMP(2), 0, 0, {})
       Endif
    Endif   
RETURN

Static Function GrvZTQ(cStatus,cArquivo, cPedido)
Default cStatus		:='LISTA'
Default cArquivo	:= ""
Default cPedido		:= ""
		
        ZTQ->(dbSelectArea("ZTQ"))
        ZTQ->(dbSetORder(2))
        IF ZTQ->(!dbSeek(xFilial("ZTQ") + cPedido))
  
            SA1->(dbSelectArea("SA1"))
            SA1->(DbSetorder(1))
            SA1->(DbSeek(FwXFilial('SA1')+cCliente + cLoja ))
            
            RecLocK("ZTQ",.T.)
            ZTQ->ZTQ_FILIAL := xFilial("ZTQ")
            ZTQ->ZTQ_ITEMCC := "PLOOMES"
            ZTQ->ZTQ_PEDLV 	:= cPEDLV
            ZTQ->ZTQ_STATUS := cStatus
            ZTQ->ZTQ_DATA   := ddatabase
            ZTQ->ZTQ_VALOR  := nValtot
            ZTQ->ZTQ_FILPED := cFILANT
        
            ZTQ->ZTQ_NOME   := SA1->A1_NOME
            ZTQ->ZTQ_NOMRED := SA1->A1_NREDUZ
            ZTQ->ZTQ_TIPO   := SA1->A1_TIPO
            ZTQ->ZTQ_TPESSO := SA1->A1_PESSOA
            ZTQ->ZTQ_CGC    := SA1->A1_CGC
            ZTQ->ZTQ_END    := SA1->A1_END
            ZTQ->ZTQ_EST    := SA1->A1_EST
            ZTQ->ZTQ_CODMUN := SA1->A1_COD_MUN
            ZTQ->ZTQ_MUN    := SA1->A1_MUN
            ZTQ->ZTQ_BAIRRO := SA1->A1_BAIRRO
            ZTQ->ZTQ_CEP    := SA1->A1_CEP
            ZTQ->ZTQ_EMAIL  := SA1->A1_EMAIL
            ZTQ->ZTQ_INSCR  := SA1->A1_INSCR
            ZTQ->ZTQ_DDD    := SA1->A1_DDD
            ZTQ->ZTQ_TEL    := SA1->A1_TEL
            ZTQ->ZTQ_ENDCOB := SA1->A1_ENDCOB
            ZTQ->ZTQ_ESTCOB := SA1->A1_ESTC
            ZTQ->ZTQ_MUNC   := SA1->A1_MUNC
            ZTQ->ZTQ_ENDENT := SA1->A1_ENDENT
            ZTQ->ZTQ_ESTENT := SA1->A1_ESTE
            ZTQ->ZTQ_BAIENT := SA1->A1_BAIRROE
            ZTQ->ZTQ_CEPENT := SA1->A1_CEPE
            ZTQ->ZTQ_MUNENT := SA1->A1_MUNE
            //ZTQ->ZTQ_ORIGEM := "CRM PLOOMES"
            ZTQ->ZTQ_INTSC5 := "0"
            ZTQ->ZTQ_INTZTS := "0"
            ZTQ->ZTQ_INTSA1 := "1"
            ZTQ->ZTQ_CONDPG := cCondPag
            ZTQ->ZTQ_TRANSP := cTransp 
            ZTQ->ZTQ_CODCLI := SA1->A1_COD
            ZTQ->ZTQ_LOJCLI := SA1->A1_LOJA
            ZTQ->ZTQ_VEND   := IF(Empty(cVend),SA1->A1_VEND,cVend)
            ZTQ->ZTQ_TPFRET := cTpFrete
            ZTQ->ZTQ_NUMPED := ""
            ZTQ->ZTQ_CANAL  := "PL"
            ZTQ->ZTQ_OCORRE := ""
            ZTQ->ZTQ_OBS    := cMensNota

            IF ZTQ->(FieldPOS("ZTQ_FILEML")> 0 )
                ZTQ->ZTQ_FILEML	:= cArquivo
            EndIF
            ZTQ->(MsUnLock())
		ENDIF
Return(lRet)

Static Function GRVZTS(cPEDLV,cItem,cProduto,nPreUnit,nQTDE,nTpOper)

ZTS->(dbSelectArea("ZTS"))
ZTS->(dbSetORder(1))
IF !ZTS->(dbSeek(xFilial("ZTS") + PADR(cPEDLV,TAMSX3("ZTS_PEDLV")[1])+ PADR(cPRODUTO,TAMSX3("ZTS_SKU")[1])+ PADR(STRZERO(Val(cItem),TAMSX3("C6_ITEM")[1]),TAMSX3("ZTS_ITEM")[1])))
    
    RecLocK("ZTS",.T.)
            
    ZTS->ZTS_FILIAL := xFilial("ZTS")
    ZTS->ZTS_ITEM   := STRZERO(Val(cItem),TAMSX3("C6_ITEM")[1])
    ZTS->ZTS_SKU    := cPRODUTO
    ZTS->ZTS_DESCRI := POSICIONE("SB1",1,FwXFilial("SB1")+cProduto,"B1_DESC")
    ZTS->ZTS_PRCVEN := nPreUnit
    ZTS->ZTS_QUANT  := nQTDE
    ZTS->ZTS_PEDLV  := cPEDLV
    ZTS->ZTS_BONIF  := IF(nTpOper==1,'2','1')
    ZTS->(MsUnLock())

   

Endif
RETURN
/*--------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--- Funcao   - Param38       - Autor -Abel Ribeiro         -             Data - 24/02/2024 ---
----------------------------------------------------------------------------------------------
---Descricao - Carrega Tela de parametros.												   ---
---          -              															   ---
--------------------------------------------------------------------------------------------*/
Static Function Param38(lOk)
	//Declaracao de Array - Local
	Local aRet		:= {}
	Local aPar		:= {}
	//Declaracao de Bloco de codigo
	Local bOk			:= {||IIF(Empty(MV_PAR01),MsgYesNo(STRMSGDIR),.T.)}
	//Monta Parametros
	aAdd( aPar,{ 6,OemToAnsi("Diretorio de entrada"),Space(80),"","","",80,.F.,OemToAnsi("Arquivos TXT |*.TXT"),'C:\'})
	//Verifica se clicou em confirmar
	If ParamBox( aPar , STRPARAME, @aRet,bOk,,.T.,,,,"ACOM038", .T., .T. )
		If Empty(MV_PAR01)
			MV_PAR01	:= cDirArq
		Else
			MV_PAR01	:= Substr(MV_PAR01,1,Rat("\",MV_PAR01))
		Endif
		lOk	:= .T.
	Else
		lOk	:= .F.
	Endif

Return aRet

	
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Geração de pedidos - Função para utilização no Schedule

@author Rafael Yera Barchi
@since 16/02/2022
@version 1.00
@type function
@param Nil
@return _aPar, array, Parâmetros de execução do Schedule
		_aPar[1] - Tipo R para relatorio P para processo
		_aPar[2] - Nome do grupo de perguntas (SX1)
		_aPar[3] - cAlias (para Relatorio)
		_aPar[4] - aArray (para Relatorio)
		_aPar[5] - XTITUL (para Relatorio)

/*/
//------------------------------------------------------------------------------------------
Static Function SchedDef()

	//--< Variáveis >-----------------------------------------------------------------------
	Local _aPar 	:= {}
	Local _cFunc	:= "DXIMPPED"
	Local _cPrgt	:= PadR(_cFunc, 10)


	//--< Procedimentos >-------------------------------------------------------------------
	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
				_cPrgt	,;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		}	//XTITUL (para Relatorio)

Return _aPar





//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
Geração de pedidos - Rotina para criação de perguntas

@author Rafael Yera Barchi
@since 16/02/2022
@version 1.00
@type function
@param Nil
@return Nil

/*/
//------------------------------------------------------------------------------------------
Static Function ValidPerg()

	//--< Variáveis >-----------------------------------------------------------------------
	Local aAreaX1 := GetArea()


	//--< Procedimentos >-------------------------------------------------------------------
	RestArea(aAreaX1)

Return
