#include 'protheus.ch'
/*/{Protheus.doc} F060QRCP
	
	Ponto de Entrada para alterar Query dos Borderôs de Cobrança

@author CI RESULT - Luciano Corrêa
@since 29/03/2023
@version Protheus 12.1.33
@param
@return cNewQuery, char, nova query a ser executada
@example
/*/
User Function F060QRCP() 

	Local cQuery	:= ParamIXB[ 1 ]
	Local nPosWhere, cNewQuery
	Local cPerg		:= "F060QRCP"
	Local BKP_PAR01	:= MV_PAR01

	//PutSX1( cGrupo, cOrdem, cTexto						, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid	, cF3		, cPicture	, cDef01			, cDef02			, cDef03			, cDef04	, cDef05	, cHelp	, cGrpSXG	)
	u_PutSX1( "F060QRCP", "01"	, "Considerar Clientes:"	, "mv_par01", "mv_ch1"	, "N"		,  1						, 0			, "C"		, ""		,			,			, "Pessoa Física"	, "Pessoa Jurídica"	, "Ambos"			,			,			,		, 			)

	If Pergunte( cPerg, .T., 'Filtro de Títulos') .and. MV_PAR01 <> 3

		nPosWhere	:= At( ' WHERE ', Upper( cQuery ) )

		cNewQuery	:= SubStr( cQuery, 1, nPosWhere ) 

		cNewQuery	+= ", " + RetSqlName( 'SA1' ) + " SA1 WHERE A1_FILIAL = '" + xFilial( "SA1" ) + "' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ' AND " 
		cNewQuery	+= " A1_PESSOA = '" + If( MV_PAR01 == 1, "F", "J" ) + "' AND "
		
		cNewQuery	+= SubStr( cQuery, nPosWhere + 6 )

		cNewQuery	:= StrTran( cNewQuery, ' D_E_L_E_T_', ' SE1.D_E_L_E_T_' )
		cNewQuery	:= StrTran( cNewQuery, ' R_E_C_N_O_', ' SE1.R_E_C_N_O_' )

	Else
		cNewQuery	:= cQuery
	EndIf

	MV_PAR01	:= BKP_PAR01

Return cNewQuery
