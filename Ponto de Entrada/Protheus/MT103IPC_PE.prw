#include "rwmake.ch"

/*/{protheus.doc} MT103IPC 
Ponto de entrada para atualiza campos customizados no Documento de Entrada. 
Programa original cedido pelo R�gis e transferido para o fonte TIPAC012.PRW

@Author R�gis Ferreira, ajustado por Donizete.
@since 18/05/19
/*/
User Function MT103IPC

// Valida��es Universais TOTVS IP
If ExistBlock("TIPAC012",.F.,.T.)
    lRet := ExecBlock("TIPAC012",.F.,.T.,PARAMIXB)
Endif

Return
