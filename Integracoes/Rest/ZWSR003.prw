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

    cQrySE1 := "  SELECT 	SE1.E1_FILIAL		AS FILIAL "
    cQrySE1 += " ,SA1.A1_PESSOA 		    	AS TIPOCLI_INT"
    cQrySE1 += " ,SA1.A1_CGC 				    AS CNPJ_INT"
    cQrySE1 += " ,SA1.A1_NOME 			    	AS NOME_INT"
    cQrySE1 += " ,TRIM(SA1.A1_COD) + TRIM(SA1.A1_LOJA) 						AS CONTRATO_INT"
    cQrySE1 += " ,TRIM(SE1.E1_NUM)+'/'+TRIM(SE1.E1_PARCELA)					AS TITULO_PARCELA_INT"
    cQrySE1 += " ,SE1.E1_VENCREA 											AS VENCIMENTO_INT"
    cQrySE1 += " ,SE1.E1_SALDO 												AS VALOR_INT"
    cQrySE1 += " ,IsNull(TRIM(SE1.E1_TIPO)+'-'+TRIM(SX5A.X5_DESCRI),'')		AS DETALHE_INT"
    cQrySE1 += " ,IsNull(TRIM(SA1.A1_ZZESTAB)+'-'+TRIM(SX5B.X5_DESCRI),'')	AS CONTRATO_INT"
    cQrySE1 += " ,SA1.A1_ENDCOB												AS END_COBRANCA_INT"
    cQrySE1 += " ,SA1.A1_ZZWHATS									     	AS FONE1_INT"
    cQrySE1 += " ,SA1.A1_EMAIL											   	AS EMAIL1_INT"
    cQrySE1 += " ,SA1.A1_END												AS END1_INT"
    cQrySE1 += " ,SA1.A1_BAIRRO												AS BAIRRO1_INT"
    cQrySE1 += " ,SA1.A1_MUN													AS CIDADE1_INT"
    cQrySE1 += " ,SA1.A1_EST													AS UF1_INT"
    cQrySE1 += " ,SA1.A1_CEP													AS CEP1_INT"
    cQrySE1 += " ,SA1.A1_TEL													AS FONE2_INT"
    cQrySE1 += " ,'NFISCAL_'+TRIM(SA1.A1_CGC)+'_'+TRIM(SE1.E1_NUM)+'_'+TRIM(SE1.E1_PARCELA)+'.PDF' AS BOLETO"
    cQrySE1 += " ,SF2.F2_CHVNFE												AS CHAVE_NF_INT"
    cQrySE1 += " ,CASE"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'B' 															THEN 'LIQUIDADO'"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA =  '' AND SE1.E1_VENCREA >  '"+Dtos(Date())+"'	THEN 'A VENCER'"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA =  '' AND SE1.E1_VENCREA <= '"+Dtos(Date())+"' 	THEN 'VENCIDO'"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA <> '' AND SE1.E1_VENCREA >  '"+Dtos(Date())+"'	THEN 'PARCIAL A VENCER'"
    cQrySE1 += " SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA <> ''      AND SE1.E1_VENCREA <= '"+Dtos(Date())+"' 	THEN 'VENCIDO PARCIAL'"
    cQrySE1 += " ELSE 'SEM STATUS' "
    cQrySE1 += " END 														AS STATUS_INT"+;
                " ,IsNull(SE1.E1_SITUACA+'-'+TRIM(FRV.FRV_DESCRI),'') 		AS SITUACAO_NOVO"+;
		        " ,IsNull(SE1.E1_ZZCART+'-'+TRIM(SX5C.X5_DESCRI),'') 			AS CARTEIRA_NOVO"+;
                " ,SE1.E1_BAIXA 												AS DTBAIXA"+;
                " ,SE1.R_E_C_N_O_												AS RECSE1"+;
                "  FROM "+Retsqlname("SE1")+" SE1 WITH(NOLOCK)"+;
                " INNER JOIN "+Retsqlname("SF2")+" AS SF2 WITH(NOLOCK)"+; 
                " ON SF2.F2_FILIAL = SE1.E1_FILIAL"+;
                " AND SF2.F2_DOC = SE1.E1_NUM"+;
                " AND SF2.F2_SERIE = SE1.E1_PREFIXO"+;
                " AND SF2.F2_CLIENTE = SE1.E1_CLIENTE"+;
                " AND SF2.F2_LOJA = SE1.E1_LOJA"+;
                " AND SF2.D_E_L_E_T_ = '' " +;
	            " INNER JOIN "+Retsqlname("SA1")+" SA1 WITH(NOLOCK)"+;
                " ON SA1.A1_FILIAL = '  '"+;
                " AND SA1.A1_COD = SE1.E1_CLIENTE"+;
                " AND SA1.A1_LOJA = SE1.E1_LOJA"+;
                " AND SA1.A1_PESSOA = 'J' "+;
                " AND SA1.D_E_L_E_T_ = ''" +;
                " LEFT JOIN "+Retsqlname("FRV")+" FRV WITH(NOLOCK)"+;
                " ON FRV.FRV_FILIAL = '  '"+;
                " AND FRV.FRV_CODIGO = SE1.E1_SITUACA"+;
                " AND FRV.D_E_L_E_T_ = ''"+;
                " LEFT JOIN "+Retsqlname("SX5")+" SX5A WITH(NOLOCK)"+;
                " ON SX5A.X5_FILIAL = '  '"+;
                " AND SX5A.X5_TABELA = '05'"+;
                " AND SX5A.X5_CHAVE = SE1.E1_TIPO"+;
                " AND SX5A.D_E_L_E_T_ = ''"+;
                " LEFT JOIN "+Retsqlname("SX5")+" SX5B WITH(NOLOCK)"+;
                " ON SX5B.X5_FILIAL = '  '"+;
                " AND SX5B.X5_TABELA = 'ES'"+;
                " AND SX5B.X5_CHAVE = SA1.A1_ZZESTAB"+;
                " AND SX5B.D_E_L_E_T_ = ''"+;
                " LEFT JOIN "+Retsqlname("SX5")+" SX5C WITH(NOLOCK)"+;
                " ON SX5C.X5_FILIAL = '  '"+;
                " AND SX5C.X5_TABELA = 'Z1'"+;
                " AND SX5C.X5_CHAVE = SE1.E1_ZZCART"+;
                " AND SX5C.D_E_L_E_T_ = ''"+;
                " WHERE SE1.E1_FILIAL IN ('02','03')"+;
                " AND SE1.E1_TIPO IN ('NF','BOL','NCC','RA') "+;
                " AND ( SE1.E1_BAIXA >= '20240811' OR SE1.E1_BAIXA = '' )"+;
                " AND SE1.D_E_L_E_T_ = ''"+;
                " ORDER BY SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_CLIENTE, SE1.E1_LOJA"
                 /////AND SE1.CAMPO = X CRITERIO PARA TITULOS QUE FORAM REGISTRADOS NO BANCO.
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
