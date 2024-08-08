#INCLUDE "RWMAKE.CH
#INCLUDE "FILEIO.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} 
O ponto de entrada A103VCTO será utilizado para manipular as informações do Array aColsSE2 utilizado na geração 
dos títulos financeiro(tabela SE2) no momento da inclusão do documento de entrada (MATA103).

@author Jedielson Rodrigues
@since 28/06/2024
@history 
@version P11,P12
@database MSSQL
@See https://tdn.totvs.com/display/public/PROT/A103VCTO

/*/

User Function A103VCTO()

Local aVencto       := condicao(PARAMIXB[2],PARAMIXB[3],PARAMIXB[4],PARAMIXB[5],PARAMIXB[6])
Local nDia          := SuperGetMv("DUX_COM003",.F.,1)
Local i             := 0
Local dData         := Date()
Local dDataVenc     := CTOD(" ")

For i:= 1 to Len(aVencto)
    If aVencto[i][1] <= dData
        dDataVenc := ( dData + nDia )
        aVencto[i][1] := dDataVenc
    Endif
Next i

Return aVencto
