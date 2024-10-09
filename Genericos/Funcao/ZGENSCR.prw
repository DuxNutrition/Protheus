#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} 
Função genérica que cria registro na tabela SCR.
@author Jedielson Rodrigues
@since 30/09/2024
@history 
@version P11,P12
@database MSSQL
@See 
/*/

User Function ZGENSCR(cDoc,cRevis,cTipoDoc,cGrupo,Obs)

Local aArea     := FwGetArea() 
Local aAreaSAL  := SAL->(FwGetArea())
Local aAreaSCR  := SCR->(FwGetArea())
Local aAreaSC7  := SC7->(FwGetArea())
Local aAreaZAD  := ZAD->(FwGetArea())
Local cFilSCR   := AllTrim(FWFilial())                                          
Local dDataRef  := dDatabase
Local cUserOri  := " "
Local cItGrp    := " "
Local cNivel    := " "
Local cAuxNivel := " "
Local lFirstNiv := .T.

Default cDoc     := " "
Default cRevis   := " "
Default cTipoDoc := " "
Default cGrupo   := " "
Default Obs      := " "

	DbSelectArea("SAL")
	SAL->(dbSetOrder(2))
	If !Empty(cGrupo) .And. SAL->(MsSeek(xFilial("SAL",cFilAnt)+cGrupo))
		While !SAL->(Eof()) .And. xFilial("SAL",cFilAnt)+cGrupo == SAL->(AL_FILIAL+AL_COD)
			cGrupo    := SAL->AL_COD
			cUserOri  := SAL->AL_USER 
			cAprovOri := SAL->AL_APROV  
			cNivel    := SAL->AL_NIVEL
			cItGrp	  := SAL->AL_ITEM

            If lFirstNiv
                cAuxNivel := SAL->AL_NIVEL
                lFirstNiv := .F.
			EndIf

			Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= cFilSCR
				SCR->CR_NUM		:= cDoc
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= cNivel
				SCR->CR_USER	:= cUserOri
				SCR->CR_APROV	:= cAprovOri
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel  ,"02","01")
				SCR->CR_TOTAL	:= 0
				SCR->CR_EMISSAO	:= dDataRef
				SCR->CR_MOEDA	:= 0
				SCR->CR_TXMOEDA	:= 0
				SCR->CR_GRUPO	:= cGrupo
				SCR->CR_ITGRP 	:= cItGrp	
				SCR->CR_OBS     := Obs
			SCR->(MsUnlock())
			
			SAL->( dbSkip() )
        
		EndDo
	
	Endif

	DbSelectArea("ZAD")
	ZAD->(dbSetOrder(2))
	If ZAD->(MsSeek(FwFilial("ZAD") + cDoc + cRevis ))	
		Reclock("ZAD",.F.)
		ZAD->ZAD_STATUS := "2"
		ZAD->(MsUnlock())
	Endif

FWRestArea(aArea)
FWRestArea(aAreaSAL)
FWRestArea(aAreaSCR)
FWRestArea(aAreaSC7)
FWRestArea(aAreaZAD)

Return
