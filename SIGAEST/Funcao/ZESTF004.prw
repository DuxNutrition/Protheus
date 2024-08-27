#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*/{Protheus.doc} ZESTF004
Amarração Shelf Life | Cliente x Grupo

@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 20/08/2024
/*/
User function ZESTF004()

    Local oBrowse       := Nil
    Private aRotina     := MenuDef()

   //Cria um Browse Simples instanciando o FWMBrowse
    oBrowse := FWMBrowse():New()

    //Define um alias para o Browse
    oBrowse:SetAlias('XZ1')
    
    //Adiciona uma descrição para o Browse
    oBrowse:SetDescription('Amarração Shelf Life | Cliente x Grupo')

    // Definição da legenda
    oBrowse:AddLegend( "XZ1->XZ1_MSBLQL == '1'"	, "BR_VERMELHO"	    ,"Bloqueado"    )
    oBrowse:AddLegend( "XZ1->XZ1_MSBLQL == '2'" , "BR_VERDE"        ,"Ativo"        )
    
    //Ativa o Browse
    oBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef
Monta o Menu de opções

@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 20/08/2024
@return array, Array dos menus
/*/
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Pesquisar'	        ACTION 'PesqBrw'		  OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar'	        ACTION 'VIEWDEF.ZESTF004' OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title 'Incluir'              ACTION 'VIEWDEF.ZESTF004' OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Alterar'              ACTION 'VIEWDEF.ZESTF004' OPERATION 4 ACCESS 0
    ADD OPTION aRotina Title 'Excluir'              ACTION 'VIEWDEF.ZESTF004' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'    	        ACTION 'U_zBrwLeg()'      OPERATION 6 ACCESS 0

Return( aRotina )

/*/{Protheus.doc} ModelDef
Modelo do mvc

@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 27/08/2024
@return object, Modelo do mvc
/*/
Static Function ModelDef()

    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruXZ1  := FWFormStruct( 1, 'XZ1', /*bAvalCampo*/,/*lViewUsado*/ )
    Local bPosValid := { ||bValidXZ1(oModel) }
    Local oModel

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New('GENF002MDL',  /*bPreValidacao*/, bPosValid /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModel:AddFields( 'XZ1MASTER', /*cOwner*/, oStruXZ1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

    oModel:SetPrimaryKey({ 'XZ1_FILIAL', 'XZ1_CODCLI', 'XZ1_LOJA', 'XZ1_GRUPO' })

    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription( 'Amarração Shelf Life | Cliente x Grupo' )

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'XZ1MASTER' ):SetDescription( 'Amarração Shelf Life | Cliente x Grupo' )

Return( oModel )

/*/{Protheus.doc} ViewDef
View do MVC

@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 27/08/2024
@return object, View do mvc
/*/
Static Function ViewDef()

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel   := FWLoadModel( 'ZESTF004' )

    // Cria a estrutura a ser usada na View
    Local oStruXZ1 := FWFormStruct( 2, 'XZ1' )
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados serÃ¡ utilizado
    oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 'VIEW_XZ1', oStruXZ1, 'XZ1MASTER' )


    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'TELA' , 100 )

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'VIEW_XZ1', 'TELA' )

Return( oView )

/*/{Protheus.doc} zBrwLeg
Browse da legenda

@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 27/08/2024
/*/
User Function zBrwLeg()

    Local aLegenda := {}

    //Monta as cores
    AADD(aLegenda,{"BR_VERMELHO"	,"Bloqueado"    })
    AADD(aLegenda,{"BR_VERDE"		,"Ativo"        })
    
    BrwLegenda("Status", "Bloqueado ?", aLegenda)

Return()

/*/{Protheus.doc} bValidXZ1
Validação do MVC

@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 27/08/2024
@param oModel, object, Modelo do MVC
@return logical, .T. OU .F.
/*/  
Static Function bValidXZ1(oModel)

    Local oModelXZ1		:= oModel:GetModel('XZ1MASTER')
    Local cCliente      := oModelXZ1:GetValue('XZ1_CODCLI')
    Local cLoja		    := oModelXZ1:GetValue('XZ1_LOJA')
    Local cGrupo		:= oModelXZ1:GetValue('XZ1_GRUPO')
    Local nOperation    := oModel:GetOperation()
    local lRet			:= .T.
    Local lExistXZ1     := .F.

    //1 - View
    //3 - Insert
    //4 - Update
    //5 - Delete
    //Inclusão(3) ou Alteração(4)
    If nOperation == 3 .Or. nOperation == 4

        //Verifica se já existe esse acesso para esse usuário e rotina.
        lExistXZ1	:= ZSeekXZ1(cCliente,cLoja,cGrupo,nOperation)

        If lExistXZ1
           lRet := .F.
        EndIf
    Endif

