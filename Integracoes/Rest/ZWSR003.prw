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


        _cUserPar 	:= AllTrim( SuperGetMv( "DUX_RES01", , "allan.rabelo"))	    // Usuario para autenticacao no WS
        _cPassPar 	:= AllTrim( SuperGetMv( "DUX_RES02", , "123456"	))	        // Senha para autenticao no WS
        _cLogin     := _cUserPar+":"+_cPassPar


        _aRet := ZVALREQ(_cLogin,_cAuthorization,_cEmpFil)


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

Static Function ZTITGET(_oJson, _cEmpFil , self )
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
    Local nDiasbx := SuperGetMv("DUX_DIBX",.F.,30)
    Local cSearch       := ''
    // Local cWhere        := "AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'"
    Local nCount        := 0
    Local nStart        := 1
    Local nReg          := 0
    Local nAux          := 0


    aCabec  := {}
    aItens  := {}
    aImpItem := {}
    JBody   := JSONObject():New()
    //
    jBody["Status"]   := {}
    aTitulos := JsonObject():New()
    aTit := JSONObject():New()

    cQrySE1 := "  SELECT 	SE1.E1_FILIAL		AS FILIAL "
    cQrySE1 += " ,SA1.A1_PESSOA 		    	AS TIPOCLI   "
    cQrySE1 += " ,SA1.A1_CGC 				    AS CNPJ   "
    cQrySE1 += " ,SA1.A1_NOME 			    	AS NOME   "
    cQrySE1 += " ,TRIM(SA1.A1_COD) + TRIM(SA1.A1_LOJA) 						AS CONTRATO   "
    cQrySE1 += " ,TRIM(SE1.E1_NUM)+'/'+TRIM(SE1.E1_PARCELA)					AS TITULO_PARCELA   "
    cQrySE1 += " ,SE1.E1_VENCREA 											AS VENCIMENTO   "
    cQrySE1 += " ,SE1.E1_SALDO 												AS VALOR   "
    cQrySE1 += " ,IsNull(TRIM(SE1.E1_TIPO)+'-'+TRIM(SX5A.X5_DESCRI),'')		AS DETALHE   "
    cQrySE1 += " ,IsNull(TRIM(SA1.A1_ZZESTAB)+'-'+TRIM(SX5B.X5_DESCRI),'')	AS CARTCONTRATO   "
    cQrySE1 += " ,SA1.A1_ENDCOB												AS END_COBRANCA   "
    cQrySE1 += " ,SA1.A1_ZZWHATS									     	AS FONE1   "
    cQrySE1 += " ,SA1.A1_EMAIL											   	AS EMAIL1   "
    cQrySE1 += " ,SA1.A1_END												AS END1   "
    cQrySE1 += " ,SA1.A1_BAIRRO												AS BAIRRO1   "
    cQrySE1 += " ,SA1.A1_MUN													AS CIDADE1   "
    cQrySE1 += " ,SA1.A1_EST													AS UF1   "
    cQrySE1 += " ,SA1.A1_CEP													AS CEP1   "
    cQrySE1 += " ,SA1.A1_TEL													AS FONE2   "
    cQrySE1 += " ,'NFISCAL_'+TRIM(SA1.A1_CGC)+'_'+TRIM(SE1.E1_NUM)+'_'+TRIM(SE1.E1_PARCELA)+'.PDF' AS BOLETO"
    cQrySE1 += " ,SF2.F2_CHVNFE												AS CHAVE_NF   "
    cQrySE1 += " ,CASE"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'B' 															THEN 'LIQUIDADO'"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA =  '' AND SE1.E1_VENCREA >  '"+Dtos(Date())+"'	THEN 'A VENCER'"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA =  '' AND SE1.E1_VENCREA <= '"+Dtos(Date())+"' 	THEN 'VENCIDO'"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA <> '' AND SE1.E1_VENCREA >  '"+Dtos(Date())+"'	THEN 'PARCIAL A VENCER'"
    cQrySE1 += " WHEN SE1.E1_STATUS  = 'A' AND SE1.E1_BAIXA <> '' AND SE1.E1_VENCREA <= '"+Dtos(Date())+"' 	THEN 'VENCIDO PARCIAL'"
    cQrySE1 += " ELSE 'SEM STATUS' "
    cQrySE1 += " END 														AS STATUSX   "
    cQrySE1 += " ,IsNull(SE1.E1_SITUACA+'-'+TRIM(FRV.FRV_DESCRI),'') 		AS SITUACAO   "
    //cQrySE1 += " ,IsNull(SE1.E1_ZZCART+'-'+TRIM(SX5C.X5_DESCRI),'') 			AS CARTEIRA   "
    cQrySE1 += " ,SE1.E1_BAIXA 												AS DTBAIXA"
    cQrySE1 += " ,SE1.R_E_C_N_O_												AS RECSE1"
    cQrySE1 += "  FROM "+Retsqlname("SE1")+" SE1 WITH(NOLOCK)"
    cQrySE1 += " INNER JOIN "+Retsqlname("SF2")+" AS SF2 WITH(NOLOCK)"
    cQrySE1 += " ON SF2.F2_FILIAL = SE1.E1_FILIAL"
    cQrySE1 += " AND SF2.F2_DOC = SE1.E1_NUM"
    cQrySE1 += " AND SF2.F2_SERIE = SE1.E1_PREFIXO"
    cQrySE1 += " AND SF2.F2_CLIENTE = SE1.E1_CLIENTE"
    cQrySE1 += " AND SF2.F2_LOJA = SE1.E1_LOJA"
    cQrySE1 += " AND SF2.D_E_L_E_T_ = '' "
    cQrySE1 += " INNER JOIN "+Retsqlname("SA1")+" SA1 WITH(NOLOCK)"
    cQrySE1 += " ON SA1.A1_FILIAL = '  '"
    cQrySE1 += " AND SA1.A1_COD = SE1.E1_CLIENTE"
    cQrySE1 += " AND SA1.A1_LOJA = SE1.E1_LOJA"
    cQrySE1 += " AND SA1.A1_PESSOA = 'J' "
    cQrySE1 += " AND SA1.D_E_L_E_T_ = ''"
    cQrySE1 += " LEFT JOIN "+Retsqlname("FRV")+" FRV WITH(NOLOCK)"
    cQrySE1 += " ON FRV.FRV_FILIAL = '  '"
    cQrySE1 += " AND FRV.FRV_CODIGO = SE1.E1_SITUACA"
    cQrySE1 += " AND FRV.D_E_L_E_T_ = ''"
    cQrySE1 += " LEFT JOIN "+Retsqlname("SX5")+" SX5A WITH(NOLOCK)"
    cQrySE1 += " ON SX5A.X5_FILIAL = '  '"
    cQrySE1 += " AND SX5A.X5_TABELA = '05'"
    cQrySE1 += " AND SX5A.X5_CHAVE = SE1.E1_TIPO"
    cQrySE1 += " AND SX5A.D_E_L_E_T_ = ''"
    cQrySE1 += " LEFT JOIN "+Retsqlname("SX5")+" SX5B WITH(NOLOCK)"
    cQrySE1 += " ON SX5B.X5_FILIAL = '  '"
    cQrySE1 += " AND SX5B.X5_TABELA = 'ES'"
    cQrySE1 += " AND SX5B.X5_CHAVE = SA1.A1_ZZESTAB"
    cQrySE1 += " AND SX5B.D_E_L_E_T_ = ''"
    /*
    cQrySE1 += " LEFT JOIN "+Retsqlname("SX5")+" SX5C WITH(NOLOCK)"
    cQrySE1 += " ON SX5C.X5_FILIAL = '  '"
    cQrySE1 += " AND SX5C.X5_TABELA = 'Z1'"
    cQrySE1 += " AND SX5C.X5_CHAVE = SE1.E1_ZZCART"
    cQrySE1 += " AND SX5C.D_E_L_E_T_ = ''"
    */
    cQrySE1 += " WHERE SE1.E1_FILIAL IN ('02','03')"
    cQrySE1 += " AND SE1.E1_TIPO IN ('NF','BOL','NCC','RA') "
    cQrySE1 += " AND ( SE1.E1_BAIXA >= '"+Dtos(DaySub(Date(),nDiasbx))+"' OR SE1.E1_BAIXA = '' )"
    /////////AND SE1.CAMPO = X CRITERIO PARA TITULOS QUE FORAM REGISTRADOS NO BANCO./////////////
    cQrySE1 += " AND SE1.D_E_L_E_T_ = ''"
    cQrySE1 += " ORDER BY SE1.E1_FILIAL, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_CLIENTE, SE1.E1_LOJA"

    /////////// Verifico qual é o processo ////////////////
    ////////////// Verifico se a tabela já se encontra aberta e fecho ////////////
    IF SELECT("TMPC1") > 0
        TMPC1->(DbCloseArea())
    ENDIF

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQrySE1),"TMPC1",.F.,.T.)
    ///////////// Aponto dados para o JSON /////////////

    If TMPC1->( ! Eof() )
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
        TMPC1->( DBGoTop() )

        //-------------------------------------------------------------------

    Else
        //-------------------------------------------------------------------
        // Nao encontrou registros
        //-------------------------------------------------------------------
        aTit['hasNext'] := .F.
    EndIf
    aTitulos["paginaatual"] := self:page
    aTitulos["numtopage"] := self:pageSize
    aTitulos["totalpaginas"] := (nReg/self:pageSize)
    // aTitulos["totalpaginas"] := (nRecord / aself:pageSize)
    aTitulos["Item"] := {}

    DbSelectArea('SE1')
    SE1->(dbSetOrder(1))

    While !TMPC1->(eof())
        nCount++
        If nCount >= nStart
            nAux++
            aTit := {}
            aTit := JSONObject():New()
            if lRet
                aTit["tipocliente"]              := TMPC1->TIPOCLI
                aTit["cnpjcpf"]                  := TMPC1->CNPJ
                aTit["nome"]                     := TMPC1->NOME
                aTit["numcontrato"]              := TMPC1->CONTRATO
                aTit["titulo"]                   := TMPC1->TITULO_PARCELA
                aTit["vencimento"]               := TMPC1->VENCIMENTO
                aTit["valor"]                    := TMPC1->VALOR
                aTit["detalhe"]                     := TMPC1->DETALHE
                if !Empty(TMPC1->CARTCONTRATO)
                    aTit["cartcontrato"]                 := TMPC1->CARTCONTRATO
                else
                    aTit["cartcontrato"]                 := "Geral"
                endif
                aTit["endcob"]                   := TMPC1->END_COBRANCA
                aTit["email"]                    := ALLTRIM(TMPC1->EMAIL1)
                aTit["end"]                      := TMPC1->END1
                aTit["bairro"]                   := TMPC1->BAIRRO1
                aTit["estado"]                   := TMPC1->UF1
                aTit["cep"]                      := TMPC1->CEP1
                aTit["telefone1"]                := TMPC1->FONE1
                aTit["telefone2"]                := TMPC1->FONE2
                aTit["boletoapi"]                := TMPC1->BOLETO
                aTit["nfapi"]                    := TMPC1->CHAVE_NF
                aTit["statusparc"]               := TMPC1->STATUSX
                aTit["situacao"]                 := TMPC1->SITUACAO
                //aTit["carteira"]                 := TMPC1->CARTEIRA
            endif
            aAdd(aTitulos["Item"], aTit)
            If Len( aTitulos["Item"]) >= self:pageSize
                Exit
            EndIf
            // nAux := nAux + 1
        endif
        TMPC1->(DBSkip())
    Enddo
    // Valida a exitencia de mais paginas
    //-------------------------------------------------------------------
    If nReg  > self:pageSize
        aTitulos['hasNext'] := .T.
    Else
        aTitulos['hasNext'] := .F.
    EndIf
   // aTitulos["Total"] := cValToChar(nAux)
    RestArea(aArea)
    TMPC1->( DBCloseArea() )
Return(aTitulos)
