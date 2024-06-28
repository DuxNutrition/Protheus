#INCLUDE 'PROTHEUS.CH'


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} M461SER
Ponto de Entrada para Mudar Número da Nota Fiscal e Série

@author    Douglas Ferreira Martins
@version   1.xx
@since     01/02/2023
/*/
//------------------------------------------------------------------------------------------
//Descrição : Ponto de Entrada Criado para Trocar Série e Número da Nota Fiscal no momento 
//do Faturamento de Notas  Fiscais de Saída  no Projeto Mercado Livre FULL
//------------------------------------------------------------------------------------------

User Function MSD2520()
	
	If ExistBlock("ADMSD2520")
		ExecBlock("ADMSD2520", .F., .F.)
	EndIf
    
Return
