#INCLUDE "totvs.ch"
#INCLUDE "parmtype.ch"

#DEFINE TIPO_SAIDA 		"S"
#DEFINE TIPO_ENTRADA 	"E"
#define aPROD 1      //-> aProd
#define INFADPROD 25
#define cMENSCLI 2   //-> cMensCli
#define cMENSFIS 3   //-> cMensFis
#define aDEST 4      //-> aDest
#define aNOTA 5      //-> aNota
#define aINFOITEM 6  //-> aInfoItem
#define aDUPL 7      //-> aDupl
#define aTRANSP 8    //-> aTransp
#define aENTREGA 9   //-> aEntrega
#define aRETIRADA 10 //-> aRetirada
#define aVEICULO 11  //-> aVeiculo
#define aREBOQUE 11  //-> aReboque
#DEFINE CRLF 	Chr(13) + Chr(10)

/*/{Protheus.doc} PE01NFESEFAZ

Implementação do ponto de entrada da NFE para buscar as msg da notas da tabela de mensagen

@type function
@author Daniel A Braga
@since 14/07/2017

@history 14/07/2017, Daniel A Braga, Exemplo de implementação da nova função. 

@see Classe FswTemplMsg
/*/
User Function PE01NFESEFAZ()
	Local aArea 	    := Lj7GetArea({"SC5","SC6","SF1","SF2","SD1","SD2","SA1","SA2","SB1","SB5","SF4","SA3"})
	Local aParam 	    := PARAMIXB
	Local cMensCli	    := aParam[02]
	Local aNota   	    := aParam[05]
	Local cTipo			:= iif(aNota[4] == "1" ,TIPO_SAIDA,TIPO_ENTRADA)
	Local cDocNF 		:= iif(cTipo == TIPO_SAIDA,SF2->F2_DOC     ,SF1->F1_DOC)
	Local cSerieNF		:= iif(cTipo == TIPO_SAIDA,SF2->F2_SERIE   ,SF1->F1_SERIE)
	Local cCodCliFor	:= iif(cTipo == TIPO_SAIDA,SF2->F2_CLIENTE ,SF1->F1_FORNECE)
	Local cLoja			:= iif(cTipo == TIPO_SAIDA,SF2->F2_LOJA    ,SF1->F1_LOJA)
	Local aRetornoPE	:= {}
	Local aRetorno		:= aParam 
	Local oFswTemplMsg 	:= FswTemplMsg():TemplMsg(cTipo,cDocNF,cSerieNF,cCodCliFor,cLoja)

	cMensCli += CRLF + oFswTemplMsg:getMsgNFE() + CRLF

	aParam[2] := alltrim(cMensCli)
	
	aadd(aParam,cCodCliFor)
	aadd(aParam,cLoja)

	

	// Integração Protheus x VTEX - Atos Data Consultoria

	If ExistBlock("ADPE01NFESEFAZ")
		ExecBlock("ADPE01NFESEFAZ", .F., .F., aParam)
	EndIf

	If ExistBlock("DUXFAT01")
		aRetornoPE := ExecBlock("DUXFAT01", .F., .F., aParam)
		If ValType(aRetornoPE) == "A" .And. Len(aRetornoPE) > 0
			aRetorno := aRetornoPE

		Endif
	EndIf

	Lj7RestArea(aArea)

Return aRetorno
