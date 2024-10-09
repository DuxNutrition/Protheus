#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.ch"

/*/{Protheus.doc} ZFATF004
Programa que faz o controle dos Contratos de Bonificação.
@author Totvs
@since 30/09/2024
@version P11,P12
@database MSSQL
@history 11/2023 - Dux Company - Jedielson Rodrigues - Revisão;
@See 
/*/

User function ZFATF004()

Local oBrowse  := NIL
Local aArea    := GetArea()
Local aSeekTmp := {	{"Contrato"		  	,{{"",FwGetSx3Cache('ZAD_CONTRA','X3_TIPO'), FwGetSx3Cache('ZAD_CONTRA','X3_TAMANHO'), 0, "ZAD_CONTRA"		, FwGetSx3Cache('ZAD_CONTRA','X3_PICTURE')	},{"",FwGetSx3Cache('ZAD_REVISA','X3_TIPO'), FwGetSx3Cache('ZAD_REVISA','X3_TAMANHO'), 0, "ZAD_REVISA"		, FwGetSx3Cache('ZAD_REVISA','X3_PICTURE')	}}}}

Private aCols    := {}
Private aHeader  := {}
Private aRotina  := MenuDef()
Private cGrupo   := SuperGetMv("DUX_FAT001",.F.,"000110")
Private cTipoDoc := SuperGetMv("DUX_FAT002",.F.,"Z1")
Private N := 1

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("ZAD")
oBrowse:SetDescription("Cadastro Contratos de descontos")
oBrowse:AddLegend( "ZAD_STATUS == '1'","GREEN","Ativo/ Aprovado")
oBrowse:AddLegend( "ZAD_STATUS == '2'","BR_AZUL","Inativo/ Em aprovação")
oBrowse:AddLegend( "ZAD_STATUS == '3'","BR_CANCEL","Inativo/ Rejeitado")
oBrowse:SetUseFilter( .T. )
oBrowse:SetSeek(.T.,aSeekTmp)
oBrowse:Activate()

Restarea(aArea)

Return 

/*----------------------------------------------------
	Monta MenuDef da rotina 
----------------------------------------------------*/

Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"			ACTION "VIEWDEF.ZFATF004"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"  			ACTION "VIEWDEF.ZFATF004"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"  			ACTION "VIEWDEF.ZFATF004"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    			ACTION "VIEWDEF.ZFATF004"   OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"    			ACTION "VIEWDEF.ZFATF004"   OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Revisao"    			ACTION "U_ZFATF04B()"       OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE "Banco Conhecimento"   ACTION "MsDocument('ZAD', ZAD->(RecNo()), 4)"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Liberar Documento"    ACTION "U_ZFATF04A()"       OPERATION 8 ACCESS 0
	
Return (aRotina)   

/*----------------------------------------------------
	Monta ModelDef da rotina 
----------------------------------------------------*/

Static Function ModelDef()

Local oModel		:= NIL
Local oStruCab		:= FWFormStruct(1,"ZAD")
Local oStruItens	:= FWFormStruct(1,"ZAE")
Local nAtual :=  1 

aGatilhos:={}
 aAdd(aGatilhos, FWStruTriggger(    "ZAD_CLIENT",;                                //Campo Origem
                                    "ZAD_NOMCLI",;                                //Campo Destino
                                    "U_ZFATF04C()",;                               //Regra de Preenchimento
                                    .F.,;                                         //Irá Posicionar?
                                    "",;                                          //Alias de Posicionamento
                                    0,;                                           //Índice de Posicionamento
                                    '',;                                          //Chave de Posicionamento
                                    NIL,;                                         //Condição para execução do gatilho
                                    "01");                                        //Sequência do gatilho
    )
 
    //Percorrendo os gatilhos e adicionando na Struct
    For nAtual := 1 To Len(aGatilhos)
        oStruCab:AddTrigger(    aGatilhos[nAtual][01],; //Campo Origem
                            aGatilhos[nAtual][02]	,; //Campo Destino
                            aGatilhos[nAtual][03],; //Bloco de código na validação da execução do gatilho
                            aGatilhos[nAtual][04])  //Bloco de código de execução do gatilho
    Next    
