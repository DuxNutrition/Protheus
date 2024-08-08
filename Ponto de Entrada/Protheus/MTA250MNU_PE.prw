#INCLUDE "TOTVS.CH"
 
/*/{Protheus.doc} MTA250MNU
O ponto de entrada MTA250MNU é executado para adicionar botões ao Menu Principal do Apontamento de Produção Simples. (MATA250)
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
/*/
User Function MTA250MNU()

    aadd(aRotina,{"Etiqueta Dux", "U_ZESTF002('SD3')"   , 0 ,   6   })
 
Return()
