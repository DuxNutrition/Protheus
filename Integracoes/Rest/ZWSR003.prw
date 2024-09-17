#Include "Protheus.ch"
#Include "RESTFUL.ch"
#Include "tbiconn.ch"
#include "rwmake.ch"
#include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "RESTFUL.CH"

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
WSRESTFUL ZWSR003 DESCRIPTION "Cadastro de produtos" FORMAT APPLICATION_JSON
    WSDATA page                AS INTEGER  OPTIONAL
    WSDATA pageSize             AS INTEGER  OPTIONAL
    WSDATA searchKey            AS STRING   OPTIONAL
    WSDATA branch               AS STRING   OPTIONAL
    WSDATA byId                 AS BOOLEAN  OPTIONAL

    WSMETHOD GET ZWS003GET DESCRIPTION "ZWSR003 GET PRODUTO" WSSYNTAX "ZWS003GET" PATH '/api/v1/ZWSR003' PRODUCES APPLICATION_JSON
    //WSMETHOD GET customers DESCRIPTION 'SP Lista de Clientes' WSSYNTAX '/api/v1/spcliente' PATH '/api/v1/spcliente' PRODUCES APPLICATION_JSON
END WSRESTFUL

WSMETHOD GET ZWS003GET WSRECEIVE searchKey, page, pageSize, branch WSREST ZWSR003
Local lRet:= .T.
lRet := GetFin10( self )
Return( lRet )

