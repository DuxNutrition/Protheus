#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} ZGENETQ2
Impressão generica de etiquetas
@type function
@version 12.1.2310
@author Dux | Jedielson Rodrigues
@since 26/08/2024
/*/
User function ZGENETQ2(cCodPrint,cGalpao,cSequencial,nQtd)

Local cPrint        := ""
Local cIniName      := ""
Local _cCaminho     := ""
Local _cCamLoc      := ""
Local cTxtBat       := ""
Local cSeqEtq       := (cGalpao + cSequencial)

Default cCodPrint   := ""
Default cGalpao     := ""
Default cSequencial := ""
Default nQtd        := 0

If !Empty(cCodPrint)

    cPrint += "^XA"+ CRLF
    cPrint += "^FO8,17^GB800,1080,12^FS"+ CRLF
    cPrint += "^FT380,810^A0B,200,200^FH\^CI28^FDDEV"+ ALLTRIM(cGalpao) +"^FS^CI27"+ CRLF
    cPrint += "^FWB"+ CRLF 
    cPrint += "^BY4,2,140"+ CRLF
    cPrint += "^FO400,305^BC^FDD"+ ALLTRIM(cSeqEtq) +"^FS"+ CRLF
    cPrint += "^FO575,090^GFA,3300,3300,20,,:::W01,,:W018,W01E,X07,X038,Y0E,Y07E,:Y0C,X038,X07,W01C,W018,,"+ CRLF  
    cPrint += "::W01FFE,W01IF,g06,g0C,Y038,Y06,X01C,X03,X0E,W018,W01BFE,W01FFE,,"+ CRLF
    cPrint += "::g06,Y03E,Y0F8,X039,X0F1,W01C1,W0101,W0181,X0E1,X039,X01F,Y07C,Y01E,g02,X06,W01FC,W019E,W0103,W0101,"+ CRLF
    cPrint += "::::::W01FFE,:,:::W01IF,W01C02,X0E,X038,Y0E,Y038,Y018,Y038,Y0E,X038,X0E,W01C,W01FFE,,"+ CRLF
    cPrint += ":::X07FC,X0C0E,W01806,W01802,W01002,:::W01802,W01806,X0FFC,X07F8,,"+ CRLF
    cPrint += "::X0618,X0E1C,W01806,:W01802,W01002,::W01802,W01806,W01C06,X0FFC,X03F,,"+ CRLF
    cPrint += ":::W01002,W01C0E,W01F1E,X0FFC,X03F8,X01E,Y0C,,Y0C,X01E,X03F8,X0FFE,W01F1E,W01C0E,W01002,,W01FF,W01FF8,W01FFC,Y01E,g0E,:g06,"+ CRLF
    cPrint += "::g0E,:W01FFE,W01FFC,W01FF8,,:X07E,X0FF8,W01FFC,W01C1E,W01C0E,W01C06,"+ CRLF
    cPrint += ":::::W01C0E,W01FFE,:X0EF6,,^FS"+ CRLF //Imagem Png
    cPrint += "^XZ"+ CRLF

    If !ExistDir( "c:\temp" )
        MakeDir( "c:\temp" )
    Endif

    cIniName := GetRemoteIniName() // Resultado: "C:\totvs\bin\SmartClient\smartclient.ini"

    lUnix := IsSrvUnix()
    nPos  := Rat( IIf( lUnix, "/", "\" ), cIniName )
    _cCaminho := ""
    _cCamLoc  := ""
    
    If !( nPos == 0 )
        _cCamLoc := SubStr( cIniName, 1, nPos - 1 )
    Else
        _cCamLoc := "c:\temp"
    Endif

    //Verificar se existe a bat
    cTxtBat := 'type ' + _cCamLoc + "\" + AllTrim(cCodPrint) +'.txt > lpt1'

    If !File( _cCamLoc + "\" + AllTrim(cCodPrint) + ".bat")
        MEMOWRITE( _cCamLoc + "\" + AllTrim(cCodPrint) + ".bat", cTxtBat)
    EndIf
    
    MEMOWRITE( _cCamLoc + "\" + AllTrim(cCodPrint) + ".txt", cPrint )
    _cCaminho := _cCamLoc + "\" + AllTrim(cCodPrint) + ".bat"

    If CB5SetImp(cCodPrint)
        Sleep(200) // Como esta em rede, esperar 2 seg para impressao (Atualizacao necessÃ¡ria)
        WinExec(_cCaminho)
    Else
        FWAlertWarning("Nao foi possivel comunicar com a Impressora", "Atenção [ ZGENETQ2 ]")
    EndIf
Else
    FWAlertWarning("Impressora não informada", "Atenção [ ZGENETQ2 ]")
EndIf

Return()
