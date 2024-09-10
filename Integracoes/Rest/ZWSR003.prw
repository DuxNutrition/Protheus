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

        PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"


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

     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"
     
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
    Local aLinha
    Local aImpostos
    Local aTitulos 
    Local aItem
    Local aTit 
    Local nLength := 0
    Local jBody     as JSON
    Local oItems
    Local nX
    Local yX
    Local cQrySE1	:= ""
    Local nProcess := 0  /// 0 = NULL, 1 == ABERTOS, 2 == VENCIDOS , 3 == BAIXADOS 
    Local cJson := ""
    Local nAux := 0 
    Local aCli 


    aCabec  := {}
    aItens  := {}
    aImpItem := {}
    JBody   := JSONObject():New()
    //
    jBody["Status"]   := {}
    aTitulos := JsonObject():New()

	cQrySE1 := " SELECT E1_NUM AS NUM, E1_TIPO AS TIPO, E1_VALOR AS VAL , E1_PARCELA AS PARCELA , E1_VENCREA AS VENCIMENTO , E1_CLIENTE AS CLIENTE , E1_LOJA AS LOJA , E1_STATUS AS STATUSX  "
    cQrySE1 += " FROM "+Retsqlname("SE1")+" WHERE "
    /////////// Verifico qual é o processo ////////////////
    if (_oJson:GetJsonObject('status') == 'abertos')
        cQrySE1 += " E1_VENCREA >='"+Dtos(Date())+"' AND E1_SALDO <> 0 AND "
        cProcess := 1
    endif 
    if (_oJson:GetJsonObject('status') == 'vencidos')
        cQrySE1 += " E1_VENCREA < '"+Dtos(Date())+"' AND E1_SALDO <> 0 AND "
        cProcess := 2
    endif 
    if (_oJson:GetJsonObject('status') == 'baixados')
        cQrySE1 += " E1_SALDO =  0 AND "
        cProcess := 3
    endif 
    ///////////////// filtro de acordo com a necessidade 
    if !Empty(_oJson:GetJsonObject('cliente'))
        cQrySE1 += " E1_CLIENTE ='"+_oJson:GetJsonObject('cliente')+"' AND "
    endif 
    if !Empty(_oJson:GetJsonObject('loja'))
        cQrySE1 += " E1_LOJA ='"+_oJson:GetJsonObject('loja')+"' AND  "
    endif 
    if !Empty(_oJson:GetJsonObject('numero'))
        cQrySE1 += " E1_NUM ='"+_oJson:GetJsonObject('numero')+"'  AND "
    endif 
     if !Empty(_oJson:GetJsonObject('parcela'))
        cQrySE1 += " E1_PARCELA ='"+_oJson:GetJsonObject('parcela')+"' AND  "
    endif 
	cQrySE1 +=  "  D_E_L_E_T_ <> '*'  "
    ////////////// Verifico se a tabela já se encontra aberta e fecho ////////////
	IF SELECT("TMPC1") > 0
		TMPC1->(DbCloseArea())
	ENDIF    
  
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQrySE1),"TMPC1",.F.,.T.)
    ///////////// Aponto dados para o JSON /////////////
    aTitulos["empresa"] := cEmpAnt
    aTitulos["filial"] := cFilAnt
    aTitulos["status"] := _oJson:GetJsonObject('status')

    if !Empty(_oJson:GetJsonObject('cliente'))
        aTitulos["cliente"] := _oJson:GetJsonObject('cliente')
    elseif !Empty(_oJson:GetJsonObject('numero'))
        aTitulos["cliente"] := TMPC1->CLIENTE
    else 
        aTitulos["cliente"] := "todos clientes"
    endif 

    if !Empty(_oJson:GetJsonObject('loja'))
        aTitulos["loja"] := _oJson:GetJsonObject('loja')
    endif 

    aTitulos["Item"] := {}
    DbSelectArea('SE1')
    SE1->(dbSetOrder(1))

    While !TMPC1->(eof())
            aTit := {}
            aCli := {}
            aTit := JSONObject():New()
            aCli := JSONObject():New()
            
        if (SA1->(dbSeek(FWxFilial("SA1")+alltrim(PadR(TMPC1->CLIENTE,TamSX3("A1_COD")[1]))+alltrim(PadR(TMPC1->LOJA,TamSX3("A1_LOJA")[1])))))
            aTit["tipocliente"]              := SA1->A1_PESSOA
            aTit["cnpjcpf"]                  := SA1->A1_CGC
            aTit["codigocliente"]            := SA1->A1_COD
            aTit["lojacliente"]              := SA1->A1_LOJA
            aTit["nome"]                     := SA1->A1_NOME
            aTit["numcontrato"]              := SA1->A1_COD+SA1->A1_LOJA
            aTit["titulo"]                   := TMPC1->NUM
            aTit["parcela"]                  := TMPC1->PARCELA
            aTit["vencimento"]               := TMPC1->VENCIMENTO
            aTit["valor"]                    := TMPC1->VAL
            aTit["tipo"]                     := TMPC1->TIPO
            aTit["endcob"]                   := SA1->A1_ENDCOB
            aTit["email"]                    := SA1->A1_EMAIL
            aTit["end"]                      := SA1->A1_END
            aTit["bairro"]                   := SA1->A1_BAIRRO
            aTit["estado"]                   := SA1->A1_EST
            aTit["cep"]                      := SA1->A1_CEP
            aTit["telefone"]                 := SA1->A1_TEL
            aTit["statusparc"]               := TMPC1->STATUSX
        else 
            aTit["erro"]                     := "Cliente "+TMPC1->NUM+" não encontrado"
        endif 
            aAdd(aTitulos["Item"], aTit)
            nAux := nAux + 1 
            TMPC1->(DBSkip())
    Enddo   
    aTitulos["Total"] := cValToChar(nAux)
    RestArea(aArea)
Return(aTitulos)
