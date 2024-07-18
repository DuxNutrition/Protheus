#Include "Protheus.ch"
#Include "RESTFUL.ch"
#Include "tbiconn.ch"
#include "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0001 ³ Autor ³  Allan Rabelo         ³ Data ³ 15/07/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retornar calculos MATAXFIS de NFS                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL ZWSF001 DESCRIPTION "Rotina para retorno de calculos de impostos"
    WSMETHOD GET  DESCRIPTION "ZWSF001" WSSYNTAX "ZWSF001"
END WSRESTFUL

WSMETHOD GET WSSERVICE ZWSF001
    Local oNFCAB     := JsonObject():New()
    Local oItem      := JsonObject():New()
    Local aPlanilha  := Array(0)
    Local aItem      := Array(0)
    Local _aRet       := ""
    Local cBody      := ""
    Local _cAuthorization := ""
    Local _cEmpFil   := ""
    Local _cUser     := ""
    Local _cPass     := ""
    Local jBody    As JSON


    Self:SetContentType("application/cJson")
    _cAuthorization := Self:GetHeader('Authorization')
    _cEmpFil 		:= Self:GetHeader("tenantid", .F.)
    _cUser 	:= AllTrim( superGetMv( "DUX_RES01"	, , "allan.rabelo"	) )	// Usuario para autenticacao no WS
    _cPass 	:= AllTrim( superGetMv( "DUX_RES02"	, , "123456"	) )	// Senha para autenticao no WS
    cBody := ::GetContent()
    jBody    := JSONObject():New()
    If Empty(_cUser) .Or. Empty(_cPass)
        _aRet := {302,"Nao Autorizado [Parametros]"}
    Else
        _cChave := _cUser+":"+_cPass
        _cChave := Encode64( _cUser+":"+_cPass)
        If _cChave == Encode64( _cUser+":"+_cPass)
            _oJson := JsonObject():new()
            _oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))
            jBody := u_duxfsc(@_oJson, _cEmpFil)
            Self:SetResponse(FwHTTPEncode(jBody:ToJSON()))
            FwFreeObj(jBody)
        Else
            _aRet := {302,"Nao Autorizado"}
        endif
    endif
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZWSF0001 ³ Autor ³  Allan Rabelo         ³ Data ³ 15/07/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega impostos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                         ValCliEth                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function duxfsc(_oJson, _cEmpFil)
    Local lRet  := .T.

    Local aArea := GetArea()
    Local aCabec
    Local aItens
    Local aLinha
    Local aImpostos
    Local aImpItem := {}
    Local nLength := 0
    Local jBody     as JSON
    Local oJson
    Local oItems

    //Local cJson     := Self:GetContent()
    Local cError

    Local nX
    Local nY
    Local yX


    aCabec  := {}
    aItens  := {}
    aImpItem := {}
    JBody   := JSONObject():New()
    JBody["Status"] := {}

    DbSelectArea('SA1')
    SA1->(dbSetOrder(3))
    IF (SA1->(dbSeek(FWxFilial("SA1")+PadR(_oJson:GetJsonObject('CNPJ'),TamSX3("A1_CGC")[1]))))

        aAdd(aCabec,{"C5_TIPO",     AllTrim(_oJson:GetJsonObject('Tipo')),                         NIL})
        aAdd(aCabec,{"C5_CLIENTE",  SA1->A1_COD,         NIL})
        aAdd(aCabec,{"C5_LOJACLI",  SA1->A1_LOJA,          NIL})
        aAdd(aCabec,{"C5_TIPOCLI",     AllTrim(_oJson:GetJsonObject('TipoCli')),         NIL})

    else
        jBody["Status"]    := "404 - CNPJ Não encontrado"
        Return(jBody)
    endif
    //Busca os itens no JSON, percorre eles e adiciona no array da SC6
    oItems  := _oJson:GetJsonObject('Items')
    For nX  := 1 To Len (oItems)
        aLinha  := {}
        aAdd(aLinha,{"C6_ITEM",     StrZero(nX,2),                                          NIL})
        DbSelectArea('SB1')
        SB1->(dbSetOrder(1))
        if (SB1->(dbSeek(FWxFilial("SB1")+PadR(oItems[nX]:GetJsonObject('Produto'),TamSX3("B1_COD")[1]))))
            aAdd(aLinha,{"C6_PRODUTO",  AllTrim(oItems[nX]:GetJsonObject('Produto')),           NIL})
        else
            jBody["Status"]    := "404 - Produto "+AllTrim(oItems[nX]:GetJsonObject('Produto'))+" não encontrado"
            Return(jBody)
        endif
        aAdd(aLinha,{"C6_QTDVEN",   oItems[nX]:GetJsonObject('Quantidade'),              NIL})
        aAdd(aLinha,{"C6_PRCVEN",   oItems[nX]:GetJsonObject('PrcVenda'),                 NIL})
        aAdd(aLinha,{"C6_VALOR",    oItems[nX]:GetJsonObject('Valor'),                      NIL})
        aAdd(aLinha,{"C6_OPER",      AllTrim(oItems[nX]:GetJsonObject('Operacao')),   NIL})
        aAdd(aItens,aLinha)

        cTes := MaTesInt(2,aItens[nX][6][2],aCabec[2][2],aCabec[3][2],"C",aItens[nX][2][2])
        aImpostos := U_FIMPOSTOS(aCabec[2][2],aCabec[3][2],aCabec[1][2],aItens[nX][2][2],cTes,aItens[nX][3][2],aItens[nX][4][2],aItens[nX][5][2])
        aAdd(aImpItem,aImpostos)

    Next nX

    nLength := 0
    jBody["Item Impostos"] := {}
    For yX :=1 To Len (aImpItem)
        jBody["Status"]    := "200 - OK"
        aAdd(jBody["Item Impostos"], JSONObject():New() )
        nLength++
        // Adiciona os atributos básicos do produto
        jBody["Item Impostos"][nLength]["Produto"]    := aImpItem[yX][1]
        jBody["Item Impostos"][nLength]["Tes"]    := aImpItem[yX][2]
        jBody["Item Impostos"][nLength]["BaseICMS"] := aImpItem[yX][4]
        jBody["Item Impostos"][nLength]["AliqICMS"]  := aImpItem[yX][5]
        jBody["Item Impostos"][nLength]["ValICMS"]  := aImpItem[yX][6]
        jBody["Item Impostos"][nLength]["BaseIPI"]  := aImpItem[yX][8]
        jBody["Item Impostos"][nLength]["AliqIPI"]  := aImpItem[yX][9]
        jBody["Item Impostos"][nLength]["ValIPI"]  := aImpItem[yX][10]
        jBody["Item Impostos"][nLength]["BasePIS"]  := aImpItem[yX][12]
        jBody["Item Impostos"][nLength]["AliqPIS"]  := aImpItem[yX][13]
        jBody["Item Impostos"][nLength]["ValPIS"]  := aImpItem[yX][14]
        jBody["Item Impostos"][nLength]["BaseCOF"]  := aImpItem[yX][16]
        jBody["Item Impostos"][nLength]["AliqCOF"]  := aImpItem[yX][17]
        jBody["Item Impostos"][nLength]["ValCOF"]  := aImpItem[yX][18]
        jBody["Item Impostos"][nLength]["BaseISS"]  := aImpItem[yX][20]
        jBody["Item Impostos"][nLength]["AliqISS"]  := aImpItem[yX][21]
        jBody["Item Impostos"][nLength]["ValISS"]  := aImpItem[yX][22]
        jBody["Item Impostos"][nLength]["BaseIRR"]  := aImpItem[yX][24]
        jBody["Item Impostos"][nLength]["AliqIRR"]  := aImpItem[yX][25]
        jBody["Item Impostos"][nLength]["ValIRR"]  := aImpItem[yX][26]
        jBody["Item Impostos"][nLength]["BaseINS"]  := aImpItem[yX][28]
        jBody["Item Impostos"][nLength]["AliqINS"]  := aImpItem[yX][29]
        jBody["Item Impostos"][nLength]["ValINS"]  := aImpItem[yX][30]
        jBody["Item Impostos"][nLength]["BaseCSL"]  := aImpItem[yX][32]
        jBody["Item Impostos"][nLength]["AliqCSL"]  := aImpItem[yX][33]
        jBody["Item Impostos"][nLength]["ValCSL"]  := aImpItem[yX][34]
        jBody["Item Impostos"][nLength]["BasePS2"]  := aImpItem[yX][36]
        jBody["Item Impostos"][nLength]["AliqPS2"]  := aImpItem[yX][37]
        jBody["Item Impostos"][nLength]["ValPS2"]  := aImpItem[yX][38]
        jBody["Item Impostos"][nLength]["BaseCF2"]  := aImpItem[yX][40]
        jBody["Item Impostos"][nLength]["AliqCF2"]  := aImpItem[yX][41]
        jBody["Item Impostos"][nLength]["ValCF2"]  := aImpItem[yX][42]
        jBody["Item Impostos"][nLength]["BaseICC"]  := aImpItem[yX][44]
        jBody["Item Impostos"][nLength]["AliqICC"]  := aImpItem[yX][45]
        jBody["Item Impostos"][nLength]["ValICC"]  := aImpItem[yX][46]
        jBody["Item Impostos"][nLength]["BaseICA"]  := aImpItem[yX][48]
        jBody["Item Impostos"][nLength]["AliqICA"]  := aImpItem[yX][49]
        jBody["Item Impostos"][nLength]["ValICA"]  := aImpItem[yX][50]
        jBody["Item Impostos"][nLength]["BaseICMSREF"]  := aImpItem[yX][52]
        jBody["Item Impostos"][nLength]["AliqICMSREF"]  := aImpItem[yX][53]
        jBody["Item Impostos"][nLength]["ValorICMSREF"]  := aImpItem[yX][54]
        jBody["Item Impostos"][nLength]["BaseICMSST"]  := aImpItem[yX][55]
        jBody["Item Impostos"][nLength]["AliqICMSST"]  := aImpItem[yX][56]
        jBody["Item Impostos"][nLength]["ValorICMSST"]  := aImpItem[yX][57]
        jBody["Item Impostos"][nLength]["Desconto"]  := aImpItem[yX][58]
        jBody["Item Impostos"][nLength]["Frete"]  := aImpItem[yX][59]
        jBody["Item Impostos"][nLength]["Seguro"]  := aImpItem[yX][60]
        jBody["Item Impostos"][nLength]["Despesas"]  := aImpItem[yX][61]
        jBody["Item Impostos"][nLength]["Mercadoria"]  := aImpItem[yX][62]
    Next yX

    RestArea(aArea)

