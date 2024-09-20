#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F200PORT
O ponto de entrada F200PORT é utilizado para definir o banco a ser utilizado na baixa do título no retorno CNAB a Receber
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 19/09/2024
@return logical, .T. or .F.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6070980
/*/
User Function F200PORT()
 
    Local lRet          := .T.
    Local cSantander    := SuperGetMV("DUX_FIN015", ,"033") 
    Local cSofisa       := SuperGetMV("DUX_FIN016", ,"637")

    /*
    .T. = Utiliza o portador do titulo, ignorando o banco do retorno CNAB (padrão caso não exista o ponto de entrada)
    .F. = Utiliza o banco do retorno CNAB
   
    Quando a conta é manipulada no F200VAR e usa exclusivamente a conta do arquivo de retorno.
    Não pode alterar a variavel cConta dos Bancos abaixo
    */
    
    //Santander
    If AllTrim(cBanco) == AllTrim(cSantander)
        lRet := .F.
    EndIf

    //Sofisa
    If AllTrim(cBanco) == AllTrim(cSofisa)
        lRet := .F.
    EndIf

Return(lRet)
