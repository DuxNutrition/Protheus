#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#Include "RWMAKE.CH"

/*/{Protheus.doc}
Relatório de pedido de compra
@author Leandro Rodrigues
@since 22/08/2022
@version P12
@param nulo
@return nulo
/*/
User Function ROGR001()
	Local oPrinter 	:= Nil
	Local lEnd		:= .T.
	Private oFont8 	:= TFont():New('Courier new',,08,.T.,.F.)
	Private oFont9 	:= TFont():New('Courier new',,09,.T.,.F.)
	Private oFont9N := TFont():New('Courier new',,09,.T.,.T.)
	Private oFont9S := TFont():New('Courier new',,09,.T.,.T.,,,,,.T.)
	Private oFontT 	:= TFont():New('Courier new',,10,.T.)
	Private oFontTN	:= TFont():New('Courier new',,10,.T.,.T.)
	Private oFontBN	:= TFont():New('Courier new',,11,.T.,.T.)
	Private oFontC 	:= TFont():New('Courier new',,12,.T.,.F.)
	Private oFontCN := TFont():New('Courier new',,12,.T.,.T.)
	Private oFontT_	:= TFont():New('Courier new',,10,.T.,.F.)
	Private aArray	:= {}
	Private li		:= 15
	Private nMaxLin	:= 3100
	Private nMaxCol	:= 2500
	Private lItemNeg:= .F.
	Private nPagina := 1
	Static oBrushCinza := TBrush():New(,Rgb(214,214,214))
	cCaminho    := GetTempPath()
	cFile       := cCaminho+"/"+"RSEM001"+".rel"
	//Criando o objeto do FMSPrinter
	oPrinter := tNewMSPrinter():New("Relatório de Pedido de Compra")
	oPrinter:SetPortrait() //SetLandscape()
	oPrinter:SetPaperSize(10)
	oPrinter:setup()
	RptStatus({|lEnd| RSEM001I(@lEnd, cFile, @oPrinter)},"Imprimindo Relatório...")
	FreeObj(oPrinter)
	oPrinter := Nil
Return Nil

