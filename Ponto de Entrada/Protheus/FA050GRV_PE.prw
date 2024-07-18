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
    Local cFormPag := superGetMv("DUX_FIN01",.T.,"30")
    Local cBanco := SuperGetMV("DUX_FIN02",.T.,"341")

    if LEFT(SE2->E2_CODBAR,3) $ Alltrim(cBanco)
        Reclock("SE2",.F.)
            SE2->E2_FORMPAG := Alltrim(cFormPag)
        SE2->(MsUnlock())
    endif 

    Return()
