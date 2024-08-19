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
        jBody["produto"]            := alltrim(SB1->B1_COD)
        jBody["desc"]               := SB1->B1_DESC
        jBody["tipo"]               := SB1->B1_TIPO
        jBody["grupo"]              := SB1->B1_GRUPO
        jBody["tamprod"]            := SB1->B1_ZTAM
        jBody["sabor"]              := SB1->B1_ZSAB
        jBody["obsgeral"]           := SB1->B1_ZZOBSGE
        JBody["posipi"]             := alltrim(SB1->B1_POSIPI)
        jBody["unidade"]            := SB1->B1_UM
        jBody["armazempad"]         := SB1->B1_LOCPAD
        jBody["armazememp"]         := SB1->B1_ZZPENC
        jBody["codgtin"]            := alltrim(SB1->B1_CODGTIN)
        jBody["aliqicms"]           := SB1->B1_PICM
        jBody["ipi"]                := SB1->B1_IPI
        jBody["alergenico"]         := SB1->B1_ZALERGE
        jBody["tipoalergenico"]     := SB1->B1_ZZALERG
        JBody["qtdemb"]             := SB1->B1_QE
        jBody["pesoliquido"]        := SB1->B1_PESO
        jBody["pesobruto"]          := SB1->B1_PESBRU
        jBody["prazoentrega"]       := SB1->B1_PE
        jBody["contacontabil"]      := alltrim(SB1->B1_CONTA)
        jBody["contadspadm"]        := SB1->B1_ZZCTA1
        JBody["contadespcml"]       := SB1->B1_ZZCTA3
        jBody["contacstdiretos"]    := SB1->B1_ZZCTA2
        jBody["contacstindiretos"]  := SB1->B1_ZZCTA4
        JBody["origem"]             := SB1->B1_ORIGEM
        jBody["controlalote"]       := SB1->B1_RASTRO
        jBody["fabricante"]         := alltrim(SB1->B1_FABRIC)
        jBody["grptrib"]            := SB1->B1_GRTRIB
        jBody["tipocq"]             := SB1->B1_TIPOCQ
        jBody["regraseq"]           := SB1->B1_REGSEQ
        jBody["unidadenegocio"]     := SB1->B1_CLVL
        JBody["cest"]               := SB1->B1_CEST
        jBody["enqipi"]             := SB1->B1_GRPCST
        jBody["codarvcat"]          := SB1->B1_XCATEGO
        jBody["codmarca"]           := SB1->B1_XMARCA
        jBody["estabatido"]         := SB1->B1_XESTABA
        jBody["qtdpcx"]             := SB1->B1_ZQEEXP
        jBody["comprasn"]           := SB1->B1_ZZCOM
        jBody["intsforce"]          := SB1->B1_XINTSF
        jBody["ean13"]              := SB1->B1_XCODBAR
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

        //PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"


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
    Local cDesc := "TESTE"
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
   
    
    if !Empty(oJson["produto"]) 
        DbSelectArea('SB1')
        SB1->(dbSetOrder(1))
        if (SB1->(dbSeek(FWxFilial("SB1")+alltrim(PadR(oJson["produto"],TamSX3("B1_COD")[1])))))
            _cRet := "Codigo de produto já existente."
        else 
            aadd( aProd ,{"B1_COD" , alltrim(oJson["produto"]) , Nil })
            cProd := alltrim(oJson["produto"])
        endif 
    elseif Empty(oJson["produto"])
        _cRet := "Codigo do produto não está preenchido."
    endif 

    if !Empty(oJson["tipo"]) .and. Empty(_cRet) 
        if !(valtype(oJson["tipo"]) <> (TamSX3("B1_TIPO")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"02"+alltrim(PadR(oJson["tipo"],TamSX3("B1_TIPO")[1])))))
                _cRet := "Tipo de produto não existente."
            else 
                aadd( aProd ,{"B1_TIPO" , alltrim(oJson["tipo"]) , Nil })
            endif 
        else 
            _cRet := "Tipo de produto não está preenchido ou o tipo do campo está diferente de"+TamSX3("B1_TIPO")[3]
        endif      
    endif 

    if !Empty(oJson["grupo"]) .and. Empty(_cRet)  
        if !(valtype(oJson["grupo"]) <> (TamSX3("B1_GRUPO")[3]) )
            DbSelectArea('SBM')
            SBM->(dbSetOrder(1))
            if !(SBM->(dbSeek(FWxFilial("SBM")+alltrim(PadR(oJson["grupo"],TamSX3("B1_GRUPO")[1])))))
                _cRet := "Grupo de estoque não existente."
            else 
                aadd( aProd ,{"B1_GRUPO" , alltrim(oJson["grupo"]) , Nil })
            endif 
        else 
            _cRet := "Grupo preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_GRUPO")[3]
        endif 

    endif 
  
    if !Empty(oJson["tamprod"]) .and. Empty(_cRet) 
        if (valtype(oJson["tamprod"]) == (TamSX3("B1_ZTAM")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"ZE"+alltrim(PadR(oJson["tamprod"],TamSX3("B1_ZTAM")[1])))))
                _cRet := "Tamanho do produto não existente."
            else 
                aadd( aProd ,{"B1_ZTAM" , alltrim(oJson["tamprod"]) , Nil })
            endif 
        else 
            _cRet := "Tamanho Produto preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZTAM")[3]
        endif 
    endif 
    
    if !Empty(oJson["sabor"]) .and. Empty(_cRet)  
        if (valtype(oJson["sabor"]) == (TamSX3("B1_ZSAB")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"ZF"+alltrim(PadR(oJson["sabor"],TamSX3("B1_ZSAB")[1])))))
                _cRet := "Sabor informado não existente."
            else 
                aadd( aProd ,{"B1_ZSAB" , alltrim(oJson["sabor"]) , Nil })
            endif 
        else 
            _cRet := "Sabor preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZSAB")[3]
        endif 
   
    endif 
  
    if !Empty(oJson["posipi"]) .and. Empty(_cRet) 
        if (valtype(oJson["posipi"]) == (TamSX3("B1_POSIPI")[3]) )
            DbSelectArea('SYD')
            SYD->(dbSetOrder(1))
            if !(SYD->(dbSeek(FWxFilial("SYD")+alltrim(PadR(oJson["posipi"],TamSX3("B1_POSIPI")[1])))))
                _cRet := "Sabor informado não existente."
            else 
                aadd( aProd ,{"B1_POSIPI" , alltrim(oJson["posipi"]) , Nil })
            endif 
        else 
            _cRet := "posipi preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_POSIPI")[3]
        endif 
    
    endif 

    if !Empty(oJson["unidade"]) .and. Empty(_cRet) 
        if (valtype(oJson["unidade"]) == (TamSX3("B1_UM")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"62"+alltrim(PadR(oJson["unidade"],TamSX3("B1_UM")[1])))))
                _cRet := "Unidade informada não existente."
            else 
                aadd( aProd ,{"B1_UM" , alltrim(oJson["unidade"]) , Nil })
            endif 
        else 
            _cRet := "unidade preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_UM")[3]
        endif 
    
    endif 

    if !Empty(oJson["armazempad"]) .and. Empty(_cRet)  
        if (valtype(oJson["armazempad"]) == (TamSX3("B1_LOCPAD")[3]) )
            DbSelectArea('NNR')
            NNR->(dbSetOrder(1))
            if !(NNR->(dbSeek(FWxFilial("NNR")+alltrim(PadR(oJson["armazempad"],TamSX3("B1_LOCPAD")[1])))))
                _cRet := "Armazém não encontrado."
            else 
               // if NNR->NNR_MSBLQL == "2"
                    aadd( aProd ,{"B1_LOCPAD" , alltrim(oJson["armazempad"]) , Nil })
                //else 
                //    _cRet := "Armazém selecionado está bloqueado."
                //endif 
            endif 
        else 
            _cRet := "armazempad preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_LOCPAD")[3]
        endif 
    endif 

   
    if !Empty(oJson["armazememp"]) .and. Empty(_cRet) 
        if (valtype(oJson["armazememp"]) == (TamSX3("B1_ZZPENC")[3]) )
            DbSelectArea('NNR')
            NNR->(dbSetOrder(1))
            if !(NNR->(dbSeek(FWxFilial("NNR")+alltrim(PadR(oJson["armazememp"],TamSX3("B1_ZZPENC")[1])))))
                _cRet := "Armazém de empenho não encontrado."
            else 
                if NNR->NNR_MSBLQL == "2"
                    aadd( aProd ,{"B1_ZZPENC" , alltrim(oJson["armazememp"]) , Nil })
                else 
                    _cRet := "Armazém de empenho selecionado está bloqueado."
                endif 
            endif 
        else 
            _cRet := "armazememp preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZPENC")[3]
        endif 
        
    endif 

    if !Empty(oJson["tipoalergenico"]) .and. Empty(_cRet) 
        if (valtype(oJson["tipoalergenico"]) == (TamSX3("B1_ZZALERG")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"ZD"+alltrim(PadR(oJson["tipoalergenico"],TamSX3("B1_ZZALERG")[1])))))
                _cRet := "Tipo de alergenico não encontrado."
            else 
                aadd( aProd ,{"B1_ZZALERG" , alltrim(oJson["tipoalergenico"]) , Nil })
            endif
        else 
            _cRet := "tipoalergenico preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZALERG")[3]    
        endif 
    endif 
 
    if !Empty(oJson["contacontabil"]) .and. Empty(_cRet) 
        if (valtype(oJson["contacontabil"]) == (TamSX3("B1_CONTA")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["contacontabil"],TamSX3("B1_CONTA")[1])))))
                _cRet := "Conta contábil não encontrada."
            else 
                aadd( aProd ,{"B1_CONTA" , alltrim(oJson["contacontabil"]) , Nil })
            endif 
        else 
            _cRet := "contacontabil preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_CONTA")[3]  
        endif 
    endif 
    
    if !Empty(oJson["contadspadm"]) .and. Empty(_cRet) 
        if (valtype(oJson["contadspadm"]) == (TamSX3("B1_ZZCTA1")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["contadspadm"],TamSX3("B1_ZZCTA1")[1])))))
                _cRet := "Conta contábil administrativa  não encontrada."
            else 
                aadd( aProd ,{"B1_ZZCTA1" , alltrim(oJson["contadspadm"]) , Nil })
            endif 
        else 
            _cRet := "contadspadm preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZCTA1")[3]  
        endif 
   
    endif 

    if !Empty(oJson["contadespcml"]) .and. Empty(_cRet) 
        if (valtype(oJson["contadespcml"]) == (TamSX3("B1_ZZCTA3")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["contadespcml"],TamSX3("B1_ZZCTA3")[1])))))
                _cRet := "Conta contábil de despesas comerciais não encontrada."
            else 
                aadd( aProd ,{"B1_ZZCTA3" , alltrim(oJson["contadespcml"]) , Nil })
            endif
        else 
            _cRet := "contadespcml preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ZZCTA3")[3]
        endif 
    endif 

    if !Empty(oJson["contacstdiretos"]) .and. Empty(_cRet) 
        if (valtype(oJson["ccontacstdiretos"]) == (TamSX3("B1_ZZCTA2")[3]) )
            DbSelectArea('CT1')
            CT1->(dbSetOrder(1))
            if !(CT1->(dbSeek(FWxFilial("CT1")+alltrim(PadR(oJson["ccontacstdiretos"],TamSX3("B1_ZZCTA2")[1])))))
                _cRet := "Conta contábil de CST diretos não encontrada."
            else 
                aadd( aProd ,{"B1_ZZCTA2" , alltrim(oJson["contacstdiretos"]) , Nil })
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
   
    if !Empty(oJson["origem"]) .and. Empty(_cRet) 
        if (valtype(oJson["origem"]) == (TamSX3("B1_ORIGEM")[3]) )
            DbSelectArea('NNR')
            NNR->(dbSetOrder(1))
            if !(NNR->(dbSeek(FWxFilial("NNR")+alltrim(PadR(oJson["origem"],TamSX3("B1_ORIGEM")[1])))))
                _cRet := "Origem não encontrada."
            else 
               // if NNR->NNR_MSBLQL == "2"
                    aadd( aProd ,{"B1_ORIGEM" , alltrim(oJson["origem"]) , Nil })
               // else 
                //    _cRet := "A origem informada está bloqueada."
               // endif 
            endif 
        else 
            _cRet := "origem preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_ORIGEM")[3]
        endif 
    endif 

    if !Empty(oJson["regraseq"]) .and. Empty(_cRet) 
        if (valtype(oJson["regraseq"]) == (TamSX3("B1_REGSEQ")[3]) )
            DbSelectArea('SX5')
            SX5->(dbSetOrder(1))
            if !(SX5->(dbSeek(FWxFilial("SX5")+"EK"+alltrim(PadR(oJson["regraseq"],TamSX3("B1_REGSEQ")[1])))))
                _cRet := "Regra de sequenciamento informada não foi encontrada. "
            else 
                aadd( aProd ,{"B1_REGSEQ" , alltrim(oJson["regraseq"]) , Nil })
            endif 
        else 
            _cRet := "regraseq preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_REGSEQ")[3] 
        endif 
    
    endif 

    if !Empty(oJson["unidadenegocio"]) .and. Empty(_cRet) 
        if (valtype(oJson["unidadenegocio"]) == (TamSX3("B1_CLVL")[3]) )
            DbSelectArea('CTH')
            CTH->(dbSetOrder(1))
            if !(CTH->(dbSeek(FWxFilial("CTH")+alltrim(PadR(oJson["unidadenegocio"],TamSX3("B1_CLVL")[1])))))
                _cRet := "Unidade de negócio informado não encontrado.  "
            else 
                aadd( aProd ,{"B1_CLVL" , alltrim(oJson["unidadenegocio"]) , Nil })
            endif 
        else 
            _cRet := "unidadenegocio preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_CLVL")[3] 
        endif 
    endif 

    if !Empty(oJson["cest"]) .and. Empty(_cRet) 
        if (valtype(oJson["cest"]) == (TamSX3("B1_CEST")[3]) )
            DbSelectArea('F0G')
            F0G->(dbSetOrder(1))
            if !(F0G->(dbSeek(FWxFilial("F0G")+alltrim(PadR(oJson["cest"],TamSX3("B1_CEST")[1])))))
                _cRet := "CEST informado não encontrado.  "
            else 
                aadd( aProd ,{"B1_CEST" , alltrim(oJson["cest"]) , Nil })
            endif
        else 
            _cRet := "cest preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_CEST")[3]  
        endif 
    endif 

    if !Empty(oJson["enqipi"]) .and. Empty(_cRet) 
        if (valtype(oJson["enqipi"]) == (TamSX3("B1_GRPCST")[3]) )
            DbSelectArea('F08')
            F08->(dbSetOrder(1))
            if !(F08->(dbSeek(FWxFilial("F08")+alltrim(PadR(oJson["enqipi"],TamSX3("B1_GRPCST")[1])))))
                _cRet := "Grupo CST informado não encontrado.  "
            else 
                aadd( aProd ,{"B1_GRPCST" , alltrim(oJson["enqipi"]) , Nil })
            endif
        else 
            _cRet := "enqipi preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_GRPCST")[3]  
        endif 
    endif 
    
    if !Empty(oJson["codarvcat"]) .and. Empty(_cRet) 
        if (valtype(oJson["codarvcat"]) == (TamSX3("B1_XCATEGO")[3]) )
            DbSelectArea('ACU') 
            ACU->(dbSetOrder(1))
            if !(ACU->(dbSeek(FWxFilial("ACU")+alltrim(PadR(oJson["codarvcat"],TamSX3("B1_XCATEGO")[1])))))
                _cRet := "Cod Arv Cat  informado não encontrado.  "
            else 
                aadd( aProd ,{"B1_XCATEGO" , alltrim(oJson["codarvcat"]) , Nil })
            endif 
        else 
            _cRet := "codarvcat preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_XCATEGO")[3] 
        endif 
    endif 

    if !Empty(oJson["codmarca"]) .and. Empty(_cRet) 
        if (valtype(oJson["codmarca"]) == (TamSX3("B1_XMARCA")[3]) )
            DbSelectArea('ZTD')
            ZTD->(dbSetOrder(1))
            if !(ZTD->(dbSeek(FWxFilial("ZTD")+alltrim(PadR(oJson["codmarca"],TamSX3("B1_XMARCA")[1])))))
                _cRet := "Cod Arv Cat  informado não encontrado.  "
            else 
                aadd( aProd ,{"B1_XMARCA" , alltrim(oJson["codmarca"]) , Nil })
            endif 
        else 
            _cRet := "codmarca preenchido incorretamente ou o tipo do campo está diferente de"+TamSX3("B1_XMARCA")[3]
        endif 
    endif 
    

    if !Empty(_cRet) 
    aadd( aProd ,{"B1_DESC" , alltrim(oJson["Desc"]) , Nil })
    endif 
    Begin Transaction
		//Chamando o cadastro de produtos de forma automática
		MSExecAuto({|x,y| Mata010(x,y)},aProd,3)
        If lMsErroAuto
			lRet := .F.
			aErro := GetAutoGRLog()
			For i := 1 To Len(aErro)
				xErro += aErro[i]
			Next

    			cRet  := '{"Error":"Erro: ' + xErro +'"}'
			SetRestFault(404, EncodeUTF8(cRet))
			
		Else
			cRet := '{"Response":"Produto incluido com sucesso ","Codigo ":"'+SB1->B1_COD+'"}'
			::SetResponse(EncodeUTF8(cRet))
        	
		//Disarmando a transação
			DisarmTransaction()
		EndIf
   
    end Transaction
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