Static Function GetFin10( Self )
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

    Default self:searchKey     := ''
    Default self:branch        := ''
    Default self:page      := 1
    Default self:pageSize  := 1000
    Default self:byId      :=.F.

    Begin Sequence

        Conout("ZWSR003 - Inicio "+DtoC(date())+" "+Time())

        Self:SetContentType("application/cJson")

        cBody           := ::GetContent()
        jBody           := JSONObject():New()
        _cAuthorization := Self:GetHeader('Authorization')
        _cEmpFil 		:= Self:GetHeader("tenantid", .F.)

        // PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"
        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_API003", , "hom.api.irecebi"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_API004", , "20@epT5jgS"	))	        // Senha para autenticao no WS
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
        jBody := ZTITGET(@_oJson, _cEmpFil, Self )
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
±±³Descri‡…o ³ Titulos a receber vencimento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Encontrar titulos financeiro                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ZTITGET(_oJson, _cEmpFil , self )

    Local aArea         := GetArea()
    Local aCabec
    Local aItens
    Local aTitulos
    Local aTit
    Local jBody         As JSON
    Local cTipoTit      := FormatIn(SuperGetMv("DUX_FAT009",.F.,"NF|BOL|NCC|RA"),"|") 
    Local cFilTit       := FormatIn(SuperGetMv("DUX_FAT010",.F.,"02|03"),"|") 
    Local cAliasTRB		:= GetNextAlias()
    Local cQrySE1	    := ""
    Local nAux          := 0
    Local lRet          := .T.
    Local nDiasbx       := SuperGetMv("DUX_FAT011",.F.,30)
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0


    aCabec          := {}
    aItens          := {}
    aImpItem        := {}
    JBody           := JSONObject():New()
    jBody["Status"] := {}
    aTitulos        := JsonObject():New()
    aTit            := JSONObject():New()

    If Select( (cAliasTRB) ) > 0
        (cAliasTRB)->(DbCloseArea())
    EndIf

    cQrySE1 := "  SELECT    SE1.E1_FILIAL		                                                    AS FILIAL "  + CRLF
    cQrySE1 += "            ,SA1.A1_PESSOA 		    	                                            AS A1_PESSOA "  + CRLF
    cQrySE1 += "            ,SA1.A1_CGC 				                                            AS A1_CGC "  + CRLF
    cQrySE1 += "            ,SA1.A1_NOME 			    	                                        AS A1_NOME "  + CRLF
    cQrySE1 += "            ,TRIM(SA1.A1_COD) + TRIM(SA1.A1_LOJA) 						            AS A1_COD_LOJA "  + CRLF
    cQrySE1 += "            ,TRIM(SE1.E1_NUM)+'/'+TRIM(SE1.E1_PARCELA)					            AS E1_NUM_PARCELA "  + CRLF
    cQrySE1 += "            ,SE1.E1_VENCREA 											            AS E1_VENCREA "  + CRLF
    cQrySE1 += "            ,SE1.E1_SALDO 												            AS E1_SALDO "  + CRLF
    cQrySE1 += "            ,IsNull(TRIM(SE1.E1_TIPO)+'-'+TRIM(SX5A.X5_DESCRI),'')		            AS E1_TIPO "  + CRLF
    cQrySE1 += "            ,IsNull(TRIM(SA1.A1_ZZESTAB)+'-'+TRIM(SX5B.X5_DESCRI),'')	            AS A1_ZZESTAB "  + CRLF
    cQrySE1 += "            ,SA1.A1_ENDCOB												            AS A1_ENDCOB "  + CRLF
    cQrySE1 += "            ,SA1.A1_ZZWHATS									     	                AS A1_ZZWHATS "  + CRLF
    cQrySE1 += "            ,SA1.A1_EMAIL											   	            AS A1_EMAIL "  + CRLF
    cQrySE1 += "            ,SA1.A1_END												                AS A1_END "  + CRLF
    cQrySE1 += "            ,SA1.A1_BAIRRO												            AS A1_BAIRRO "  + CRLF
    cQrySE1 += "            ,SA1.A1_MUN													            AS A1_MUN "  + CRLF
    cQrySE1 += "            ,SA1.A1_EST													            AS A1_EST "  + CRLF
    cQrySE1 += "            ,SA1.A1_CEP													            AS A1_CEP "  + CRLF
    cQrySE1 += "            ,SA1.A1_TEL													            AS A1_TEL "  + CRLF
    cQrySE1 += "            ,'nfiscal_'+TRIM(SA1.A1_CGC)+'_'+TRIM(SE1.E1_PORTADO)+'_'+TRIM(SE1.E1_PREFIXO)+'_'+TRIM(SE1.E1_NUM)+'_'+TRIM(SE1.E1_PARCELA)+'.PDF' AS ARQ_BOLETO "  + CRLF
    cQrySE1 += "            ,SF2.F2_CHVNFE												            AS F2_CHVNFE "  + CRLF
    cQrySE1 += "            ,CASE "  + CRLF
    cQrySE1 += "                WHEN SE1.E1_STATUS  = 'B' 															        THEN 'LIQUIDADO' "  + CRLF
    cQrySE1 += "                WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA =  '' AND SE1.E1_VENCREA >  '"+Dtos(Date())+"'	THEN 'A VENCER' "  + CRLF
    cQrySE1 += "                WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA =  '' AND SE1.E1_VENCREA <= '"+Dtos(Date())+"' 	THEN 'VENCIDO' "  + CRLF
    cQrySE1 += "                WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA <> '' AND SE1.E1_VENCREA >  '"+Dtos(Date())+"'	THEN 'PARCIAL A VENCER' "  + CRLF
    cQrySE1 += "                WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA <> '' AND SE1.E1_VENCREA <= '"+Dtos(Date())+"' 	THEN 'VENCIDO PARCIAL' "  + CRLF
    cQrySE1 += "                ELSE 'SEM STATUS' "  + CRLF
    cQrySE1 += "            END 														            AS STATUSPARC "  + CRLF
    cQrySE1 += "            ,IsNull(SE1.E1_SITUACA+'-'+TRIM(FRV.FRV_DESCRI),'') 		            AS E1_SITUACA "  + CRLF
    //cQrySE1 += "            ,IsNull(SE1.E1_ZZCART+'-'+TRIM(SX5C.X5_DESCRI),'') 			            AS E1_ZZCART "  + CRLF
    cQrySE1 += " FROM "+Retsqlname("SE1")+" SE1 WITH(NOLOCK) "  + CRLF
    cQrySE1 += "    INNER JOIN "+Retsqlname("SF2")+" AS SF2 WITH(NOLOCK) "  + CRLF
    cQrySE1 += "        ON SF2.F2_FILIAL = SE1.E1_FILIAL "  + CRLF
    cQrySE1 += "        AND SF2.F2_DOC = SE1.E1_NUM "  + CRLF
    cQrySE1 += "        AND SF2.F2_SERIE = SE1.E1_PREFIXO "  + CRLF
    cQrySE1 += "        AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "  + CRLF
    cQrySE1 += "        AND SF2.F2_LOJA = SE1.E1_LOJA "  + CRLF
    cQrySE1 += "        AND SF2.D_E_L_E_T_ = '' "  + CRLF
    cQrySE1 += "    INNER JOIN "+Retsqlname("SA1")+" SA1 WITH(NOLOCK) "  + CRLF
    cQrySE1 += "        ON SA1.A1_FILIAL = '  ' "  + CRLF
    cQrySE1 += "        AND SA1.A1_COD = SE1.E1_CLIENTE "  + CRLF
    cQrySE1 += "        AND SA1.A1_LOJA = SE1.E1_LOJA "  + CRLF
    cQrySE1 += "        AND SA1.A1_PESSOA = 'J' "  + CRLF
    cQrySE1 += "        AND SA1.D_E_L_E_T_ = '' "  + CRLF
    cQrySE1 += "    LEFT JOIN "+Retsqlname("FRV")+" FRV WITH(NOLOCK) "  + CRLF
    cQrySE1 += "        ON FRV.FRV_FILIAL = '  ' "  + CRLF
    cQrySE1 += "        AND FRV.FRV_CODIGO = SE1.E1_SITUACA "  + CRLF
    cQrySE1 += "        AND FRV.D_E_L_E_T_ = '' "  + CRLF
    cQrySE1 += "    LEFT JOIN "+Retsqlname("SX5")+" SX5A WITH(NOLOCK) "  + CRLF
    cQrySE1 += "        ON SX5A.X5_FILIAL = '  ' "  + CRLF
    cQrySE1 += "        AND SX5A.X5_TABELA = '05' "  + CRLF
    cQrySE1 += "        AND SX5A.X5_CHAVE = SE1.E1_TIPO "  + CRLF
    cQrySE1 += "        AND SX5A.D_E_L_E_T_ = '' "  + CRLF
    cQrySE1 += "    LEFT JOIN "+Retsqlname("SX5")+" SX5B WITH(NOLOCK) "  + CRLF
    cQrySE1 += "        ON SX5B.X5_FILIAL = '  ' "  + CRLF
    cQrySE1 += "        AND SX5B.X5_TABELA = 'ES' "  + CRLF
    cQrySE1 += "        AND SX5B.X5_CHAVE = SA1.A1_ZZESTAB "  + CRLF
    cQrySE1 += "        AND SX5B.D_E_L_E_T_ = '' "  + CRLF
    /*  
    cQrySE1 += "    LEFT JOIN "+Retsqlname("SX5")+" SX5C WITH(NOLOCK) "  + CRLF
    cQrySE1 += "        ON SX5C.X5_FILIAL = '  ' "  + CRLF
    cQrySE1 += "        AND SX5C.X5_TABELA = 'Z1' "  + CRLF
    cQrySE1 += "        AND SX5C.X5_CHAVE = SE1.E1_ZZCART "  + CRLF
    cQrySE1 += "        AND SX5C.D_E_L_E_T_ = '' "  + CRLF
    */ 
    cQrySE1 += " WHERE SE1.E1_FILIAL IN "+cFilTit+" "  + CRLF
    cQrySE1 += " AND SE1.E1_TIPO IN "+cTipoTit+" "  + CRLF
    cQrySE1 += " AND ( SE1.E1_BAIXA >= '"+Dtos(DaySub(Date(),nDiasbx))+"' OR SE1.E1_BAIXA = '' ) "  + CRLF
    cQrySE1 += " AND SE1.E1_PORTADO <> '' "  + CRLF
    cQrySE1 += " AND SE1.E1_NUMBCO <> '' "  + CRLF
    /////////AND SE1.CAMPO = X CRITERIO PARA TITULOS QUE FORAM REGISTRADOS NO BANCO./////////////
    cQrySE1 += " AND SE1.D_E_L_E_T_ = '' "  + CRLF
    cQrySE1 += " ORDER BY SE1.E1_FILIAL, SE1.E1_PORTADO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NUM, SE1.E1_PARCELA " + CRLF

   // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQrySE1), cAliasTRB, .T., .T. )

    DbSelectArea((cAliasTRB))
    (cAliasTRB)->(dbGoTop())
    If (cAliasTRB)->( ! Eof() )
        //-------------------------------------------------------------------
        // Identifica a quantidade de registro no alias temporário
        //-------------------------------------------------------------------
        COUNT TO nRecord
        //-------------------------------------------------------------------
        // nStart -> primeiro registro da pagina
        // nReg -> numero de registros do inicio da pagina ao fim do arquivo
        //-------------------------------------------------------------------
        If self:page > 1
            nStart := ( ( self:page - 1 ) * self:pageSize ) + 1
            nReg := nRecord - nStart + 1
        Else
            nReg := nRecord
        EndIf

        //-------------------------------------------------------------------
        // Posiciona no primeiro registro.
        //-------------------------------------------------------------------
        (cAliasTRB)->( DBGoTop() )

        //-------------------------------------------------------------------

    Else
        //-------------------------------------------------------------------
        // Nao encontrou registros
        //-------------------------------------------------------------------
        aTit['hasNext'] := .F.
    EndIf
    aTitulos["paginaatual"] := self:page
    aTitulos["numtopage"] := self:pageSize
    aTitulos["totalpaginas"] := Round((nReg/self:pageSize),0)
    aTitulos["Item"] := {}

    DbSelectArea('SE1')
    SE1->(dbSetOrder(1))

    (cAliasTRB)->(dbGoTop())
    While !(cAliasTRB)->(eof())

        nCount++
    
        If nCount >= nStart
    
            nAux++
            aTit := {}
            aTit := JSONObject():New()
            If lRet
                aTit["ctipocli"]            := AllTrim((cAliasTRB)->A1_PESSOA)
                aTit["ccnpj"]               := AllTrim((cAliasTRB)->A1_CGC)
                aTit["cnome"]               := AllTrim((cAliasTRB)->A1_NOME)
                aTit["ccontrato"]           := AllTrim((cAliasTRB)->A1_COD_LOJA)
                aTit["ctitulo"]             := AllTrim((cAliasTRB)->E1_NUM_PARCELA)
                aTit["cvencimento"]         := AllTrim(DToC(SToD((cAliasTRB)->E1_VENCREA)))
                aTit["nvalor"]              := (cAliasTRB)->E1_SALDO
                aTit["cdetalhe"]            := AllTrim((cAliasTRB)->E1_TIPO)
                If !Empty((cAliasTRB)->A1_ZZESTAB)
                    aTit["ccartcontrato"]   := AllTrim((cAliasTRB)->A1_ZZESTAB)
                Else
                    aTit["ccartcontrato"]   := "GERAL"
                EndIf
                aTit["cendcob"]             := AllTrim((cAliasTRB)->A1_ENDCOB)
                aTit["cemail"]              := AllTrim((cAliasTRB)->A1_EMAIL)
                aTit["cendereco"]           := AllTrim((cAliasTRB)->A1_END)
                aTit["cbairro"]             := AllTrim((cAliasTRB)->A1_BAIRRO)
                aTit["cmunicipio"]          := AllTrim((cAliasTRB)->A1_MUN)
                aTit["cestado"]             := AllTrim((cAliasTRB)->A1_EST)
                aTit["ccep"]                := AllTrim((cAliasTRB)->A1_CEP)
                aTit["cfone1"]              := AllTrim((cAliasTRB)->A1_ZZWHATS)
                aTit["cfone2"]              := AllTrim((cAliasTRB)->A1_TEL)
                aTit["cboletoapi"]          := AllTrim((cAliasTRB)->ARQ_BOLETO)
                aTit["cchavenfe"]           := AllTrim((cAliasTRB)->F2_CHVNFE)
                aTit["csituacao"]           := AllTrim((cAliasTRB)->E1_SITUACA)
                aTit["ccarteira"]           := ""//AllTrim((cAliasTRB)->E1_ZZCART)
                aTit["cstatusparc"]         := AllTrim((cAliasTRB)->STATUSPARC)
            EndIf

            aAdd(aTitulos["Item"], aTit)

            If Len( aTitulos["Item"]) >= self:pageSize
                Exit
            EndIf

        EndIf
        (cAliasTRB)->(DBSkip())
    EndDo

    // Valida a exitencia de mais paginas
    If nReg  > self:pageSize
        aTitulos['hasNext'] := .T.
    Else
        aTitulos['hasNext'] := .F.
    EndIf

    RestArea(aArea)
    (cAliasTRB)->( DBCloseArea() )
Return(aTitulos)
