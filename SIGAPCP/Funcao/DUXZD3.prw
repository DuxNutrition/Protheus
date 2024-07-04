//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari�veis Est�ticas
Static cTitulo := "Monitor de Transferencias"

/*/{Protheus.doc} DUXZD3
Fun��o para cadastro de Grupo de Produtos (ZD3), exemplo de Modelo 1 em MVC
@author Atilio
@since 17/08/2015
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
    u_DUXZD3()
    @obs N�o se pode executar fun��o MVC dentro do f�rmulas
/*/

User Function DUXZD3()
	Local aArea   := GetArea()
	Local oBrowse

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZD3")

	//Setando a descri��o da rotina
	oBrowse:SetDescription(cTitulo)

	//Legendas
	oBrowse:AddLegend( "ZD3->ZD3_QTDORI == ZD3->ZD3_QTDDES .AND. ZD3->ZD3_FLAG == ' ' ", "ORANGE",    "Qtd Origem Igual Destino" )
	oBrowse:AddLegend( "ZD3->ZD3_QTDORI <> ZD3->ZD3_QTDDES .AND. ZD3->ZD3_FLAG == ' ' ", "RED",    "Qtd Origem Diferente Destino" )
	oBrowse:AddLegend( "ZD3->ZD3_FLAG == 'P'"              , "GREEN",    "Transferencia/Empenho atualizado" )
	oBrowse:AddLegend( "ZD3->ZD3_FLAG == 'R'"              , "BLACK",    "Quantidade Rejeitada" )

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar'           ACTION 'VIEWDEF.DUXZD3' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE 'Atualiza Empenhos'    ACTION 'u_atuEmp'      OPERATION 6                      ACCESS 0 //OPERATION X
    //ADD OPTION aRot TITLE 'Incluir'              ACTION 'VIEWDEF.DUXZD3' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'              ACTION 'VIEWDEF.DUXZD3' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'              ACTION 'VIEWDEF.DUXZD3' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Analise de Saldos'    ACTION 'u_anlSld'      OPERATION 6                      ACCESS 0 //OPERATION X
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil
     
    //Cria��o da estrutura de dados utilizada na interface
    Local oStZD3 := FWFormStruct(1, "ZD3")
     
    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("DUXZD3M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMZD3",/*cOwner*/,oStZD3)
     
    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({'ZD3_FILIAL','ZD3_ORDSEP','ZD3_ITEM','ZD3_DOCMOV','ZD3_PROD','ZD3_LOCORI','ZD3_ENDORI'})
     
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMZD3"):SetDescription("Formul�rio do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("DUXZD3")
     
    //Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZD3 := FWFormStruct(2, "ZD3")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZD3_NOME|ZD3_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_ZD3", oStZD3, "FORMZD3")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_ZD3', 'Dados do Grupo de Produtos' )  
     
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_ZD3","TELA")
Return oView
 
User Function atuEmp()

	Local aZD3	:= ZD3->(GetArea())
    Local cOrdSep   := ZD3->ZD3_ORDSEP
    Local cOP       := ZD3->ZD3_OP

    if(substr(cOP,1,4)<>'AGLT')
	    Processa( {|| U_DUXEMP1(cOrdSep,cOP) }, "Aguarde...", "Processando ...",.F.)
    else 
        Processa( {|| U_DUXEMP2(cOrdSep,cOP) }, "Aguarde...", "Processando ...",.F.)
    endif 

	ZD3->(RestArea(aZD3))

Return


User Function anlSld()
    Local aZD3  	:= ZD3->(GetArea())
    Local cDocMov   := ZD3->ZD3_DOCMOV
    Local cOrdSep   := ZD3->ZD3_ORDSEP
    Local cOP       := ZD3->ZD3_OP
    Local cQry      := ""
    Local cRetCmp   := ''
    


    If ZD3->ZD3_FLAG == 'P'
        MsgInfo("Documento j� processado !","DUXZD301" )
    Else 
        cQry := "SELECT ZB8_OP,ZB8_LOCAL,ZB8_ITEM,ZB8_PROD,ZB8_LOTECT,ZB8_QTDORI FROM "+ RetSqlName( "ZB8" ) +" "
	cQry += "WHERE ZB8_FILIAL = '" + CB7->CB7_FILIAL + "' AND ZB8_OSAGL = '" + CB7->CB7_ORDSEP + "' "
	cQry += "AND D_E_L_E_T_ = '' "

    cQry := "SELECT BF_QUANT,BF_EMPENHO,ZD3_DOCMOV,ZD3_PROD,ZD3_LOCORI,ZD3_ENDORI,ZD3_LOTORI,ZD3_QTDORI, "
    cQry += "ZD3_LOCDES,ZD3_ENDDES,ZD3_LOTDES,ZD3_QTDDES,ZD3_USRORI,ZD3_USRDES,ZD3_DTORI,ZD3_DTDES FROM "+ RetSqlName( "ZD3" ) +" ZD3 "
    cQry += "LEFT JOIN "+ RetSqlName( "SBF" ) +" SBF ON "
    cQry += "ZD3_FILIAL = BF_FILIAL AND "
    cQry += "ZD3_PROD = BF_PRODUTO AND "
    cQry += "ZD3_LOCORI = BF_LOCAL AND "
    cQry += "ZD3_LOTORI = BF_LOTECTL AND  "
    cQry += "ZD3_ENDORI = BF_LOCALIZ AND "
    cQry += "SBF.D_E_L_E_T_ = '' "
    cQry += "WHERE ZD3.D_E_L_E_T_�=�'' "
    If !empty(cDocMov)
    cQry += "AND ZD3_DOCMOV = '" + cDocMov + "' "
    Else 
    cQry += "AND ZD3_ORDSEP = '" + cOrdSep + "' "
    Endif 

    cRetCmp := "BF_QUANT,BF_EMPENHO,ZD3_DOCMOV,ZD3_PROD,ZD3_LOCORI,ZD3_ENDORI,ZD3_LOTORI,ZD3_QTDORI,"
    cRetCmp += "ZD3_LOCDES,ZD3_ENDDES,ZD3_LOTDES,ZD3_QTDDES,ZD3_USRORI,ZD3_USRDES,ZD3_DTORI,ZD3_DTDES"


	u_zConsSQL(cQry,cRetCmp)

    EndIf

    ZD3->(RestArea(aZD3))
Return 
