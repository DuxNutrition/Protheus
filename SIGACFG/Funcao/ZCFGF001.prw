//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} ZCFGF001
Formula Customizada
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 25/07/2024
@return variant, return_description
/*/
User Function ZCFGF001()

    Local aArea := GetArea()
    //Vari�veis da tela
    Private oDlgForm
    Private oGrpForm
    Private oGetForm
    Private cGetForm := Space(250)
    Private oGrpAco
    Private oBtnExec
    //Tamanho da Janela
    Private nJanLarg := 500
    Private nJanAltu := 120
    Private nJanMeio := ((nJanLarg)/2)/2
    Private nTamBtn  := 048
     
    //Criando a janela
    DEFINE MSDIALOG oDlgForm TITLE "[ZCFGF001] - DUX - Execu��o de F�rmulas" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo F�rmula com o Get
        @ 003, 003  GROUP oGrpForm TO 30, (nJanLarg/2)-1        PROMPT "F�rmula: " OF oDlgForm COLOR 0, 16777215 PIXEL
            @ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 OF oDlgForm COLORS 0, 16777215 PIXEL
         
        //Grupo A��es com o Bot�o
        @ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "A��es: " OF oDlgForm COLOR 0, 16777215 PIXEL
            @ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExecuta()) PIXEL
         
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgForm CENTERED
     
    RestArea(aArea)
Return
 
/*/{Protheus.doc} fExecuta
Executa o formulas
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 25/07/2024
@return variant, return_description
/*/
Static Function fExecuta()
    Local aArea    := GetArea()
    Local cFormula := Alltrim(cGetForm)
    Local cError   := ""
    Local bError   := ErrorBlock({ |oError| cError := oError:Description})
     
    //Se tiver conte�do digitado
    If ! Empty(cFormula)
        //Inicio a utiliza��o da tentativa
        Begin Sequence
            &(cFormula)
        End Sequence
         
        //Restaurando bloco de erro do sistema
        ErrorBlock(bError)
         
        //Se houve erro, ser� mostrado ao usu�rio
        If ! Empty(cError)
            MsgStop("Houve um erro na f�rmula digitada: "+CRLF+CRLF+cError, "Aten��o")
        EndIf
    EndIf
     
    RestArea(aArea)
Return
