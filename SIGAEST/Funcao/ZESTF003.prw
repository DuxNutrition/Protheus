#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ZESTF003
Tela para impressão de Etiqueta
@type Function
@version 12.1.23
@author Jedielson Rodrigues
@since 23/08/2024
@version 12.1.2310
@database MSSQL
@See 
/*/
User Function ZESTF003()

Local oQtde       := Nil
Local oCombo      := Nil
Local cCodPrint   := Space(TamSX3("CB5_CODIGO")[1])
Local cGalpao     := " "
Local nQtd        := 1
Local cSequencial := GetSequencial()

Private oDlg      := Nil      // Dialog Principal

    DEFINE MSDIALOG oDlg TITLE "[ ZESTF003 ] - Geração de Etiquetas" FROM C(178),C(160) TO C(490),C(450) PIXEL

    @ C(005),C(006) TO C(140),C(140) LABEL "Preencha os Parametros" PIXEL OF oDlg

    @ C(022),C(020) Say "Galpão de Destino:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
    @ C(030),C(020) COMBOBOX oCombo VAR cGalpao ITEMS {"01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20"} SIZE 050,08  PIXEL OF oDlg
    
    @ C(042),C(020) Say "Número Sequencial:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
    @ C(049),C(020) MsGet cSequencial PICTURE "@!" WHEN .F. SIZE 050,08  PIXEL OF oDlg 

    @ C(061),C(020) Say "Qtde de Etiquetas:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
    @ C(068),C(020) GET oQtde VAR nQtd PICTURE "999" SIZE 050,08  PIXEL OF oDlg

    @ C(080),C(020) Say "Impressora:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
    @ C(087),C(020) MsGet cCodPrint PICTURE "@!" VALID  !Empty(cCodPrint) .And. FValidCpo("IMPRESSORA" , cCodPrint)  F3 "CB5IMP" WHEN .T. SIZE 060,08  PIXEL OF oDlg 
        
    DEFINE SBUTTON FROM C(143),C(095) TYPE 6 ENABLE OF oDlg ACTION ( Processa( { || ZETQDEV(cCodPrint,cGalpao,cSequencial,nQtd)} ,"[ ZESTF003 ] - Imprimindo Etiqueta..." )  ,oDlg:End() )
    DEFINE SBUTTON FROM C(143),C(120) TYPE 2 ENABLE OF oDlg ACTION ( oDlg:End() )
        
    ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*/{Protheus.doc} GetSequencial
Gera sequencial automaticamente e atualiza a SX5.
@type function
@version 12.1.2310
@author Dux | Jedielson Rodrigues
@since 23/08/2024
@param cAcao, character, Campo
@param xVar, variant, Variavel
/*/
Static Function GetSequencial()

Local nSeq      := 0
Local cTab      := "SE"
Local aRetSeq   := FWGetSX5(cTab)
Local cFil      := " "
Local cSeq      := " "
Local cChave    := " " 

    If Len(aRetSeq) > 0 
        cFil    := aRetSeq[1][1]
        cChave  := ALLTRIM(aRetSeq[1][3])
        cSeq    := ALLTRIM(aRetSeq[1][4])
        nSeq    := Val(cSeq) + 1
        cSeq    := StrZero(nSeq, 5)
        FwPutSX5( cFil, cTab, cChave, cSeq, cSeq, cSeq, /*cTextoAlt*/)
    Endif

Return cSeq

/*/{Protheus.doc} FValidCpo
Valida os campos da ZESTF003
@type function
@version 12.1.2310
@author Dux | Jedielson Rodrigues
@since 23/08/2024
@param cAcao, character, Campo
@param xVar, variant, Variavel
/*/
Static Function FValidCpo( cAcao, xVar )
    
Local lRet

lRet  := .T.
cAcao := IF(cAcao==NIL,"",Upper(cAcao))

If cAcao == "IMPRESSORA"
    If Empty(xVar)
        lRet := .F.
        FWAlertWarning("Necessario informar uma impressora", "Atenção [ ZESTF003 ]")
    EndIf
    DbSelectArea("CB5")
    CB5->(DbSetOrder(1))
    If !DbSeek(xFilial("CB5")+xVar)
        lRet := .F.
        FWAlertWarning("Impressora nao encontrada no cadastro", "Atenção [ ZESTF003 ]")
    EndIf
EndIf

Return(lRet)

/*/{Protheus.doc} ZETQDEV
Prepara as Etiquetas para impressao
@type function
@version 12.1.2310
@author Dux | Jedielson Rodrigues
@since 23/08/2024
@param oMarkBrowse, object, Browse Inicial
/*/
Static Function ZETQDEV(cCodPrint,cGalpao,cSequencial,nQtd)

Local nX := 0

For nX := 1 To nQtd
    Processa({|| U_ZGENETQ2(cCodPrint,cGalpao,cSequencial,nQtd) },"Imprimindo etiqueta " + cValToChar(nX))
    Sleep(500)
Next nX
    
Return()
