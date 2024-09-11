#Include "Protheus.ch"
#Include "RESTFUL.ch"
#Include "tbiconn.ch"
#include "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0003 ³ Autor ³  Allan Rabelo         ³ Data ³ 09/09/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GET titulos a receber vencidos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL ZWSR003 DESCRIPTION "Cadastro de produtos"
    WSMETHOD GET  DESCRIPTION "ZWSR003 GET PRODUTO" WSSYNTAX "ZWS003GET"
END WSRESTFUL

WSMETHOD GET WSSERVICE ZWSR003
    Local _aRet             := ""
    Local cBody             := ""
    Local _cAuthorization   := ""
    Local _cEmpFil          := ""
    Local _cUserPar         := ""
    Local _cPassPar         := ""
    Local jBody             As JSON
    Local _cEmpresa         := ""
    Local _cFilial          := ""
    Local _cLogin           := ""
    Local _nPos

    Begin Sequence

        Conout("ZWSR003 - Inicio "+DtoC(date())+" "+Time())

        Self:SetContentType("application/cJson")

        cBody           := ::GetContent()
        jBody           := JSONObject():New()
        _cAuthorization := Self:GetHeader('Authorization')
        _cEmpFil 		:= Self:GetHeader("tenantid", .F.)

        // PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"


        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_RES01", , "allan.rabelo"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_RES02", , "123456"	))	        // Senha para autenticao no WS
        _cLogin     := _cUserPar+":"+_cPassPar


        _aRet := ZVALREQ(_cLogin,_cAuthorization,_cEmpFil)


    End Sequence

    If Empty(_aRet)
        _oJson := JsonObject():new()
        _oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))
        jBody := ZTITGET(@_oJson, _cEmpFil)
        Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
        FwFreeObj(jBody)
    Else
        jBody["Status"]    := _aRet
        Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
        FwFreeObj(jBody)
    Endif

    Conout("ZWSR003 - Fim "+DtoC(date())+" "+Time())
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0003 ³ Autor ³  Allan Rabelo         ³ Data ³ 09/09/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para encontrar empresa e user                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIN                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ZVALREQ(_cLogin,_cAuthorization,_cEmpFil)
    Local _cEmpresa         := ""
    Local _cFilial          := ""
    Local _nPos
    Local _aRet             := ""

    //  PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"

    If AllTrim(_cLogin) <> AllTrim(Decode64(StrTran(_cAuthorization, "Basic ", "")))
        _aRet := {302,"Usuario ou senha Nao Autorizado "}
        Break
    EndIf

    _nPos := At(",", _cEmpFil)
    If _nPos <= 0
        _aRet := {302,"Tenanid nao informado ."}
        Break
    EndIf

    _cEmpresa := SubsTr(_cEmpFil,1,_nPos-1)
    _cFilial  := SubsTr(_cEmpFil,_nPos+1)

    If Empty(_cEmpresa)
        _aRet := {302,"Empresa nao encontrada."}
        Break
    Endif

    If Empty(_cFilial)
        _aRet := {302,"Filial nao encontrada."}
        Break
    Endif

    //Verifica a existencia empresa, para não ficar retornando erro 5, valida se a tabela esta abertar
    If Select("SM0") > 0
        SM0->(DbSetOrder(1))  //M0_CODIGO+M0_CODFIL
        If !SM0->(DbSeek(_cEmpresa+_cFilial))
            _aRet := {302,"Dados da Empresa inconsistente"}
            Break
        Endif
    Endif

    //Tratar abertura da empresa conforme enviado no parametro
    If cEmpAnt <> _cEmpresa .or. cFilAnt <> _cFilial
        RpcClearEnv()
        RPCSetType(3)
        If !RpcSetEnv(_cEmpresa,_cFilial,,,,GetEnvServer(),{ })
            _aRet := {302,"Nao foi possivel acessar ambiente"}
            Break
        Endif
    EndIf


