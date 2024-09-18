#Include "Protheus.ch"
#Include "RESTFUL.ch"
#Include "tbiconn.ch"
#include "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0001 ³ Autor ³  Allan Rabelo         ³ Data ³ 15/07/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ POST,GET,PUT PRODUTOS PROTHEUS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL ZWSR002 DESCRIPTION "Cadastro de produtos"
    WSMETHOD GET  DESCRIPTION "ZWSR002 GET PRODUTO" WSSYNTAX "ZWS002GET"
    WSMETHOD POST DESCRIPTION "ZWSR002 CAD PRODUTO" WSSYNTAX "ZWS002POST"
    WSMETHOD PUT  DESCRIPTION "ZWSR002 ALT PRODUTO" WSSYNTAX "ZWS002PUT"
END WSRESTFUL

WSMETHOD GET WSSERVICE ZWSR002
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

        Conout("ZWSR002 - Inicio "+DtoC(date())+" "+Time())

        Self:SetContentType("application/cJson")

        cBody           := ::GetContent()
        jBody           := JSONObject():New()
        _cAuthorization := Self:GetHeader('Authorization')
        _cEmpFil 		:= Self:GetHeader("tenantid", .F.)

        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_API001", , "hom.api.produto"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_API002", , "N1R7v668oZ2%"	))	    // Senha para autenticao no WS
        _cLogin     := _cUserPar+":"+_cPassPar

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

    End Sequence

    If Empty(_aRet)
        _oJson := JsonObject():new()
        _oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))
        jBody := ZPRODGET(@_oJson, _cEmpFil)
        Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
        FwFreeObj(jBody)
    Else
        jBody["Status"]    := _aRet
        Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
        FwFreeObj(jBody)
    EndIf

    Conout("ZWSR002 - Fim "+DtoC(date())+" "+Time())
Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0001 ³ Autor ³  Allan Rabelo         ³ Data ³ 07/08/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ POST,GET,PUT PRODUTOS PROTHEUS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PRODUTOS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ZPRODGET(_oJson, _cEmpFil)
    Local aArea := GetArea()
    Local aCabec
    Local aItens
    Local aImpItem := {}
    Local jBody     as JSON

    aCabec  := {}
    aItens  := {}
    aImpItem := {}
    JBody   := JSONObject():New()
    jBody["Status"]   := {}

    DbSelectArea('SB1')
    SB1->(dbSetOrder(1))
    IF (SB1->(dbSeek(FWxFilial("SB1")+PadR(_oJson:GetJsonObject('produto'),TamSX3("B1_COD")[1]))))
        jBody["Status"]             := "200"
        jBody["Message"]            := "OK"
        jBody["cproduto"]           := Alltrim(SB1->B1_COD)
        jBody["cdesc"]              := Alltrim(SB1->B1_DESC)
        jBody["ctipo"]              := Alltrim(SB1->B1_TIPO)
        jBody["cgrupo"]             := Alltrim(SB1->B1_GRUPO)
        jBody["ctamprod"]           := Alltrim(SB1->B1_ZTAM)
        jBody["csabor"]             := Alltrim(SB1->B1_ZSAB)
        jBody["cobsgeral"]          := Alltrim(SB1->B1_ZZOBSGE)
        JBody["cposipi"]            := Alltrim(SB1->B1_POSIPI)
        jBody["cunidade"]           := Alltrim(SB1->B1_UM)
        jBody["carmazempad"]        := Alltrim(SB1->B1_LOCPAD)
        jBody["carmazememp"]        := Alltrim(SB1->B1_ZZPENC)
        jBody["ccodgtin"]           := Alltrim(SB1->B1_CODGTIN)
        jBody["naliqicms"]          := SB1->B1_PICM
        jBody["nipi"]               := SB1->B1_IPI
        jBody["calergenico"]        := Alltrim(SB1->B1_ZALERGE)
        jBody["ctipoalergenico"]    := Alltrim(SB1->B1_ZZALERG)
        JBody["nqtdemb"]            := SB1->B1_QE
        jBody["npesoliquido"]       := SB1->B1_PESO
        jBody["npesobruto"]         := SB1->B1_PESBRU
        jBody["nprazoentrega"]      := SB1->B1_PE
        jBody["ccontacontabil"]     := Alltrim(SB1->B1_CONTA)
        jBody["ccontadspadm"]       := Alltrim(SB1->B1_ZZCTA1)
        JBody["ccontadespcml"]      := Alltrim(SB1->B1_ZZCTA3)
        jBody["ccontacstdiretos"]   := Alltrim(SB1->B1_ZZCTA2)
        jBody["contacstindiretos"]  := Alltrim(SB1->B1_ZZCTA4)
        JBody["corigem"]            := Alltrim(SB1->B1_ORIGEM)
        jBody["ccontrolalote"]      := Alltrim(SB1->B1_RASTRO)
        jBody["cfabricante"]        := Alltrim(SB1->B1_FABRIC)
        jBody["cgrptrib"]           := Alltrim(SB1->B1_GRTRIB)
        jBody["ctipocq"]            := Alltrim(SB1->B1_TIPOCQ)
        jBody["cregraseq"]          := Alltrim(SB1->B1_REGSEQ)
        jBody["cunidadenegocio"]    := Alltrim(SB1->B1_CLVL)
        JBody["ccest"]              := Alltrim(SB1->B1_CEST)
        jBody["cenqipi"]            := Alltrim(SB1->B1_GRPCST)
        jBody["ccodarvcat"]         := Alltrim(SB1->B1_XCATEGO)
        jBody["ccodmarca"]          := Alltrim(SB1->B1_XMARCA)
        jBody["nestabatido"]        := SB1->B1_XESTABA
        jBody["nqtdpcx"]            := SB1->B1_ZQEEXP
        jBody["ccomprasn"]          := Alltrim(SB1->B1_ZZCOM)
        jBody["cintsforce"]         := Alltrim(SB1->B1_XINTSF)
        //   jBody["cean13"]              := Alltrim(SB1->B1_XCODBAR)
    else
        jBody["Status"]             := "400"
        jBody["Message"]            := "Produto não encontrado"
    endif
    RestArea(aArea)
