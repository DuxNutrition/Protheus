#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F200VAR
O ponto de entrada F200VAR possibilita manipular as informações (variáveis) no retorno do Cnab a Receber (FINA200). 
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 19/09/2024
@return array, retorno do array
/*/
User Function F200VAR()
 
    Local aDados        := PARAMIXB
    Local aArea         := GetArea()
    Local cSantander    := SuperGetMV("DUX_FIN015", ,"033") 
    Local cSofisa       := SuperGetMV("DUX_FIN016", ,"637") 
    Local cLinhaTxt     := PARAMIXB[1][16]

    /*Dados[1] = Número do Título    | Variavel de origem: cNumTit
    aDados[2] = Data da Baixa       | Variavel de origem: dBaixa
    aDados[3] = Tipo do Título      | Variavel de origem: cTipo
    aDados[4] = Nosso Número        | Variavel de origem: cNsNum
    aDados[5] = Valor da Despesa    | Variavel de origem: nDespes
    aDados[6] = Valor do Desconto   | Variavel de origem: nDescont
    aDados[7] = Valor do Abatimento | Variavel de origem: nAbatim
    aDados[8] = Valor Recebido      | Variavel de origem: nValRec
    aDados[9] = Juros               | Variavel de origem: nJuros
    aDados[10] = Multa              | Variavel de origem: nMulta
    aDados[11] = Outras Despesas    | Variavel de origem: nOutrDesp
    aDados[12] = Valor do Credito   | Variavel de origem: nValCc
    aDados[13] = Data do Credito    | Variavel de origem: dDataCred
    aDados[14] = Ocorrência         | Variavel de origem: cOcorr
    aDados[15] = Motivo do banco    | Variavel de origem: cMotBan
    aDados[16] = Linha Inteira      | Variavel de origem: xBuffer
    aDados[17] = Data de Vencimento | Variavel de origem: dDtVc*/
        
    If !Empty(cLinhaTxt) //Precisa ter conteudo na linha        
        
        If AllTrim(cBanco) == AllTrim(cSantander) //Altera somente quando é o banco é Santander.
          
            If SubString(cLinhaTxt,014,001) == "T" //Executa somente para segmento T
    
                If AllTrim(SubString(cLinhaTxt,184,010)) == "0130044887"
                    cAgencia    := PadR("2050", TamSx3('A6_AGENCIA') [1])
                    cConta      := "13004488"
                ElseIf AllTrim(SubString(cLinhaTxt,184,010)) == "0290005221"
                    cAgencia    := PadR("2050", TamSx3('A6_AGENCIA') [1])
                    cConta      := "29000522"
                ElseIf AllTrim(SubString(cLinhaTxt,184,010)) == "0290005427"
                    cAgencia    := PadR("2050", TamSx3('A6_AGENCIA') [1])
                    cConta      := "29000542"
                ElseIf AllTrim(SubString(cLinhaTxt,184,010)) == "0290005764"
                    cAgencia    := PadR("2050", TamSx3('A6_AGENCIA') [1])
                    cConta      := "290005764"
                EndIf
                
            EndIf
        
        ElseIf AllTrim(cBanco) == AllTrim(cSofisa) //Altera somente quando é o banco é Sofisa.
          
            If SubString(cLinhaTxt,001,001) == "1" //Executa somente para segmento T
    
                If  AllTrim(SubString(cLinhaTxt,108,001)) == "1"     //Cobranca Simples
                    cAgencia    := PadR("0001", TamSx3('A6_AGENCIA') [1])
                    cConta      := "0003033653"
                ElseIf AllTrim(SubString(cLinhaTxt,184,001)) == "2" //Cobranca Vinculada
                    cAgencia    := PadR("0001", TamSx3('A6_AGENCIA') [1])
                    cConta      := "0003033661"
                ElseIf AllTrim(SubString(cLinhaTxt,184,001)) == "3" //Cobranca Caucionada
                    cAgencia    := cAgencia
                    cConta      := cConta
                ElseIf AllTrim(SubString(cLinhaTxt,184,001)) == "4" //Titulo Descontado
                    cAgencia    := cAgencia
                    cConta      := cConta
                EndIf
                
            EndIf

        EndIf

    EndIf
     
    RestArea(aArea)
 
Return(aDados)
