#include "rwmake.ch"

/*/{protheus.doc} MT103IPC 
Ponto de entrada para atualiza campos customizados no Documento de Entrada. 
Programa original cedido pelo Régis e transferido para o fonte TIPAC012.PRW

@Author Régis Ferreira, ajustado por Donizete.
@since 18/05/19
/*/
User Function MT103IPC

// Validações Universais TOTVS IP
If ExistBlock("TIPAC012",.F.,.T.)
    lRet := ExecBlock("TIPAC012",.F.,.T.,PARAMIXB)
Endif

Return
