#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  � WSR005.prw � Autor � Allan Rabelo � Data � 25/09/2024      ���
//�������������������������������������������������������������������������͹��
//���Descricao � Schedule para enviar ZFR j� processadas                    ���
//���          �                                                            ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

User function ZWSR005()
local cURL      := GetMV("DX_URL",.F.,"localhost:3000/")
local cEnd      := GetMV("DX_ENDPT",.F.,"count")
local cApiKey   := GetMV("DX_APIKEY",.F.,"Zqc8nwZxI2v4IoKDpTQxXnwKEjQug8GNwiBEnxSuO2dSkgSpYsJ1lDfKjo5V")
local cBearer   := GetMv("DX_BEARE",.F.,"Zqc8nwZxI2v4IoKDpTQxXnwKEjQug8GNwiBEnxSuO2dSkgSpYsJ1lDfKjo5V")
local cKeynam   := GetMv("DX_KEYNAM",.F.,"Api-Key=")
local cPar  := cKeynam+cApiKey
local aHeader := {}
Local cResponse 
Local cHeaderRet as char 
Local cOper     := "PATCH"
Local cAtual := "."
Local nTamanho := 13
Local nLinha := 0
Local cRet := ""

aadd(aHeader,'Authorization: Bearer '+cBearer)
aadd(aHeader,'Content-Type: application/json;charset=UTF-8')


if U_QueryZFR(cOper) //--> Verifico na query itens disponiveis para envio
    DbSelectArea("ZFR")
    While XZFR->(!Eof())
        cResponse := HTTPQuote(cURL+cEnd, "PATCH",cPar,XZFR->IDX,120,aHeader,@cHeaderRet)
        While !Empty(cAtual) //--> Verifico se existe a palavra STATUS na linha, caso sim ele leve para condi��o 'ok'
            nLinha++
            cAtual := MemoLine(cResponse,nTamanho,nLinha)
            if !Empty(cAtual)
                if (cAtual $ "status")
                    cRet   := cAtual
                    cAtual := ""
                endif 
            endif 
        Enddo
		ZFR->(dbgoto(XZFR->RECNO))
        if (cRet$"200")
             RecLock("ZFR",.F.)
             ZFR->ZFR_STATUS := 20 
             ZFR->ZFR_DATACR := Stod(Date()) 
             ZFR->ZFR_HORACR := Time()
             ZFR->(MsUnlock())
        else 
            ZFR->ZFR_ERROR := "Erro no envio de PATH para INFRACOMMERCE "
        endif 
        XZFR->(dbskip())
    Enddo    
    XZFR->(dbCloseArea())
endif 
Return()


/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa � QueryZFR           �Autor� Allan Rabelo            � Data � 25/09/2024 ���
������������������������������������������������������������������������������������͹��
���Desc.    � Query na ZFR trazendo resultados de acordo com processo                ���
���         �                                                                        ���
���         �                                                                        ���
���         �                                                                        ���
������������������������������������������������������������������������������������͹��
���Parametr.� ExpC1= Variavel caracter com opera��o (PATCH,GET,POST)                 ���
���         � ExpC2=                                                                 ���
������������������������������������������������������������������������������������͹��
���Retorno  �                                                                        ���
���         �                                                                        ���
������������������������������������������������������������������������������������͹��
���Uso      � DUXNutrition                                                           ���
������������������������������������������������������������������������������������͹��
���                        PROJETO INFRACOMMERCE                                     ���
������������������������������������������������������������������������������������͹��
���  Programador  �  Data   � Motivo da Alteracao                                    ���
������������������������������������������������������������������������������������͹��
���              �         �                                                        ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
//// seguir mesma nomeclatura 
User Function QueryZFR(cOper)
Local cQuery := ""
Local lRet := .F.

cQuery := " SELECT ZFR_STATUS as STATUSX, ZFR_ID AS IDX, R_E_C_N_O_ AS RECNO  FROM "+RetSqlName("ZFR")+" AS ZFR "
cQuery += " WHERE ZFR.D_E_L_E_T_ = ''  "
cQuery += " AND "
if     (cOper == "PATCH")
    cQuery += " ZFR_STATUS = 1  "
elseif (cOper == "NOTA")
    cQuery += " ZFR_STATUS = 20 "
elseif (cOper == "OK")
    cQuery += " ZFR_STATUS = 30 "
elseif (cOper == "ERRO")
    cQuery += " ZFR_STATUS = 99 "
endif 

TcQuery cQuery New Alias "XZFR"

if XZFR->(!Eof())
    lRet := .T. 
endif 
Return (lRet)
