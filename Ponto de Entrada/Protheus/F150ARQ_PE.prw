#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F150ARQ
Ponto de Entrada que permite alterar o nome e extens�o do arquivo de sa�da, gerado a partir da rotina Arquivos de Cobran�as (FINA150).
@type Function
@version 12.1.23
@author Jedielson Rodrigues
@since 19/08/2024
@version 12.1.2310
@database MSSQL
@See https://tdn.totvs.com/display/public/mp/F150ARQ+-+Altera+nome+de+arquivo+--+111877

/*/

User Function F150ARQ()

Local _aArea   := GetArea()
Local cTeste   := PARAMIXB
Local cDirCnab := SuperGetMV("DUX_FIN006",.F.,"\Cnab_Daycoval\")
Local cArquivo := ArqRemessa(cDirCnab)
Local cBanco   := MV_PAR05 

If !EMPTY(cDirCnab) .AND. cBanco == "707"

    cTeste := ALLTRIM(cArquivo)

Endif

RestArea(_aArea)

Return cTeste


Static Function ArqRemessa(cDirCnab)
    
Local cSigla    := "8DK"                    
Local dData     := Date()                   
Local cDia      := StrZero(Day(dData), 2)   
Local cMes      := StrZero(Month(dData), 2) 
Local nSeq      := 1                        
Local cArquivo  := " "

cArquivo  := ALLTRIM(cDirCnab + cSigla + cDia + cMes + StrZero(nSeq, 1) + ".TXT")

//Se n�o existir a pasta na Protheus Data, cria ela
If !ExistDir(cDirCnab)
    MakeDir(cDirCnab)
EndIf

While File(cArquivo) .AND. nSeq < 10
    nSeq ++
    cArquivo  := ALLTRIM(cDirCnab + cSigla + cDia + cMes + StrZero(nSeq, 1) + ".TXT")
Enddo

If nSeq > 9
    MsgStop("Erro: Sequencial do arquivo excedeu o limite de 9!")
    Return Nil
EndIf
    
Return cArquivo
