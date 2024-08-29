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

        //PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"


        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_RES01", , "allan.rabelo"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_RES02", , "123456"	))	        // Senha para autenticao no WS
        _cLogin     := _cUserPar+":"+_cPassPar

        
        _aRet := ZVALREQ(_cLogin,_cAuthorization,_cEmpFil)
        

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
    jBody["Status"]   := {}

    DbSelectArea('SB1')
    SB1->(dbSetOrder(1))
    IF (SB1->(dbSeek(FWxFilial("SB1")+PadR(_oJson:GetJsonObject('produto'),TamSX3("B1_COD")[1]))))
        jBody["Status"]             := "200"
        jBody["Message"]            := "OK"
        jBody["cproduto"]            := alltrim(SB1->B1_COD)
        jBody["cdesc"]               := SB1->B1_DESC
        jBody["ctipo"]               := SB1->B1_TIPO
        jBody["cgrupo"]              := SB1->B1_GRUPO
        jBody["ctamprod"]            := SB1->B1_ZTAM
        jBody["csabor"]              := SB1->B1_ZSAB
        jBody["cobsgeral"]           := SB1->B1_ZZOBSGE
        JBody["cposipi"]             := alltrim(SB1->B1_POSIPI)
        jBody["cunidade"]            := SB1->B1_UM
        jBody["carmazempad"]         := SB1->B1_LOCPAD
        jBody["carmazememp"]         := SB1->B1_ZZPENC
        jBody["ccodgtin"]            := alltrim(SB1->B1_CODGTIN)
        jBody["naliqicms"]           := SB1->B1_PICM
        jBody["nipi"]                := SB1->B1_IPI
        jBody["calergenico"]         := SB1->B1_ZALERGE
        jBody["ctipoalergenico"]     := SB1->B1_ZZALERG
        JBody["nqtdemb"]             := SB1->B1_QE
        jBody["npesoliquido"]        := SB1->B1_PESO
        jBody["npesobruto"]          := SB1->B1_PESBRU
        jBody["nprazoentrega"]       := SB1->B1_PE
        jBody["ccontacontabil"]      := alltrim(SB1->B1_CONTA)
        jBody["ccontadspadm"]        := SB1->B1_ZZCTA1
        JBody["ccontadespcml"]       := SB1->B1_ZZCTA3
        jBody["ccontacstdiretos"]    := SB1->B1_ZZCTA2
        jBody["contacstindiretos"]  := SB1->B1_ZZCTA4
        JBody["corigem"]             := SB1->B1_ORIGEM
        jBody["ccontrolalote"]       := SB1->B1_RASTRO
        jBody["cfabricante"]         := alltrim(SB1->B1_FABRIC)
        jBody["cgrptrib"]            := SB1->B1_GRTRIB
        jBody["ctipocq"]             := SB1->B1_TIPOCQ
        jBody["cregraseq"]           := SB1->B1_REGSEQ
        jBody["cunidadenegocio"]     := SB1->B1_CLVL
        JBody["ccest"]               := SB1->B1_CEST
        jBody["cenqipi"]             := SB1->B1_GRPCST
        jBody["ccodarvcat"]          := SB1->B1_XCATEGO
        jBody["ccodmarca"]           := SB1->B1_XMARCA
        jBody["nestabatido"]         := SB1->B1_XESTABA
        jBody["nqtdpcx"]             := SB1->B1_ZQEEXP
        jBody["ccomprasn"]           := SB1->B1_ZZCOM
        jBody["cintsforce"]          := SB1->B1_XINTSF
     //   jBody["cean13"]              := SB1->B1_XCODBAR
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

        //PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "COM"


        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_RES01", , "allan.rabelo"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_RES02", , "123456"	))	        // Senha para autenticao no WS
        _cLogin     := _cUserPar+":"+_cPassPar

      
        ZVALREQ(_cLogin,_cAuthorization,_cEmpFil)
      
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
    Local retJson 
    Local aProd := {}
    Local _cRet := ""
    Local cProd := ""
    Local cTipo := ""
    Local cArmazem := ""
    //Local cDesc := "TESTE"
    Local cUn := ""
    Local aVetor := {}
    Local cRet := ""
	Local lRet := ""
	Local aErro := ""
    Local i
	Local x
    Local xErro := ""
    
    
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
            _cRet := "Tipo de produto não está preenchido ou o tipo do campo está diferente de "+TamSX3("B1_TIPO")[3]
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
            _cRet := "Grupo preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_GRUPO")[3]
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
            _cRet := "Tamanho Produto preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZTAM")[3]
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
            _cRet := "Sabor preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZSAB")[3]
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
            _cRet := "posipi preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_POSIPI")[3]
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
            _cRet := "unidade preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_UM")[3]
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
            _cRet := "armazempad preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_LOCPAD")[3]
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
            _cRet := "armazememp preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZZPENC")[3]
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
            _cRet := "tipoalergenico preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZZALERG")[3]    
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
            _cRet := "contacontabil preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_CONTA")[3]  
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
            _cRet := "contadspadm preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZZCTA1")[3]  
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
            _cRet := "contadespcml preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZZCTA3")[3]
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
            _cRet := "contacstdiretos preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZZCTA2")[3]
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
            _cRet := "contacstindiretos preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ZZCTA4")[3]
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
            _cRet := "origem preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_ORIGEM")[3]
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
            _cRet := "regraseq preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_REGSEQ")[3] 
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
            _cRet := "unidadenegocio preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_CLVL")[3] 
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
            _cRet := "cest preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_CEST")[3]  
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
            _cRet := "enqipi preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_GRPCST")[3]  
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
            _cRet := "codarvcat preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_XCATEGO")[3] 
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
            _cRet := "codmarca preenchido incorretamente ou o tipo do campo está diferente de "+TamSX3("B1_XMARCA")[3]
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
                //SetRestFault(404, EncodeUTF8(cRet))
            Else
                jBody["Status"] := "200" 
                jBody["Message"] := "Response Produto incluido com sucesso, Codigo: "+SB1->B1_COD+" "
                //::SetResponse(EncodeUTF8(cRet))
            EndIf
        end Transaction
    else 
        jBody["Status"] := "400" 
        jBody["Message"]  := "Erro de envio: "+_cRet+" "
    endif 
    RestArea(aArea)
Return (jBody)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0001 ³ Autor ³  Allan Rabelo         ³ Data ³ 18/08/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ VALIDAR EMPRESA, USER E ACESSO                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PRODUTOS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ZVALREQ(_cLogin,_cAuthorization,_cEmpFil)
    Local _cEmpresa         := ""
    Local _cFilial          := ""
    Local _nPos
    Local _aRet             := ""

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
