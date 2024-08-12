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

        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_RES01", , "allan.rabelo"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_RES02", , "123456"	))	        // Senha para autenticao no WS*/
        _cLogin     := _cUserPar+":"+_cPassPar

        //Verifica se o usuário de autenticação é igual ao do Parametro.
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
    Local aLinha
    Local aImpostos
    Local aImpItem := {}
    Local nLength := 0
    Local jBody     as JSON
    Local oItems
    Local nX
    Local yX


    aCabec  := {}
    aItens  := {}
    aImpItem := {}
    JBody   := JSONObject():New()

    DbSelectArea('SB1')
    SB1->(dbSetOrder(1))
    IF (SB1->(dbSeek(FWxFilial("SB1")+PadR(_oJson:GetJsonObject('Codigo'),TamSX3("B1_COD")[1]))))
        jBody["Status"]    := "200 - OK"
        aAdd(jBody["Produto"], JSONObject():New() )
        //nLength++
        // Adiciona os atributos básicos do produto
        jBody["Produto"]["Codigo"]    := SB1->B1_COD
        jBody["Produto"]["Descricao"]    := SB1->B1_DESC
    endif
    RestArea(aArea)


Return (jBody)

