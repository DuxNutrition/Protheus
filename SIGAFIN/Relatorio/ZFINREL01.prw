//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "rwmake.ch"

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} nccfat
Função que cria as perguntas para relatório NCC 
@author Allan Rabelo
@since 28/06/2024
@version 1.0
    @example
    u_nccfat()
/*/

User Function ZFINREL01()
	Local aPergs   := {}
	Local lExit := .F.
	Private cDataIni := Ctod('')
	Private cCliente      := SPACE(12)
	Private cFil     := SPACE(7)
	Private cLoja     := SPACE(4)

	//Adiciona os parâmetros
	aAdd(aPergs, {1, "Filial",   cFil,   "",             ".T.",         "SM0",    ".T.", 110,  .T.})
	aAdd(aPergs, {1, "A partir de ",      cDataIni,  "",             ".T.", "", ".T.", 70,   .T.})
	aAdd(aPergs, {1, "Cliente",      cCliente,  "",             ".T.", "", ".T.", 70,   .F.})
	aAdd(aPergs, {1, "Loja",   cLoja,   "",             ".T.",         "",    ".T.", 110,  .F.})
	//aAdd(aPergs, {1, "Sequencia do lançamento",   cSeq,   "",             ".T.",         "",    ".T.", 110,  .T.})

	//Se a pergunta foi confirmada
	If ParamBox(aPergs, "Informe os parâmetros", /*aRet*/, /*bOK*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/,cUserName, .T., .T.)
		cFil     := MV_PAR01
		cDataIni := MV_PAR02
		cCliente := MV_PAR03
		cLoja      := MV_PAR04
		// cSeq     := MV_PAR05
		FwMsgRun(,{ || u_nccfat(cFil,cDataIni,cCliente,cLoja)},"Processando","Processando registros ")
	EndIf

Return


/*/{Protheus.doc} nccfat
Função que cria relatório em excel com NCC e devidos NFS
@author Allan Rabelo
@since 28/06/2024
@version 1.0
    @example
    u_nccfat()
