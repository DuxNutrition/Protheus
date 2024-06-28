#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "FileIO.ch"
#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.CH'
#Include 'tbiconn.ch'
#Include "TopConn.ch"




 /*/{Protheus.doc}User Function DUXINT001()

Funcao 
type  Function.
	@since 1
	@version 1.0
 /*/

User Function DUXINT001()

Local aPergs := {}
Local dDataDe  := dDataBase
Local dDataAt  := dDataBase
Local cProdDe := space(TamSX3("D2_DOC")[1])
Local cProdAt := space(TamSX3("D2_DOC")[1])
Local cSerie := space(TamSX3("F2_SERIE")[1])


Local cTRanps := space(TamSX3("F2_TRANSP")[1])
Local cTRanpsAT := space(TamSX3("F2_TRANSP")[1])
Private  cAliasTrb := GetNextalias()

   
    aAdd(aPergs, {1, "Transportadora ", cTRanps ,  "", ".T.","SA4", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Transportadora ", cTRanpsAT ,  "", ".T.","SA4", ".T.", 80,  .T.})
    aAdd(aPergs, {1, "Nota De",  cProdDe,  "", ".T.", "SF2", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Nota Até", cProdAt,  "", ".T.", "SF2", ".T.", 80,  .T.})
    aAdd(aPergs, {1, "Serie",  cSerie,"" ,".T.","", ".T.", 80,  .F.})
    
    aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Data Até", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})
 
    If ParamBox(aPergs, "Informe os parâmetros") 
        cQuery := " "
        cQuery += " SELECT *   " 
        cQuery += " FROM   " + RetSQLName("SF2") + "   " 
        cQuery += " WHERE  F2_TRANSP BETWEEN '"+ MV_PAR01+"'  and  '"+ MV_PAR02+"'  " 
        cQuery += "        AND F2_DOC BETWEEN '"+ MV_PAR03+"'   " 
        cQuery += "        AND '"+ MV_PAR04+"'   " 
        cQuery += "        AND F2_EMISSAO BETWEEN'"+ dtos(MV_PAR06) +"'   " 
        cQuery += "        AND '"+ dtos(MV_PAR07)+"'   " 
        If !Empty(alltrim(MV_PAR05)) 
          cQuery += "        AND F2_SERIE = '"+ MV_PAR05+" '   " 
        ENDIF  
        cQuery += "        AND D_E_L_E_T_ = ' '   " 
        cQuery := changequery(cQuery)
        FwmsgRun(,{|| dDuxQuery(cQuery) },"Aguarde...","Gerando Dados...")
    ENDIF 
Return 
Static Function dDuxQuery()
    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), (cAliasTrb), .T., .T.)
     while !(cAliasTrb)->(eof())
            DUXPRCINF((cAliasTrb)->F2_CHVNFE,(cAliasTrb)->F2_TRANSP,(cAliasTrb)->F2_SERIE+(cAliasTrb)->F2_DOC,stod((cAliasTrb)->F2_EMISSAO))
            (cAliasTrb)->(dbskip())
        end
    
RETURN
Static Function  DUXPRCINF(cChave,cTranps,cnomeArq,dDataGer)


Local curlReport := GetMv("TI_MERCREP",,"https://apihml.ifcshop.com.br/freight/shipment/orders/key/[CHAVE]/simplified/label")

Local cLocalGRV := GetMv("TI_LOCGRVE",,"c:\temp\")


Default cChave := ''

DEFAULT cnomeArq := ''
DEFAULT dDataGer := ddatabase
Local oObj2 := '' 

Local aHeader := {}  

local cValor := GETMV( "TI_APIAUT", .F., "Authorization=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiaW50ZWdyYXRpb24iLCJzdWIiOiI2NTI0MGQ2ZWZmNTg0NjE2MjQzMGU3MjIiLCJuYW1lIjoiRHV4IE51dHJpdGlvbiIsImlzcyI6ImluWjNYdU8xd0VINHQwMDh6bEZoYUZDWlc5QWRvcDFOIiwibmJmIjoxNjk2ODY4NDQ5LCJleHAiOjIwMTI0ODc2NDksImlhdCI6MTY5Njg2ODQ0OX0.L6Rkcaqpfa1mPVIJwyVG8-95IOPXjnGiFVQ1Wr41enE" )
local cVlr2 := GETMV( "TI_APIKEY", .F., "api-key=lKl2GV2UCDEVnEFj3wYY4oiuuF0EkjLW" )
Local oRest      := Nil 	



  curlReport := STRTRAN(curlReport,'[CHAVE]',cChave)

    oRest := FWRest():New(alltrim(curlReport))
    oRest:SetPath('?'+cValor+'&'+ cVlr2) 
        //HEADER
    aHeader:={}
    aAdd(aHeader, 'Content-Type: application/json'  ) 
   // aadd( aHeader,' "Authorization" : "OAuth oauth_consumer_key="api_dev",oauth_token="54aafd43-bebd-475a-8b82-6977e5d9c52b",oauth_signature_method="HMAC-SHA1"' )



    oRest:GET(aHeader)
    IF AllTrim( oRest:oResponseH:cStatusCode ) $ GetMV("TI_CODCOMP",,"200/201/202/204")
          nRet := MakeDir( "\etiqinfracomerce" )
          if (nRet !=  0 .and. nRet != 5)
            conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
          endif
       
        oFileXML := FWFileWriter():New('\etiqinfracomerce\'+Alltrim(cnomeArq)+'.pdf', .T.)
        oFileXML:SetEncodeUTF8(.T.)
        oFileXML:Create()
        oFileXML:Write(oRest:cResult)
        oFileXML:Close()
        cNmTr := ALLTRIM(Posicione("SA4",1,xFilial('SA4')+cTranps,"A4_NREDUZ"))
        cData := STRTRAN(dtoc(dDataGer),'/','-')
        nRet := MakeDir( cLocalGRV+cData )
        if (nRet !=  0 .and. nRet != 5)
            conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
        endif
        cData := STRTRAN(dtoc(dDataGer),'/','-')
        nRet := MakeDir( cLocalGRV+cData+'\'+ cNmTr)
        if (nRet !=  0 .and. nRet != 5)
            conout( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
        endif
        __CopyFile( '\etiqinfracomerce\'+cnomeArq+'.pdf', cLocalGRV+cData+'\'+cNmTr +'\'+Alltrim(cnomeArq)+'.pdf') 
    else   
        FWJsonDeserialize(oRest:cResult, @oObj2)
   Endif

RETURN