Return( lRet )

/*/{Protheus.doc} ZSeekXZ1
Procura se já existe um cadasto para aquele cliente/loja e grupo

@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 27/08/2024
@param cCliente, character, cliente
@param cLoja, character, loja
@param cGrupo, character, grupo
@param nOperation, numeric, tipo de operacao
@return logical, .T. ou .F.
/*/
Static Function ZSeekXZ1(cCliente,cLoja,cGrupo,nOperation)

    Local cQryXZ1   	:= ""
    Local cAliXZ1 		:= GetNextAlias()
    Local lRetorno      := .F.
    Local cMsgErro      := ""
    Local cMsgSolu      := ""
    Local lSeek         := .T.

    Default cCliente    := ""
    Default cLoja       := ""
    Default cGrupo      := ""
    Default nOperation  := 0

    //1 - View | 3 - Insert | 4 - Update | 5 - Delete
    //Inclusão(3) ou Alteração(4)
    If ( nOperation == 4 .And. ( AllTrim(XZ1->XZ1_CODCLI) == AllTrim(cCliente) .And. AllTrim(XZ1->XZ1_LOJA) == AllTrim(cLoja) .And. AllTrim(XZ1->XZ1_GRUPO) == AllTrim(cGrupo)  ) )
        lSeek := .F.
    EndIf

    SA1->(dbSetOrder(1))
	If !(SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja)))
        cMsgErro      := "Cliente/Loja não encontrado"
        cMsgSolu      := "Verifique o preenchimento dos campos de Cliente/Loja"
                    
        Help(NIL, NIL, "[ ZESTF004 ] - Help", NIL, cMsgErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgSolu})
        lRetorno := .T.
        lSeek := .F.
    EndIf

    If lSeek

        If Select((cAliXZ1)) > 0
            (cAliXZ1)->(DbCloseArea())
        EndIf

        cQryXZ1 := ""
        cQryXZ1 += " SELECT XZ1_FILIAL, XZ1_CODCLI, XZ1_LOJA, XZ1_GRUPO, XZ1_MSBLQL "       + CRLF
        cQryXZ1 += " FROM "+RetSQLName('XZ1')+" XZ1 "                                       + CRLF
        cQryXZ1 += " WHERE XZ1.XZ1_FILIAL = '"+FWxFilial('XZ1')+"' "                        + CRLF
        cQryXZ1 += " AND XZ1.XZ1_CODCLI = '" + cCliente + "' "                              + CRLF
        cQryXZ1 += " AND XZ1.XZ1_LOJA = '" + cLoja + "' "                                   + CRLF
        cQryXZ1 += " AND XZ1.XZ1_GRUPO = '" + cGrupo + "' "                                 + CRLF
        cQryXZ1 += " AND XZ1.D_E_L_E_T_ = '' "                                              + CRLF
        cQryXZ1 += " ORDER BY XZ1_FILIAL, XZ1_CODCLI, XZ1_LOJA, XZ1_GRUPO "                 + CRLF

        //Executa a consulta
        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryXZ1), cAliXZ1, .T., .T. )

        DbSelectArea((cAliXZ1))
        (cAliXZ1)->(DbGoTop())
        If (cAliXZ1)->(!Eof())

            If (cAliXZ1)->XZ1_MSBLQL == "2"

                cMsgErro      := "Já existe uma amarração para esse cliente e grupo Ativa"
                cMsgSolu      := "Verifique o preenchimento dos campos de Cliente/Loja e Grupo"
                    
                Help(NIL, NIL, "[ ZESTF004 ] - Help", NIL, cMsgErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgSolu})
                lRetorno := .T.

            Else

                cMsgErro      := "Já existe uma amarração para esse cliente e grupo bloqueada"
                cMsgSolu      := "Identifique o cadastro e realize o desbloqueio"
                    
                Help(NIL, NIL, "[ ZESTF004 ] - Help", NIL, cMsgErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgSolu})
                lRetorno := .T.

            EndIf

        EndIf
        (cAliXZ1)->(DbCloseArea())
    EndIf

Return( lRetorno )
