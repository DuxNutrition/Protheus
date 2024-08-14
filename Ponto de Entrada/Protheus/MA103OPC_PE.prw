#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MA103OPC
Ponto de Entrada utilizado para adicionar itens no menu
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 14/08/2024
@return logical, Retorna o menu adicionado
/*/
User Function MA103OPC()

    Local aRet := {}
    
    If Len(aRotina[1]) == 4
		 aadd(aRotina,{"Etiqueta Dux" ,"U_ZESTF002('SF1')"  , 0 ,   6   })
	Else
        aadd(aRotina,{"Etiqueta Dux" ,"U_ZESTF002('SF1')"   ,0 ,6 ,0 , })
	EndIf
    
Return aRet
