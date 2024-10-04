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

User Function M461SER()

	Local aDados	:= {}
	//// incluido uma valida��o de chamada, pois ele entrava mesmo sem ser solicitado.
	if FWIsInCallStack("ADM461SER")
		If ( ExistBlock("ADM461SER") )
			aDados  := ExecBlock("ADM461SER",.T.,.T.)
			cSerie  := aDados[1]
			cNumero := aDados[2]
		EndIf
	endif 
	//���������������������������������������������������������������������������Ŀ
	//� Customiza��o com variavel private para altera��o de DOC DUXFATB       �
	//�����������������������������������������������������������������������������
	if FWIsInCallStack("U_DuxFatB")
        cNumero := _DxNfc
    endif 

Return
