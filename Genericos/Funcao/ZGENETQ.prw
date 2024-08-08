#Include "rwmake.ch"
#include "topconn.ch"
#INCLUDE 'COLORS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include "RPTDef.ch"
#include "tbiconn.ch"
#include "fileio.ch"

/*/{Protheus.doc} ZGENETQ
Impressão generica de etiquetas
@type function
@version 12.1.2310
@author Dux | Evandro Mariano
@since 07/08/2024
/*/
User function ZGENETQ(cCodPrint)

	Local cPrint     := ""
	Local cIniName   := ""
    Local _cCaminho  := ""
    Local _cCamLoc   := ""
	Local cAlerg     := Posicione("SB1",1,xFilial("SB1")+Padr((cAliasTRB)->TR_PRODUTO,TamSX3("B1_COD")[1]),"B1_ZALERGE")
	Local cDescAlerg := IIf((cAlerg == "1" ),"ALERGENICO","NAO ALERGENICO")
	Local cTxtBat    := ""
	Local nLength    := Len(AllTrim((cAliasTRB)->TR_LOTE))

    Default cCodPrint := " "

    If !Empty(cCodPrint)

        cPrint += "^XA"+ CRLF
        cPrint += CRLF
        cPrint += "~TA000"+ CRLF
        cPrint += "~JSN"+ CRLF
        cPrint += "^LT0"+ CRLF
        cPrint += "^MNW"+ CRLF
        cPrint += "^MTD"+ CRLF
        cPrint += "^PON"+ CRLF
        cPrint += "^PMN"+ CRLF
        cPrint += "^LH0,0"+ CRLF
        cPrint += "^JMA"+ CRLF
        cPrint += "^PR4,4"+ CRLF
        cPrint += "~SD15"+ CRLF
        cPrint += "^JUS"+ CRLF
        cPrint += "^LRN"+ CRLF
        cPrint += "^CI27"+ CRLF
        cPrint += "^PA0,1,1,0"+ CRLF
        cPrint += "^XZ"+ CRLF
        cPrint += "^XA"+ CRLF
        cPrint += "^MMT"+ CRLF
        cPrint += "^PW812"+ CRLF
        cPrint += "^LL1218"+ CRLF
        cPrint += "^LS0"+ CRLF
        cPrint += "^FO8,17^GB800,200,12^FS"+ CRLF
        cPrint += "^FO8,210^GB800,280,12^FS"+ CRLF
        cPrint += "^FO8,470^GB800,150,12^FS"+ CRLF
        cPrint += "^FO8,610^GB800,150,12^FS"+ CRLF
        cPrint += "^FO8,750^GB800,120,12^FS"+ CRLF
        cPrint += "^FO8,750^GB800,350,12^FS"+ CRLF
        cPrint += CRLF
        cPrint += "^FT30,70^A0N,30,30^FH\^CI28^FDITEM:^FS^CI27"+ CRLF
        cPrint += "^FT30,140^A0N,50,50^FH\^CI28^FD " + Left((cAliasTRB)->TR_DESCR,25) + " ^FS^CI27"+ CRLF
        cPrint += "^FT30,200^A0N,50,50^FH\^CI28^FD " + SubString((cAliasTRB)->TR_DESCR,26,25) + " ^FS^CI27"+ CRLF
        cPrint += CRLF
        cPrint += "^FT30,250^A0N,30,30^FH\^CI28^FDLOTE:^FS^CI27"+ CRLF
        Do Case
            Case nLength <= 10
                cPrint += "^BY4,2,130"+ CRLF
            Case nLength <= 15
                cPrint += "^BY3,2,130"+ CRLF
            Case nLength <= 25
                cPrint += "^BY2,2,130"+ CRLF
            Case nLength > 25
                cPrint += "^BY1,2,130"+ CRLF
        EndCase
        cPrint += "^FO60,270^BC^FD" + Alltrim((cAliasTRB)->TR_LOTE) + "^FS"+ CRLF
        cPrint += CRLF
        cPrint += "^FT30,530^A0N,30,30^FH\^CI28^FD VAL:^FS^CI27"+ CRLF
        cPrint += "^FT90,590^A0N,110,110^FH\^CI28^FD " + DToC((cAliasTRB)->TR_VLD) + " ^FS^CI27"+ CRLF
        cPrint += CRLF
        cPrint += "^FT30,660^A0N,30,30^FH\^CI28^FD QTD: ^FS^CI27"+ CRLF
        cPrint += "^FT90,720^A0N,110,110^FH\^CI28^FD "+ AllTrim(Transform((cAliasTRB)->TR_QTDEMB,"@E 999,999,999.999")) +" ^FS^CI27"+ CRLF
        If !Empty(cAlerg)
            If cAlerg == "1" 
                cPrint += "^FT140,850^A0N,100,100^FH\^CI28^FD"+ Alltrim(cDescAlerg) +"^FS^CI27"+CRLF
                cPrint += CRLF
            Elseif cAlerg == "2" 
                cPrint += "^FT45,850^A0N,100,100^FH\^CI28^FD"+ Alltrim(cDescAlerg) +"^FS^CI27"+CRLF 
                cPrint += CRLF
            Endif 
        Endif
        cPrint += "^FT30,900^A0N,30,30^FH\^CI28^FD SKU: ^FS^CI27"+ CRLF
        cPrint += "^BY4,2,140"+ CRLF
        cPrint += "^FO60,910^BC^FD"+ AllTrim((cAliasTRB)->TR_PRODUTO) +"^FS"+ CRLF
        cPrint += "^XZ"

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
            FWAlertWarning("Nao foi possivel comunicar com a Impressora", "Atenção [ ZESTF002 ]")
        EndIf
    Else
        FWAlertWarning("Impressora não informada", "Atenção [ ZESTF002 ]")
    EndIf
Return()
