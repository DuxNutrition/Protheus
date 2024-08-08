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
WSRESTFUL ZWSF002 DESCRIPTION "Cadastro de produtos"
    WSMETHOD GET  DESCRIPTION "ZWS002 GET PRODUTO" WSSYNTAX "ZWS002GET"
    WSMETHOD POST DESCRIPTION "ZWS002 CAD PRODUTO" WSSYNTAX "ZWS002POST"
    WSMETHOD PUT  DESCRIPTION "ZWS002 ALT PRODUTO" WSSYNTAX "ZWS002PUT"
END WSRESTFUL

WSMETHOD GET WSSERVICE ZWSF002
    Local _aRet       := ""
    Local cBody      := ""
    Local _cAuthorization := ""
    Local _cEmpFil   := ""
    Local _cUser     := ""
    Local _cPass     := ""
    Local jBody    As JSON
    Local cTenantId := ""
    Local empresa := ""
    Local filial := ""
    Local lRet := .F.
    Local _cLogin := ""

    Self:SetContentType("application/cJson")
    _cAuthorization := SUBSTR(Self:GetHeader('Authorization'),7,50)
    _cEmpFil 		:= Self:GetHeader("tenantid", .F.)
    //_cUser  		:= Decode64(Self:GetHeader("user", .F.))
    //_cPass          := Decode64(Self:GetHeader("pass", .F. ))
    
    _cUserPar 	:= Encode64(AllTrim( superGetMv( "DUX_RES01", , "allan.rabelo"	) ))	// Usuario para autenticacao no WS
    _cPassPar 	:= Encode64(AllTrim( superGetMv( "DUX_RES02", , "123456"	) ))	// Senha para autenticao no WS*/
    cLogin := Encode64(Decode64(_cUserPar) +":"+ Decode64(_cPassPar)) 
    cBody := ::GetContent()
    jBody    := JSONObject():New()

    cTenantId := HTTPHeader("tenantId")

    if cTenantid <> "" 
        If ("," $ cTenantId)
        empresa := StrTokArr2(cTenantId, ",")[1]
        filial  := StrTokArr2(cTenantId, ",")[2]
        EndIf
    else 
        _aRet := {302," Empresa ou filial não encontrada."}
    endif 

    cEmpAnt:= empresa
    cFilAnt:= filial

    if (_cAuthorization!=cLogin) 
        _aRet := {302,"Usuario ou senha Nao Autorizado "}
    endif 
        If !Empty(_aRet) 
            _oJson := JsonObject():new()
            _oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))
            jBody := ZPRODGET(@_oJson, _cEmpFil)
            Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
            FwFreeObj(jBody)
        Else
            jBody["Status"]    := _aRet 
            Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
            FwFreeObj(jBody)
        endif
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
    JBody["Status"] := {}

    DbSelectArea('SB1')
    SB1->(dbSetOrder(1))
    IF (SB1->(dbSeek(FWxFilial("SB1")+PadR(_oJson:GetJsonObject('Codigo'),TamSX3("B1_COD")[1]))))
        jBody["Status"]    := "200 - OK"
        aAdd(jBody["Produto"], JSONObject():New() )
        nLength++
        // Adiciona os atributos básicos do produto
        jBody["Produto"]["Produto"]    := SB1->B1_COD 

    endif     
    RestArea(aArea)

    
Return (jBody)

     
