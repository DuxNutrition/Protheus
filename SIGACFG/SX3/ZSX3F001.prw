#Include 'Protheus.ch'

/*/{Protheus.doc} ZSX3F001
Função para validar o When dos campos customizado
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 13/09/2024
@return logical, .T. Or .F.
/*/
User Function ZSX3F001()

Local lRet := .T.

If !Empty(M->C5_XPEDLV) .Or. !Empty(M->C5_XIDSFOR) .Or. !Empty(M->C5_ZZNUMPJ)
    lRet := .F.
EndIf

Return(lRet)
