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

Local _aArea        := GetArea()
Local aVencto       := {} //Array com os vencimentos e valores para geração dos títulos.
Local aPELinhas     := PARAMIXB[1]
Local nDia          := SuperGetMv("DUX_COM003",.F.,1)
Local i             := 0
Local dData         := Date()
Local dDataVenc     := CTOD(" ")
Local lZCom001      := .T.

If ExistFunc("U_ZCOMF001")
    For i:= 1 to Len(aPELinhas)
        lZCom001 := U_ZCOMF001(aPELinhas[i][2])
        If lZCom001 == .F.
             dDataVenc := ( dData + nDia )
            //Aadd(aVencto,{dDataVenc})
            //aadd(aVencto,{stod("20181004"),10})
        Endif
    Next i
Endif

RestArea(_aArea)

Return (aVencto)