oModel := MPFormModel():New("MZFATF004",,{ |oModel| DUXCTR( oModel ) })

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields("PR2MASTER",/*cOwner*/ ,oStruCab)
IF Fwisincallstack('U_ZFATF04B')
	oStruItens:SetProperty('ZAE_CONTRA',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"ZAD->ZAD_CONTRA"))
	oStruCab:SetProperty('ZAD_CONTRA',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"ZAD->ZAD_CONTRA"))
	
	oStruCab:SetProperty('ZAD_REVISA',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SOMA1(ZAD->ZAD_REVISA)"))
	oStruItens:SetProperty('ZAE_REVISA',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SOMA1(ZAD->ZAD_REVISA)"))
ENDIF
//Adiciona grid de itens
oModel:AddGrid("PR3DETAIL", "PR2MASTER" ,oStruItens )
oModel:SetPrimaryKey( {"ZAD_FILIAL","ZAD_CONTRA","ZAD_REVISA","ZAE_CLIENT"} )
//Seta chave unica do grid de itens.
                                                // [04] Bloco de codigo de execução do gatilho
		
//oStruCab:SetProperty('ZAD_NOMCLI',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"POSICIONE('SA1',1,xFilial('SA1')+FWFLDGET('ZAD_CLIENT')+FWFLDGET('ZAD_LOJACL'),'A1_NOME')"))
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription("Cadastro Contratos")

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( "PR2MASTER" ):SetDescription("Cabecalho")
//oModel:AddCalc( 'TOTCTJ', 'CTJMASTER', 'CTJDETAIL', 'CTJ_QTDDIS', 'DEBQTD', 'SUM',{|oModel| CT120CALC(oModel,.T.)} ,,"Qtd.Debito" ) // "Qtd.Debito"

//oModel:AddCalc('TOT_SALDO', 'PR2MASTER', 'PR3DETAIL', 'ZAE_DESC  ', 'XX_TOTAL2', 'SUM', , , "Percentual Total:" )

//Relacionamento dos modelos
oModel:SetRelation('PR3DETAIL',{{'ZAE_FILIAL','ZAD_FILIAL'},{'ZAE_CONTRA','ZAD_CONTRA'},{'ZAE_REVISA','ZAD_REVISA'},{'ZAE_CLIENT','ZAD_CLIENT'},{'ZAE_LOJACL','ZAD_LOJACL'}}, ZAE->(IndexKey(1)))

//oModel:AddCalc('TOT_SALDO', 'PR2MASTER', 'PR3DETAIL', 'ZAE_DESC', 'XX_TOTA1', 'SUM', , , 'Precentual Total:' )
//oModel:AddCalc('TOT_SALDO', 'PR2MASTER', 'PR3DETAIL', 'ZAE_VLDESC', 'XX_TOTA', 'SUM', , , 'Vl Descont Total:' )

// Criar uma chave primaria


Return oModel

/*----------------------------------------------------
	Tela de visualização do arotina. 
----------------------------------------------------*/

Static Function ViewDef()

Local oModel		:= FWLoadModel( "ZFATF004" )
Local oStruCab		:= FWFormStruct(2,"ZAD")
Local oStruItens	:= FWFormStruct(2,"ZAE" , {|cField| !(AllTrim(Upper(cField)) $ "ZAE_CONTRA|ZAE_REVISA|ZAE_CLIENT|ZAE_LOJACL")})
Local oView			:= NIL
Local nOperation    := oModel:NOPERATION
//Local oStTot        := FWCalcStruct(oModel:GetModel('TOT_SALDO'))
// Cria objeto de VIEW
oView := FWFormView():New()
oView:SetModel(oModel)

// Adiciona controle do tipo enchoice (antiga)
oView:AddField("VIEWPR2"	, oStruCab	    , "PR2MASTER")
oView:AddGrid("VIEWITENS"	, oStruItens    , "PR3DETAIL")
//oView:AddField("VIEWRODA"	, oStTot    , "TOT_SALDO")
//Divisão da tela
oView:CreateHorizontalBox("TELA"    ,30)
oView:CreateHorizontalBox("ITENS"   ,60)
//oView:CreateHorizontalBox("RODA"   ,10 ) 
//Seta as view nos box criados.
oView:SetOwnerView("VIEWPR2"	,"TELA")
oView:SetOwnerView("VIEWITENS"	,"ITENS")
//oView:SetOwnerView("VIEWRODA"	,"RODA")
oView:AddUserButton("Aprovac.",'BUDGET', {|| U_ZGENF004('ZAD',ZAD->(RecNo()),nOperation,cTipoDoc,,.F.,aRotina)}) 

oView:SetCloseOnOk({||.T.})

Return oView

Static Function DUXCTR( omodel )

local oMldZad    := omodel:GetModel('PR2MASTER')
local oMdlZAe    := omodel:GetModel('PR3DETAIL')
Local cDoc       := oMldZad:getValue('ZAD_CONTRA')
Local cRevis     := oMldZad:getValue('ZAD_REVISA')
Local Obs        := oMldZad:getValue('ZAD_OBS')
Local lExcl      := .F.
Local nOperation := oModel:NOPERATION
local nu         := 0 

If nOperation <> MODEL_OPERATION_DELETE
 For nU := 1 to oMdlZAe:Length()
	oMdlZAe:goline(nU)
	oMdlZAe:LoadValue('ZAE_CONTRA',oMldZad:getValue('ZAD_CONTRA'))
	oMdlZAe:LoadValue('ZAE_REVISA',oMldZad:getValue('ZAD_REVISA'))
	oMdlZAe:LoadValue('ZAE_CLIENT',oMldZad:getValue('ZAD_CLIENT'))
	oMdlZAe:LoadValue('ZAE_LOJACL',oMldZad:getValue('ZAD_LOJACL'))
 next nU 
Endif

If nOperation == 3 
	U_ZGENSCR(cDoc,cRevis,cTipoDoc,cGrupo,Obs)
Elseif nOperation == 4
	lExcl := ExcSCR(cTipoDoc,cDoc)
	If !lExcl
		Aviso("[ZFATF004] - Atencao","Não foi possível excluir itens da alçada." + CHR(13),{"Ok"})
	Endif
	
	U_ZGENSCR(cDoc,cRevis,cTipoDoc,cGrupo,Obs)

Endif

Return .T.

User Function ZFATF04B()

	If MsgYesno('Deseja efetuar nova revisão, a atual sera desativada')
		 FWExecView( 'Revisão', 'ZFATF004', OP_COPIA,, {|| .T.} )
	Endif

Return 

User Function ZFATF04C()
    Local cCampo    := "ZAD_CLIENT"
	local cCampos2 := "ZAD_LOJACL" 
    Local cRetorno  := 'Grupo Teste'
	cRetorno := POsicione('SA1',1,xFilial("SA1")+AllTrim(FwFldGet(cCampo))+AllTrim(FwFldGet(cCampos2)),'A1_NOME')
    //Você pode usar o mesmo gatilho para atualizar outros campos com o FwFldPut, como
    //FwFldPut(cCampo, cConteudo,,,, .T.)
Return cRetorno

/*----------------------------------------------------
	Função que exclui os itens da tabela SCR. 
----------------------------------------------------*/

Static Function ExcSCR(cTipoDoc,cDoc)

Local aAreaSCR := SCR->(FwGetArea())
Local cFilSCR  := AllTrim(FWFilial())            
Local lExcl    := .F.                              

DbSelectArea("SCR")
SCR->(dbSetOrder(1))
If !Empty(cTipoDoc) .And. SCR->(MsSeek(xFilial("SCR",cFilSCR)+cTipoDoc+cDoc))
	While !SCR->(Eof()) .And. xFilial("SCR",cFilSCR)+cTipoDoc+cDoc == AllTrim(SCR->(CR_FILIAL+CR_TIPO+CR_NUM))
		DbGoTo(SCR->(RecNo()))
		RecLock('SCR',.F.)
		SCR->(DbDelete())
		SCR->(MsUnlock())
		lExcl := .T.
		SCR->( dbSkip() )
	EndDo

Endif

FWRestArea(aAreaSCR)

Return(lExcl)

/*/
@Function: ZFATF04A()
@Desc: Função que chama o Menu de Lieberação de Documentos
@Author: Jedielson Rodrigues - Dux Company   
@version: 1.00
@since: 08/10/2024
/*/

User Function ZFATF04A()

Local aAreaSCR   := SCR->(FwGetArea())
Local oBrowse    := Nil 
Local ca097User  := RetCodUsr()
Local cFiltraSCR
Local nx         := 0
Local aLegenda   := {}
Local cCadastro  := "Aprovação de Documentos"

	If Fwisincallstack('U_ZFATF04A')
		aRotina := FwLoadMenuDef("MATA094")
	Endif

	If FwModeAccess("SCR") <> FwModeAccess("DBM")
		MsgAlert("Para o correto funcionamento da rotina o compartilhamento das tabelas SCR/DBM precisam estar iguais.")
	Endif

	dbSelectArea("SAK")
	dbSetOrder(2)
	If !MsSeek(xFilial("SAK")+RetCodUsr())
		Help(" ",1,"A097APROV")
		dbSelectArea("SCR")
		dbSetOrder(1)
	Else
			
		If Pergunte("MTA097",.T.)
		
			//-------------------------------------------------------------------
			// Controle de Aprovacao : CR_STATUS                
			// 01 - Bloqueado p/ sistema (aguardando outros niveis) 
			// 02 - Aguardando Liberacao do usuario                 
			// 03 - Pedido Liberado pelo usuario                    
			// 04 - Pedido Bloqueado pelo usuario                   
			// 05 - Pedido Liberado por outro usuario               
			// 06 - Documento Rejeitado
			//-------------------------------------------------------------------
			dbSelectArea("SCR")
			dbSetOrder(1)		
			      
			If cFiltraSCR == NIL
				cFiltraSCR  := 'CR_FILIAL=="'+xFilial("SCR")+'"'+'.And.CR_USER=="'+ca097User 
			EndIf		
	   	    
			Do Case
				Case mv_par01 == 1
					cFiltraSCR += '".And.CR_STATUS=="02"'
				Case mv_par01 == 2
					cFiltraSCR += '".And.(CR_STATUS=="03".OR.CR_STATUS=="05")'
				Case mv_par01 == 3
					cFiltraSCR += '"'
				Case mv_par01 == 4
					cFiltraSCR += '".And.CR_STATUS=="04"'
				Case mv_par01 == 5
					cFiltraSCR += '".And.CR_STATUS=="06"'
				OtherWise
					cFiltraSCR += '".And.(CR_STATUS=="01".OR.CR_STATUS=="04")'
			EndCase

			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias('SCR')       
			                                   
			// Definição da legenda
			aAdd(aLegenda, { "CR_STATUS=='01'", "BR_AZUL" , "Bloqueado (aguardando outros niveis)" }) //"Blqueado (aguardando outros niveis)"
			aAdd(aLegenda, { "CR_STATUS=='02'", "DISABLE" , "Aguardando Liberacao do usuario" }) //"Aguardando Liberacao do usuario"
			aAdd(aLegenda, { "CR_STATUS=='03'", "ENABLE"  , "Documento Liberado pelo usuario" }) //"Documento Liberado pelo usuario"
			aAdd(aLegenda, { "CR_STATUS=='04'", "BR_PRETO", "Documento Bloqueado pelo usuario" }) //"Documento Bloqueado pelo usuario"
			aAdd(aLegenda, { "CR_STATUS=='05'", "BR_CINZA", "Documento Liberado por outro usuario" }) //"Documento Liberado por outro usuario"
			aAdd(aLegenda, { "CR_STATUS=='06'", "BR_CANCEL","Documento Rejeitado pelo usuario" }) //"Documento Rejeitado pelo usuário"
			aAdd(aLegenda, { "CR_STATUS=='07'","BR_AMARELO","Documento Rejeitado ou Bloqueado por outro usuario" }) //"Documento Rejeitado ou Bloqueado por outro usuário"
			
		
			FOR nx := 1 TO LEN(aLegenda)
				oBrowse:AddLegend(aLegenda[nx][1], aLegenda[nx][2], aLegenda[nx][3])
			NEXT nx
			
			oBrowse:SetCacheView(.F.)
			oBrowse:DisableDetails()
			oBrowse:SetDescription(cCadastro)  //"Aprovação de Documentos"
			oBrowse:SetFilterDefault(cFiltraSCR)
			obrowse:SetChgAll(.F.)
			obrowse:SetSeeAll(.F.)
			
			oBrowse:Activate()		
		EndIf
	EndIf

FWRestArea(aAreaSCR)	

Return NIL

/*----------------------------------------------------
	Função que chama ModelDefs do programa MATA094
----------------------------------------------------*/

Static Function ModelDefs()
Return FWLoadModel('MATA094')

/*----------------------------------------------------
	Função que chama ViewDefs do programa MATA094
----------------------------------------------------*/
    
Static Function ViewDefs()
Return FWLoadView('MATA094')





