#include "totvs.ch"

/*/{Protheus.doc} FISTRFNFE
Ponto de entrada que inclui mais opções
de rotinas na rotina SPEDNFE.
@type  Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
User Function FISTRFNFE()

    Local aArea := GetArea()
    Local aSubMenu := {}
 
    //Adicionando opções no primeiro submenu
    Aadd(aSubMenu,{"Danfe Transp A4"     ,"U_ZFATF002(1)",0,3,0,nil})
    Aadd(aSubMenu,{"Danfe Transp Zebra"  ,"U_ZFATF002(2)",0,3,0,nil})

    //Adicionando uma função no menu principal e adicionando o submenu
    aAdd(aRotina, {"Danfe Transportadora",       aSubMenu,      0, 2, 0, NIL})
     
    RestArea(aArea)

Return()


