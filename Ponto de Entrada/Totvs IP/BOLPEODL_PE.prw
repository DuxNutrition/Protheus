#Include 'Protheus.ch'

/*/{Protheus.doc} BOLPEODL
Ponto de entrada da TotvsIP que permite incluir componentes visuais na tela de impressão do boleto.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 23/07/2024
@return variant, return_description
@obs GAP008 | Impressao de boleto	
/*/
User Function BOLPEODL()

	Local oDlg		:= PARAMIXB[1]
	local bImprime  := {||u_ZFINF001(aTitulos)}
	
    oDlg:nHeight := 490
	@ 200,245 BUTTON "Boleto Dux" SIZE 50,12 ACTION {|| oDlg:End(), Eval(bImprime)} PIXEL OF oDlg
	
Return
