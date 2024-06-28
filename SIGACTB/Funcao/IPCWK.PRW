#include "Protheus.ch"
#include "TopConn.ch"

/*
=====================================================================================
Programa.:              IPCWK
Autor....:              ERP MAIS | José Donizete R.silva
Data.....:              22/05/2023
Descricao / Objetivo:   Este programa tem a função de executar as fórmulas do cadastro de fórmulas da contabilidade (CWK).
                        O funcionamento é praticament e o mesmo da função EJEFOR. A diferença é que o sistema não deixa usar o 
                        EJERFOR mais de uam vez no mesmo campo no CT5, por exemplo EJEFOR().AND.EJEFOR().
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function IPCWK(cCodForm)

// Declaração de variáveis
local xRet      := Nil
local xArea		:= GetArea()
local cTipo     := ""
local cForm     := ""

// Ativa áreas CWK para buscar a fórmula
dbSelectArea("CWK")
dbSetOrder(1)

// Posiciona na fórmula para macro executar
If dbseek(xFilial("CWK")+cCodForm)
	
    // Verifica o tipo de dado da CWK
	cTipo := CWK->CWK_TIPO
	
    If cTipo == "1" // Conta
        xRet := ALLTRIM(CWK->CWK_CUENTA)
    ElseIf cTipo == "2" // Centro de custos
        xRet := ALLTRIM(CWK->CWK_CC)
    ElseIf cTipo == "3" // Item contábil
        xRet := ALLTRIM(CWK->CWK_ITECTB)
    ElseIf cTipo == "4" // Classe de Valor
        xRet := ALLTRIM(CWK->CWK_CLVALO)
    ElseIf cTipo == "5" // Expressão ADVPL
        cForm := AllTrim(CWK->CWK_ADVPL)
        xRet := &cForm
    Endif    
Else
    // Tratamento para mostrar msg de fórmula não quebrar e tentativa do
    // código não quebrar
    If Left(cCodForm,2)=="VR"
        xRet := 999999
    ElseIf Left(cCodForm,2)$"CT,IT,CL,CC,HS"
        xRet := cCodForm
    EndIf
    Aviso( OemToAnsi("Erro"),OemToAnsi("Fórmula ") + cCodForm + OemToAnsi(" não encontrada no cadastro de fórmulas CWK"), {OemToAnsi("OK")} )
 	cCodForm := "ERR:" + cCodForm
EndIf

// Fiz este bloco apenas para validar e ver na tela de lançamentos contábeis qual fórmula foi chamada
/*
If Valtype(xRet)=="C"
    if empty(xRet)
        xRet := cCodForm
    Endif
EndIf
*/

RestArea(xArea)

Return xRet