/*/{Protheus.doc}
Processa relaorio de pedido de compra
@author Leandro Rodrigues
@since 22/08/2022
@version P12
@param nulo
@return nulo
/*/
Static Function RSEM001I(lEnd, cIdent, oPrinter)
	Local aArea    	:= GetArea()
	Local aAreaSC7 	:= SC7->(GetArea())
	Local aAreaSB5 	:= SB5->(GetArea())
	Local nRecnoSC7 := SC7->(Recno())
	Local cChave    := SC7->C7_FILIAL+SC7->C7_NUM
	local cDesCond	:= AllTrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))
	Local nTotIpi	:= 0
	Local nTotPrd   := 0
	Local nTotDesc  := 0
	Local nTotFreDes:= 0
	Local nI		:= 0
	Local cHrRe2a5a	:= SuperGetMV("ZZ_HRRE2A5",,": 7:00 as 12:00 e 13:00 as 16:00.")
	Local cHrRe6a	:= SuperGetMV("ZZ_HRRE6A",,": 7:00 as 12:00 e 13:00 as 15:00.")
	

	IF lEnd
		oPrinter:StartPage()
		oPrinter:Say(li,5,"Cancelado pelo Operador")
		oPrinter:EndPage()
		oPrinter:Print()
		return
	EndIF
	cabecOp(nPagina,oPrinter)
	oPrinter:Box( li,50, li+66, nMaxCol-220)
	li+= 15
	oPrinter:Say(li,850,"ITENS DO PEDIDO DE COMPRA" ,oFontCN)
	DO CASE
		CASE SC7->C7_MOEDA = 1
			oPrinter:Say(li,1400," - REAL" ,oFontCN)
		CASE SC7->C7_MOEDA = 2
			oPrinter:Say(li,1400," - DOLAR" ,oFontCN)
		CASE SC7->C7_MOEDA = 3
			oPrinter:Say(li,1400," - UFIR" ,oFontCN)
		CASE SC7->C7_MOEDA = 4
			oPrinter:Say(li,1400," - EURO" ,oFontCN)
		CASE SC7->C7_MOEDA = 5
			oPrinter:Say(li,1400," - IENE" ,oFontCN)
	ENDCASE
	li+= 50
	
	oPrinter:Box( li,50,  li+50			,  	270    ) //Item
	oPrinter:FillRect( {li+3,53,  li+47	,  	270}		, oBrushCinza )
	oPrinter:Box( li,270, li+50			,  	520    ) //Qtde.
	oPrinter:FillRect( {li+3,273,  li+47,  	520}		, oBrushCinza )
	oPrinter:Box( li,520, li+50			,  	940    ) //Descrição
	oPrinter:FillRect( {li+3,523,  li+47,	940}		, oBrushCinza )
	oPrinter:Box( li,940, li+50			,  	1040   ) //UM
	oPrinter:FillRect( {li+3,943,  li+47,  	1040}		, oBrushCinza )
	oPrinter:Box( li,1040, li+50		, 	1290   ) //Vlr. Unit.
	oPrinter:FillRect( {li+3,1043, li+47,	1290}		, oBrushCinza )
	oPrinter:Box( li,1290,li+50			,	1430   ) //%IPI
	oPrinter:FillRect( {li+3,1293, li+47,	1430}		, oBrushCinza )
	oPrinter:Box( li,1430,li+50			,	1690   ) //Vlr. Total
	oPrinter:FillRect( {li+3,1433, li+47,	1690}		, oBrushCinza )
	oPrinter:Box( li,1690,li+50			,	1940   ) //Dt. Entrega
	oPrinter:FillRect( {li+3,1693, li+47,	1940}		, oBrushCinza )
	oPrinter:Box( li,1940,li+50			,	2280   ) //Observação
	oPrinter:FillRect( {li+3,1943, li+47,	2280}		, oBrushCinza )
	
	oPrinter:Say(li+10 ,60	,"Item"         ,oFontBN)
	oPrinter:Say(li+10 ,280	,"Qtde."        ,oFontBN)
	oPrinter:Say(li+10 ,530	,"Descrição"    ,oFontBN)
	oPrinter:Say(li+10 ,950	,"UM"           ,oFontBN)
	oPrinter:Say(li+10 ,1050,"Vlr. Unit."   ,oFontBN)
	oPrinter:Say(li+10 ,1300,"%IPI"         ,oFontBN)
	oPrinter:Say(li+10 ,1440,"Vlr. Total"   ,oFontBN)
	oPrinter:Say(li+10 ,1700,"Dt. Entrega" 	,oFontBN)
	oPrinter:Say(li+10 ,1950,"Observação"   ,oFontBN)
	
	li+= 50
	
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(xFilial("SC7")+SC7->C7_NUM))
	While SC7->(!EOF()) .AND. cChave == SC7->C7_FILIAL+SC7->C7_NUM
		/*
		cProd 	:= "99999999"
		nQtde 	:= 999999.9999
		cDesc 	:= "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras diam felis, viverra et ex sed."
		cObs  	:= "Donec id dui mattis felis ornare eleifend ut pellentesque neque. Nunc eget laoreet dui. Integer accumsan aliquet massa gravida elementum."
		cUM   	:= "UN"
		nVlrUnit:= 999999.9999
		nIPI	:= 9.99
		nVlrTot := 999999.99
		dDtEnt  := ctod("28/06/2023")
		*/

		if SB5->(DbSeek(xFilial("SB5")+SC7->C7_PRODUTO))
			cProd 	:= SC7->C7_PRODUTO
			nQtde 	:= SC7->C7_QUANT
			cDesc 	:= Alltrim(SB5->B5_CEME)
			cObs  	:= Alltrim(SC7->C7_OBS)
			cUM   	:= SC7->C7_UM
			nVlrUnit:= SC7->C7_PRECO
			nIPI	:= SC7->C7_IPI
			nVlrTot := SC7->C7_TOTAL
			dDtEnt  := SC7->C7_DATPRF
			
			nTamDes := mlcount(AllTrim(cDesc),22)
			nTamObs := mlcount(AllTrim(cObs),17)
			nTamMax := Max(nTamDes,nTamObs)

			if nTamMax > 1
	
				If li + (nTamMax*50) > nMaxLin
					oPrinter:EndPage()
					oPrinter:StartPage()
					nPagina++
					li:=15
					cabecOp(nPagina,oPrinter)
				EndIf
				
				oPrinter:Box( li ,50,   li + (nTamMax*50),  270    ) //Item
				oPrinter:Box( li ,270,  li + (nTamMax*50),  520    ) //Qtde.
				oPrinter:Box( li ,520,  li + (nTamMax*50),  940    ) //Descrição
				oPrinter:Box( li ,940,  li + (nTamMax*50),  1040   ) //UM
				oPrinter:Box( li ,1040, li + (nTamMax*50),  1290   ) //Vlr. Unit.
				oPrinter:Box( li ,1290, li + (nTamMax*50),  1430   ) //%IPI
				oPrinter:Box( li ,1430, li + (nTamMax*50),  1690   ) //Vlr. Total
				oPrinter:Box( li ,1690, li + (nTamMax*50),  1940   ) //Dt. Entrega
				oPrinter:Box( li ,1940, li + (nTamMax*50),  2280   ) //Observação

				oPrinter:Say(li+05	,60		,cProd                                        			,oFontT)
				oPrinter:Say(li+05	,280	,Alltrim(Transform(nQtde, "@E 999,999.9999"))  			,oFontT)
				oPrinter:Say(li+05	,530	,Alltrim(memoline(cDesc,22,1))                          ,oFontT)
				oPrinter:Say(li+05 	,950	,cUM                                                    ,oFontT)
				oPrinter:Say(li+05 	,1050	,Alltrim(Transform(nVlrUnit, "@E 999,999.9999"))		,oFontT)
				oPrinter:Say(li+05 	,1300	,Alltrim(Transform(nIPI, PesqPict("SC7","C7_IPI")))     ,oFontT)
				oPrinter:Say(li+05 	,1440	,Alltrim(Transform(nVlrTot, PesqPict("SC7","C7_TOTAL"))),oFontT)
				oPrinter:Say(li+05 	,1700	,dToc(dDtEnt)                                           ,oFontT)
				oPrinter:Say(li+05	,1950	,Alltrim(memoline(cObs,17,1))                  			,oFontT)
				
				For nI := 2 to nTamMax		
					li+= 50

					oPrinter:Say(li+05	,530	,Alltrim(memoline(cDesc,22,nI))                     ,oFontT)
					oPrinter:Say(li+05	,1950	,Alltrim(memoline(cObs,17,nI))             			,oFontT)
				Next nI

			else

				oPrinter:Box( li ,50,   li+50 ,  270    )
				oPrinter:Box( li ,270,  li+50 ,  520    )
				oPrinter:Box( li ,520,  li+50 ,  940    )
				oPrinter:Box( li ,940,  li+50 ,  1040   )
				oPrinter:Box( li ,1040, li+50 ,  1290   )
				oPrinter:Box( li ,1290, li+50 ,  1430   )
				oPrinter:Box( li ,1430, li+50 ,  1690   )
				oPrinter:Box( li ,1690, li+50 ,  1940   )
				oPrinter:Box( li ,1940, li+50 ,  2280   )

				oPrinter:Say(li+05	,60		,cProd                                        			,oFontT)
				oPrinter:Say(li+05	,280	,Alltrim(Transform(nQtde, "@E 999,999.9999"))  			,oFontT)
				oPrinter:Say(li+05	,530	,Alltrim(memoline(cDesc,22,1))                          ,oFontT)
				oPrinter:Say(li+05	,950	,cUM                  									,oFontT)
				oPrinter:Say(li+05 	,1050	,Alltrim(Transform(nVlrUnit, "@E 999,999.9999"))        ,oFontT)
				oPrinter:Say(li+05 	,1300	,Alltrim(Transform(nIPI, PesqPict("SC7","C7_IPI")))		,oFontT)
				oPrinter:Say(li+05 	,1440	,Alltrim(Transform(nVlrTot, PesqPict("SC7","C7_TOTAL"))),oFontT)
				oPrinter:Say(li+05 	,1700	,dToc(dDtEnt)											,oFontT)
				oPrinter:Say(li+05 	,1950	,Alltrim(memoline(cObs,17,1))                           ,oFontT)	

			endIf
		endIf

		nTotPrd		+= SC7->C7_TOTAL
		nTotIpi		+= SC7->C7_VALIPI
		nTotDesc	+= SC7->C7_VLDESC
		nTotFreDes	+= (SC7->C7_VALFRE + SC7->C7_DESPESA)
		
		li += 50

		If li > nMaxLin
			oPrinter:EndPage()
			oPrinter:StartPage()
			nPagina++
			li:=15
			cabecOp(nPagina,oPrinter)
		EndIf

		SC7->(DbSkip())
	EndDo
	SC7->(DbGoto(nRecnoSC7))
	li+= 80
	
	If li + 600 > nMaxLin
		oPrinter:EndPage()
		oPrinter:StartPage()
		nPagina++
		li:=15
		cabecOp(nPagina,oPrinter)
	EndIf

	oPrinter:Box( li,50, li+80,500     )
	oPrinter:FillRect( {li+3,53, li+78,  498}, oBrushCinza )
	oPrinter:Box( li ,500, li+80, 1100    )
	oPrinter:FillRect( {li+3,503,  li+78,  1098}, oBrushCinza )
	oPrinter:Say( li+30, 80 ,"Valor Produtos" ,oFontBN)
	oPrinter:Say( li+30, 1070, Alltrim(Transform(nTotPrd, PesqPict("SC7","C7_TOTAL")))   ,oFontT, , , ,1 )
	
	oPrinter:Box( li+80 ,50,li+160,   500 )
	oPrinter:FillRect( {li+83,53,  li+158,  498}, oBrushCinza )
	oPrinter:Box( li+80 ,500, li+160, 1100    )
	oPrinter:FillRect( {li+83,503,  li+158,  1098}, oBrushCinza )
	oPrinter:Say( li+110,80,"Total IPI" ,oFontBN)
	oPrinter:Say(li+110,1070, Alltrim(Transform(nTotIpi, PesqPict("SC7","C7_VALIPI")))   ,oFontT, , , ,1 )
	
	oPrinter:Box( li+160 ,50,li+240,  500 )
	oPrinter:FillRect( {li+163,53,  li+238,  498}, oBrushCinza )
	oPrinter:Box( li+160 ,500, li+240, 1100    )
	oPrinter:FillRect( {li+163,503,  li+238  ,1098}, oBrushCinza )
	oPrinter:Say( li+190,80,"Valor Desconto" ,oFontBN)
	oPrinter:Say(li+190,1070, Alltrim(Transform(nTotDesc, PesqPict("SC7","C7_TOTAL")))   ,oFontT, , , ,1 )
	
	oPrinter:Box( li+240,50, li+320 , 500)
	oPrinter:FillRect( {li+243,53,  li+318,  498}, oBrushCinza )
	oPrinter:Box( li+240 ,500, li+320,  1100)
	oPrinter:FillRect( {li+243,503,  li+318,1098}, oBrushCinza )
	oPrinter:Say( li+270,80,"Valor Frete + Despesa" ,oFontBN)
	oPrinter:Say(li+270,1070, Alltrim(Transform(nTotFreDes, PesqPict("SC7","C7_TOTAL")))   ,oFontT, , , ,1 )
		
	oPrinter:Box( li+320,50, li+400 , 500)
	oPrinter:FillRect( {li+323,53,  li+398,  498}, oBrushCinza )
	oPrinter:Box( li+320 ,500, li+400,  1100)
	oPrinter:FillRect( {li+323,503,  li+398,1098}, oBrushCinza )
	oPrinter:Say( li+350,80,"Total Geral" ,oFontBN)
	oPrinter:Say(li+350,1070, Alltrim(Transform((nTotPrd-nTotDesc)+nTotIpi+nTotFreDes, PesqPict("SC7","C7_TOTAL")))   ,oFontT, , , ,1 )
	
	oPrinter:Box( li+400,50, li+480 , 500)
	oPrinter:FillRect( {li+403,53,  li+478,  498}, oBrushCinza )
	oPrinter:Box( li+400 ,500, li+480,  1100)
	oPrinter:FillRect( {li+403,503,  li+478 ,1098}, oBrushCinza )
	oPrinter:Say( li+430,80,"Condição Pagamento" ,oFontBN)
	oPrinter:Say(li+430,1070, cDesCond ,oFontT, , , ,1 )
	
	oPrinter:Box( li+480,50, li+560 , 500)
	oPrinter:FillRect( {li+483,53,  li+558,  498}, oBrushCinza )
	oPrinter:Box( li+480,500, li+560,  1100)
	oPrinter:FillRect( {li+483,503,  li+558 ,1098}, oBrushCinza )
	oPrinter:Say( li+510,80,"Frete" ,oFontBN)
	oPrinter:Say(li+510,1070, iif(SC7->C7_TPFRETE == "C","CIF-Por conta emitente","FOB-Por conta destinatário")  ,oFontT, , , ,1 )
	
	li+= 640
	
	If li + 950 > nMaxLin
		oPrinter:EndPage()
		oPrinter:StartPage()
		nPagina++
		li:=15
		cabecOp(nPagina,oPrinter)
	EndIf

	oPrinter:Box( li,50, li+70, 2280)
	oPrinter:FillRect( {li+3,53,  li+67  ,2279}, oBrushCinza )
	oPrinter:Say( li+15,0850,"INFORMAÇÕES IMPORTANTES" ,oFontCN)
	oPrinter:Box( li,0050, li+800, 2280)
	li+= 100
	oPrinter:Say(li,0070,"Enviar",oFont9)
	oPrinter:Say(li,0180,"NOTA FISCAL, BOLETO E LAUDO DE QUALIDADE ",oFont9N)
	oPrinter:Say(li,0850,"para ", oFont9)
	oPrinter:Say(li,0930,"nfe@duxnutrition.com", oFont9S,,CLR_BLUE)
	li+= 50
	oPrinter:Say(li,0070,"A falta de envio do boleto ou dados bancários para pagamento com antecedência mínima de  ",oFont9)
	oPrinter:Say(li,1480,"10 dias do vencimento",oFont9N)
	oPrinter:Say(li,1820,", estará sujeito á",oFont9)
	li+= 50
	oPrinter:Say(li,0070,"prorrogação sem ônus para DUX.",oFont9)
	li+= 50
	oPrinter:Say(li,0070,"Não estará autorizado o faturamento, caso o valor e demais condições comerciais não estiverem de acordo com a ordem de compra.",oFont9)
	li+= 50
	oPrinter:Say(li,0070,"Informar na Nota Fiscal o número da ordem de compra, código do item e taxa PTAX (caso o material seja comercializado em Dólar/Euro).",oFont9)
	li+= 80
	oPrinter:Say(li,0070,"MATÉRIA-PRIMA", oFont9S)
	oPrinter:Say(li,0290,"Não serão aceitas com SHELF LIFE maior ou igual a 6 meses.", oFont9)
	li+= 50
	oPrinter:Say(li,0070,"Validade inferior a 6 meses, deve ser solicitado ao Depto. de Compras autorização para envio.",oFont9)
	li+= 80
	oPrinter:Say(li,0070,"Todo material deve ser paletizado (Pallet 1,00 x 1,20 - altura maxima 1,60mts - peso máximo por pallet de 900kg) e estrechado.",oFont9)
	li+= 50
	oPrinter:Say(li,0070,"Não serão recebidas mercadorias transportadas em carro aberto, sem paletizacão e sem laudo de qualidade.",oFont9)
	li+= 50
	oPrinter:Say(li,0070,"Horário de recebimento:", oFont9S)
	oPrinter:Say(li,0450,"de", oFont9)
	oPrinter:Say(li,0490,"Segunda a Quinta-feira", oFont9S)
	oPrinter:Say(li,0850,cHrRe2a5a, oFont9)
	li+= 50
	oPrinter:Say(li,0070,"Sexta-feira", oFont9S)
	oPrinter:Say(li,0280,cHrRe6a, oFont9)
	
	li+= 50 * 5
	oPrinter:Say(li,1500,"Obrigado(a),",oFontCN)
	li+= 50
	oPrinter:Say(li,1500,UsrFullName(SC7->C7_USER),oFontCN)
	li+= 50
	oPrinter:EndPage()
	Li := 15
	oPrinter:Preview()
	oPrinter:end()
	RestArea(aAreaSC7)
	RestArea(aAreaSB5)
	RestArea(aArea)
