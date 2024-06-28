#INCLUDE 	"TOTVS.CH"
#INCLUDE 	"RWMAKE.CH"
#INCLUDE 	"PROTHEUS.CH"

#DEFINE 	cEOL			Chr(13) + Chr(10)

/*
=====================================================================================
Programa.:              ADIP02CEL
Autor....:              Atos | Rafael Yera Barchi
Data.....:              22/05/2023
Descricao / Objetivo:   INTELIPOST | Ponto de entrada para personalizar a leitura do celular do cliente.
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 
User Function ADIP02CEL()
	
	Local 	cRet := SA1->A1_ZZWHATS


	cRet := StrTran(cRet, "-", "")
	cRet := StrTran(cRet, "/", "")
	cRet := StrTran(cRet, "(", "")
	cRet := StrTran(cRet, ")", "")
	cRet := AllTrim(cRet)

Return cRet