Return(_aRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0003 ³ Autor ³  Allan Rabelo         ³ Data ³ 09/09/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Titulos a receber vencimento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Encontrar titulos financeiro                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ZTITGET(_oJson, _cEmpFil)
    Local aArea := GetArea()
    Local aCabec
    Local aItens
    Local aTitulos
    Local aTit
    Local jBody     as JSON
    Local cTipoTit := SuperGetMv("DUX_TPTIT",.F.,"'NF'")
    Local cQrySE1	:= ""
    Local nAux := 0
    Local aCli
    Local lRet := .T.


    aCabec  := {}
    aItens  := {}
    aImpItem := {}
    JBody   := JSONObject():New()
    //
    jBody["Status"]   := {}
    aTitulos := JsonObject():New()

    cQrySE1 := " SELECT E1_NUM AS NUM, E1_TIPO AS TIPO, E1_VALOR AS VAL , E1_PARCELA AS PARCELA , E1_VENCREA AS VENCIMENTO , E1_CLIENTE AS CLIENTE , E1_LOJA AS LOJA , E1_STATUS AS STATUSX,  "
    cQrySE1 += " SF2.F2_CHVNFE AS CHAVE, SF2.F2_DOC AS DOCNF,  "
    cQrySE1 += " SA1.A1_PESSOA AS SA1PESSOA, SA1.A1_CGC AS SA1CGC, SA1.A1_COD AS SA1COD, SA1.A1_LOJA AS SA1LOJA, SA1.A1_NOME AS SA1NOME, SA1.A1_ZZESTAB AS SA1ESTAB,     "
    cQrySE1 += " SA1.A1_ENDCOB AS SA1ENDCOB, SA1.A1_EMAIL AS SA1EMAIL, SA1.A1_END AS SA1END, SA1.A1_BAIRRO AS SA1BAIRRO , SA1.A1_EST AS SA1EST , SA1.A1_CEP AS SA1CEP , SA1.A1_TEL AS SA1TEL  "
    cQrySE1 += " FROM "+Retsqlname("SE1")+" AS SE1 "
    cQrySE1 += " INNER JOIN "+Retsqlname("SF2")+" AS SF2 ON SE1.E1_NUM = SF2.F2_DUPL AND SE1.E1_FILIAL = SF2.F2_FILIAL AND SF2.D_E_L_E_T_ = '' "
    cQrySE1 += " INNER JOIN "+Retsqlname("SA1")+" AS SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA "
    cQrySE1 += " WHERE SA1.A1_PESSOA = 'J' AND SE1.E1_TIPO IN ("+cTipoTit+") AND SE1.E1_SALDO <> 0  AND SE1.D_E_L_E_T_ = '' "
    cQrySE1 += " ORDER BY E1_NUM, E1_PARCELA, E1_CLIENTE , E1_LOJA"
    /////////// Verifico qual é o processo ////////////////
    ////////////// Verifico se a tabela já se encontra aberta e fecho ////////////
    IF SELECT("TMPC1") > 0
        TMPC1->(DbCloseArea())
    ENDIF

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQrySE1),"TMPC1",.F.,.T.)
    ///////////// Aponto dados para o JSON /////////////
    aTitulos["empresa"] := cEmpAnt
    aTitulos["filial"] := cFilAnt
    aTitulos["Item"] := {}
    DbSelectArea('SE1')
    SE1->(dbSetOrder(1))

    While !TMPC1->(eof())
        aTit := {}
        aTit := JSONObject():New()
        if lRet
            aTit["tipocliente"]              := TMPC1->SA1PESSOA
            aTit["cnpjcpf"]                  := TMPC1->SA1CGC
            aTit["codigocliente"]            := TMPC1->SA1COD
            aTit["lojacliente"]              := TMPC1->SA1LOJA
            aTit["nome"]                     := TMPC1->SA1NOME
            aTit["numcontrato"]              := TMPC1->SA1COD+TMPC1->SA1LOJA
            aTit["titulo"]                   := TMPC1->NUM
            aTit["parcela"]                  := TMPC1->PARCELA
            aTit["vencimento"]               := TMPC1->VENCIMENTO
            aTit["valor"]                    := TMPC1->VAL
            aTit["tipo"]                     := TMPC1->TIPO
            if !Empty(TMPC1->SA1ESTAB)
                aTit["cartcontr"]                 := TMPC1->SA1ESTAB
            else
                aTit["cartcontr"]                 := "Geral"
            endif
            aTit["endcob"]                   := TMPC1->SA1ENDCOB
            aTit["email"]                    := TMPC1->SA1EMAIL
            aTit["end"]                      := TMPC1->SA1END
            aTit["bairro"]                   := TMPC1->SA1BAIRRO
            aTit["estado"]                   := TMPC1->SA1EST
            aTit["cep"]                      := TMPC1->SA1CEP
            aTit["telefone"]                 := TMPC1->SA1TEL
            aTit["boletoapi"]                := alltrim(TMPC1->DOCNF)+alltrim(TMPC1->SA1COD)+alltrim(TMPC1->SA1LOJA)+alltrim(TMPC1->NUM)+alltrim(TMPC1->PARCELA)+".pdf"
            aTit["nfapi"]                    := TMPC1->CHAVE
            aTit["statusparc"]               := TMPC1->STATUSX
        endif
        aAdd(aTitulos["Item"], aTit)
        nAux := nAux + 1
        TMPC1->(DBSkip())
    Enddo
    aTitulos["Total"] := cValToChar(nAux)
    RestArea(aArea)
Return(aTitulos)
