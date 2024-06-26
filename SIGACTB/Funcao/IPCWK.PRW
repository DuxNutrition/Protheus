#include "Protheus.ch"
#include "TopConn.ch"

/*
=====================================================================================
Programa.:              IPCWK
Autor....:              ERP MAIS | Jos� Donizete R.silva
Data.....:              22/05/2023
Descricao / Objetivo:   Este programa tem a fun��o de executar as f�rmulas do cadastro de f�rmulas da contabilidade (CWK).
                        O funcionamento � praticament e o mesmo da fun��o EJEFOR. A diferen�a � que o sistema n�o deixa usar o 
                        EJERFOR mais de uam vez no mesmo campo no CT5, por exemplo EJEFOR().AND.EJEFOR().
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function IPCWK(cCodForm)

// Declara��o de vari�veis
local xRet      := Nil
local xArea		:= GetArea()
local cTipo     := ""
local cForm     := ""

// Ativa �reas CWK para buscar a f�rmula
dbSelectArea("CWK")
dbSetOrder(1)

// Posiciona na f�rmula para macro executar
If dbseek(xFilial("CWK")+cCodForm)
	
    // Verifica o tipo de dado da CWK
	cTipo := CWK->CWK_TIPO
	
    If cTipo == "1" // Conta
        xRet := ALLTRIM(CWK->CWK_CUENTA)
    ElseIf cTipo == "2" // Centro de custos
        xRet := ALLTRIM(CWK->CWK_CC)
    ElseIf cTipo == "3" // Item cont�bil
        xRet := ALLTRIM(CWK->CWK_ITECTB)
    ElseIf cTipo == "4" // Classe de Valor
        xRet := ALLTRIM(CWK->CWK_CLVALO)
    ElseIf cTipo == "5" // Express�o ADVPL
        cForm := AllTrim(CWK->CWK_ADVPL)
        xRet := &cForm
    Endif    
Else
    // Tratamento para mostrar msg de f�rmula n�o quebrar e tentativa do
    // c�digo n�o quebrar
    If Left(cCodForm,2)=="VR"
        xRet := 999999
    ElseIf Left(cCodForm,2)$"CT,IT,CL,CC,HS"
        xRet := cCodForm
    EndIf
    Aviso( OemToAnsi("Erro"),OemToAnsi("F�rmula ") + cCodForm + OemToAnsi(" n�o encontrada no cadastro de f�rmulas CWK"), {OemToAnsi("OK")} )
 	cCodForm := "ERR:" + cCodForm
EndIf

// Fiz este bloco apenas para validar e ver na tela de lan�amentos cont�beis qual f�rmula foi chamada
/*
If Valtype(xRet)=="C"
    if empty(xRet)
        xRet := cCodForm
    Endif
EndIf
*/

RestArea(xArea)

Return xRet
