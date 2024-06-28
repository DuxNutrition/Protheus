#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'


User Function NFEMNUCC()
	Local aArea := GetArea()

	
		//Adicionando função de vincular
		aadd(aRotina,{"Transmissão em Lote","U_CCeLote", 0 , 3, 0 , Nil})

	

	RestArea(aArea)
Return
