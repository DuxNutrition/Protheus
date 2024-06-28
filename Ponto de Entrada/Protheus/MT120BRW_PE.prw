#INCLUDE "PROTHEUS.CH"

User Function MT120BRW()

    AAdd( aRotina, { "Imp. Pedido Compra", "U_ROGR001", 4, 0, 4 } )

    if ExistBlock("DUACOM01",.F.,.T.)
        AADD(aRotina, {"Alt. Data Pedido de Compra", "U_DUACOM01", 4, 0, 4})
    endif
Return
