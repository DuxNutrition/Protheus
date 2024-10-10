#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} MTA094RO
Função que rejeita documentos - Tipos Z1. 
@See 
@type function 
@author:Jedielson Rodrigues
@since 04/10/2024
@return 
/*/

User Function ZFATF005(cTpDoc)

Local lRet 		:= .F.
Local aArea 	:= GetArea()
Local cTipo		:= ""
Local cNumDoc	:= ""
Local cFilCtr 	:= ""
Local cFilScr	:= ""
Local cQuery	:= ""
Local cTmpAlias	:= ""
Local lProces   := .F.
Local cDoc      := SCR->CR_NUM
Local cStatus   := SCR->CR_STATUS
Local cTipDoc   := SuperGetMv("DUX_FAT002",.F.,"Z1")

If cStatus == "01"
    Aviso("[MTA094RO] - Atencao","Esse documento "+AllTrim(cDoc)+" esta Bloqueado (aguardando outros niveis)." + CHR(13),{"Ok"})
    Return lRet
Elseif cStatus == "03"
     Aviso("[MTA094RO] - Atencao","Esse documento "+AllTrim(cDoc)+" ja esta Liberado pelo usuario." + CHR(13),{"Ok"})
    Return lRet
Elseif cStatus == "04"
     Aviso("[MTA094RO] - Atencao","Esse documento "+AllTrim(cDoc)+" esta Bloqueado pelo usuario." + CHR(13),{"Ok"})
    Return lRet
Elseif cStatus $ "05|06|07"
    Aviso("[MTA094RO] - Atencao","Esse documento "+AllTrim(cDoc)+"  esta Aprovado/rejeitado pelo nível." + CHR(13),{"Ok"})
    Return lRet
Endif

If cTpDoc = cTipDoc
    Begin Transaction
        If RecLock("SCR",.F.)
            SCR->CR_DATALIB := dDataBase
            SCR->CR_USERLIB := SCR->CR_USER
            SCR->CR_LIBAPRO := SCR->CR_APROV
            SCR->CR_STATUS := "06"
            If SCR->(MsUnlock())
                //- Realiza rejeição do documento originador da aprovação.
                If cTipDoc $ "CT|IC|RV|IR|Z1"
                    cTipo	 := Iif(cTipDoc $ "CT|IC|Z1" ,"'CT','IC','Z1'","'RV','IR'")
                    cNumDoc := LEFT(SCR->CR_NUM,Iif(cTipDoc $ "CT|IC|Z1",TAMSX3('CN9_NUMERO')[1],TAMSX3('CN9_NUMERO')[1]+TAMSX3('CN9_REVISA')[1]))
                    cFilCtr := xFilial("CN9",cFilAnt)
                    cFilScr := CnFilCtr(cNumdoc)

                    CN9->(dbSetOrder(1)) 		//- CN9_FILIAL+CN9_NUMERO+CN9_REVISA
                    If CN9->(MsSeek(cFilCtr+cNumDoc))
                        RecLock("CN9",.F.)
                        CN9->CN9_SITUAC := "11"
                        lRet := CN9->(MsUnlock())
                    Else
                        lRet := .T.
                    Endif
                ElseIf cTipDoc $ "MD|IM"
                    cTipo	 := "'MD','IM'"
                    cNumDoc := LEFT(SCR->CR_NUM, TAMSX3('CND_NUMMED')[1])
                    cFilCtr := xFilial("CND",cFilAnt)
                    cFilScr := xFilial('SCR')

                    CND->(dbSetOrder(4)) 		//- CND_FILIAL+CND_NUMMED
                    If CND->(MsSeek(cFilCtr+cNumDoc)) .And. RecLock("CND",.F.)
                        RecLock("CND",.F.)
                        CND->CND_ALCAPR := "R"
                        CND->CND_SITUAC := "R"
                        lRet := CND->(MsUnlock())
                    EndIf
                EndIf

                //- Realiza rejeição das alçadas que ainda não foram aprovadas.
                If lRet
                    cTmpAlias := GetNextAlias()
                    cQuery += " SELECT "
                    cQuery += " SCR.R_E_C_N_O_ "
                    cQuery += " FROM	"
                    cQuery +=   RetSqlName("SCR")+" SCR "
                    cQuery += " WHERE "
                    cQuery += " SCR.CR_FILIAL 	= 		'"+cFilScr	+"'	 	AND "
                    cQuery += " SCR.CR_NUM 		LIKE 	'"+cNumDoc		   	+"%'	AND "

                    cQuery += " SCR.CR_TIPO		IN		("+cTipo			+")	 	AND "
                    cQuery += " SCR.CR_STATUS	IN		('01','02','04')			AND "
                    cQuery += " SCR.D_E_L_E_T_	= 		' '"

                    cQuery  := ChangeQuery( cQuery )
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cTmpAlias,.T.,.T.)

                    While !(cTmpAlias)->(EOF()) .And. lRet
                        SCR->(MsGoto((cTmpAlias)->R_E_C_N_O_))
                        If RecLock("SCR",.F.)
                            SCR->CR_DATALIB := dDataBase
                            SCR->CR_STATUS := "05"
                            lRet := SCR->(MsUnlock()) .And. lRet
                        Else
                            lRet := .F.
                        EndIf
                        (cTmpAlias)->(DbSkip())
                    EndDo
                EndIf
            EndIf
        EndIf
        If !lRet //- Valida Transação
            DisarmTransaction()
            Aviso("[MTA094RO] - Atencao","Não foi possível rejeitar o Documento." + CHR(13),{"Ok"})
        Else
            lProces := U_ZFATF006(AllTrim(SCR->(CR_FILIAL+CR_NUM)))
            If !lProces
                Aviso("[MTA094RO] - Atencao","Não foi possível atualizar o status de Rejeição do item na tabela ZAD." + CHR(13),{"Ok"})
            Endif
            FWAlertSuccess("Documento "+AllTrim(cNumDoc)+" rejeitado.!", "Sucesso")
        Endif
    End Transaction
Else
    Aviso("[MTA094RO] - Atencao","Essa opção é apenas para Documentos do Tipo "+cTipDoc+" (Contratos de Bonificação)" + CHR(13),{"Ok"})
Endif

RestArea(aArea)

Return lRet
