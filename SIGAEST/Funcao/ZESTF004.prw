#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*/{Protheus.doc} ZESTF004
Amarração Cliente x Grupo | Shelf Life
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
    oBrowse:SetDescription('Amarração Cliente x Grupo | Shelf Life')

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

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ModelDef()

    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruXZ1  := FWFormStruct( 1, 'XZ1', /*bAvalCampo*/,/*lViewUsado*/ )
    Local bPos      := { ||bPosXZ1(oModel) }
    Local oModel

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New('GENF002MDL',  /*bPreValidacao*/, bPos /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModel:AddFields( 'XZ1MASTER', /*cOwner*/, oStruXZ1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

    oModel:SetPrimaryKey({ 'XZ1_FILIAL', 'XZ1_CODCLI', 'XZ1_LOJA', 'XZ1_GRUPO' })

    // Adiciona a descricao do Modelo de Dados
    oModel:SetDescription( 'Amarração Cliente x Grupo | Shelf Life | MODEL' )

    // Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel( 'XZ1MASTER' ):SetDescription( 'Amarração Cliente x Grupo | Shelf Life | MODEL' )

Return( oModel )

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
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
/*
=====================================================================================
Programa.:              zBrwLeg
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              02/08/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/  

User Function zBrwLeg()

    Local aLegenda := {}

    //Monta as cores
    AADD(aLegenda,{"BR_VERMELHO"	,"Bloqueado"    })
    AADD(aLegenda,{"BR_VERDE"		,"Ativo"        })
    
    BrwLegenda("Status", "Bloqueado ?", aLegenda)

Return()

/*
=====================================================================================
Programa.:              bPosXZ1
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/  
Static Function bPosXZ1(oModel)

    Local oModelXZ1		:= oModel:getmodel('XZ1MASTER')
    Local cCod          := oModelXZ1:GetValue('XZ1_COD')
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

        If !(lExistXZ1)
            If Empty(cCod)
                Help(NIL, NIL, "[ ZESTF004 ] - Help", NIL, "Motivo do bloqueio não preenchido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Quando um usuário é bloqueado, é obrigatorio o preenchimento do Motivo do Bloqueio"})
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        EndIf
    Endif

Return( lRet )

/*
=====================================================================================
Programa.:              ZSeekXZ1
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Verifica se existe algum cadastro igual o que está 
                        sendo realizado.
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/ 
Static Function ZSeekXZ1(cRotina,cId,nOperation)

    Local cQryXZ1   	:= ""
    Local cAliXZ1 		:= GetNextAlias()
    Local cRotSeek      := cRotina
    Local cIDSeek       := cId
    Local nOperSeek     := nOperation
    Local lRetorno      := .F.
    Local cMsgErro      := ""
    Local cMsgSolu      := ""
    Local lSeek         := .T.

//É uma alteração e Rotina não mudou e ID não mudou, não precisa realizar uma nova busca.
    If ( nOperSeek == 4 .And. ( AllTrim(XZ1->ZX_ROTINA) == AllTrim(cRotSeek) .And. AllTrim(XZ1->ZX_ID) == AllTrim(cIDSeek)  ) )
        lSeek := .F.
    EndIf

    If lSeek

        If Select((cAliXZ1)) > 0
            (cAliXZ1)->(DbCloseArea())
        EndIf

        cQryXZ1 := ""
        cQryXZ1 += " SELECT ZX_ROTINA, ZX_ID, ZX_LOGIN, ZX_ACESSO "                             + CRLF
        cQryXZ1 += " FROM "+RetSQLName('XZ1')+" XZ1 "                                           + CRLF
        cQryXZ1 += " WHERE XZ1.ZX_FILIAL = '"+FWxFilial('XZ1')+"' "                             + CRLF
        cQryXZ1 += " AND XZ1.ZX_ID = '" + cIDSeek + "' "                       					+ CRLF
        cQryXZ1 += " AND (XZ1.ZX_ROTINA = '" + cRotSeek + "' OR XZ1.ZX_ROTINA = '**********') " + CRLF
        cQryXZ1 += " AND XZ1.D_E_L_E_T_ = ' ' "                                					+ CRLF
        cQryXZ1 += " ORDER BY XZ1.ZX_FILIAL, XZ1.ZX_ID, XZ1.ZX_ROTINA "       					+ CRLF

        cQryXZ1 := ChangeQuery(cQryXZ1)

        //Executa a consulta
        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryXZ1), cAliXZ1, .T., .T. )

        DbSelectArea((cAliXZ1))
        (cAliXZ1)->(dbGoTop())
        If (cAliXZ1)->(!Eof())
            If (cAliXZ1)->ZX_ROTINA == "**********"
                If (cAliXZ1)->ZX_ACESSO $ "S|T"
                    cMsgErro      := "Usuário com perfil de acesso Completo (FULL)"
                    cMsgSolu      := "Não existe a necessidade de cadastrar o seu usuário para essa rotina, seu usuário possui acesso Completo!"
                ElseIf !((cAliXZ1)->ZX_ACESSO) $ "S|T"
                    cMsgErro      := "Usuário com perfil de acesso Completo (FULL) - Com Problema"
                    cMsgSolu      := "Usuário possui cadastro Completo (FULL), porém existe divergência no acesso cadastrado, verifique o cadastro existente e os acessos para esse usuário!"
                EndIf
            Else
                If (cAliXZ1)->ZX_ACESSO $ "S|T"
                    cMsgErro      := "Usuário já possui cadastro para essa rotina."
                    cMsgSolu      := "Não existe a necessidade de cadastrar o seu usuário para essa rotina, seu usuário possui acesso!"
                ElseIf !((cAliXZ1)->ZX_ACESSO) $ "S|T"
                    cMsgErro      := "Usuário já possui cadastro para essa rotina - Com Problema"
                    cMsgSolu      := "Usuário possui cadastro, porém existe divergência no acesso cadastrado, verifique o cadastro existente e os acessos para esse usuário!"
                EndIf
            EndIf
            Help(NIL, NIL, "[ ZCFGF003 ] - Help", NIL, cMsgErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgSolu})
            lRetorno := .T.
        EndIf
        (cAliXZ1)->(DbCloseArea())
    EndIf

Return( lRetorno )

/*
=====================================================================================
Programa.:              ZCopyXZ1
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Copia os direitos de um Usuário para Outro
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/ 
User Function ZCopyXZ1()

Local cQryUpd   	:= ""
// Local cError        := ""
Local cQryCopy   	:= ""
Local cAliCopy 		:= GetNextAlias()
Local cPerg         := "ZCFGF003P1"
Local lMaster       := .F.
Local lContinua     := .T.
Local lUpdXZ1       := .F.

DbSelectArea("XZ1")
XZ1->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA

Pergunte(cPerg,.T.)

If !( Empty(MV_PAR01) .Or. Empty(MV_PAR02) )
    If !( MV_PAR01 == MV_PAR02 )
        If MsgYesNo("Deseja prosseguir com a seguinte cópia ?" + CRLF + CRLF + "Copiar Acessos" + CRLF + CRLF + "De:   " + MV_PAR01 + " - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + "Para: " + MV_PAR02 + " - " + AllTrim( UsrRetName( MV_PAR02 ) ) + CRLF + CRLF + "Deseja realmente continuar ??? ","ZCFGF003")

            //Verifica se o DE: possui acesso Completo(FULL), caso possua, não realiza a copia.
            XZ1->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
            If XZ1->( dbSeek( xFilial("XZ1") + MV_PAR01 + "**********" ))
                lMaster := .T.
            EndIf

            If !( lMaster )

                //Verifica se o DE: possui cadastro de acesso, caso não possua, cancela a operação
                XZ1->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
                If XZ1->( dbSeek( xFilial("XZ1") + MV_PAR01 ))
                
                    //Verifica se o PARA: possui cadastro de acesso, caso possua, pergunta se realmente deseja substituir.
                    XZ1->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
                    If XZ1->( dbSeek( xFilial("XZ1") + MV_PAR02 ))
                        If MsgYesNo("O usuário: " + MV_PAR02 + " - " + AllTrim( UsrRetName( MV_PAR02 ) ) + " possui um cadastro de acesso."    + CRLF + CRLF + "Deseja realmente substituir os acessos ??? ","ZCFGF003")
                            
                            //Confirmando a substituição, apaga os registros do PARA:
                            lContinua := .T.
                            cQryUpd := ""
                            cQryUpd += " UPDATE " + RetSqlName("XZ1")       + CRLF
                            cQryUpd += " SET D_E_L_E_T_ = '*' "             + CRLF
                            cQryUpd += " WHERE D_E_L_E_T_ = ' ' "           + CRLF
                            cQryUpd += " AND ZX_ID = '" + MV_PAR02 + "' "   + CRLF
                            
                            lUpdXZ1 :=  TcSqlExec(cQryUpd)
        
                            If lUpdXZ1 <> 0
                                ApMsgStop("Problema para substituir os registros! Tente novamente." + CRLF + CRLF + "SQL Error: " +TcSqlError() ,"ZCFGF003")    
                                lContinua := .F.
                            Else
                                lContinua := .T.
                            Endif   
                        Else
                            lContinua := .F.
                        EndIf
                    EndIf
                
                    If lContinua
                        If Select((cAliCopy)) > 0
                            (cAliCopy)->(DbCloseArea())
                        EndIf

                        cQryCopy := ""
                        cQryCopy += " SELECT * "                                            + CRLF
                        cQryCopy += " FROM "+RetSQLName('XZ1')+" XZ1 "                      + CRLF
                        cQryCopy += " WHERE XZ1.ZX_FILIAL = '"+FWxFilial('XZ1')+"' "        + CRLF
                        cQryCopy += " AND XZ1.ZX_ID = '" + MV_PAR01 + "' "                  + CRLF
                        cQryCopy += " AND XZ1.D_E_L_E_T_ = ' ' "                            + CRLF
                        cQryCopy += " ORDER BY XZ1.ZX_FILIAL, XZ1.ZX_ID, XZ1.ZX_ROTINA "    + CRLF

                        cQryCopy := ChangeQuery(cQryCopy)

                        //Executa a consulta
                        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryCopy), cAliCopy, .T., .T. )

                        DbSelectArea((cAliCopy))
                        (cAliCopy)->(dbGoTop())
                        While (cAliCopy)->(!Eof())

                            Reclock( "XZ1" , .T. )
                                XZ1->ZX_FILIAL      := xFilial("XZ1")
                                XZ1->ZX_ROTINA      := (cAliCopy)->ZX_ROTINA
                                XZ1->ZX_ID          := MV_PAR02
                                XZ1->ZX_LOGIN       := UsrRetName( MV_PAR02 )
                                XZ1->ZX_NOME        := UsrFullName( MV_PAR02 )
                                XZ1->ZX_DEPART      := AllTrim( MV_PAR03 )
                                XZ1->ZX_ACESSO      := (cAliCopy)->ZX_ACESSO
                                XZ1->ZX_DESCROT     := (cAliCopy)->ZX_DESCROT
                                XZ1->ZX_DTAUTDE     := SToD( (cAliCopy)->ZX_DTAUTDE )
                                XZ1->ZX_DTAUTAT     := SToD( (cAliCopy)->ZX_DTAUTAT )
                                XZ1->ZX_MOTBLOQ     := If( (cAliCopy)->ZX_ACESSO == "B" , "BLOQUEIO HERDADO DEVIDO A CÓPIA DO USUÁRIO: "+MV_PAR01 , "" )
                            XZ1->(MsUnlock())   

                            (cAliCopy)->(DbSkip())
                        EndDo
                        ApMsgInfo("Usuário copiado com Sucesso!!","[ ZCFGF003 ] - Concluído")
                        (cAliCopy)->(DbCloseArea())
                    Else
                        ApMsgStop("Processo abortado com sucesso.","ZCFGF003")  
                    EndIf
                Else
                    ApMsgStop("O usuário: " + MV_PAR01 +" - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + CRLF + "Não possui nenhum registro de acesso cadastrado, revise os parâmetros e tente novamente!!","ZCFGF003")
                EndIf
            Else
                ApMsgStop("O Usuário que está sendo copiado, possui o perfil de acesso Completo (FULL)"+ CRLF + CRLF + "Não é permitido a cópia desse tipo de perfil, realize um novo cadastro.","ZCFGF003")
            EndIf
        Else
            ApMsgStop("Processo cancelado com sucesso.","ZCFGF003")
        EndIf
    Else
        ApMsgStop("Não é permitida a cópia para o mesmo usuário de origem!","ZCFGF003")
    EndIf
Else
    ApMsgStop("É necessário o preenchimento de ambos os usuários para cópia!","ZCFGF003")
EndIf

Return()

/*
=====================================================================================
Programa.:              ZBlqXZ1
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/08/19
Descricao / Objetivo:   Bloqueia direitos de um Usuário
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/ 
User Function ZBlqXZ1()

Local cQryBlq   	:= ""
Local cAliBlq 		:= GetNextAlias()
Local cPerg         := "ZCFGF003P2"
// Local lMaster       := .F.
// Local lContinua     := .T.
// Local lUpdXZ1       := .F.

DbSelectArea("XZ1")
XZ1->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA

Pergunte(cPerg,.T.)

If !( Empty(MV_PAR01) )
    If MsgYesNo("Deseja prosseguir com o bloqueio seguinte ?" + CRLF + CRLF + "Bloquear Usuário: " + MV_PAR01 + " - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + CRLF + "Deseja realmente realizar o bloqueio ??? ","ZCFGF003")

        //Verifica se o usuário de bloqueio possui cadastro de acesso, caso não possua, cancela a operação
        XZ1->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
        If XZ1->( dbSeek( xFilial("XZ1") + MV_PAR01 ))

            If Select( (cAliBlq) ) > 0
                (cAliBlq)->(DbCloseArea())
            EndIf

            cQryBlq := ""
            cQryBlq += " SELECT ZX_FILIAL, ZX_ID, ZX_ROTINA  "                 + CRLF
            cQryBlq += " FROM "+RetSQLName('XZ1')+" XZ1 "                      + CRLF
            cQryBlq += " WHERE XZ1.ZX_FILIAL = '"+FWxFilial('XZ1')+"' "        + CRLF
            cQryBlq += " AND XZ1.ZX_ID = '" + MV_PAR01 + "' "                  + CRLF
            cQryBlq += " AND XZ1.D_E_L_E_T_ = ' ' "                            + CRLF
            cQryBlq += " ORDER BY XZ1.ZX_FILIAL, XZ1.ZX_ID, XZ1.ZX_ROTINA "    + CRLF

            cQryBlq := ChangeQuery(cQryBlq)

            //Executa a consulta
            DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryBlq), cAliBlq, .T., .T. )

            DbSelectArea((cAliBlq))
            (cAliBlq)->(dbGoTop())
            While (cAliBlq)->(!Eof())
                
                XZ1->(DbSetOrder(1)) //ZX_FILIAL + ZX_ID + ZX_ROTINA
                If XZ1->( DbSeek( (cAliBlq)->ZX_FILIAL  + (cAliBlq)->ZX_ID + (cAliBlq)->ZX_ROTINA  ))
                    Reclock( "XZ1" , .F. )
                        XZ1->ZX_ACESSO      := "B"
                        XZ1->ZX_MOTBLOQ     := AllTrim( MV_PAR02 )
                    XZ1->(MsUnlock())   
                EndIf

                (cAliBlq)->(DbSkip())
            EndDo
            ApMsgInfo("Usuário bloqueado com Sucesso!!","[ ZCFGF003 ] - Concluído")
            (cAliBlq)->(DbCloseArea())
        Else
            ApMsgStop("O usuário: " + MV_PAR01 +" - " + AllTrim( UsrRetName( MV_PAR01 ) ) + CRLF + CRLF + "Não possui nenhum registro de acesso cadastrado, revise os parâmetros e tente novamente!!","ZCFGF003")
        EndIf
    Else
        ApMsgStop("Processo cancelado com sucesso.","ZCFGF003")
    EndIf
Else
    ApMsgStop("É necessário o preenchimento do usuário que será bloqueado!","ZCFGF003")
EndIf

Return()
