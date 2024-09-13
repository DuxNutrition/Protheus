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
Local cTipoTi := Space(30)

    aAdd(aPergs, {1,"Filial"			  ,cFil		,/*Pict*/,/*Valid*/,"SM0",/*When*/,20,.T.})    //MV_PAR01
    aAdd(aPergs, {1,"A partir de"		  ,dData	,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,50,.T.})   //MV_PAR02
    aAdd(aPergs, {1,"Cliente"  			  ,cCodCli	,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,50,.F.})   //MV_PAR03
    aAdd(aPergs, {1,"Loja"                ,cLoja	,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,10,.F.})   //MV_PAR04
	aAdd(aPergs, {1,"Tipo (,)"            ,cTipoTi	,/*Pict*/,/*Valid*/,/*F3*/,/*When*/,50,.T.})   //MV_PAR05

	//Se a pergunta foi confirmada
	If ParamBox(aPergs, "Informe os parametros", /*aRet*/, /*bOK*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/,cUserName, .T., .T.)
		cFil     := MV_PAR01
		dData    := MV_PAR02
		cCodCli  := MV_PAR03
		cLoja    := MV_PAR04
		cTipoTi  := Alltrim(MV_PAR05)
		FwMsgRun(,{ || RaFat(cFil,dData,cCodCli,cLoja,cTipoTi)},"Processando","Processando registros ")
	EndIf

Return

/*{Protheus.doc} RaFat()
Funcao que cria relatorio em excel com RA e devidas NFS
@author Jedielson Rodrigues
@since 10/09/2024
*/

Static Function RaFat(cFil,dData,cCodCli,cLoja,cTipoTi)

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
Local cTipos    := FormatIn(cTipoTi,",") 
Local nVal      := 0


	oFWMSEx:AddworkSheet("RA x TÌtulos a Receber")
	oFWMSEx:AddTable ("RA x TÌtulos a Receber","RA x " + cTipoTi + "")
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","CLIENTE",2,1)
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","NOME",2,1)
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","LOJA",2,1)
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","PREFIXO",2,1)
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","NUMERO",2,1)
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","PARCELA",2,1)
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","TIPO",2,1)
	oFWMSEx:AddColumn("RA x TÌtulos a Receber","RA x " + cTipoTi + "","VALOR",2,3)

    If !Empty(cAlias)
		(cAlias)->(DbCloseArea())
	EndIf

	cQuery := " SELECT E1_CLIENTE, E1_NOMCLI, E1_LOJA, E1_PREFIXO, E1_NUM, E1_TIPO, E1_PARCELA, E1_VALOR "+ CRLF
    cQuery += " FROM "+RetSqlName("SE1")+" WITH(NOLOCK) "+ CRLF
	cQuery += " WHERE E1_FILIAL = '" + Alltrim(cFil) + "' "+ CRLF
	cQuery += " AND D_E_L_E_T_ = '' "+ CRLF
	cQuery += " AND E1_EMISSAO > '" + DTOS(dData) + "' "+ CRLF
	cQuery += " AND E1_SALDO <> 0 "+ CRLF
	cQuery += " AND E1_TIPO = 'RA' "+ CRLF
	IF !Empty(cCodCli) 
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
        oFWMSEx:SetCelFont('Calibri')
        oFWMSEx:SetCelItalic(.F.)
        oFWMSEx:SetCelUnderLine(.F.)
        oFWMSEx:SetCelSizeFont(10)
        oFWMSEx:AddRow("RA x TÌtulos a Receber","RA x " + cTipoTi + "",{Alltrim((cAlias)->(E1_CLIENTE)),Alltrim((cAlias)->(E1_NOMCLI)),Alltrim((cAlias)->(E1_LOJA)),Alltrim((cAlias)->(E1_PREFIXO)),Alltrim((cAlias)->(E1_NUM)),Alltrim((cAlias)->(E1_PARCELA)),Alltrim((cAlias)->(E1_TIPO)),(cAlias)->(E1_VALOR)},{,,,,,,})

        If !Empty((cAlias)->(E1_CLIENTE))

            If !Empty(cAliasNF)
		    	(cAliasNF)->(DbCloseArea())
	        EndIf

            cQueryNF := " SELECT E1_CLIENTE, E1_NOMCLI, E1_LOJA, E1_PREFIXO AS PRX, E1_NUM AS NUM, E1_PARCELA AS PARC, E1_TIPO AS TIP, E1_VALOR AS VAL "+ CRLF 
            cQueryNF += " FROM "+RetSqlName("SE1")+" WITH(NOLOCK) "+ CRLF
            cQueryNF += " WHERE E1_FILIAL = '" + Alltrim(cFil)+"' "+ CRLF
			cQueryNF += " AND D_E_L_E_T_ = '' "+ CRLF
			cQueryNF += " AND E1_EMISSAO > '" + DTOS(dData) + "' "+ CRLF
			cQueryNF += " AND E1_CLIENTE = '" + Alltrim((cAlias)->(E1_CLIENTE)) + "' "+ CRLF
			cQueryNF += " AND E1_LOJA = '" + Alltrim((cAlias)->(E1_LOJA)) + "' "+ CRLF
			cQueryNF += " AND E1_TIPO IN " + cTipos + " "+ CRLF 
            cQueryNF += " AND E1_SALDO <> 0 "+ CRLF
            cQueryNF += " ORDER BY E1_CLIENTE,E1_NOMCLI,E1_LOJA,PRX,NUM,PARC,TIP,VAL "+ CRLF

            cAliasNF := MpSysOpenQuery(cQueryNF)

            While (cAliasNF)->(!Eof())
                cPrx  := Alltrim((cAliasNF)->(PRX))
                cNum  := Alltrim((cAliasNF)->(NUM))
                cParc := Alltrim((cAliasNF)->(PARC))
                cTip  := Alltrim((cAliasNF)->(TIP))
                nVal  := (cAliasNF)->(VAL)

                oFWMSEx:SetCelBold(.T.)
                oFWMSEx:SetCelFont('Calibri')
                oFWMSEx:SetCelItalic(.F.)
                oFWMSEx:SetCelUnderLine(.F.)
                oFWMSEx:SetCelSizeFont(10)
                oFWMSEx:AddRow("RA x TÌtulos a Receber","RA x " + cTipoTi + "",{"","","",cPrx,cNum,cParc,cTip,nVal},{,})

                (cAliasNF)->(DBSkip())
            EndDo

		Endif
		 
		oFWMSEx:SetCelBgColor('#FFFFFF')
		oFWMSEx:AddRow("RA x TÌtulos a Receber","RA x " + cTipoTi + "",{"","","","","","","",""},{1,2,3,4,5,6,7,8})

		oFWMSEx:SetCelBgColor('#4F81BD')
		oFWMSEx:SetCelBold(.T.)
		oFWMSEx:SetCelFont('Calibri')
		oFWMSEx:SetCelItalic(.F.)
		oFWMSEx:SetCelUnderLine(.F.)
		oFWMSEx:SetCelSizeFont(10)
		oFWMSEx:SetCelFrColor("#FFFFFF")
		oFWMSEx:AddRow("RA x TÌtulos a Receber","RA x " + cTipoTi + "",{"CLIENTE","NOME","LOJA","PREFIXO","NUMERO","PARCELA","TIPO","VALOR"},{1,2,3,4,5,6,7,8})

		(cAlias)->(DBSkip())

	Enddo
	//Adicionando aba 2
	oFWMSEx:AddworkSheet("Parametros")
	//Adicionando a tabela
	oFWMSEx:AddTable("Parametros","RA x " + cTipoTi + "")
	//Adicionando as colunas
	oFWMSEx:AddColumn("Parametros","RA x " + cTipoTi + "","Parametros",1)
	oFWMSEx:AddColumn("Parametros","RA x " + cTipoTi + "","Dados Inseridos",2)
	oFWMSEx:AddRow("Parametros","RA x " + cTipoTi + "",{"Filial",cFil})
	oFWMSEx:AddRow("Parametros","RA x " + cTipoTi + "",{"A partir de ",dData})
	oFWMSEx:AddRow("Parametros","RA x " + cTipoTi + "",{"Cliente",cCodCli})
	oFWMSEx:AddRow("Parametros","RA x " + cTipoTi + "",{"Loja",cLoja})
	oFWMSEx:AddRow("Parametros","RA x " + cTipoTi + "",{"Tipo (,)",cTipoTi})

	//Criando o XML
	oFWMSEx:Activate()
	//cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
	cArquivo  :=  GetTempPath() +"RAplanilha"+AllTrim(Str(Randomize(0,999)))+".xlxs"
	If !Empty(cArquivo)
		oFWMSEx:GetXMLFile(cArquivo)
		//Abrindo o excel e abrindo o arquivo xml
		oExcel:= MsExcel():New()               //Abre uma nova conex√£o com Excel
		oExcel:WorkBooks:Open(cArquivo)        //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()                       //Encerra o processo do gerenciador de tarefas
	Endif

FWRestArea(aArea)

Return
