#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F150ARQ
Ponto de Entrada que permite alterar o nome e extensão do arquivo de saída, gerado a partir da rotina Arquivos de Cobranças (FINA150).
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

If !Empty(cDirCnab) .AND. cBanco == "707"
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
Local cArquivo  := ""
Local cSufixo   := ""

cArquivo  := ALLTRIM(cDirCnab + cSigla + cDia + cMes + StrZero(nSeq, 1) + ".TXT")

//Se não existir a pasta na Protheus Data, cria ela
If !ExistDir(cDirCnab)
    MakeDir(cDirCnab)
EndIf

While File(cArquivo) 
    nSeq ++
    If nSeq > 9
        If Empty(cSufixo)
            cSufixo := "A"
        Else
            cSufixo := Chr(Asc(cSufixo) + 1)
        EndIf
        nSeq := 0  
    EndIf

    If nSeq > 0
        cArquivo := ALLTRIM(cDirCnab + cSigla + cDia + cMes + StrZero(nSeq, 1) + ".TXT")
    Else
        cArquivo := ALLTRIM(cDirCnab + cSigla + cDia + cMes + cSufixo + ".TXT")
    EndIf
    
    If !Empty(cSufixo) .AND. cSufixo > "Z"
        MsgStop("Erro: Sequencial do arquivo excedeu o limite!")
        Return Nil
    EndIf

Enddo

Return cArquivo
