#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PRTOPDEF.ch"

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

User function ZWSR005(cId)
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
	Local lRet := .F.

	Default nRecno := 0
    If IsBlind()
		Conout("JOB ZWSR005 (ENVIO PROCESSADAS) INICIADO NA DATA: "+Dtos(Date())+" NO HOR�RIO: "+TIME()+" ")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT" 
	Endif


	aadd(aHeader,'Authorization: Bearer '+cBearer)
	aadd(aHeader,'Content-Type: application/json;charset=UTF-8')
	aadd(aHeader,cPar)


	//DbSelectArea("ZFR")
	//cResponse := HTTPQuote(cURL+cEnd, "PATCH",,cId,120,aHeader,@cHeaderRet)
	cResponse := "status: 200" // <----- TIRAR DEPOIS

	if !Empty(cResponse)
		/*
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
		*/
		cRet  := cResponse
		//	ZFR->(DBSetOrder(2))
//		ZFR->(DbGoTo(nRecno))
		if ("200"$cRet)
			RecLock("ZFR",.F.)
			ZFR->ZFR_STATUS := "20"
			ZFR->ZFR_DATACR := Date()
			ZFR->ZFR_HORACR := Time()
			ZFR->(MsUnlock())
			lRet := .T.
		else
			RecLock("ZFR",.F.)
			ZFR->ZFR_ERROR := "Erro no envio de PATH para INFRACOMMERCE "
			ZFR->ZFR_STERRO := "20"
			ZFR->(MsUnlock())
			lRet := .F.
		endif

	endif
	ZFR->(dbCloseArea())
If IsBlind()
    Conout("JOB ZWSR005 (ENVIO PROCESSADAS) FINALIZADO NA DATA: "+Dtos(Date())+" NO HOR�RIO: "+TIME()+" ")
    RESET ENVIRONMENT
endif 
Return(lRet)