Return
/*/{Protheus.doc}
Imprime cabecalho do pedido
@author Leandro Rodrigues
@since 22/08/2022
@version P12
@param nulo
@return nulo
/*/
Static Function CabecOp(nPagOp, oPrinter)
	Local aArea    	:= GetArea()
	Local aAreaSC7 	:= SC7->(GetArea())
	Local aAreaSA2 	:= SA2->(GetArea())
	Local aEmpresa  := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt, {"M0_ENDCOB","M0_CIDCOB","M0_ESTCOB","M0_CEPCOB","M0_NOME","M0_CGC","M0_TEL"})
	Local aEmpEnd   := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt, {"M0_ENDENT","M0_CIDENT","M0_ESTENT","M0_CEPENT","M0_NOMECOM","M0_CGC","M0_TEL"})
	Local cCabec1   := Alltrim(aEmpresa[5,2])
	Local cCabecEnd := Alltrim(aEmpresa[1,2])
	Local cCabecCid := Alltrim(aEmpresa[2,2])+" - "+Alltrim(aEmpresa[3,2])+" - "+Alltrim(aEmpresa[4,2])
	Local cCabec2   := "Ordem de Compra"
	Local cCabec3   := SC7->C7_NUM
	Local lImpFor   := SC7->C7_ZZFORNE
	Local cCGCEmp   := Alltrim(aEmpresa[6,2])
	Local cContEmp  := Alltrim(aEmpresa[7,2])
	Local dDtEnv    := "Data Envio: "+dToc(dDataBase)
	Local cFornec   := ""
	Local cCGCFor   := ""
	Local cEndFor   := ""
	Local cBaiFor   := ""
	Local cCepFor   := ""
	Local cContFor  := ""
	Local cEndEnt   := ""
	Local cBaiEnt   := ""
	Local cCepEnt   := ""
	Local cContEnt  := ""
	Local cNomEnt	:= ""
	Local cCGCEnt	:= ""
	Local cLogopv   := GetSrvProfString("Startpath","") + "logopedido" + ".bmp"
	Local cAssin    := GetSrvProfString("Startpath","") + "assinatura" + ".bmp"
	Local nAltura   := 0
	Private oFontC
	Private oFontT

		dbSelectArea("SA2")
		dbSetOrder(1)
		SA2->(DbGoTop())
		SA2->(Dbseek(XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
		cFornec   := Alltrim(SA2->A2_NOME)
		cCGCFor   := "CNPJ: "+Alltrim(SA2->A2_CGC)
		cEndFor   := Alltrim(SA2->A2_END)
		cBaiFor   := Alltrim(SA2->A2_BAIRRO) + " - " + Alltrim(SA2->A2_MUN) + " - " + Alltrim(SA2->A2_EST)
		cCepFor   := "CEP: "+Alltrim(SA2->A2_CEP)
		cContFor  := "Contato: " + "(" + Alltrim(SA2->A2_DDD)+")" + Alltrim(SA2->A2_TEL)
		cNomEnt   := Alltrim(aEmpEnd[5,2])
		cCGCEnt   := "CNPJ: "+Alltrim(aEmpEnd[6,2])
		cEndEnt   := Alltrim(aEmpEnd[1,2])
		cBaiEnt   := Alltrim(aEmpEnd[2,2])+" - "+Alltrim(aEmpEnd[3,2])+" - "+Alltrim(aEmpEnd[4,2])
		cCepEnt   := "CEP: " +Alltrim(aEmpEnd[4,2])
		cContEnt  := "Contato: " +Alltrim(aEmpEnd[7,2])
	//Local cLogopv   := GetSrvProfString("Startpath","") + "lgrl010101" + ".bmp" - Atualizado Cesar Santos - 19/01/2023
	
	oFontCB	:= TFont():New('Courier new',,06,.T.)
	oFontT 	:= TFont():New('Courier new',,10,.T.)
	oFontTN := TFont():New('Courier new',,10,.T.,.T.)
	oFontC 	:= TFont():New('Courier new',,12,.T.)
	oFontCN := TFont():New('Courier new',,12,.T.,.T.)
	oFont14 := TFont():New('Courier new',,14,.T.,.T.)
	oFont16 := TFont():New('Courier new',,16,.T.,.T.)
	oPrinter:StartPage()
	li+= 20
	nAltura := 10//oPrinter:nPageHeight
	nLargura:= 10//oPrinter:nPageWidth
	oPrinter:SayBitmap(010,010,cLogopv,0400,0400 )
	oPrinter:SayBitmap(2470,1300,cAssin,0400,0400 )
	li += 40
	oPrinter:Say(li,0480,cCabec1,oFontCN)
	oPrinter:Say(li,1425,cCabec2,oFont14)
	oPrinter:Say(li,2200,("Pág. "+cValtoChar(nPagina)), oFont9)
	li += 40
	oPrinter:Say(li,0480,cCabecEnd,oFontT)
	oPrinter:Say(li,1425,cCabec3,oFont14)
	li += 40
	oPrinter:Say(li,0480,cCabecCid,oFontT)
	li += 80
	oPrinter:Say(li,0050,"Fornecedor: " ,oFontCN,,,,0)
	oPrinter:Say(li,1425,dDtEnv,oFontCN)
	li += 40
	oPrinter:Say(li,0050,cFornec ,oFontT,,,,0)
	li += 40
	oPrinter:Say(li,0050,cCGCFor,oFontT)
	li += 40
	oPrinter:Say(li,0050,cEndFor,oFontT)
	li += 40
	oPrinter:Say(li,0050,cBaiFor,oFontT)
	li += 40
	oPrinter:Say(li,0050,cCepFor,oFontT)
	li += 40
	oPrinter:Say(li,0050,cContFor,oFontT)
	li += 60
	oPrinter:Say(li,0050,"Dados para Faturamento: " ,oFontCN,,,,0)
	oPrinter:Say(li,1425,"Dados para Entrega: "     ,oFontCN,,,,0)
	li += 40
	If !Empty(lImpFor)
		SA2->(DbGoTop())
		If SA2->(Dbseek(XFILIAL("SA2")+SC7->C7_ZZFORNE+SC7->C7_ZZLOJA))
			cNomEnt   := Alltrim(SA2->A2_NOME)
			cCGCEnt   := "CNPJ: "+Alltrim(SA2->A2_CGC)
			cEndEnt   := Alltrim(SA2->A2_END)
			cBaiEnt   := Alltrim(SA2->A2_BAIRRO) + " - " + Alltrim(SA2->A2_MUN) + " - " + Alltrim(SA2->A2_EST) + " - " + Alltrim(SA2->A2_CEP)
			//	cCepEnt   := "CEP: "+Alltrim(SA2->A2_CEP)
			cContEnt  := "Contato: " + "(" + Alltrim(SA2->A2_DDD)+")" + Alltrim(SA2->A2_TEL)
		EndIF
	EndIf
	oPrinter:Say(li,0050,cCabec1 ,oFontT,,,,0)
	oPrinter:Say(li,1425,cNomEnt ,oFontT,,,,0)
	li += 40
	oPrinter:Say(li,0050,cCGCEmp,oFontT)
	oPrinter:Say(li,1425,cCGCEnt,oFontT)
	li += 40
	oPrinter:Say(li,0050,"Endereço: "+cCabecEnd,oFontT)
	oPrinter:Say(li,1425,"Endereço: "+cEndEnt,oFontT)
	li += 40
	oPrinter:Say(li,0050,cCabecCid,oFontT)
	oPrinter:Say(li,1425,cBaiEnt,oFontT)
	li += 40
	oPrinter:Say(li,0050,cContEmp,oFontT)
	oPrinter:Say(li,1425,cContEnt,oFontT)
	li += 100
	RestArea(aAreaSC7)
	RestArea(aAreaSA2)
	RestArea(aArea)
return