/*/

User Function nccfat(cFil,dData,cCli,cLoj)
	//Local cArquivo    := GetTempPath()+'nccfat01.xml'
	Local cTitulo	    := "Escolha o caminho para salvar o arquivo!"
	Local cMainPath     := "\"
	Local cArquivo	    := ""
	Local cExtens       := "Arquivo XML | *.XML"
	Local oFWMSEx        := FWMsExcelEx():New()
	Local oExcel
	Local aArea := GetArea()
	Local cQuery := ""
	Local cAlias := ""
	Local cNome := ""
	Local cQueryNF := ""
	Local cAliasNF := ""
	Local prx := ""
	Local cnum := ""
	Local cparc := ""
	Local ctip := ""
	Local vval := 0

	//Criando a Aba Teste 1
	oFWMSEx:AddworkSheet("Titulos NCC x NF")
	//Adicionando a tabela
	oFWMSEx:AddTable ("Titulos NCC x NF","NCC")
	//Adicionando as colunas
	oFWMSEx:AddColumn("Titulos NCC x NF","NCC","CLIENTE",1,1)
	oFWMSEx:AddColumn("Titulos NCC x NF","NCC","NOME",2,2)
	oFWMSEx:AddColumn("Titulos NCC x NF","NCC","PREFIXO",3,3)
	oFWMSEx:AddColumn("Titulos NCC x NF","NCC","NUMERO",1,1)
	oFWMSEx:AddColumn("Titulos NCC x NF","NCC","PARCELA",1,1)
	oFWMSEx:AddColumn("Titulos NCC x NF","NCC","TIPO",1,1)
	oFWMSEx:AddColumn("Titulos NCC x NF","NCC","VALOR",3,3)

	cQuery += " SELECT E1_CLIENTE,E1_NOMCLI,E1_PREFIXO, E1_TIPO, E1_NUM, E1_VALOR ,E1_PARCELA FROM "+RetSqlName("SE1")+" "
	cQuery += " WHERE E1_TIPO = 'NCC' AND E1_SALDO <> 0 AND D_E_L_E_T_ = '' AND E1_EMISSAO > '"+Dtos(dData)+"' "
	if ALLTRIM(cFil) <> ""
		cQuery += " AND E1_FILIAL = '"+alltrim(cFil)+"' "
	endif
	if ALLTRIM(cCli) <> ""
		cQuery += " AND E1_CLIENTE = '"+alltrim(cCli)+"' AND E1_LOJA = '"+alltrim(cLoj)+"' "
		cQuery += " ORDER BY E1_CLIENTE "
	else
		cQuery += " ORDER BY E1_CLIENTE "
	endif
	cAlias := MpSysOpenQuery(cQuery)
    
    if (cAlias)->(Eof()) 
		ApMsgAlert(" Não foram encontrados titulos NCC ")
        Return()
	Endif 
		While (cAlias)->(!Eof())
			oFWMSEx:SetCelBold(.T.)
			oFWMSEx:SetCelFont('Arial')
			oFWMSEx:SetCelItalic(.F.)
			oFWMSEx:SetCelUnderLine(.F.)
			oFWMSEx:SetCelSizeFont(9)
			oFWMSEx:AddRow("Titulos NCC x NF","NCC",{Alltrim((cAlias)->(E1_CLIENTE)),Alltrim((cAlias)->(E1_NOMCLI)),Alltrim((cAlias)->(E1_PREFIXO)),Alltrim((cAlias)->(E1_NUM)),Alltrim((cAlias)->(E1_PARCELA)),Alltrim((cAlias)->(E1_TIPO)),(cAlias)->(E1_VALOR)},{,,,,,,})

			if (cAlias)->(E1_CLIENTE) <> ""
				if cAliasNF <> ""
					(cAliasNF)->(DbCloseArea())
				endif
				cQueryNF := ""
				cQueryNF += " SELECT E1_CLIENTE,E1_NOMCLI,E1_PREFIXO as prx, E1_TIPO as tip , E1_NUM as num , E1_VALOR as val ,E1_PARCELA as parc FROM "+RetSqlName("SE1")+" "
				cQueryNF += " WHERE E1_TIPO = 'NF' AND E1_SALDO <> 0 AND D_E_L_E_T_ = '' AND E1_EMISSAO > '"+Dtos(dData)+"' AND E1_CLIENTE = '"+ALLTRIM((cAlias)->(E1_CLIENTE))+"' "
				cQueryNF += " AND E1_PREFIXO = '"+ALLTRIM((cAlias)->(E1_PREFIXO))+"' AND  E1_FILIAL = '"+alltrim(cFil)+"' "
				cQueryNF += " ORDER BY E1_CLIENTE,E1_NOMCLI,E1_PREFIXO, E1_TIPO, E1_NUM, E1_VALOR ,E1_PARCELA "
				cAliasNF := MpSysOpenQuery(cQueryNF)
				While (cAliasNF)->(!Eof())
					prx := Alltrim((cAliasNF)->(prx))
					cnum := Alltrim((cAliasNF)->(num))
					cparc := Alltrim((cAliasNF)->(parc))
					ctip := Alltrim((cAliasNF)->(tip))
					vval := (cAliasNF)->(val)

					oFWMSEx:SetCelBold(.T.)
					oFWMSEx:SetCelFont('Arial')
					oFWMSEx:SetCelItalic(.F.)
					oFWMSEx:SetCelUnderLine(.F.)
					oFWMSEx:SetCelSizeFont(9)
					oFWMSEx:AddRow("Titulos NCC x NF","NCC",{"","",prx,cnum,cparc,ctip,vval},{,})
					(cAliasNF)->(DBSkip())
				Enddo
			endif
		 
		oFWMSEx:SetCelBgColor('#ffffff')
		oFWMSEx:AddRow("Titulos NCC x NF","NCC",{"","","","","","",""},{1,2,3,4,5,6,7})

		oFWMSEx:SetCelBgColor('#4F81BD')
		oFWMSEx:SetCelBold(.T.)
		oFWMSEx:SetCelFont('Arial')
		oFWMSEx:SetCelItalic(.F.)
		oFWMSEx:SetCelUnderLine(.F.)
		oFWMSEx:SetCelSizeFont(9)
		oFWMSEx:SetCelFrColor("#FFFFFF")
		oFWMSEx:AddRow("Titulos NCC x NF","NCC",{"CLIENTE","NOME","PREFIXO","NUMERO","PARCELA","TIPO","VALOR"},{1,2,3,4,5,6,7})

		(cAlias)->(DBSkip())
	Enddo
	//Adicionando aba 2
	oFWMSEx:AddworkSheet("Parametros")
	//Adicionando a tabela
	oFWMSEx:AddTable("Parametros","NCC")
	//Adicionando as colunas
	oFWMSEx:AddColumn("Parametros","NCC","Parametros",1)
	oFWMSEx:AddColumn("Parametros","NCC","Dados Inseridos",2)
	oFWMSEx:AddRow("Parametros","NCC",{"Filial",cFil})
	oFWMSEx:AddRow("Parametros","NCC",{"Data acima de ",dData})
	oFWMSEx:AddRow("Parametros","NCC",{"Cliente(S/N)",cCli})
	oFWMSEx:AddRow("Parametros","NCC",{"Loja",cLoj})

	//Criando o XML
	oFWMSEx:Activate()
	//cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
	cArquivo  :=  GetTempPath() +"NCCplanilha"+AllTrim(Str(Randomize(0,999)))+".xlxs"
	If !Empty(cArquivo)
		oFWMSEx:GetXMLFile(cArquivo)
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)                 //Visualiza a planilha
		oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
	endif
Return
