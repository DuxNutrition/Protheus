#INCLUDE "PROTHEUS.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} M410AGRV
    Chamada ponto de entrada correção de financeiro -> DDA 341
    @type  Function
    @author Allan R
    @since 17/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

    User Function  FA050GRV()
    Local cCodBar := ""
    Local cFormPag := "30"

    if LEFT(SE2->E2_CODBAR,3) == "341"
        Reclock("SE2",.F.)
            SE2->E2_FORMPAG := cFormPag
        SE2->(MsUnlock())
    endif 

    Return()
