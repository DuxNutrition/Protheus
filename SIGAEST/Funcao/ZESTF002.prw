#Include "rwmake.ch"
#include "topconn.ch"
#INCLUDE 'COLORS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include "RPTDef.ch"
#include "tbiconn.ch"
#include "fileio.ch"
/*/{Protheus.doc} ZESTF002
Rotina para montar o Browse de impressão das Etiquetas.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
/*/
User Function ZESTF002(cTabela)

//Declarar variáveis locais
Local aFields       := {}
Local aSeek         := {}
Local aFieFilter    := {}
Private cAliasSQL	:= GetNextAlias()
Private cAliasTRB   := ""
Private oTempTable  := Nil
Private oMarkBrowse := Nil
Private cCadastro 	:= "Etiquetas Dux"
Private aRetPer     := ""
Private aPergs      := {}
Private aRetPerg    := {}
Private cCodPrint   := Space(TamSX3("CB5_CODIGO")[1])

Default cTabela     := ""

    FWMsgRun(, {|oSay| ZESTS001(cTabela) }, "Processando", "Carregando lotes disponiveis...")

    DbSelectArea((cAliasSQL))
    (cAliasSQL)->(DbGoTop())
    If !(cAliasSQL)->(Eof())
        
        //Criar a tabela temporária
        AAdd(aFields, {"TR_OK"  	    ,"C"    ,02 ,00  }) //Este campo será usado para marcar/desmarcar
        AAdd(aFields, {"TR_STATUS"      ,"C"    ,03 ,00  }) //Status de impressão da Etiqueta
        AAdd(aFields, {"TR_DESCR"       ,"C"    ,60 ,00  }) //Descrição do Item
        AAdd(aFields, {"TR_LOTE"        ,"C"    ,25 ,00  }) //Lote do item
        AAdd(aFields, {"TR_VLD"         ,"D"    ,08 ,00  }) //Validade do item
        AAdd(aFields, {"TR_QTDEMB"      ,"N"    ,14 ,03  }) //Quantidade na Embalagem
        AAdd(aFields, {"TR_QTDETQ"      ,"N"    ,09 ,00  }) //Quantidade de Etiquetas
        AAdd(aFields, {"TR_QTDDOC"      ,"N"    ,14 ,03  }) //Quantidade do Documento
        AAdd(aFields, {"TR_PRODUTO"     ,"C"    ,15 ,00  }) //Codigo do Produto

        //Cria a temporária
        oTempTable := FWTemporaryTable():New()

        //Seta os campos
        oTempTable:SetFields(aFields)

        //Cria índice com colunas setadas anteriormente
        oTempTable:AddIndex("1"     , {"TR_PRODUTO","TR_LOTE" } )

        //Utilizamos o método Create para criar a tabela temporária, ela será criada e aberta
        oTempTable:Create()

        //Recupera o Alias criado
        cAliasTRB   := oTempTable:GetAlias()

        //Popular tabela temporária, irei colocar apenas um unico registro
        DbSelectArea(cAliasSQL)
        (cAliasSQL)->(DbGoTop())
        While (cAliasSQL)->(!Eof())
            If RecLock((cAliasTRB),.T.)
                (cAliasTRB)->TR_OK         := "  "
                (cAliasTRB)->TR_STATUS     := "NAO"
                (cAliasTRB)->TR_DESCR      := (cAliasSQL)->DESCR
                (cAliasTRB)->TR_LOTE       := (cAliasSQL)->LOTE
                (cAliasTRB)->TR_VLD        := SToD((cAliasSQL)->VALIDADE)
                (cAliasTRB)->TR_QTDEMB     := (cAliasSQL)->QTDE
                (cAliasTRB)->TR_QTDETQ     := 1
                (cAliasTRB)->TR_QTDDOC     := (cAliasSQL)->QTDE
                (cAliasTRB)->TR_PRODUTO    := (cAliasSQL)->COD
                (cAliasTRB)->(MsUnLock())
           Endif
            (cAliasSQL)->(DbSkip())
        EndDo
        (cAliasSQL)->(DbCloseArea())
            
        (cAliasTRB)->(DbGoTop())
        If (cAliasTRB)->(!Eof())
            
            //Irei criar a pesquisa que será apresentada na tela
            aAdd(aSeek,{"Produto"	        ,{{ ""  ,"C"  ,15 ,0    ,"Produto"  ,"@!"   ,1  , .T.   }} } )
                    
            //Campos que irão compor a tela de filtro
            Aadd(aFieFilter,{"TR_PRODUTO"	,"Produto"  ,"C"    ,15    ,0    ,"@!"   })
            Aadd(aFieFilter,{"TR_LOTE"	    ,"Lote"     ,"C"    ,25    ,0    ,"@!"   })
            
            //Agora iremos usar a classe FWMarkBrowse
            oMarkBrowse:= FWMarkBrowse():New()
            oMarkBrowse:SetDescription(cCadastro) //Titulo da Janela
            oMarkBrowse:SetAlias((cAliasTRB)) //Indica o alias da tabela que será utilizada no Browse
            oMarkBrowse:SetFieldMark("TR_OK") //Indica o campo que deverá ser atualizado com a marca no registro
            oMarkBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
            oMarkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
            oMarkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
            oMarkBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
            oMarkBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
            oMarkBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
            oMarkBrowse:SetFieldFilter(aFieFilter)
            oMarkBrowse:DisableDetails()
            oMarkBrowse:DisableConfig()
		    oMarkBrowse:DisableReport() //Desabilita a impressao do browser

            //Permite adicionar legendas no Browse
            oMarkBrowse:AddLegend( "TR_VLD < Date() .And. TR_STATUS == 'SIM'"  ,"BLACK"     ,"Lote Vencido, etiqueta já impressa"       )
		    oMarkBrowse:AddLegend( "TR_VLD < Date() .And. TR_STATUS <>'SIM'"   ,"RED"       ,"Lote Vencido, não foi impresso etiqueta"  )
		    oMarkBrowse:AddLegend( "TR_STATUS =='SIM'"                         ,"GREEN"	    ,"Etiqueta Impressa"                        )
		    oMarkBrowse:AddLegend( "TR_STATUS =='NAO'"                         ,"YELLOW"    ,"Etiqueta Aguardando impressão"            )

            //Adiciona uma coluna no Browse em tempo de execução
            oMarkBrowse:SetColumns(ZESTS002("TR_DESCR"      ,"Descricao"    ,02 ,"@!"                   ,1  ,60 ,0  ))
            oMarkBrowse:SetColumns(ZESTS002("TR_LOTE"       ,"Lote"         ,03 ,"@!"                   ,1  ,25 ,0  ))
            oMarkBrowse:SetColumns(ZESTS002("TR_VLD"        ,"Validade"     ,04 ,"D"                    ,0  ,10 ,0  ))
            oMarkBrowse:SetColumns(ZESTS002("TR_QTDEMB"     ,"Qtd.Embal."   ,05 ,"@E 99,999,999.999"    ,2  ,14 ,3  ))
            oMarkBrowse:SetColumns(ZESTS002("TR_QTDETQ"     ,"Qtd.Etiq."    ,06 ,"@E 9,999.999"         ,2  ,09 ,3  ))
            oMarkBrowse:SetColumns(ZESTS002("TR_QTDDOC"     ,"Qtd.Docum."   ,07 ,"@E 99,999,999.999"    ,2  ,14 ,3  ))
            oMarkBrowse:SetColumns(ZESTS002("TR_PRODUTO"    ,"Produto"      ,08 ,"@!"                   ,0  ,15 ,0  ))
            oMarkBrowse:SetColumns(ZESTS002("TR_STATUS"     ,"Impressa"     ,09 ,"@!"                   ,0  ,03 ,0  ))

            //Adiciona botoes na janela
            oMarkBrowse:AddButton("Alterar Etiq."   , { || ZESTS003(oMarkBrowse)        },,,, .F., 4 )
		    oMarkBrowse:AddButton("Imprimir Etiq"   , { || ZESTS007(oMarkBrowse)        },,,, .F., 6 )
           
            //Método de ativação da classe
            oMarkBrowse:Activate()

            //Efetuar a exclusão da tabela, e fechar o alias
            oTempTable:Delete()

            //Método de destruição da classe
            oMarkBrowse:DeActivate() 
        Else
            FWAlertWarning("Não existe dados para serem exibidos", "Atenção [ ZESTF002 ]")
            Return
        EndIf
    Else
        FWAlertWarning("Não existe dados para serem exibidos", "Atenção [ ZESTF002 ]")
    EndIf

