#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} MTALCFIM
Ponto de Entrada MTALCFIM no final da fun��o MaAlcDoc - Controla a al�ada dos documentos.
@See https://tdn.totvs.com/display/public/PROT/MTALCFIM
@type Function
@author Jedielson Rodrigues
@since 04/10/2024
@return
/*/

User function MTALCFIM()

Local aAreaSCR  := SCR->(FwGetArea())
Local aAreaZAD  := ZAD->(FwGetArea())
Local cFilSCR   := AllTrim(FWFilial())  
Local aDocto    := ParamIXB[1]
Local dDataRef  := ParamIXB[2]
Local nOper     := ParamIXB[3]
Local cDocSF1   := ParamIXB[4]
Local lResiduo  := ParamIXB[5]   
Local cDoc      := AllTrim(aDocto[1])
Local cTipoDoc  := aDocto[2]
Local lScr      := .F.
Local lRet      := .T.
Local lFirstNiv := .T.
Local lFirstNiv2 := .T.
Local cAuxNivel  := " "


If cTipoDoc == 'Z1'
    DbSelectArea("SCR")
    SCR->(dbSetOrder(1))
    If !Empty(cTipoDoc) .And. SCR->(MsSeek(xFilial("SCR",cFilSCR)+cTipoDoc+cDoc))
        While !SCR->(Eof()) .And. xFilial("SCR",cFilSCR)+cTipoDoc+cDoc == AllTrim(SCR->(CR_FILIAL+CR_TIPO+CR_NUM))

            If lFirstNiv
                cAuxNivel := SCR->CR_NIVEL
                lFirstNiv := .F.
			EndIf
           
            Do Case
                Case SCR->CR_STATUS == "03"    
                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := "1"
                        ZAD->(MsUnlock())
                    Endif
                Case SCR->CR_STATUS == "01" .AND. SCR->CR_NIVEL == cAuxNivel
                    DbGoTo(SCR->(RecNo()))
                    RecLock('SCR',.F.)
                    SCR->CR_STATUS := "05"
                    SCR->(MsUnlock())

                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := "2"
                        ZAD->(MsUnlock())
                    Endif
                Case SCR->CR_NIVEL == cAuxNivel
                    DbGoTo(SCR->(RecNo()))
                    RecLock('SCR',.F.)
                    SCR->CR_STATUS := "05"
                    SCR->(MsUnlock())

                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := "1"
                        ZAD->(MsUnlock())
                    Endif
                Case SCR->CR_STATUS == "01"

                    If lFirstNiv2
                        cAuxNivel := SCR->CR_NIVEL
                        lFirstNiv2 := .F.
                    EndIf

                    DbGoTo(SCR->(RecNo()))
                    RecLock('SCR',.F.)
                    SCR->CR_STATUS := IIF(SCR->CR_NIVEL == cAuxNivel  ,"02","01")
                    SCR->(MsUnlock())

                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := "2"
                        ZAD->(MsUnlock())
                    Endif
                Case SCR->CR_STATUS == "05"

                    If lFirstNiv2
                        cAuxNivel := SCR->CR_NIVEL
                        lFirstNiv2 := .F.
                    EndIf
                    
                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := IIF(SCR->CR_NIVEL == cAuxNivel  ,"1","2")
                        ZAD->(MsUnlock())
                    Endif
                Case SCR->CR_STATUS == "06"
                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := "3"
                        ZAD->(MsUnlock())
                    Endif
                Case SCR->CR_STATUS == "02"
                    lScr := ConSCR(cFilScr,cDoc,cTipoDoc,SCR->CR_NIVEL)
                    If lScr == .T.
                        DbGoTo(SCR->(RecNo()))
                        RecLock('SCR',.F.)
                        SCR->CR_STATUS	:= "05"
                        SCR->(MsUnlock())

                        DbSelectArea("ZAD")
                        ZAD->(dbSetOrder(2))
                        If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                            Reclock("ZAD",.F.)
                            ZAD->ZAD_STATUS := "1"
                            ZAD->(MsUnlock())
                        Endif
                    Else
                        DbGoTo(SCR->(RecNo()))
                        RecLock('SCR',.F.)
                        SCR->CR_STATUS	:= "02"
                        SCR->(MsUnlock())

                        DbSelectArea("ZAD")
                        ZAD->(dbSetOrder(2))
                        If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                            Reclock("ZAD",.F.)
                            ZAD->ZAD_STATUS := "2"
                            ZAD->(MsUnlock())
                        Endif
                    Endif
            EndCase

        SCR->( dbSkip() )

        EndDo

    Endif
Endif

FWRestArea(aAreaSCR)
FWRestArea(aAreaZAD)

Return(lRet)

/*-----------------------------------------------------------
	Consulta se existe SCR com o mesmo n�vel com Status 03.
-----------------------------------------------------------*/

Static Function ConSCR(cFilScr,cNumDoc,cTipoDoc,cNivel)

Local cQuery    := " "
Local cTmpAlias := GetNextAlias()
Local aAreaSCR  := SCR->(FwGetArea())
Local lRet      := .F.  

    If Select( cTmpAlias ) > 0
		(cTmpAlias)->(DbCloseArea())
	EndIf

    cQuery := " SELECT "+ CRLF
    cQuery += " SCR.R_E_C_N_O_ "+ CRLF
    cQuery += " FROM " + RetSqlName("SCR") + " SCR WITH(NOLOCK) "+ CRLF
    cQuery += " WHERE SCR.CR_FILIAL = '"+cFilScr+"' "+ CRLF
    cQuery += " AND SCR.CR_NUM = '"+cNumDoc+"' "+ CRLF
    cQuery += " AND SCR.CR_TIPO = '"+cTipoDoc+"' "+ CRLF
    cQuery += " AND SCR.CR_STATUS = '03' "+ CRLF
    cQuery += " AND SCR.CR_NIVEL = '"+cNivel+"' "+ CRLF
    cQuery += " AND SCR.D_E_L_E_T_ = ' ' "+ CRLF

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias := GetNextAlias(),.T.,.T.)

    While !(cTmpAlias)->(EOF())
        SCR->(MsGoto((cTmpAlias)->R_E_C_N_O_))
            lRet := .T.
        (cTmpAlias)->(DbSkip())
    EndDo

    (cTmpAlias)->(DbCloseArea())

    RestArea(aAreaSCR )

Return lRet

