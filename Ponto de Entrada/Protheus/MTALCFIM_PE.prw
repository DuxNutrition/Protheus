#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/	{Protheus.doc} MTA094RO
Ponto de Entrada MTALCFIM no final da função MaAlcDoc - Controla a alçada dos documentos.
@See https://tdn.totvs.com/display/public/PROT/MTALCFIM
@type function 
@author:Jedielson Rodrigues
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
Local lRet      := .T.
Local lFirstNiv := .T.

If cTipoDoc == 'Z1'
    DbSelectArea("SCR")
    SCR->(dbSetOrder(1))
    If !Empty(cTipoDoc) .And. SCR->(MsSeek(xFilial("SCR",cFilSCR)+cTipoDoc+cDoc))
        While !SCR->(Eof()) .And. xFilial("SCR",cFilSCR)+cTipoDoc+cDoc == AllTrim(SCR->(CR_FILIAL+CR_TIPO+CR_NUM))

            If lFirstNiv
                cAuxNivel := SCR->CR_NIVEL
                lFirstNiv := .F.
			EndIf
           
            If SCR->CR_STATUS == '03'
                DbGoTo(SCR->(RecNo()))
                RecLock('SCR',.F.)
                SCR->CR_STATUS	:= IIF(SCR->CR_NIVEL == cAuxNivel  ,"03","05")
                SCR->(MsUnlock())

                DbSelectArea("ZAD")
                ZAD->(dbSetOrder(2))
                If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                    Reclock("ZAD",.F.)
                    ZAD->ZAD_STATUS := "1"
                    ZAD->(MsUnlock())
                Endif
            Elseif SCR->CR_NIVEL == cAuxNivel
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
                If SCR->CR_STATUS == '01'
                    DbGoTo(SCR->(RecNo()))
                    RecLock('SCR',.F.)
                    SCR->CR_STATUS	:= "03"
                    SCR->(MsUnlock())

                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := "1"
                        ZAD->(MsUnlock())
                    Endif
                Else
                    DbSelectArea("ZAD")
                    ZAD->(dbSetOrder(2))
                    If ZAD->(MsSeek(FwFilial("ZAD") + cDoc))	
                        Reclock("ZAD",.F.)
                        ZAD->ZAD_STATUS := "2"
                        ZAD->(MsUnlock())
                    Endif
                Endif
            Endif

        SCR->( dbSkip() )

        EndDo

    Endif
Endif

FWRestArea(aAreaSCR)
FWRestArea(aAreaZAD)

Return(lRet)