Return()   

/*/{Protheus.doc} ZESTS001
Monta a query de acordo com a tabela
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
@param cTabela, character, tabela do processo
/*/
Static Function ZESTS001(cTabela)

    Local cQuery    := ""
    Default cTabela := ""

    If Select( (cAliasSQL) ) > 0
        (cAliasSQL)->(DbCloseArea())
    EndIf

    If cTabela == "SF1"

        cQuery := " "
        cQuery := " SELECT 	TRIM(SD1.D1_COD)        AS COD "                        + CRLF
    	cQuery += " 	    ,SB1.B1_DESC            AS DESCR "                      + CRLF
    	cQuery += " 	    ,SD1.D1_LOTECTL         AS LOTE "                       + CRLF
    	cQuery += " 	    ,SD1.D1_DTVALID         AS VALIDADE "                   + CRLF
    	cQuery += " 	    ,SD1.D1_QUANT           AS QTDE "                       + CRLF
        cQuery += " FROM " + RetSQLName('SD1') + " SD1 "                            + CRLF
        cQuery += "     INNER JOIN " + RetSQLName('SB1') + " SB1 "                  + CRLF
        cQuery += "         ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "         + CRLF
        cQuery += "         AND SB1.B1_COD = SD1.D1_COD "                           + CRLF
        cQuery += "         AND SB1.D_E_L_E_T_ = ' ' "                              + CRLF
        cQuery += " WHERE SD1.D1_FILIAL = '" + SF1->F1_FILIAL + "' "                + CRLF
        cQuery += " AND SD1.D1_DOC      = '" + SF1->F1_DOC + "' "                   + CRLF
        cQuery += " AND SD1.D1_SERIE    = '" + SF1->F1_SERIE + "' "                 + CRLF
        cQuery += " AND SD1.D1_FORNECE  = '" + SF1->F1_FORNECE + "' "               + CRLF
        cQuery += " AND SD1.D1_LOJA     = '" + SF1->F1_LOJA + "' "                  + CRLF
        cQuery += " AND SD1.D_E_L_E_T_  = ' ' "                                     + CRLF
        cQuery += " ORDER BY SD1.D1_COD, SD1.D1_LOTECTL  "                          + CRLF

        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    ElseIf cTabela == "SD3"

        cQuery := " "
        cQuery := " SELECT 	TRIM(SD3.D3_COD)        AS COD "                        + CRLF
    	cQuery += " 	    ,SB1.B1_DESC            AS DESCR "                      + CRLF
    	cQuery += " 	    ,SD3.D3_LOTECTL         AS LOTE "                       + CRLF
    	cQuery += " 	    ,SD3.D3_DTVALID         AS VALIDADE "                   + CRLF
    	cQuery += " 	    ,SD3.D3_QUANT           AS QTDE "                       + CRLF
        cQuery += " FROM " + RetSQLName('SD3') + " SD3 "                            + CRLF
        cQuery += "     INNER JOIN " + RetSQLName('SB1') + " SB1 "                  + CRLF
        cQuery += "         ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "         + CRLF
        cQuery += "         AND SB1.B1_COD = SD3.D3_COD "                           + CRLF
        cQuery += "         AND SB1.D_E_L_E_T_ = ' ' "                              + CRLF
        cQuery += " WHERE SD3.D3_FILIAL = '" + SD3->D3_FILIAL + "' "                + CRLF
        cQuery += " AND SD3.D3_DOC      = '" + SD3->D3_DOC + "' "                   + CRLF
        cQuery += " AND SD3.D3_CF LIKE 'PR%' "                                      + CRLF
        cQuery += " AND SD3.D3_ESTORNO <> 'S' "                                     + CRLF
        cQuery += " AND SD3.D_E_L_E_T_  = ' ' "                                     + CRLF
        cQuery += " ORDER BY SD3.D3_COD, SD3.D3_LOTECTL  "                          + CRLF

        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    ElseIf cTabela == "SB8"

        cQuery := " "
        cQuery := " SELECT 	TRIM(SB8.B8_PRODUTO)    AS COD "                        + CRLF
    	cQuery += " 	    ,SB1.B1_DESC            AS DESCR "                      + CRLF
    	cQuery += " 	    ,SB8.B8_LOTECTL         AS LOTE "                       + CRLF
    	cQuery += " 	    ,SB8.B8_DTVALID         AS VALIDADE "                   + CRLF
    	cQuery += " 	    ,SB8.B8_SALDO           AS QTDE "                       + CRLF
        cQuery += " FROM " + RetSQLName('SB8') + " SB8 "                            + CRLF
        cQuery += "     INNER JOIN " + RetSQLName('SB1') + " SB1 "                  + CRLF
        cQuery += "         ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "         + CRLF
        cQuery += "         AND SB1.B1_COD = SB8.B8_PRODUTO "                       + CRLF
        cQuery += "         AND SB1.D_E_L_E_T_ = ' ' "                              + CRLF
        cQuery += " WHERE SB8.B8_FILIAL = '" + SB8->B8_FILIAL + "' "                + CRLF
        cQuery += " AND SB8.B8_LOTECTL  = '" + SB8->B8_LOTECTL + "' "               + CRLF
        cQuery += " AND SB8.B8_PRODUTO  = '" + SB8->B8_PRODUTO + "' "               + CRLF
        cQuery += " AND SB8.B8_LOCAL    = '" + SB8->B8_LOCAL + "' "                 + CRLF
        cQuery += " AND SB8.D_E_L_E_T_  = ' ' "                                     + CRLF
        cQuery += " ORDER BY SB8.B8_PRODUTO, SB8.B8_LOTECTL  "                      + CRLF

        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    EndIf

