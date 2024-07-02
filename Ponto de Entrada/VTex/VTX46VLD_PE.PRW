#INCLUDE 'PROTHEUS.CH'

// #########################################################################################
// Projeto: VTEX

// Modulo : Integração E-Commerce
// Fonte  : VTX46VLD
// Cliente: ATOMED
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 18/11/20 | Douglas F Martins | Ponto de entrada para validar Pedido pago com VALE
// ---------+-------------------+-----------------------------------------------------------

User Function VTX46VLD()


	Local lRet      := .T.
	Local cTrapOK   := SuperGetMV("VT_TRSPOK",,"")
	Local cTrapNO   := SuperGetMV("VT_TRSPNO",,"")
	Local lTrocFil   := SuperGetMV("VT_TRANFIL",,.F.)


	Private _cStatusPed	:= ""

	IF lTrocFil
		IF !Empty(cTrapOK)
			IF UPPER(PARAMIXB[1]:SHIPPINGDATA:LOGISTICSINFO[1]:DELIVERYIDS[1]:COURIERID) $UPPER(cTrapOK)
				lRet := .T.
			Else
				lRet := .F.
				RecLock("ZTQ",.F.)
				//ZTQ->ZTQ_STATUS := 'ERLST'
				ZTQ->ZTQ_FILPED := IF(cFilAnt=='02','04','02')
				ZTQ->(MsUnLock())
			EndIF
		Else
			IF UPPER(PARAMIXB[1]:SHIPPINGDATA:LOGISTICSINFO[1]:DELIVERYIDS[1]:COURIERID) $UPPER(cTrapNO)
				lRet := .F.
				RecLock("ZTQ",.F.)
//			ZTQ->ZTQ_NOME := 'ERLST'
				ZTQ->ZTQ_FILPED := IF(cFilAnt=='02','04','02')
				ZTQ->(MsUnLock())
			Else
				lRet := .T.
			EndIF
		EndIF

	Else
		lREt := .T.
	EndIF

Return lRet






