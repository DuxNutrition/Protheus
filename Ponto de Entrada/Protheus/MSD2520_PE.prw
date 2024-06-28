#INCLUDE 'PROTHEUS.CH'


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} M461SER
Ponto de Entrada para Mudar N�mero da Nota Fiscal e S�rie

@author    Douglas Ferreira Martins
@version   1.xx
@since     01/02/2023
/*/
//------------------------------------------------------------------------------------------
//Descri��o : Ponto de Entrada Criado para Trocar S�rie e N�mero da Nota Fiscal no momento 
//do Faturamento de Notas  Fiscais de Sa�da  no Projeto Mercado Livre FULL
//------------------------------------------------------------------------------------------

User Function MSD2520()
	
	If ExistBlock("ADMSD2520")
		ExecBlock("ADMSD2520", .F., .F.)
	EndIf
    
Return
