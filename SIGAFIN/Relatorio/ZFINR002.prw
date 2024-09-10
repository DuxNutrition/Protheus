#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#Include "TOTVS.CH"

#Define STR_PULA    Chr(13)+Chr(10)

/*{Protheus.doc} ZFINREL02
Relatorio de RA x Titulos em aberto
@type function
@author Jedielson Rodrigues
@since 10/09/2024
@version 12.1.2310
@database MSSQL
*/

User Function ZFINR002()

Local aPergs  := {}
Local dData   := Ctod(Space(8))
Local cCodCli := Space(TamSX3('E1_CLIENTE')[1])
Local cFil    := Space(TamSX3('E1_FILIAL')[1])
Local cLoja   := Space(TamSX3('E1_LOJA')[1])

    aAdd(aPergs, {1,"Filial"			  ,cFil		,/*Pict*/,/*Valid*/,"SM0",/*When*/,20,.T.})    //MV_PAR01
    aAdd(aPergs, {1,"A partir de"		  ,dData	,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,50,.T.})   //MV_PAR02
    aAdd(aPergs, {1,"Cliente"  			  ,cCodCli	,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,50,.F.})   //MV_PAR03
    aAdd(aPergs, {1,"Loja"                ,cLoja	,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,10,.F.})   //MV_PAR04

	//Se a pergunta foi confirmada
	If ParamBox(aPergs, "Informe os parametros", /*aRet*/, /*bOK*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/,cUserName, .T., .T.)
		cFil     := MV_PAR01
		dData    := MV_PAR02
		cCodCli  := MV_PAR03
		cLoja    := MV_PAR04
		FwMsgRun(,{ || RaFat(cFil,dData,cCodCli,cLoja)},"Processando","Processando registros ")
	EndIf

Return

/*{Protheus.doc} RaFat()
Funcao que cria relatorio em excel com RA e devidas NFS
@author Jedielson Rodrigues
@since 10/09/2024
*/

Static Function RaFat(cFil,dData,cCodCli,cLoja)

Local oExcel
Local oFWMSEx   := FWMsExcelEx():New()
Local aArea     := FwGetArea()	
Local cArquivo	:= ""
Local cQuery    := ""
Local cAlias    := ""
Local cQueryNF  := ""
Local cAliasNF  := ""
Local cPrx      := ""
Local cNum      := ""
Local cParc     := ""
Local cTip      := ""
Local nVal      := 0

	
	oFWMSEx:AddworkSheet("Titulos RA x NF")
	oFWMSEx:AddTable ("Titulos RA x NF","RA x NF")
	oFWMSEx:AddColumn("Titulos RA x NF","RA x NF","CLIENTE",1,1)
	oFWMSEx:AddColumn("Titulos RA x NF","RA x NF","NOME",2,2)
	oFWMSEx:AddColumn("Titulos RA x NF","RA x NF","PREFIXO",3,3)
	oFWMSEx:AddColumn("Titulos RA x NF","RA x NF","NUMERO",1,1)
	oFWMSEx:AddColumn("Titulos RA x NF","RA x NF","PARCELA",1,1)
	oFWMSEx:AddColumn("Titulos RA x NF","RA x NF","TIPO",1,1)
	oFWMSEx:AddColumn("Titulos RA x NF","RA x NF","VALOR",3,3)

    If !EMPTY(cAlias)
		(cAlias)->(DbCloseArea())
	EndIf

	cQuery := " SELECT E1_CLIENTE, E1_NOMCLI, E1_PREFIXO, E1_TIPO, E1_NUM, E1_VALOR, E1_PARCELA "+ CRLF
    cQuery += " FROM "+RetSqlName("SE1")+" WITH(NOLOCK) "+ CRLF
	cQuery += " WHERE E1_TIPO = 'RA' "+ CRLF
    cQuery += " AND E1_SALDO <> 0 "+ CRLF
    cQuery += " AND D_E_L_E_T_ = '' "+ CRLF
    cQuery += " AND E1_EMISSAO > '" + DTOS(dData) + "' "+ CRLF
	If !EMPTY(cFil)
		cQuery += " AND E1_FILIAL = '" + Alltrim(cFil) + "' "+ CRLF
	Endif
	IF !EMPTY(cCodCli) 
		cQuery += " AND E1_CLIENTE = '" + Alltrim(cCodCli) + "' "+ CRLF
        cQuery += " AND E1_LOJA = '" + Alltrim(cLoja) + "' "+ CRLF
		cQuery += " ORDER BY E1_CLIENTE "
	Else
		cQuery += " ORDER BY E1_CLIENTE "
	Endif

	cAlias := MpSysOpenQuery(cQuery)
    
    If (cAlias)->(Eof()) 
		ApMsgAlert("Nao foram encontrados titulos RA ")
        Return()
	Endif 

    While (cAlias)->(!Eof())
        oFWMSEx:SetCelBold(.T.)
        oFWMSEx:SetCelFont('Arial')
        oFWMSEx:SetCelItalic(.F.)
        oFWMSEx:SetCelUnderLine(.F.)
        oFWMSEx:SetCelSizeFont(9)
        oFWMSEx:AddRow("Titulos RA x NF","RA x NF",{Alltrim((cAlias)->(E1_CLIENTE)),Alltrim((cAlias)->(E1_NOMCLI)),Alltrim((cAlias)->(E1_PREFIXO)),Alltrim((cAlias)->(E1_NUM)),Alltrim((cAlias)->(E1_PARCELA)),Alltrim((cAlias)->(E1_TIPO)),(cAlias)->(E1_VALOR)},{,,,,,,})

        If !EMPTY((cAlias)->(E1_CLIENTE))

            IF !EMPTY(cAliasNF)
		    	(cAliasNF)->(DbCloseArea())
	        EndIf

            cQueryNF := " SELECT E1_CLIENTE, E1_NOMCLI, E1_PREFIXO AS PRX, E1_TIPO AS TIP, E1_NUM AS NUM, E1_VALOR AS VAL, E1_PARCELA AS PARC "+ CRLF 
            cQueryNF += " FROM "+RetSqlName("SE1")+" WITH(NOLOCK) "+ CRLF
            cQueryNF += " WHERE E1_FILIAL = '" + Alltrim(cFil)+"' "+ CRLF
            cQueryNF += " AND E1_TIPO = 'NF' "+ CRLF
            cQueryNF += " AND E1_SALDO <> 0 "+ CRLF
            cQueryNF += " AND D_E_L_E_T_ = '' "+ CRLF
            cQueryNF += " AND E1_EMISSAO > '" + DTOS(dData) + "' "+ CRLF
            cQueryNF += " AND E1_CLIENTE = '" + Alltrim((cAlias)->(E1_CLIENTE)) + "' "+ CRLF
            cQueryNF += " AND E1_PREFIXO = '" + Alltrim((cAlias)->(E1_PREFIXO)) + "' "+ CRLF
            cQueryNF += " ORDER BY E1_CLIENTE,E1_NOMCLI,E1_PREFIXO, E1_TIPO, E1_NUM, E1_VALOR ,E1_PARCELA "+ CRLF

            cAliasNF := MpSysOpenQuery(cQueryNF)

            While (cAliasNF)->(!Eof())
                cPrx  := Alltrim((cAliasNF)->(PRX))
                cNum  := Alltrim((cAliasNF)->(NUM))
                cParc := Alltrim((cAliasNF)->(PARC))
                cTip  := Alltrim((cAliasNF)->(TIP))
                nVal  := (cAliasNF)->(VAL)

                oFWMSEx:SetCelBold(.T.)
                oFWMSEx:SetCelFont('Arial')
                oFWMSEx:SetCelItalic(.F.)
                oFWMSEx:SetCelUnderLine(.F.)
                oFWMSEx:SetCelSizeFont(9)
                oFWMSEx:AddRow("Titulos RA x NF","RA x NF",{"","",cPrx,cNum,cparc,cParc,nVal},{,})

                (cAliasNF)->(DBSkip())
            EndDo

		Endif
		 
		oFWMSEx:SetCelBgColor('#FFFFFF')
		oFWMSEx:AddRow("Titulos RA x NF","RA x NF",{"","","","","","",""},{1,2,3,4,5,6,7})

		oFWMSEx:SetCelBgColor('#4F81BD')
		oFWMSEx:SetCelBold(.T.)
		oFWMSEx:SetCelFont('Arial')
		oFWMSEx:SetCelItalic(.F.)
		oFWMSEx:SetCelUnderLine(.F.)
		oFWMSEx:SetCelSizeFont(9)
		oFWMSEx:SetCelFrColor("#FFFFFF")
		oFWMSEx:AddRow("Titulos RA x NF","RA x NF",{"CLIENTE","NOME","PREFIXO","NUMERO","PARCELA","TIPO","VALOR"},{1,2,3,4,5,6,7})

		(cAlias)->(DBSkip())

	Enddo
	//Adicionando aba 2
	oFWMSEx:AddworkSheet("Parametros")
	//Adicionando a tabela
	oFWMSEx:AddTable("Parametros","RA x NF")
	//Adicionando as colunas
	oFWMSEx:AddColumn("Parametros","RA x NF","Parametros",1)
	oFWMSEx:AddColumn("Parametros","RA x NF","Dados Inseridos",2)
	oFWMSEx:AddRow("Parametros","RA x NF",{"Filial",cFil})
	oFWMSEx:AddRow("Parametros","RA x NF",{"A partir de ",dData})
	oFWMSEx:AddRow("Parametros","RA x NF",{"Cliente",cCodCli})
	oFWMSEx:AddRow("Parametros","RA x NF",{"Loja",cLoja})

	//Criando o XML
	oFWMSEx:Activate()
	//cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
	cArquivo  :=  GetTempPath() +"RAplanilha"+AllTrim(Str(Randomize(0,999)))+".xlxs"
	If !Empty(cArquivo)
		oFWMSEx:GetXMLFile(cArquivo)
		//Abrindo o excel e abrindo o arquivo xml
		oExcel:= MsExcel():New()               //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo)        //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()                       //Encerra o processo do gerenciador de tarefas
	Endif

FWRestArea(aArea)

Return