Return (jBody)


/*______________________________________________________________________
   ¦Autor     ¦ Allan Rabelo                      ¦ Data ¦ 17/07/2024 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Funcao para calcular os impostos                      ¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

user function FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)
    local aImp := {}

    for i := 1 to 62
        AAdd(aImp,0)
    next

    // -------------------------------------------------------------------
    // Realiza os calculos necessários
    // -------------------------------------------------------------------
    MaFisIni(cCliente,;										// 01- Codigo Cliente/Fornecedor
        cLoja,;										// 02- Loja do Cliente/Fornecedor
        "C",;											// 03- C: Cliente / F: Fornecedor
        "N",;											// 04- Tipo da NF
        cTipo,;										// 05- Tipo do Cliente/Fornecedor
        MaFisRelImp("MTR700",{"SC5","SC6"}),;			// 06- Relacao de Impostos que suportados no arquivo
        ,;												// 07- Tipo de complemento
        ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
        "SB1",;										// 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
        "MTR700")										// 10- Nome da rotina que esta utilizando a funcao

    // -------------------------------------------------------------------
    // Monta o retorno para a MaFisRet
    // -------------------------------------------------------------------
    MaFisAdd(cProduto,cTes,nQtd,nPrc,0,"","",,0,0,0,0,nValor,0)

    // -------------------------------------------------------------------
    // Monta um array com os valores necessários
    // -------------------------------------------------------------------
    aImp[01] := cProduto
    aImp[02] := cTes
    aImp[03] := "ICM"							//03 ICMS
    aImp[04] := MaFisRet(1,"IT_BASEICM")		//04 Base do ICMS
    aImp[05] := MaFisRet(1,"IT_ALIQICM")		//05 Aliquota do ICMS
    aImp[06] := MaFisRet(1,"IT_VALICM")			//06 Valor do ICMS
    aImp[07] := "IPI"							//07 IPI
    aImp[08] := MaFisRet(1,"IT_BASEIPI")		//08 Base do IPI
    aImp[09] := MaFisRet(1,"IT_ALIQIPI")		//09 Aliquota do IPI
    aImp[10] := MaFisRet(1,"IT_VALIPI")			//10 Valor do IPI
    aImp[11] := "PIS"							//11 PIS/PASEP
    aImp[12] := MaFisRet(1,"IT_BASEPIS")		//12 Base do PIS
    aImp[13] := MaFisRet(1,"IT_ALIQPIS")		//13 Aliquota do PIS
    aImp[14] := MaFisRet(1,"IT_VALPIS")			//14 Valor do PIS
    aImp[15] := "COF"							//15 COFINS
    aImp[16] := MaFisRet(1,"IT_BASECOF")		//16 Base do COFINS
    aImp[17] := MaFisRet(1,"IT_ALIQCOF")		//17 Aliquota COFINS
    aImp[18] := MaFisRet(1,"IT_VALCOF")			//18 Valor do COFINS
    aImp[19] := "ISS"							//19 ISS
    aImp[20] := MaFisRet(1,"IT_BASEISS")		//20 Base do ISS
    aImp[21] := MaFisRet(1,"IT_ALIQISS")		//21 Aliquota ISS
    aImp[22] := MaFisRet(1,"IT_VALISS")			//22 Valor do ISS
    aImp[23] := "IRR"							//23 IRRF
    aImp[24] := MaFisRet(1,"IT_BASEIRR")		//24 Base do IRRF
    aImp[25] := MaFisRet(1,"IT_ALIQIRR")		//25 Aliquota IRRF
    aImp[26] := MaFisRet(1,"IT_VALIRR")			//26 Valor do IRRF
    aImp[27] := "INS"							//27 INSS
    aImp[28] := MaFisRet(1,"IT_BASEINS")		//28 Base do INSS
    aImp[29] := MaFisRet(1,"IT_ALIQINS")		//29 Aliquota INSS
    aImp[30] := MaFisRet(1,"IT_VALINS")			//30 Valor do INSS
    aImp[31] := "CSL"							//31 CSLL
    aImp[32] := MaFisRet(1,"IT_BASECSL")		//32 Base do CSLL
    aImp[33] := MaFisRet(1,"IT_ALIQCSL")		//33 Aliquota CSLL
    aImp[34] := MaFisRet(1,"IT_VALCSL")			//34 Valor do CSLL
    aImp[35] := "PS2"							//35 PIS/Pasep - Via Apuração
    aImp[36] := MaFisRet(1,"IT_BASEPS2")		//36 Base do PS2 (PIS/Pasep - Via Apuração)
    aImp[37] := MaFisRet(1,"IT_ALIQPS2")		//37 Aliquota PS2 (PIS/Pasep - Via Apuração)
    aImp[38] := MaFisRet(1,"IT_VALPS2")			//38 Valor do PS2 (PIS/Pasep - Via Apuração)
    aImp[39] := "CF2"							//39 COFINS - Via Apuração
    aImp[40] := MaFisRet(1,"IT_BASECF2")		//40 Base do CF2 (COFINS - Via Apuração)
    aImp[41] := MaFisRet(1,"IT_ALIQCF2")		//41 Aliquota CF2 (COFINS - Via Apuração)
    aImp[42] := MaFisRet(1,"IT_VALCF2")			//42 Valor do CF2 (COFINS - Via Apuração)
    aImp[43] := "ICC"							//43 ICMS Complementar
    aImp[44] := MaFisRet(1,"IT_ALIQCMP")		//44 Base do ICMS Complementar
    aImp[45] := MaFisRet(1,"IT_ALIQCMP")		//45 Aliquota do ICMS Complementar
    aImp[46] := MaFisRet(1,"IT_VALCMP")			//46 Valor do do ICMS Complementar
    aImp[47] := "ICA"							//47 ICMS ref. Frete Autonomo
    aImp[48] := MaFisRet(1,"IT_BASEICA")		//48 Base do ICMS ref. Frete Autonomo
    aImp[49] := 0								//49 Aliquota do ICMS ref. Frete Autonomo
    aImp[50] := MaFisRet(1,"IT_VALICA")			//50 Valor do ICMS ref. Frete Autonomo
    aImp[51] := "TST"							//51 ICMS ref. Frete Autonomo ST
    aImp[52] := MaFisRet(1,"IT_BASETST")		//52 Base do ICMS ref. Frete Autonomo ST
    aImp[53] := MaFisRet(1,"IT_ALIQTST")		//53 Aliquota do ICMS ref. Frete Autonomo ST
    aImp[54] := MaFisRet(1,"IT_VALTST")			//54 Valor do ICMS ref. Frete Autonomo ST
    aImp[55] := MaFisRet(1,"IT_BASESOL")		//55 Base do ICMS ST
    aImp[56] := MaFisRet(1,"IT_ALIQSOL")		//56 Aliquota do ICMS ST
    aImp[57] := MaFisRet(1,"IT_VALSOL")			//57 Valor do ICMS ST
    aImp[58] := MaFisRet(1,"IT_DESCONTO")		//58 Valor do Desconto
    aImp[59] := MaFisRet(1,"IT_FRETE")			//59 Valor do Frete
    aImp[60] := MaFisRet(1,"IT_SEGURO")			//60 Valor do Seguro
    aImp[61] := MaFisRet(1,"IT_DESPESA")		//61 Valor das Despesas
    aImp[62] := MaFisRet(1,"IT_VALMERC")		//62 Valor da Mercadoria
    /*	aImp[10] := MaFisRet(1,"IT_DESCZF")		//Valor de Desconto da Zona Franca de Manaus
	aImp[14] := MaFisRet(1,"IT_BASESOL")	//Base do ICMS Solidario
	aImp[15] := MaFisRet(1,"IT_ALIQSOL")	//Aliquota do ICMS Solidario
    aImp[16] := MaFisRet(1,"IT_MARGEM")		//Margem de lucro para calculo da Base do ICMS Sol.*/

    //	MaFisSave()
    MaFisEnd()
return aImp

