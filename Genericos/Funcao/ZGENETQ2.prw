#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} ZGENETQ2
Impressão generica de etiquetas de devolução.
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
    cPrint += "^FT150,490^A0N,200,200^FH\^CI28^FDDEV"+ ALLTRIM(cGalpao) +"^FS^CI27"+ CRLF
    cPrint += "^BY4,2,140"+ CRLF
    cPrint += "^FO160,520^BC^FDD"+ ALLTRIM(cSeqEtq) +"^FS"+ CRLF
    cPrint += "^FO330,810^GFA,3360,3360,21,,::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"+ CRLF
    cPrint += "3FFC3807700703FE03FC0C0187FF80E01C06300C8,7FFE3807380E078F070E0E03860181B01E06300C,"+ CRLF
    cPrint += "7IF3807380E06018C030E038600C13012061818,700738071C1C0C018C010B068600C3181B060C38,"+ CRLF
    cPrint += "300738071E3C0CI0C0109048601861819860C3,700738070F780CI0C01098C8601860C1886066,"+ CRLF
    cPrint += "700738070F780CI0C010J86018C0418C603C,700738070E380CI0C0108D886030C06186601C,"+ CRLF
    cPrint += "700E380F1C1C0C018C01087087FE1FFE1826018,381E3E3E3C1E04018C030870860018061836018,"+ CRLF
    cPrint += "7FFC1FFC380E07070607080086001803181E018,7FF80FF8780703FE03FE080186003003180E018,"+ CRLF
    cPrint += "gJ08P04,,:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::^FS"+ CRLF //Imagem Png
    cPrint += "^XZ"+ CRLF
    cPrint += "^XA^ID*.*^XZ"+ CRLF

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
        Sleep(200) // Como esta em rede, esperar 2 seg para impressao (Atualizacao necessaria)
        WinExec(_cCaminho)
    Else
        FWAlertWarning("Nao foi possivel comunicar com a Impressora", "Atenção [ ZGENETQ2 ]")
    EndIf
Else
    FWAlertWarning("Impressora não informada", "Atenção [ ZGENETQ2 ]")
EndIf

Return()
