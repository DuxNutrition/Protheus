#INCLUDE "PROTHEUS.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} M460FIM
Ponto de entrada chamado apos o fim do processamento da Nota Fiscal de Saida.
@type function
@version 12.1.2310
@author Totvs IP | Eduardo Zanardo
@since 06/08/2024
@return logical, .T.
/*/
User Function M460FIM()

Local aArea 	:= GetArea()
Local aAreaSF2	:= SF2->( GetArea() )
Local aAreaSC5	:= SC5->( GetArea() )
Local aAreaSD2	:= SD2->( GetArea() )
Local aAreaSE1	:= SE1->( GetArea() )
Local aAreaSE2 	:= SE2->( GetArea() )

Local cPrefix 	:= 'ABT'
Local cParc		:= "00"
Local cArquivo 	:= "ERRO_TIT_"
local cQuery 	:= " "
Local cCCUSTO	:= GetNextAlias()

Private lMSHelpAuto 	:= .t.
Private lMsErroAuto	:= .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o campo tipo de Integracao para que o JOB possa enviar a Nota      ³
//³ Fiscal de Saida para o Banco de Dados do Muro Easy e Sercorp             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


cQuery := " "
cQuery += " SELECT *   " 
cQuery += " FROM   " + RetSQLName("ZAD") + " A   " 
cQuery += " INNER JOIN " + RetSQLName("ZAE") + " B   " 
cQuery += "         ON ZAD_CONTRA = ZAE_CONTRA   " 
cQuery += "        AND ZAD_REVISA = ZAE_REVISA   " 
cQuery += "        AND ZAD_FILIAL = ZAE_FILIAL   " 
cQuery += "        AND ZAD_CLIENT = ZAE_CLIENT   " 
cQuery += "        AND ZAD_LOJACL = ZAE_LOJACL   " 
cQuery += "        AND B.D_E_L_E_T_ = ' '   " 
cQuery += " WHERE  A.D_E_L_E_T_ = ' '   " 
cQuery += "        AND ZAD_STATUS = '1' " 
cQuery += "        AND ZAD_CLIENT = '"+SF2->F2_CLIENTE+"'   " 
cQuery += "        AND ZAD_LOJACL = '"+SF2->F2_LOJA+"'   " 
cQuery += "        AND ZAE_ABATTI = '1'   " 
cQuery += "        AND ZAE_MODALI = '1'   " 


dbUseArea(.T.,"TopConn",tcGenQRY(,,cQuery),cCCUSTO,.F.,.T.)

While !(cCCUSTO)->(Eof())
	If (cCCUSTO)->ZAE_VLDESC > 0 
		nVal := (cCCUSTO)->ZAE_VLDESC 
		
	ElseIF 	(cCCUSTO)->ZAE_DESC > 0 
		nVal := (((cCCUSTO)->ZAE_DESC / 100) * iif((cCCUSTO)->ZAD_ABATIT == '2',SF2->F2_VALBRUT,SF2->F2_VALMERC))  
		
	ENDIF
	iF nVal > 0 
	    cParc:= Soma1(cParc)
		aTitulo := { 		 {"E1_PREFIXO"        , cPrefix		        ,NIL},;  
								{"E1_NUM"        , SF2->F2_DOC		        ,NIL},;
								{"E1_PARCELA"	, cParc					    ,NIL},;
								{"E1_TIPO"		, 'NCC'                 	,NIL},;
								{"E1_CLIENTE"	, SF2->F2_CLIENTE			,NIL},;
								{"E1_LOJA"		, SF2->F2_LOJA				,NIL},;
								{"E1_NATUREZ"	, SC5->C5_NATUREZ            , NIL},;
								{"E1_EMISSAO"	, dDatabase					,NIL},;
								{"E1_VENCTO"	, dDatabase					,NIL},;
								{"E1_VENCREA"	, dDatabase					,Nil},;
								{"E1_MOEDA"		, 1				            ,NIL},;
								{"E1_HIST"		, 'Desconto de Contrato'    ,NIL},;
								{"E1_VALOR"		, nVal 					    ,NIL},; 
								{"E1_VLCRUZ"	, nVal				        ,NIL},; 								
								{"E1_DEBITO"   ,(cCCUSTO)->ZAE_CONTA 	   	,NIL},; 
								{"E1_CCD"      ,(cCCUSTO)->ZAE_CC      		,NIL} }

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento especifico para Titulos a Pagar tipo 'PA'. Quando for alteracao o    ³
			//³ titulo sera excluido via programacao ( DBDelete ) pois o Titulo ainda nao esta- ³
			//³ ra liberado e so existe na Tabela SE2. Apos isso sera Incluido. Para casos de   ³				
			//³ exclusao somente o comando DBDelete sera executado ( nao sera usado MsExecAuto )³				
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			
			MSExecAuto( { | x, y| FINA040( x, y ) }, aTitulo,3 )
							 					
			If lMsErroAuto

				
				cMensagem := MostraErro("\system\", cArquivo+SF2->F2_DOC )
								

			Endif
	ENDIF			
			lMSHelpAuto := .F.	
			
	(cCCUSTO)->(DBSKIP())
EndDO

RestArea( aAreaSF2 )
RestArea( aAreaSC5 )
RestArea( aAreaSD2 )
RestArea( aAreaSE1 )
RestArea( aAreaSE2 )
RestArea( aArea )

RETURN(.T.)
