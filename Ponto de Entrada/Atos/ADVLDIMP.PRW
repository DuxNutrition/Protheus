#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ADVLDIMP
Ponto de Entrada para Validar se pode importar o pedido ou não, para evitar duplicidade

@author    Douglas Ferreira Martins
@version   1.xx
@since     12/03/2024
/*/
//------------------------------------------------------------------------------------------
User Function ADVLDIMP()

	Local   cQuery		:= ""



	cQuery := " SELECT COUNT(*) AS QUANTIDADE "
	cQuery += " FROM " + RetSqlName("SC5") + " "
	cQuery += " WHERE C5_FILIAL = '"+XFILIAL("SC5")+"'
	cQuery += " AND C5_ZZNUMPJ = '"+Alltrim(ZTQ->ZTQ_PEDLV)+"'
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	IF MpSysExecScalar(cQuery,"QUANTIDADE")==0
		lContinua := .T.
	Else
		lContinua := .F.
		_cMsg := " Pedido "+ZTQ->ZTQ_PEDLV+"  não será importado, pois já existe no ERP"
	EndIF



Return lContinua
