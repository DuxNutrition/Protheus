#Include 'Protheus.ch'

/*/{Protheus.doc} F200FIM
O ponto de entrada F200FIM do CNAB a receber sera executado após gravar a linha de lançamento contábil no arquivo de contra-prova.
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 22/08/2024
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6070979
/*/
User Function F200FIM()

Local cBancoVal := SuperGetMV("DUX_FIN007", ,"033|637") 

If AllTrim(SE1->E1_PORTADO) $ cBancoVal

    RecLock("FI0",.F.)
	    FI0->FI0_LASTLN	:= 1
	FI0->(MsUnlock())
    
EndIf

Return()
