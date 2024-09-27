#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ WSR005.prw º Autor ³ Allan Rabelo º Data ³ 25/09/2024      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Schedule para enviar ZFR já processadas                    º±±
//±±º          ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

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
        While !Empty(cAtual) //--> Verifico se existe a palavra STATUS na linha, caso sim ele leve para condição 'ok'
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ QueryZFR           ºAutor³ Allan Rabelo            º Data ³ 25/09/2024 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Query na ZFR trazendo resultados de acordo com processo                º±±
±±º         ³                                                                        º±±
±±º         ³                                                                        º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametr.³ ExpC1= Variavel caracter com operação (PATCH,GET,POST)                 º±±
±±º         ³ ExpC2=                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³                                                                        º±±
±±º         ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ DUXNutrition                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                        PROJETO INFRACOMMERCE                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Programador  ³  Data   ³ Motivo da Alteracao                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º              ³         ³                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
