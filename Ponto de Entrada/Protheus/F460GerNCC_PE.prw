#include "protheus.ch"

//Ponto de Entrada que permite definir se a rotina FINA460 deve ou não gerar NCC. O funcionamento padrão é gerar NCC.

     
User Function F460GerNCC()
    Local lRet := .F. //Se verdadeiro (.T.), gera o registro de NCC. Se falso (.F.), não gera o registro de NCC.
Return lRet