#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} FINA885M
Ponto de entrada MVC para validar o cadastro da chave Pix.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 23/08/2024
@return logical, retorno do paramixb
/*/
User Function FINA885M()

Local aParam        := PARAMIXB
Local xRet          := .T.
Local oObj          := NIL
Local cIdPonto      := ""
Local cIdModel      := ""
Local cCodigo       := ""
Local cLoja         := ""
Local cStatus       := ""
Local nAtual        := 0
Local nOpc          := 0
Local cFormaPgt     := AllTrim( SuperGetMv( "DUXFIN008"	, , "45"	) )
Local aArea         := GetArea()
Local aAreaSA2      := SA2->(GetArea())

If aParam <> NIL

    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]

    nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

    oFieldF72   := oObj:GetModel('FORDETAIL')
    

    If cIdPonto == "MODELPOS"

        cCodigo := FWFldGet("F72_COD")
        cLoja   := FWFldGet("F72_LOJA")

        For nAtual := 1 To oFieldF72:Length()

            oFieldF72:GoLine(nAtual)

            If !(oFieldF72:IsDeleted()) .And. oFieldF72:GetValue('F72_ACTIVE') == "1"       //Linha Ativa e Pix Principal
                cStatus += "A|"
            ElseIf oFieldF72:IsDeleted() .And. oFieldF72:GetValue('F72_ACTIVE') == "1"      //Linha deletada e Pix Principal
                cStatus += "B|"
            ElseIf oFieldF72:IsDeleted() .And. oFieldF72:GetValue('F72_ACTIVE') == "2"      //Linha deletada e não é Pix Princiapal
                cStatus += "C|"
            ElseIf !(oFieldF72:IsDeleted()) .And. oFieldF72:GetValue('F72_ACTIVE') == "2"   //Linha Ativa e não é Pix Principal
                cStatus += "C|"
            EndIf 

        Next

        If "A" $ AllTrim(cStatus) //Pix Ativo e a linha não esta deletada

            SA2->(DbSetOrder(1))
            If SA2->( DbSeek( FwxFilial("SA2")+cCodigo+cLoja ) )

                If !( SA2->A2_FORMPAG == cFormaPgt )
                    If  RecLock("SA2",.F.)
                            SA2->A2_FORMPAG := cFormaPgt
                        SA2->(MsUnlock())

                        ApMsgInfo( "[ FINA885M_PE ] - Alterado a forma de Pagamento para: " + cFormaPgt + CRLF +;
                                "Fornecedor: " + cCodigo + CRLF +;
                                "Loja: " + cLoja )
                    EndIf
                    
                EndIf

            EndIf
        
        ElseIf "B" $ AllTrim(cStatus) //Pix Ativo e a linha deletada

            SA2->(DbSetOrder(1))
            If SA2->( DbSeek( FwxFilial("SA2")+cCodigo+cLoja ) )

                If !( SA2->A2_FORMPAG == "" )
                    If  RecLock("SA2",.F.)
                            SA2->A2_FORMPAG := ""
                        SA2->(MsUnlock())

                        ApMsgInfo( "[ FINA885M_PE ] - Alterado a forma de Pagamento para Vazio" + CRLF +;
                                "Fornecedor: " + cCodigo + CRLF +;
                                "Loja: " + cLoja )
                    EndIf

                EndIf
            
            EndIf
            
        ElseIf "C" $ AllTrim(cStatus) //Pix Inativo e a linha não esta deletada

            SA2->(DbSetOrder(1))
            If SA2->( DbSeek( FwxFilial("SA2")+cCodigo+cLoja ) )

                If SA2->A2_FORMPAG == "45"
                    If  RecLock("SA2",.F.)
                            SA2->A2_FORMPAG := ""
                        SA2->(MsUnlock())

                        ApMsgInfo( "[ FINA885M_PE ] - Alterado a forma de Pagamento para Vazio" + CRLF +;
                                "Fornecedor: " + cCodigo + CRLF +;
                                "Loja: " + cLoja )
                    EndIf

                EndIf

            EndIf    
     
        EndIf

    EndIf

EndIf

RestArea(aArea)
RestArea(aAreaSA2)

Return xRet
