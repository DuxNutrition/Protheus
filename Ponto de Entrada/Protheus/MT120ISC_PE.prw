#INCLUDE "totvs.ch"

/*
{Protheus.doc} MT120ISC
Function A120MovCampos responsável pela carga das solicitações de compras 
ou Contratos de Parceria das tabelas SC1 - SCs e SC3 - Contratos parceria 
para o pedido de compras - tabela SC7  para o Pedido de Compras / Autorização de Entrega
*
* PE			:	MT120ISC
* Autor			:	CSA
* Data			:	23/01/2023
* Descricao		:	
*/


User Function MT120ISC()
  
  Local aArea    := GetArea()
  Local aAreaSC1 := SC1->(GetArea())
  Local aAreaSC7 := SC7->(GetArea())
  Local nFornece := GDFIELDPOS("C7_ZZFORNE")
  Local nLojaFor := GDFIELDPOS("C7_ZZLOJA")
 

  If nFornece <> 0
    aCols[ n , nFornece ] := SC1->C1_ZZFORN // Alterado por Paulo Rafael 13.04.2023. Original: SC1->C1_ZZFORNE
  Endif

  If nLojaFor <> 0  
      aCols[ n , nLojaFor ] := SC1->C1_ZZLOJA
  Endif

  RestArea(aAreaSC7)
  RestArea(aAreaSC1)
  RestArea(aArea)

Return
