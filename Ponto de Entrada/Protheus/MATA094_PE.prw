#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function MATA094()

    Local aParam        := PARAMIXB
    Local xRet          := .T.
    Local oObj          := ""
    Local cIdPonto      := ""
    Local cIdModel      := ""
    Local lIsGrid       := .F.
    Local nLinha        := 0
    Local nQtdLinhas    := 0
    Local cMsg          := ""
    Local nOp
    Local oFieldSCR 
    Local oView

    If (aParam <> NIL)
        
        oObj        := aParam[1]
        cIdPonto    := aParam[2]
        cIdModel    := aParam[3]
        lIsGrid     := (Len(aParam) > 3)

        nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

        oFieldSCR	:= oObj:GetModel("FieldSCR")

        If (cIdPonto == "MODELPOS")
            /* 
            cMsg := "Chamada na validação total do modelo." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            IF nOp == 3
                Alert('inclusão')
            ENDIF

            xRet := MsgYesNo(cMsg + "Continua?")
            */
        ElseIf (cIdPonto == "MODELVLDACTIVE")
            /*
            cMsg := "Chamada na ativação do modelo de dados."

            xRet := MsgYesNo(cMsg + "Continua?")
            */

        ElseIf (cIdPonto == "FORMPOS")
            /*oObj
            cMsg := "Chamada na validação total do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF

            If (lIsGrid == .T.)
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            Else
                cMsg += "É um FORMFIELD" + CRLF
            EndIf

            xRet := MsgYesNo(cMsg + "Continua?")
            */
        ElseIf (cIdPonto =="FORMLINEPRE")
            /*
            If aParam[5] =="DELETE"
                cMsg := "Chamada na pré validação da linha do formulário." + CRLF
                cMsg += "Onde esta se tentando deletar a linha" + CRLF
                cMsg += "ID " + cIdModel + CRLF
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF

                xRet := MsgYesNo(cMsg + " Continua?")
            EndIf
            */
        ElseIf (cIdPonto =="FORMLINEPOS")
            /*
            cMsg := "Chamada na validação da linha do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
            cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF

            xRet := MsgYesNo(cMsg + " Continua?")
            */
        ElseIf (cIdPonto =="MODELCOMMITTTS")
            //MsgInfo("Chamada após a gravação total do modelo e dentro da transação do MVC.")
        ElseIf (cIdPonto =="MODELCOMMITNTTS")
            //MsgInfo("Chamada após a gravação total do modelo e fora da transação do MVC.")
        ElseIf (cIdPonto =="FORMCOMMITTTSPRE")
            //MsgInfo("Chamada após a gravação da tabela do formulário.")
        ElseIf (cIdPonto =="FORMCOMMITTTSPOS")
            //MsgInfo("Chamada após a gravação da tabela do formulário.")
        ElseIf (cIdPonto =="MODELCANCEL")
            /*
            cMsg := "Deseja realmente sair?"

            xRet := MsgYesNo(cMsg)
            */
        ElseIf (cIdPonto =="BUTTONBAR")
            //xRet := {{"Botão", "BOTÃO", {|| MsgInfo("Buttonbar")}}}

            oView   := FWViewActive()

            oFieldSCR:LoadValue("CR_XCODPG" , U_DUXAISCR("CR_XCODPG")   )
            oFieldSCR:LoadValue("CR_XDESPG" , U_DUXAISCR("CR_XDESPG")   )
            oFieldSCR:LoadValue("CR_XCODFOR", U_DUXAISCR("CR_XCODFOR")  )
            oFieldSCR:LoadValue("CR_XLJFOR" , U_DUXAISCR("CR_XLJFOR")   )
            oFieldSCR:LoadValue("CR_XNOMFOR", U_DUXAISCR("CR_XNOMFOR")  )

            oView:Refresh('FieldSCR')
        EndIf
    EndIf

Return (xRet)
