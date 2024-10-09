#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} MTA094RO
O Ponto de Entrada MTA094RO, localizado na rotina de Liberação de Documento, permite adicionar opções no item Outras Ações.
@See https://tdn.totvs.com/display/public/PROT/TTLFI2_COM_DT_Ponto_de_Entrada_MTA094RO
@type function 
@author:Jedielson Rodrigues
@since 04/10/2024
@return 
/*/

User Function MTA094RO()

Local aRotina := PARAMIXB[1]
Local aArea   := FwGetArea()

    Aadd(aRotina,{"Rejeitar Contrato", "U_ZFATF005(SCR->CR_TIPO)", 0, 4, 0, NIL})
   
FWRestArea(aArea)

Return (aRotina)

