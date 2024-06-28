#include "protheus.ch"
#include "parmtype.ch"
#include 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980
Ponto de entrada para incluir automaticamente um  item contábil para
cada cliente cadastrado.

@type function
@author Jose Donizete R.Silva
@since 02/2022
@version P12.1.33
@Return
/*/
//-------------------------------------------------------------------

User Function CRMA980()

Local oObj
Local nOper
Local aParam := PARAMIXB
Local cIdPonto := ""
Local cIdModel := ""
Local xRet     := .t.
Local cMsg     := ""

// Usado pelo ERP+
// Observação: para este PE funcionar alterar o parâmetro MV_MVCSA1 com .T.
Local cCtaCli := ""
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

            If SA1->A1_EST=="EX"
                cPrefNor := ""
                cRefNor  := ""
                cPrefAdt := ""
                cRefAdt  := "2"
            else
                cPrefNor := ""
                cRefNor  := ""
                cPrefAdt := ""
                cRefAdt  := ""
            EndIf

            // Conta do cliente
            cCtaCli :=  cPrefNor + SA1->A1_COD+SA1->A1_LOJA

            // Conta de adiantamento (caso necessário)
            cCtaAdt :=  cPrefAdt + SA1->A1_COD+SA1->A1_LOJA

            If Empty(SA1->A1_CONTA)

                If ExistBlock("TIPAC018",.F.,.T.) .And. !Empty(cCtaCli)
                    // Criação de conta do cliente
                    U_TIPAC018(cCtaCli,SA1->A1_NOME,1,3,cRefNor,cEntRef,cCodPla,cVersao,cCusto) //Código, Desc.Conta, 1-Cliente/2-Fornecedor,3-Inclusão/5-Exclusão,cCtaRef,cEntRef,cCodPla,cVersao,cCusto
                EndIf

                If ExistBlock("TIPAC018",.F.,.T.) .And. !Empty(cCtaAdt)
                    // Criação de conta do cliente (adiantamento)
                    U_TIPAC018(cCtaAdt,SA1->A1_NOME,1,3,cRefAdt,cEntRef,cCodPla,cVersao,cCusto) //Código, Desc.Conta, 1-Cliente/2-Fornecedor,3-Inclusão/5-Exclusão,cCtaRef,cEntRef,cCodPla,cVersao,cCusto
                EndIf

                If SuperGetMV("ZZ_TPCTA", .f., 0)==1 //Criação é por conta contábil
                    SA1->A1_CONTA := cCtaCli // Atualiza o cadastro
                    If SA1->(FieldPos("A1_ZZCTAAD")) > 0
                        If Empty(SA1->A1_ZZCTAAD)
                            SA1->A1_ZZCTAAD := cCtaAdt
                        EndIf
                    EndIf
                EndIf
            EndIf
        ElseIf nOper == MODEL_OPERATION_DELETE
            If !Empty(SA1->A1_CONTA)
                cMsg := "A exclusao de conta contabil deve ser manual. Avisar o contador para excluir a(s) conta(s):" + (chr(13) + chr(10))
                cMsg += SA1->A1_CONTA
                MsgAlert(cMsg, "Exclusao de Cliente")
            EndIf
        EndIf
    EndIf
EndIf

Return xRet
