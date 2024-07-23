#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*{Protheus.doc} 
Ponto de Entrada utilizado para permitir alterar TES e a Condição de pagamento 
utilizadas na importação das notas de conhecimento de transporte.

@author Jedielson Rodrigues
@since 16/06/2024
@history 
@version 1.0
@database MSSQL
@See https://tdn.totvs.com/pages/releaseview.action?pageId=51250511
*/

User Function A116TECT()

Local oXML 		:= Paramixb[1]
Local aRet		:= {} //Deve retornar {TES, CONDICAO_PAGAMENTO}
Local _cDest 	:= " "
Local cTesCte   := SuperGetMV("DUX_COM001",.F.,"163")
Local cCnpjDest := AllTrim(SuperGetMV("DUX_COM002",.F.,"31112243"))
Local cCondCte	:= " "
Local cResult	:= " "

cResult := XmlChildEx(oXml,"_CTEPROC")

If ValType(cResult) <> "U"
	If ValType(XmlChildEx(oXml:_CteProc:_Cte:_InfCte:_Dest,"_CNPJ")) <> "U"
		_cDest	:= Substr(AllTrim(oXml:_CteProc:_Cte:_InfCte:_Dest:_CNPJ:Text),1,8)
	Else
		_cDest	:= Substr(AllTrim(oXml:_CteProc:_Cte:_InfCte:_Dest:_CPF:Text),1,8) 
	Endif
Else
	If ValType(XmlChildEx(oXml:_InfCte:_Dest,"_CNPJ")) <> "U"
		_cDest	:= Substr(AllTrim(oXml:_InfCte:_Dest:_CNPJ:Text),1,8)
	Else
		_cDest	:= Substr(AllTrim(oXml:_InfCte:_Dest:_CPF:Text),1,8)
	Endif
Endif

If _cDest == cCnpjDest
	aAdd(aRet,cTesCte)
	aAdd(aRet,cCondCte)
Else 
	aAdd(aRet," ")
	aAdd(aRet," ")
Endif

Return aRet
