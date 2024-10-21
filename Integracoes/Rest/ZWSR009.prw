#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  � ZWSR009.prw � Autor � Allan Rabelo � Data � 28/09/2024     ���
//�������������������������������������������������������������������������͹��
//���Descricao � Schedule para pegar os XML e gravar na VTEX                ���
//���          �                                                            ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

User function ZWSR009(jBody,cPedNum,cId)
	local cURL      := GetMV("DX_VTX01",.F.,"https://duxnutrition.vtexcommercestable.com.br/api/oms/pvt/orders/")
	local cEnd      := GetMV("DX_VTX02",.F.,"/invoice")
	local cApiKey   := GetMV("DX_VTX03",.F.,"vtexappkey-duxnutrition-ANSENB")
	local cToken    := GetMv("DX_VTX04",.F.,"NWMCEYASEVOEVRBYGCVTNQOZMBPWIPAGVLOFMVYZNUHHXCODMDTZQUBEABTKTLDLVPKUJZGYXUWNRTDMJTHZTJEOLPINEAWURSEWWEQCUORHHBRLSAKDAKJFDSNTBLLL")
	local cKeynam   := GetMv("DX_VTX05",.F.,"X-VTEX-API-AppKey: ")
    local cHeadNam  := GetMv("DX_VTX06",.F.,"X-VTEX-API-AppToken: ")
	local oRest as object
	Local oOBj
	local cPar1  := cKeynam+cApiKey
    Local cPar2  := cHeadNam+cToken
	local aHeader := {}
	local aJson := {}
	Local cResponse
	Local cHeaderRet as char


	If IsBlind()
		Conout("JOB ZWSR009 (ENVIO A VTEX) INICIADO NA DATA: "+Dtos(Date())+" NO HOR�RIO: "+TIME()+" ")
		PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FAT"
	Endif
     //���������������������������������������������������������������������������Ŀ
	//� Monto cabe�alho para envio a POST da VETEX                                �
	//����������������������������������������������������������������������������� 
	aAdd(aHeader,"Accept: application/json;charset=UTF-8")
	aadd(aHeader,'Content-Type: application/json;charset=UTF-8')
	aadd(aHeader,cPar1)
    aadd(aHeader,cPar2)
	cResponse := HttpPost(cURL+alltrim(cPedNum)+cEnd,"",jBody,120,aHeader,@cHeaderRet)

	//���������������������������������������������������������������������������Ŀ
	//� Pega o JSON e decode64 nele para gravar na ZFR                           �
	//����������������������������������������������������������������������������� 
	if !Empty(cResponse)
		FWJSONDESERIALIZE(cResponse,@oObj)
       if !(Select('ZFR') > 0)
            DbSelectArea("ZFR")
            ZFR->(DBSetOrder(2))
            ZFR->(DbSeek(xFilial("ZFR")+PADR(cId,TamSX3("ZFR_ID")[1])))
	    endif 
		if !("Error"$cResponse)
        	    RecLock("ZFR",.F.)
				ZFR->ZFR_STATUS := "50"
				ZFR->ZFR_DTENVX := Date()
				ZFR->ZFR_HRENVX := Time()
                ZFR->ZFR_XPEDLV := cPedNum
				ZFR->ZFR_DTRETV := oObj:Date 
				ZFR->ZFR_OIRETV := oObj:Orderid 
				ZFR->ZFR_PRRETV := oObj:Receipt 
				ZFR->(MsUnlock())
		else
				ZFR->ZFR_ERROR := oObj:message 
                ZFR->ZFR_STERRO := "50"
				ZFR->ZFR_STATUS := "99"
				ZFR->(MsUnlock())
        endif 
    endif 
If IsBlind()
	Conout("JOB ZWSR009 (ENVIO A VTEX) FINALIZADO NA DATA: "+Dtos(Date())+" NO HOR�RIO: "+TIME()+" ")
	RESET ENVIRONMENT
endif 
Return()