Return()

/*/{Protheus.doc} ZESTS002
Monta as colunas do Browse
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
@param cCampo, character, Campo
@param cTitulo, character, Titulo
@param nArrData, numeric, Array
@param cPicture, character, Picture
@param nAlign, numeric, Alinhamento
@param nSize, numeric, Tamanho
@param nDecimal, numeric, Decimal
@return array, Colunas
/*/
Static Function ZESTS002(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

    Local aColumn
    Local bData      := {||}
    Default nAlign   := 1
    Default nSize    := 20
    Default nDecimal := 0
    Default nArrData := 0  
            
    If nArrData > 0
        bData := &("{||" + cCampo +"}") 
    EndIf
        
    /* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
    */
    aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return{aColumn}

/*/{Protheus.doc} ZESTS003
Monta a tela de edição das etiquetas
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
@param oMarkBrowse, object, Browse inicial
/*/
Static Function ZESTS003(oMarkBrowse)

	Local oEditar   := Nil
	Local oSayEtq   := Nil
	Local oGetEtq   := Nil
	Local oSayEmb   := Nil
	Local oGetEmb   := Nil
	Local nQtdeEtq  := (cAliasTRB)->TR_QTDETQ
	Local nQtdEmb   := (cAliasTRB)->TR_QTDEMB

    Default oMarkBrowse := Nil

	oEditar:= MSDialog():New(060,010,320,300,'Gestão de Quantidades',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	oSayEtq:= TSay():Create(oEditar,{||"Quantidade de Etiquetas"},10,10,,/* oFont */,,,,.T.,CLR_RED,CLR_WHITE,80,10)
	oGetEtq:= TGet():New( 20,10,{|U|If(PCount()==0,nQtdeEtq,nQtdeEtq:=U)},oEditar,080,020,"@E 999,999,999.999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"TR_QTDETQ",,,, )
	oSayEmb:= TSay():Create(oEditar,{||"Quantidade por Embalagem"},50,10,,/* oFont */,,,,.T.,CLR_RED,CLR_WHITE,80,10)
	oGetEmb:= TGet():New( 60,10,{|U|If(PCount()==0,nQtdEmb,nQtdEmb:=U)},oEditar,080,020,"@E 999,999,999.999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"TR_QTDEMB",,,, )
	@095, 15 Button oBtn1 Prompt 'Confirmar'    Size 50, 30 Action ( ZESTS005(oMarkBrowse, nQtdeEtq, nQtdEmb ),oEditar:End()  ) Of oEditar Pixel
	@095, 80 Button oBtn2 Prompt 'Cancelar'     Size 50, 30 Action ( oEditar:End() ) Of oEditar Pixel
	oEditar:Activate()

	oMarkBrowse:Refresh()

Return()

/*/{Protheus.doc} ZESTS004
Prepara as Etiquetas para impressao
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
@param oMarkBrowse, object, Browse Inicial
/*/
Static Function ZESTS004(oMarkBrowse)

	Local nX := 0

    Default oMarkBrowse     := Nil

	DbSelectArea((cAliasTRB))
	(cAliasTRB)->(DbGoTop())
	While !((cAliasTRB))->(Eof())

		If !Empty((cAliasTRB)->TR_OK)

			//Repetir a impressao da mesma etiqueta conforme selecionado pelo usuario
			For nX := 1 To (cAliasTRB)->TR_QTDETQ
				Processa({|| U_ZGENETQ(cCodPrint ,(cAliasTRB)->TR_DESCR ,Alltrim((cAliasTRB)->TR_LOTE), (cAliasTRB)->TR_VLD ,(cAliasTRB)->TR_QTDEMB ,(cAliasTRB)->TR_PRODUTO) },"Imprimindo etiqueta " + cValToChar(nX))
				Sleep(500)
			Next nX
		Endif

		(cAliasTRB)->(DbSkip())
	EndDo

    (cAliasTRB)->(DbGoTop())
    oMarkBrowse:Refresh(.T.) 

Return()

/*/{Protheus.doc} ZESTS005
Grava os novas informações no browse
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
@param oMarkBrowse, object, Browse inicial
@param nQtdeEtq, numeric, Qtde Etiquetas
@param nQtdEmb, numeric, Qtde Embalagem
/*/
Static Function ZESTS005(oMarkBrowse, nQtdeEtq, nQtdEmb)

	Local cMarca 	    := oMarkBrowse:Mark()
    Default nQtdeEtq    := 1
    Default nQtdEmb     := 1

	RecLock((cAliasTRB),.F.)
        (cAliasTRB)->TR_QTDETQ := nQtdeEtq
        (cAliasTRB)->TR_QTDEMB := nQtdEmb
        If (cAliasTRB)->TR_QTDETQ > 0
            If !oMarkBrowse:IsMark(cMarca)
                (cAliasTRB)->TR_OK := cMarca
            EndIf
        Else
            If (cAliasTRB)->TR_QTDETQ < 0
                (cAliasTRB)->TR_QTDETQ := 0
            EndIf
            (cAliasTRB)->TR_OK := ''
        EndIf
	(cAliasTRB)->(MsUnLock())

Return()

/*/{Protheus.doc} ZESTS007
Monta a tela de selecionar as impressoras
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 08/08/2024
@param oMarkBrowse, object, Browse Principal
/*/
 Static Function ZESTS007(oMarkBrowse)

Private oDlg        := Nil		// Dialog Principal
Default oMarkBrowse := Nil

    DEFINE MSDIALOG oDlg TITLE "[ ZESTF002 ] - Gestão de Impressão" FROM C(178),C(160) TO C(329),C(450) PIXEL
		
	@ C(005),C(006) TO C(061),C(140) LABEL "Selecione a Impressora" PIXEL OF oDlg
		
	@ C(022),C(020) Say "Impressora:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(030),C(020) MsGet cCodPrint PICTURE "@!" VALID  !Empty(cCodPrint) .And. FValidCpo("IMPRESSORA" , cCodPrint)  F3 "CB5IMP" WHEN .T. SIZE 100,08  PIXEL OF oDlg 
		
	DEFINE SBUTTON FROM C(065),C(068) TYPE 6 ENABLE OF oDlg ACTION ( Processa( { || ZESTS004(oMarkBrowse) }	,"[ ZESTF002 ] - Imprimindo Etiqueta..." )	,oDlg:End() )
	DEFINE SBUTTON FROM C(065),C(098) TYPE 2 ENABLE OF oDlg ACTION ( oDlg:End() )
		
	ACTIVATE MSDIALOG oDlg CENTERED

Return()
/*/{Protheus.doc} FValidCpo
Valida os campos da ZESTF007
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 08/08/2024
@param cAcao, character, Campo
@param xVar, variant, Variavel
/*/
Static Function FValidCpo( cAcao, xVar )
	
    Local lRet

	lRet    := .T.
	cAcao := IF(cAcao==NIL,"",Upper(cAcao))

	If cAcao == "IMPRESSORA"
        If Empty(xVar)
            lRet := .F.
			FWAlertWarning("Necessario informar uma impressora", "Atenção [ ZESTF002 ]")
		EndIf
        DbSelectArea("CB5")
        CB5->(DbSetOrder(1))
        If !DbSeek(xFilial("CB5")+xVar)
            lRet := .F.
            FWAlertWarning("Impressora nao encontrada no cadastro", "Atenção [ ZESTF002 ]")
        EndIf
	EndIf

Return(lRet)