Return (jBody)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0001 ³ Autor ³  Allan Rabelo         ³ Data ³ 18/08/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ POST                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PRODUTOS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD POST WSSERVICE ZWSR002
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

        Conout("ZWSR002 - Inicio "+DtoC(date())+" "+Time())

        Self:SetContentType("application/cJson")

        cBody           := ::GetContent()
        jBody           := JSONObject():New()
        _cAuthorization := Self:GetHeader('Authorization')
        _cEmpFil 		:= Self:GetHeader("tenantid", .F.)

        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_API001", , "hom.api.fluig"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_API002", , "N1R7v668oZ2%"	))	    // Senha para autenticao no WS
        _cLogin     := _cUserPar+":"+_cPassPar


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

    End Sequence

    If Empty(_aRet)
        _oJson := JsonObject():new()
        _oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))
        jBody := ZPRODPOST(@_oJson, _cEmpFil)
        Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
        FwFreeObj(jBody)
    Else
        jBody["Status"]    := _aRet
        Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
        FwFreeObj(jBody)
    EndIf

    Conout("ZWSR002 - Fim "+DtoC(date())+" "+Time())
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0001 ³ Autor ³  Allan Rabelo         ³ Data ³ 07/08/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ POST                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PRODUTOS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ZPRODPOST(_oJson, _cEmpFil)
    Local aArea := GetArea()
    Local oJson := _oJson
    Local aProd := {}
    Local _cRet := ""
    Local cProd := ""
    Local aCompl := {}
    Local lRet := ""
    Local aErro := ""
    Local i
    Local x
    Local xErro := ""
    Local nAux := 0

    Private lMsErroAuto := .F.
    Private lAutoErrNoFile := .T.
    Private lMsHelpAuto :=.T.

    JBody   := JSONObject():New()
    jBody["Status"]   := {}

    if !Empty(oJson["cproduto"])
        DbSelectArea('SB1')
        SB1->(dbSetOrder(1))
        if (SB1->(dbSeek(FWxFilial("SB1")+alltrim(PadR(oJson["cproduto"],TamSX3("B1_COD")[1])))))
            _cRet := "Codigo de produto já existente."
        else
            aadd( aProd ,{"B1_COD" , alltrim(oJson["cproduto"]) , Nil })
            cProd := alltrim(oJson["cproduto"])
        endif
    elseif Empty(oJson["cproduto"])
        _cRet := "Codigo do produto não está preenchido."
    endif

    if !Empty(oJson["ctipo"]) .and. Empty(_cRet)
        if !(valtype(oJson["ctipo"]) <> (TamSX3("B1_TIPO")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"02"+alltrim(PadR(oJson["ctipo"],TamSX3("B1_TIPO")[1])))))
                _cRet := "Tipo de produto não existente."
            else
                aadd( aProd ,{"B1_TIPO" , alltrim(oJson["ctipo"]) , Nil })
            endif
        else
            _cRet := "Tipo de produto não está preenchido ou o tipo do campo está diferente de"+TamSX3("B1_TIPO")[3]
        endif
    endif

    if !Empty(oJson["cgrupo"]) .and. Empty(_cRet)
        if !(valtype(oJson["cgrupo"]) <> (TamSX3("B1_GRUPO")[3]) )
            DbSelectArea('SBM')
            SBM->(dbSetOrder(1))
            if !(SBM->(dbSeek(FWxFilial("SBM")+alltrim(PadR(oJson["cgrupo"],TamSX3("B1_GRUPO")[1])))))
                _cRet := "Grupo de estoque não existente."
            else
                aadd( aProd ,{"B1_GRUPO" , alltrim(oJson["cgrupo"]) , Nil })
            endif
        else
            _cRet := "Grupo preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_GRUPO")[3]
        endif

    endif

    if !Empty(oJson["ctamprod"]) .and. Empty(_cRet)
        if (valtype(oJson["ctamprod"]) == (TamSX3("B1_ZTAM")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"ZE"+alltrim(PadR(oJson["ctamprod"],TamSX3("B1_ZTAM")[1])))))
                _cRet := "Tamanho do produto não existente."
            else
                aadd( aProd ,{"B1_ZTAM" , alltrim(oJson["ctamprod"]) , Nil })
            endif
        else
            _cRet := "Tamanho Produto preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZTAM")[3]
        endif
    endif

    if !Empty(oJson["csabor"]) .and. Empty(_cRet)
        if (valtype(oJson["csabor"]) == (TamSX3("B1_ZSAB")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"ZF"+alltrim(PadR(oJson["csabor"],TamSX3("B1_ZSAB")[1])))))
                _cRet := "Sabor informado não existente."
            else
                aadd( aProd ,{"B1_ZSAB" , alltrim(oJson["csabor"]) , Nil })
            endif
        else
            _cRet := "Sabor preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZSAB")[3]
        endif

    endif

    if !Empty(oJson["cposipi"]) .and. Empty(_cRet)
        if (valtype(oJson["cposipi"]) == (TamSX3("B1_POSIPI")[3]) )
            DbSelectArea('SYD')
            SYD->(dbSetOrder(1))
            if !(SYD->(dbSeek(FWxFilial("SYD")+alltrim(PadR(oJson["cposipi"],TamSX3("B1_POSIPI")[1])))))
                _cRet := "posipi informado não existente."
            else
                aadd( aProd ,{"B1_POSIPI" , alltrim(oJson["cposipi"]) , Nil })
            endif
        else
            _cRet := "posipi preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_POSIPI")[3]
        endif

    endif

    if !Empty(oJson["cunidade"]) .and. Empty(_cRet)
        if (valtype(oJson["cunidade"]) == (TamSX3("B1_UM")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"62"+alltrim(PadR(oJson["cunidade"],TamSX3("B1_UM")[1])))))
                _cRet := "Unidade informada não existente."
            else
                aadd( aProd ,{"B1_UM" , alltrim(oJson["cunidade"]) , Nil })
            endif
        else
            _cRet := "unidade preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_UM")[3]
        endif

    endif

    if !Empty(oJson["carmazempad"]) .and. Empty(_cRet)
        if (valtype(oJson["carmazempad"]) == (TamSX3("B1_LOCPAD")[3]) )
            DbSelectArea('NNR')
            NNR->(dbSetOrder(1))
            if !(NNR->(dbSeek(FWxFilial("NNR")+alltrim(PadR(oJson["carmazempad"],TamSX3("B1_LOCPAD")[1])))))
                _cRet := "Armazém não encontrado."
            else
                // if NNR->NNR_MSBLQL == "2"
                aadd( aProd ,{"B1_LOCPAD" , alltrim(oJson["carmazempad"]) , Nil })
                //else
                //    _cRet := "Armazém selecionado está bloqueado."
                //endif
            endif
        else
            _cRet := "armazempad preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_LOCPAD")[3]
        endif
    endif


    if !Empty(oJson["carmazememp"]) .and. Empty(_cRet)
        if (valtype(oJson["carmazememp"]) == (TamSX3("B1_ZZPENC")[3]) )
            DbSelectArea('NNR')
            NNR->(dbSetOrder(1))
            if !(NNR->(dbSeek(FWxFilial("NNR")+alltrim(PadR(oJson["carmazememp"],TamSX3("B1_ZZPENC")[1])))))
                _cRet := "Armazém de empenho não encontrado."
            else
                if NNR->NNR_MSBLQL == "2"
                    aadd( aProd ,{"B1_ZZPENC" , alltrim(oJson["carmazememp"]) , Nil })
                else
                    _cRet := "Armazém de empenho selecionado está bloqueado."
                endif
            endif
        else
            _cRet := "armazememp preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZPENC")[3]
        endif

    endif

    if !Empty(oJson["ctipoalergenico"]) .and. Empty(_cRet)
        if (valtype(oJson["ctipoalergenico"]) == (TamSX3("B1_ZZALERG")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"ZD"+alltrim(PadR(oJson["ctipoalergenico"],TamSX3("B1_ZZALERG")[1])))))
                _cRet := "Tipo de alergenico não encontrado."
            else
                aadd( aProd ,{"B1_ZZALERG" , alltrim(oJson["ctipoalergenico"]) , Nil })
            endif
        else
            _cRet := "tipoalergenico preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZALERG")[3]
        endif
    endif

    if !Empty(oJson["ccontacontabil"]) .and. Empty(_cRet)
        if (valtype(oJson["ccontacontabil"]) == (TamSX3("B1_CONTA")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["ccontacontabil"],TamSX3("B1_CONTA")[1])))))
                _cRet := "Conta contábil não encontrada."
            else
                aadd( aProd ,{"B1_CONTA" , alltrim(oJson["ccontacontabil"]) , Nil })
            endif
        else
            _cRet := "contacontabil preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_CONTA")[3]
        endif
    endif

    if !Empty(oJson["ccontadspadm"]) .and. Empty(_cRet)
        if (valtype(oJson["ccontadspadm"]) == (TamSX3("B1_ZZCTA1")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["ccontadspadm"],TamSX3("B1_ZZCTA1")[1])))))
                _cRet := "Conta contábil administrativa  não encontrada."
            else
                aadd( aProd ,{"B1_ZZCTA1" , alltrim(oJson["ccontadspadm"]) , Nil })
            endif
        else
            _cRet := "contadspadm preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZCTA1")[3]
        endif

    endif

    if !Empty(oJson["ccontadespcml"]) .and. Empty(_cRet)
        if (valtype(oJson["ccontadespcml"]) == (TamSX3("B1_ZZCTA3")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["ccontadespcml"],TamSX3("B1_ZZCTA3")[1])))))
                _cRet := "Conta contábil de despesas comerciais não encontrada."
            else
                aadd( aProd ,{"B1_ZZCTA3" , alltrim(oJson["ccontadespcml"]) , Nil })
            endif
        else
            _cRet := "contadespcml preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZCTA3")[3]
        endif
    endif

    if !Empty(oJson["ccontacstdiretos"]) .and. Empty(_cRet)
        if (valtype(oJson["ccontacstdiretos"]) == (TamSX3("B1_ZZCTA2")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["ccontacstdiretos"],TamSX3("B1_ZZCTA2")[1])))))
                _cRet := "Conta contábil de CST diretos não encontrada."
            else
                aadd( aProd ,{"B1_ZZCTA2" , alltrim(oJson["ccontacstdiretos"]) , Nil })
            endif
        else
            _cRet := "contacstdiretos preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZCTA2")[3]
        endif
    endif

    if !Empty(oJson["contacstindiretos"]) .and. Empty(_cRet)
        if (valtype(oJson["contacstindiretos"]) == (TamSX3("B1_ZZCTA4")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["contacstindiretos"],TamSX3("B1_ZZCTA4")[1])))))
                _cRet := "Conta contábil de CST indiretos não encontrada."
            else
                aadd( aProd ,{"B1_ZZCTA4" , alltrim(oJson["contacstindiretos"]) , Nil })
            endif
        else
            _cRet := "contacstindiretos preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZCTA4")[3]
        endif
    endif

    if !Empty(oJson["corigem"]) .and. Empty(_cRet)
        if (valtype(oJson["corigem"]) == (TamSX3("B1_ORIGEM")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"S0"+alltrim(PadR(oJson["corigem"],TamSX3("B1_ORIGEM")[1])))))
                _cRet := "Origem não encontrada."
            else
                // if NNR->NNR_MSBLQL == "2"
                aadd( aProd ,{"B1_ORIGEM" , alltrim(oJson["corigem"]) , Nil })
                // else
                //    _cRet := "A origem informada está bloqueada."
                // endif
            endif
        else
            _cRet := "origem preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ORIGEM")[3]
        endif
    endif

    if !Empty(oJson["cregraseq"]) .and. Empty(_cRet)
        if (valtype(oJson["cregraseq"]) == (TamSX3("B1_REGSEQ")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"EK"+alltrim(PadR(oJson["cregraseq"],TamSX3("B1_REGSEQ")[1])))))
                _cRet := "Regra de sequenciamento informada não foi encontrada. "
            else
                aadd( aProd ,{"B1_REGSEQ" , alltrim(oJson["cregraseq"]) , Nil })
            endif
        else
            _cRet := "regraseq preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_REGSEQ")[3]
        endif

    endif

    if !Empty(oJson["cunidadenegocio"]) .and. Empty(_cRet)
        if (valtype(oJson["cunidadenegocio"]) == (TamSX3("B1_CLVL")[3]) )
            DbSelectArea('CTH')
            CTH->(dbSetOrder(1))
            if !(CTH->(dbSeek(FWxFilial("CTH")+alltrim(PadR(oJson["cunidadenegocio"],TamSX3("B1_CLVL")[1])))))
                _cRet := "Unidade de negócio informado não encontrado.  "
            else
                aadd( aProd ,{"B1_CLVL" , alltrim(oJson["cunidadenegocio"]) , Nil })
            endif
        else
            _cRet := "unidadenegocio preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_CLVL")[3]
        endif
    endif

    if !Empty(oJson["ccest"]) .and. Empty(_cRet)
        if (valtype(oJson["ccest"]) == (TamSX3("B1_CEST")[3]) )
            DbSelectArea('F0G')
            F0G->(dbSetOrder(1))
            if !(F0G->(dbSeek(FWxFilial("F0G")+alltrim(PadR(oJson["ccest"],TamSX3("B1_CEST")[1])))))
                _cRet := "CEST informado não encontrado.  "
            else
                aadd( aProd ,{"B1_CEST" , alltrim(oJson["ccest"]) , Nil })
            endif
        else
            _cRet := "cest preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_CEST")[3]
        endif
    endif

    if !Empty(oJson["cenqipi"]) .and. Empty(_cRet)
        if (valtype(oJson["cenqipi"]) == (TamSX3("B1_GRPCST")[3]) )
            DbSelectArea('F08')
            F08->(dbSetOrder(1))
            if !(F08->(dbSeek(FWxFilial("F08")+alltrim(PadR(oJson["cenqipi"],TamSX3("B1_GRPCST")[1])))))
                _cRet := "Grupo CST informado não encontrado.  "
            else
                aadd( aProd ,{"B1_GRPCST" , alltrim(oJson["cenqipi"]) , Nil })
            endif
        else
            _cRet := "enqipi preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_GRPCST")[3]
        endif
    endif

    if !Empty(oJson["ccodarvcat"]) .and. Empty(_cRet)
        if (valtype(oJson["ccodarvcat"]) == (TamSX3("B1_XCATEGO")[3]) )
            DbSelectArea('ACU')
            ACU->(dbSetOrder(1))
            if !(ACU->(dbSeek(FWxFilial("ACU")+alltrim(PadR(oJson["ccodarvcat"],TamSX3("B1_XCATEGO")[1])))))
                _cRet := "Cod Arv Cat  informado não encontrado.  "
            else
                aadd( aProd ,{"B1_XCATEGO" , alltrim(oJson["ccodarvcat"]) , Nil })
            endif
        else
            _cRet := "codarvcat preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_XCATEGO")[3]
        endif
    endif

    if !Empty(oJson["ccodmarca"]) .and. Empty(_cRet)
        if (valtype(oJson["ccodmarca"]) == (TamSX3("B1_XMARCA")[3]) )
            DbSelectArea('ZTD')
            ZTD->(dbSetOrder(1))
            if !(ZTD->(dbSeek(FWxFilial("ZTD")+alltrim(PadR(oJson["ccodmarca"],TamSX3("B1_XMARCA")[1])))))
                _cRet := "Cod Arv Cat  informado não encontrado.  "
            else
                aadd( aProd ,{"B1_XMARCA" , alltrim(oJson["ccodmarca"]) , Nil })
            endif
        else
            _cRet := "codmarca preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_XMARCA")[3]
        endif
    endif

    if !Empty(oJson["cobsgeral"]) .and. Empty(_cRet)
        //if (valtype(oJson["cobsgeral"]) == (TamSX3("B1_ZZOBSGE")[3]) )
        aadd( aProd ,{"B1_ZZOBSGE" , alltrim(oJson["cobsgeral"]) , Nil })
        //endif
    endif

    if !Empty(oJson["ccodgtin"]) .and. Empty(_cRet)
        if (valtype(oJson["ccodgtin"]) == (TamSX3("B1_CODGTIN")[3]) )
            aadd( aProd ,{"B1_CODGTIN" , alltrim(oJson["ccodgtin"]) , Nil })

        else
            _cRet := "ccodgtin preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_CODGTIN")[3]
        endif
    endif

    if !Empty(oJson["naliqicms"]) .and. Empty(_cRet)
        if (valtype(oJson["naliqicms"]) == (TamSX3("B1_PICM")[3]) )
            aadd( aProd ,{"B1_PICM" , oJson["naliqicms"] , Nil })

        else
            _cRet := "naliqicms preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_PICM")[3]
        endif
    endif

    if !Empty(oJson["nipi"]) .and. Empty(_cRet)
        if (valtype(oJson["nipi"]) == (TamSX3("B1_IPI")[3]) )
            aadd( aProd ,{"B1_IPI" , oJson["nipi"] , Nil })

        else
            _cRet := "nipi preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_IPI")[3]
        endif
    endif

    if !Empty(oJson["nqtdemb"]) .and. Empty(_cRet)
        if (valtype(oJson["nqtdemb"]) == (TamSX3("B1_QE")[3]) )
            aadd( aProd ,{"B1_QE" , oJson["nqtdemb"] , Nil })

        else
            _cRet := "nqtdemb preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_QE")[3]
        endif
    endif

    if !Empty(oJson["npesoliquido"]) .and. Empty(_cRet)
        if (valtype(oJson["npesoliquido"]) == (TamSX3("B1_PESO")[3]) )
            aadd( aProd ,{"B1_PESO" , oJson["npesoliquido"] , Nil })
        else
            _cRet := "npesoliquido preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_PESO")[3]
        endif
    endif

    if !Empty(oJson["npesobruto"]) .and. Empty(_cRet)
        if (valtype(oJson["npesobruto"]) == (TamSX3("B1_PESBRU")[3]) )
            aadd( aProd ,{"B1_PESBRU" , oJson["npesobruto"] , Nil })

        else
            _cRet := "npesobruto preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_PESBRU")[3]
        endif
    endif

    if !Empty(oJson["nprazoentrega"]) .and. Empty(_cRet)
        if (valtype(oJson["nprazoentrega"]) == (TamSX3("B1_PE")[3]) )
            aadd( aProd ,{"B1_PE" , oJson["nprazoentrega"] , Nil })

        else
            _cRet := "nprazoentrega preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_PE")[3]
        endif
    endif

    if !Empty(oJson["ccontrolalote"]) .and. Empty(_cRet)
        if (valtype(oJson["ccontrolalote"]) == (TamSX3("B1_RASTRO")[3]) )
            aadd( aProd ,{"B1_RASTRO" , alltrim(oJson["ccontrolalote"]) , Nil })
        else
            _cRet := "ccontrolalote preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_RASTRO")[3]
        endif
    endif

    if !Empty(oJson["cfabricante"]) .and. Empty(_cRet)
        if (valtype(oJson["cfabricante"]) == (TamSX3("B1_FABRIC")[3]) )
            aadd( aProd ,{"B1_FABRIC" , alltrim(oJson["cfabricante"]) , Nil })
        else
            _cRet := "cfabricante preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_FABRIC")[3]
        endif
    endif

    if !Empty(oJson["cgrptrib"]) .and. Empty(_cRet)
        if (valtype(oJson["cgrptrib"]) == (TamSX3("B1_GRTRIB")[3]) )
            aadd( aProd ,{"B1_GRTRIB" , alltrim(oJson["cgrptrib"]) , Nil })
        else
            _cRet := "cgrptrib preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_GRTRIB")[3]
        endif
    endif

    if !Empty(oJson["ctipocq"]) .and. Empty(_cRet)
        if (valtype(oJson["ctipocq"]) == (TamSX3("B1_TIPOCQ")[3]) )
            aadd( aProd ,{"B1_TIPOCQ" , alltrim(oJson["ctipocq"]) , Nil })
        else
            _cRet := "ctipocq preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_TIPOCQ")[3]
        endif
    endif

    if !Empty(oJson["nestabatido"]) .and. Empty(_cRet)
        if (valtype(oJson["nestabatido"]) == (TamSX3("B1_XESTABA")[3]) )
            aadd( aProd ,{"B1_XESTABA" , oJson["nestabatido"] , Nil })
        else
            _cRet := "nestabatido preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_XESTABA")[3]
        endif
    endif

    if !Empty(oJson["ccomprasn"]) .and. Empty(_cRet)
        if (valtype(oJson["ccomprasn"]) == (TamSX3("B1_ZZCOM")[3]) )
            aadd( aProd ,{"B1_ZZCOM" , alltrim(oJson["ccomprasn"]) , Nil })
        else
            _cRet := "ccomprasn preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZCOM")[3]
        endif
    endif

    if !Empty(oJson["cintsforce"]) .and. Empty(_cRet)
        if (valtype(oJson["cintsforce"]) == (TamSX3("B1_XINTSF")[3]) )
            aadd( aProd ,{"B1_XINTSF" , alltrim(oJson["cintsforce"]) , Nil })
        else
            _cRet := "cintsforce preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_XINTSF")[3]
        endif
    endif


    ////////////////////////SB5 /////////////////////////////////////////////////////////////////////////////////
    if !Empty(oJson["nomeciencia"]) .and. Empty(_cRet)
        if (valtype(oJson["nomeciencia"]) == (TamSX3("B5_CEME")[3]) )
            aadd( aCompl ,{"B5_COD" , alltrim(oJson["cproduto"]) , Nil })
            aadd( aCompl ,{"B5_CEME" , alltrim(oJson["nomeciencia"]) , Nil })
        else
            _cRet := "nomeciencia preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B5_CEME")[3]
        endif
    endif

    if !Empty(oJson["naltura"]) .and. Empty(_cRet)
        if (valtype(oJson["naltura"]) == (TamSX3("B5_ALTURA")[3]) )
            aadd( aCompl ,{"B5_ALTURA" , oJson["naltura"] , Nil })
        else
            _cRet := "naltura preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B5_ALTURA")[3]
        endif
    endif

    if !Empty(oJson["ncomprimento"]) .and. Empty(_cRet)
        if (valtype(oJson["ncomprimento"]) == (TamSX3("B5_ECCOMP")[3]) )
            aadd( aCompl ,{"B5_ECCOMP" , oJson["ncomprimento"] , Nil })
        else
            _cRet := "ncomprimento preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B5_ECCOMP")[3]
        endif
    endif

    if !Empty(oJson["nlargura"]) .and. Empty(_cRet)
        if (valtype(oJson["nlargura"]) == (TamSX3("B5_ECLARGU")[3]) )
            aadd( aCompl ,{"B5_ECLARGU" , oJson["nlargura"] , Nil })
        else
            _cRet := "nlargura preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B5_ECLARGU")[3]
        endif
    endif

    if !Empty(oJson["nembpeso"]) .and. Empty(_cRet)
        if (valtype(oJson["nembpeso"]) == (TamSX3("B5_ECPESOE")[3]) )
            aadd( aCompl ,{"B5_ECPESOE" , oJson["nembpeso"] , Nil })
        else
            _cRet := "nembpeso preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B5_ECPESOE")[3]
        endif
    endif

    if !Empty(oJson["nemb1"]) .and. Empty(_cRet)
        if (valtype(oJson["nemb1"]) == (TamSX3("B5_QE1")[3]) )
            aadd( aCompl ,{"B5_QE1" , oJson["nemb1"] , Nil })
        else
            _cRet := "nemb1 preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B5_QE1")[3]
        endif
    endif

    if !Empty(oJson["nemb2"]) .and. Empty(_cRet)
        if (valtype(oJson["nemb2"]) == (TamSX3("B5_QE2")[3]) )
            aadd( aCompl ,{"B5_QE2" , oJson["nemb2"] , Nil })
        else
            _cRet := "nemb2 preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B5_QE2")[3]
        endif
    endif

    if Empty(_cRet)
        aadd( aProd ,{"B1_DESC" , alltrim(oJson["cdesc"]) , Nil })
        aadd( aProd ,{"B1_ZALERGE" , alltrim(oJson["calergenico"]) , Nil })
    endif

    if Empty(_cRet)
        Begin Transaction
            //Chamando o cadastro de produtos de forma automática
            MSExecAuto({|x,y| Mata010(x,y)},aProd,3)
            If lMsErroAuto
                lRet := .F.
                aErro := GetAutoGRLog()
                For i := 1 To Len(aErro)
                    xErro += aErro[i]
                Next
                jBody["Status"] := "400"
                jBody["Message"]  := "Erro: "+ xErro +" "
                nAux := 0
                //SetRestFault(404, EncodeUTF8(cRet))
            Else
                //jBody["Status"] := "200"
                //jBody["Message"] := "Response Produto incluido com sucesso, Codigo: "+SB1->B1_COD+" "
                nAux := 1
                //::SetResponse(EncodeUTF8(cRet))
            EndIf

        end Transaction
    else
        jBody["Status"] := "400"
        jBody["Message"]  := "Erro de envio: "+_cRet+" "
    endif

    if nAux == 1 //Chamando o cadastro de complemento de produtos de forma automática
        MSExecAuto({|x,y| Mata180(x,y)},aCompl,3)
        If lMsErroAuto
            lRet := .F.
            aErro := GetAutoGRLog()
            For i := 1 To Len(aErro)
                xErro += aErro[i]
            Next
            jBody["Status"] := "400"
            jBody["Message"]  := "Erro: "+ xErro +" "
            //SetRestFault(404, EncodeUTF8(cRet))
        Else
            jBody["Status"] := "200"
            jBody["Message"] := "Response Produto incluido com sucesso, Codigo: "+SB5->B5_COD+" "
            //::SetResponse(EncodeUTF8(cRet))
        EndIf
    endif

    RestArea(aArea)
Return (jBody)
