#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

User Function M460ICM()

    Local nCont     := 0
    Local nSubtrai  := 0

    //_ALIQICM      := 10
    //_BASEICM      := 100
    //_VALICM       := 10
    //_QUANTIDADE   := 0
    //_FRETE        := 0
    //_VALICMFRETE  := 0
    //_DESCONTO     := 0
    //_VALRATICM    := 0
    //_ACRESFIN     := 0 

    If FWIsInCallStack("U_ZFATF008")
  
        For nCont := 1 To Len(_aImpICMS)

            If AllTrim(SC9->C9_ITEM) == AllTrim(_aImpICMS[nCont][01]) .And. AllTrim(SC9->C9_PRODUTO) == AllTrim(_aImpICMS[nCont][02])

                If ( _VALICM > 0 .And. Val(_aImpICMS[nCont][05]) > 0 ) // Só valida se o icms escriturado e xml são maiores que 0

                    If (_VALICM - Val(_aImpICMS[nCont][05])) < 0
                        nSubtrai := (_VALICM - Val(_aImpICMS[nCont][05])) * -1
                    Else
                        nSubtrai := (_VALICM - Val(_aImpICMS[nCont][05]))
                    EndIf

                    If nSubtrai < 1 //NoRound(_VALICM,1) <> NoRound(Val(_aImpICMS[nCont][05]),1) 

                        _BASEICM := Val(_aImpICMS[nCont][03]) //Base do Icms - Xml InfraCommerce
                        _ALIQICM := Val(_aImpICMS[nCont][04]) //Aliquota do Icms - Xml InfraCommerce
                        _VALICM  := Val(_aImpICMS[nCont][05]) //Valor do Icms - Xml InfraCommerce

                    EndIf
                EndIf
            EndIf
		Next
    EndIf

Return()
