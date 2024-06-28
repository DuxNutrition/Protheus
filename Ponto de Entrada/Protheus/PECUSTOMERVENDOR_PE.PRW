#include "protheus.ch"
#include "parmtype.ch"
#include 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CUSTOMERVENDOR
Ponto de entrada para incluir automaticamente um  item contábil ou
conta contábil para cada fornecedor cadastrado.

@type function
@author CES J.Donizete
@since 02/2022
@version P12.1.33
@Return
/*/
//-------------------------------------------------------------------

User Function CUSTOMERVENDOR()

Local oObj
Local nOper
Local aParam := PARAMIXB
Local cIdPonto := ""
Local cIdModel := ""
Local xRet     := .t.
Local cMsg     := ""

// Usado pelo ERP+
Local cCtaFor := ""
Local cCtaAdt := ""
Local cPrefNor:= ""
Local cPrefAdt:= ""
// Variáveis para o plano referencial
Local cEntRef := ""
Local cCodPla := ""
Local cVersao := ""
Local cRefNor := ""
Local cRefAdt := ""
Local cCusto  := ""

If aParam <> NIL

    oObj := aParam[1]
    nOper := oObj:GetOperation()

    cIdPonto := aParam[2]
    cIdModel := aParam[3]

    If cIdPonto == "FORMCOMMITTTSPOS"

        If nOper == MODEL_OPERATION_INSERT

            cEntRef := ""
            cCodPla := ""
            cVersao := ""
            cCusto  := ""

            If SA2->A2_EST=="EX"
                cPrefNor := ""
                cRefNor  := ""
                cPrefAdt := ""
                cRefAdt  := ""
            else
                cPrefNor := ""
                cRefNor  := ""
                cPrefAdt := ""
                cRefAdt  := ""
            EndIf

            // Conta do fornecedor
            cCtaFor :=  cPrefNor + SA2->A2_COD+SA2->A2_LOJA

            // Conta de adiantamento (caso necessário)
            cCtaAdt :=  cPrefAdt + SA2->A2_COD+SA2->A2_LOJA

            If Empty(SA2->A2_CONTA)

                If ExistBlock("TIPAC018",.F.,.T.) .And. !Empty(cCtaFor)
                    // Criação de conta do fornecedor
                    U_TIPAC018(cCtaFor,M->A2_NOME,2,3,cRefNor,cEntRef,cCodPla,cVersao,cCusto) //Código, Desc.Conta, 1-Cliente/2-Fornecedor,3-Inclusão/5-Exclusão,cCtaRef,cEntRef,cCodPla,cVersao,cCusto
                EndIf

                If ExistBlock("TIPAC018",.F.,.T.) .And. !Empty(cCtaAdt)
                    // Criação de conta do fornecedor (adiantamento)
                    U_TIPAC018(cCtaAdt,SA2->A2_NOME,2,3,cRefAdt,cEntRef,cCodPla,cVersao,cCusto) //Código, Desc.Conta, 1-Cliente/2-Fornecedor,3-Inclusão/5-Exclusão,cCtaRef,cEntRef,cCodPla,cVersao,cCusto
                EndIf

                If SuperGetMV("ZZ_TPCTA", .f., 0)==1 //Criação é por conta contábil
                    SA2->A2_CONTA := cCtaFor // Atualiza o cadastro
                    If SA2->(FieldPos("A2_ZZCTAAD")) > 0
                        If Empty(SA2->A2_ZZCTAAD)
                            SA2->A2_ZZCTAAD := cCtaAdt
                        EndIf
                    EndIf
                EndIf
            EndIf
        ElseIf nOper == MODEL_OPERATION_DELETE
            If !Empty(SA2->A2_CONTA)
                cMsg := "A exclusao de conta contabil deve ser manual. Avisar o contador para excluir a(s) conta(s):" + (chr(13) + chr(10))
                cMsg += SA2->A2_CONTA
                MsgAlert(cMsg, "Exclusao de Fornecedor")
            EndIf
        EndIf
    EndIf
EndIf

Return xRet
