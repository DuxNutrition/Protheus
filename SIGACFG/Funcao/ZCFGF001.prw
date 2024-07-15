#INCLUDE "VKEY.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

#IFNDEF VAR_NAME_LEN
	#DEFINE VAR_NAME_LEN	50
#ENDIF	

//#IFDEF __DEBUG	//Se estiver definida, executo diretamente pela tela de abertura do sistema

/*/{Protheus.doc} EVExePrg
Rotina para executar rotinas direto, sem abertura de login Protheus
@type function
@version 12.1.33
@author Valdemir Rabelo
@since 15/02/2023
@return variant, Não há
/*/
User Function ZCFGF001()
    Local cEmpNew := ""
    Local cFilNew := ""
    //Local cTitulo := ""

    If (Select("SX2")==0)
        cEmpNew := FWInputBox("Informe o código da Empresa", "01")
        cFilNew := FWInputBox("Informe a Filial da Empresa", "01")
    Else 
       cEmpNew := cEmpAnt
       If FWAlertYesNo("Filial logada: "+cFilAnt+ " Deseja Mudar?","Atenção")
          cFilNew := FWInputBox("Informe a Filial da Empresa", cFilAnt)
          If Empty(cFilNew)
             cFilNew := cFilAnt
          Endif 
       Else 
           cFilNew := cFilAnt                
       Endif 
    Endif 
    //if !FWFilExist(cEmpNew,cFilNew)
       //FWAlertWarning("Filial informada: '"+cFilNew+"' está incorreta. Por favor verifique. ",cTitulo)
       //Return 
    //endif 



Return( EvalPrg( { || VJRPROG1() } , cEmpNew , cFilNew , "SIGAESP" , "CTT" ) )



/*/{Protheus.doc} EvalPrg
Executa um Programa Diretamente
@type function
@version 12.1.33
@author Valdemir Rabelo
@since 15/02/2023
@param bExec, codeblock, Bloco com chamada da rotina generica
@param cEmp, character, Empresa
@param cFil, character, Filial
@param cModulo, character, Modulo a ser aberto
@param cTables, character, Tabela utilizada
@return variant, Não há
/*/
Static Function EvalPrg( bExec , cEmp , cFil , cModulo , cTables )

    Local nVarNameLen	:= SetVarNameLen( VAR_NAME_LEN )		//Para Poder usar Nomes Longos

    Local bWindowInit	:= { || Eval( bExec ) }
    Local lPrepEnv		:= ( IsBlind() .or. ( Select( "SM0" ) == 0 ) )
    
    Local uRet

    BEGIN SEQUENCE

        IF ( lPrepEnv )
            RpcSetType( 3 )
            PREPARE ENVIRONMENT EMPRESA( cEmp ) FILIAL ( cFil ) MODULO ( cModulo ) TABLES ( cTables )
            SetVarNameLen( VAR_NAME_LEN )
            InitPublic()
            SetsDefault()
        EndIF

            IF ( Type(  "oMainWnd" ) == "O" )
                uRet := Eval( bExec )
                BREAK
            EndIF

            bWindowInit	:= { || uRet := Eval( bExec ) }
            DEFINE WINDOW oMainWnd FROM 0,0 TO 0,0 TITLE OemToAnsi( FunName() )
            ACTIVATE WINDOW oMainWnd MAXIMIZED ON INIT ( Eval( bWindowInit ) , oMainWnd:End() )
        
        IF ( lPrepEnv )
            RESET ENVIRONMENT
        EndIF	

    END SEQUENCE

    SetVarNameLen( nVarNameLen )

Return( uRet )

//#ENDIF


/*/{Protheus.doc} VJRPROG1
Rotina que fará a pergunta da rotina a ser
executada
@type function
@version 12.1.33
@author Valdemir Rabelo
@since 15/02/2023
@return variant, Não há
/*/
Static Function VJRPROG1()
    local cCmd:=SPACE(256)
    local lContinua := .T.

    cCmd := GetNewPar("EXECADVPL",'CRIAR')   // Caso não exista o parametro retorna a palavra CRIAR

    IF (cCmd=='CRIAR')
        cCmd := CRIASX6()
    ENDIF 
    if Empty(cCmd)
       cCmd := Space(30)
    endif
    cCmd := FWInputBox("Rotina a executar (não esquecer 'U_')",cCmd)

    While lContinua
        if Empty(cCmd)
            FWAlertInfo("É necessário informar o nome da rotina","Atenção!")
            cCmd := FWInput("Rotina a executar (não esquecer 'U_')",cCmd)
            if Empty(cCmd)
               if FWAlertNoYes("Deseja sair da rotina","Informativo")
                  lContinua := .F.
               endif 
            Endif 
        else           
           exit
        endif 
    EndDo
    if lContinua
        xRun(cCmd)
    endif 

Return 


Static Function xRun(cCmd) //Executa a Rotina
    cCmd := ALLTRIM(cCmd)
    IF at("(",cCmd)==0
        cCmd:=ALLTRIM(cCmd)+"("
    EndIF
    
    IF at(")",cCmd)==0
        cCmd:=ALLTRIM(cCmd)+")"
    EndIF

    PUTMV("EXECADVPL",cCmd)
    if FindFunction(cCmd)
        &(cCmd) 
    else
       FWAlertInfo("Verifique se a rotina foi compilada","Rotina não encontrada") 
    endif 

 Return 



/*/{Protheus.doc} CRIASX6
Rotina chamada para gerar
@type function
@version  12.1.33
@author valdemir Rabelo
@since 18/05/2022
@return variant, space
/*/
Static Function CRIASX6()
	Local aPars := {}

	aAdd(aPars, {"EXECADVPL", "C", "Ultima rotina executada",          " "} )

	EVCriaPar(aPars)

Return (space(20))


/*/{Protheus.doc} EVCriaPar
Rotina para criar parâmetro
@type function
@version  12.1.33
@author valdemir Rabelo
@since 18/05/2022
@param aPars, array, dados a serem criado
@return variant, Nil
/*/
Static Function EVCriaPar(aPars)
    Local nAtual        := 0
    Local aArea        := GetArea()
    Local aAreaX6        := SX6->(GetArea())
    Default aPars        := {}
     
    DbSelectArea("SX6")
    SX6->(DbGoTop())
     
    //Percorrendo os parâmetros e gerando os registros
    For nAtual := 1 To Len(aPars)
        //Se não conseguir posicionar no parâmetro cria
        If !(SX6->(DbSeek(xFilial("SX6")+aPars[nAtual][1])))
            RecLock("SX6",.T.)
                //Geral
                X6_VAR        :=    aPars[nAtual][1]
                X6_TIPO    :=    aPars[nAtual][2]
                X6_PROPRI    :=    "U"
                //Descrição
                X6_DESCRIC    :=    aPars[nAtual][3]
                X6_DSCSPA    :=    aPars[nAtual][3]
                X6_DSCENG    :=    aPars[nAtual][3]
                //Conteúdo
                X6_CONTEUD    :=    aPars[nAtual][4]
                X6_CONTSPA    :=    aPars[nAtual][4]
                X6_CONTENG    :=    aPars[nAtual][4]
            SX6->(MsUnlock())
        EndIf
    Next
     
    RestArea(aAreaX6)
    RestArea(aArea)
Return
