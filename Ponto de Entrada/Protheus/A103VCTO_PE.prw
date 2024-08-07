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

Local aVencto       := {} //Array com os vencimentos e valores para geração dos títulos.
Local aPELinhas     := PARAMIXB[1]
Local nDia          := SuperGetMv("DUX_COM003",.F.,1)
Local i             := 0
Local dData         := Date()
Local dDataVenc     := CTOD(" ")

For i:= 1 to Len(aPELinhas)
    If aPELinhas[i][3] > 0 
        If aPELinhas[i][2] < dData
            dDataVenc := ( dData + nDia )
            Aadd(aVencto,{dDataVenc,aPELinhas[i][3]})
            aPELinhas[i][2] := dDataVenc
    Endif
Next i

Return aVencto
