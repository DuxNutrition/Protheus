#Include "Protheus.ch"

/*/{Protheus.doc} BUSCANF
//TODO Descrição Função para buscar a Chave NFE da Nota Fiscasl e gravar no bloco Y52 Mod.2
[DUX] Compilado por Paulo Rodrigues dia 07/12/2023, solicitado por Erika Lessa. 
@author Eduardo Pereira
@since 09/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

User Function BUSCANF()

Local cNFisc := "" 

dbSelectArea("SF2")
dbSetOrder(1)	// F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO  
If ( dbseek(xFilial("SF2") + SE1->E1_NUM + SE1->E1_PREFIXO) )   
	cNFisc := SF2->F2_CHVNFE
Else
    cNFisc := Replicate("0", 44)   
EndIf                                              

SF2->( dbCloseArea() )

Return cNFisc
