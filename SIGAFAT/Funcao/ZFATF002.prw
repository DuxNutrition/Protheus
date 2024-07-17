#include "totvs.ch"
#include "FWPrintSetup.ch"
#include "RPTDEF.ch"
//#include "tlpp-core.th"
//#include "tlpp-object.th"

#define IMP_DANFE    1
#define IMP_ETIQUETA 2

/*/{Protheus.doc} ImprimeNotaFiscal
Reliza a impressão customizada da nota fiscal 
e etiqueta (danfinho)de acordo com o range de 
transportadoras.
@type  Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
User Function ZFATF002(nTipoImp)

    Local lRet            := .T.
    Private cAliasTemp    := ""
    Private cChaveNfe     := ""
    Private cTranspDe     := ""
    Private cTranspAte    := ""
    Private cNFiscalDe    := ""
    Private cNFiscalAte   := ""
    Private cSerieNF      := ""
    Private cMsg          := ""
    Private cSolucao      := ""
    Private cImpressora   := ""
    Private nImpressora   := 0
    Private nTipoOperacao := 0
    Private dDataDe       := stod("")
    Private dDataAte      := stod("")
    Default nTipoImp      := 1

        if(getPergunta(nTipoImp))
            setPergunta(nTipoImp)

            FwMsgRun( ,{|| lRet := getChaveNfe() }, FwFilialName(), "Aguarde...Buscando informaçõe..." )

            if(lRet)
                setChaveNfe()
                if(!empty(cChaveNfe))
                    if(nTipoImp == IMP_DANFE)
                        imprimeDanfe()
                    elseif(nTipoImp == IMP_ETIQUETA)
                        imprimeEtiqueta()
                    endif
                else
                    lRet := .f.
                endif
            endif

            if(!lRet)
                cMsg     := "Não foi possível obter informações das notas fiscais."
                cSolucao := "Verifique os parâmetros digitados."
                showMessage()
            endif
        endif
return

/*/{Protheus.doc} imprimeDanfe
Realiza a impressão do DANFE.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function imprimeDanfe()
    local oDanfe        := nil
    local oSetup        := nil
    local cSession  	:= GetPrinterSession()
    //local cDevice     	:= if(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)) as character
    local cBarra		:= iif(IsSrvUnix(),"/","\")
    local cDir			:= ""
    local cFilePrint	:= "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
    local nRet 			:= 0 
    local nX 			:= 0 
    local nTipo		    := 0 
    local nPar		    := 0 
    //local nFlags        := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN as numeric
    //local nLocal       	:= if(fwGetProfString(cSession,"local","SERVER",.T.)== "SERVER",1,2) as numeric
    //local nOrientation 	:= if(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2) as numeric
    local cIdEnt 		:= getCfgEntidade()
    local lJob			:= isBlind()
    local lDanfeII		:= tssHasRdm("PrtNfeSef")
    local lDanfeIII		:= tssHasRdm("DANFE_P1")
    local lMsgVld		:= .f.
    //local aDevice  		:= {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"} as array 
    //local nPrintType    := aScan(aDevice,{|x| x == cDevice }) as numeric
    //local lAdjustToLegacy := .f. as logical

        if(tssHasRdm("DANFE_V") .and. if(lJob, nPar == 1, .t.))
            nRet := tssExecRdm("Danfe_v", .F.)
        elseif tssHasRdm("DANFE_VI") .and. if(lJob, nPar == 2, .t.)
            nRet := tssExecRdm("Danfe_vi", .F.)
        endif

        Pergunte("NFSIGW",.F.) 

        mv_par01 := cNFiscalDe
        mv_par02 := cNFiscalAte
        mv_par03 := cSerieNF
        mv_par04 := 2
		mv_par05 := 2
		mv_par06 := 2
        mv_par07 := dDataDe
        mv_par08 := dDataAte
	
        if(nRet >= 20100824)
            cDir := SuperGetMV('MV_RELT',,"\SPOOL\")
            
            if(!empty(cDir) .and. !ExistDir(cDir))
                aDir := StrTokArr(cDir, cBarra)
                cDir := ""
                for nX := 1 to len(aDir)
                    cDir += aDir[nX] + cBarra
                    if !ExistDir(cDir)
                        MakeDir(cDir)
                    endif
                next
            endif

            if(nTipo != 1)

                oDanfe      := FWMSPrinter():New(cFilePrint ,   ,.F., cDir  , .T.,,,,,.F. )
                //oDanfe      := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, cDir, .T. )

                if(lJob)
                    oDanfe:SetViewPDF(.F.)
                    oDanfe:lInJob := .T.
                endif

                if(!oDanfe:lInJob)

                    oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN, "DANFE")
                    oSetup:SetPropert(PD_PRINTTYPE , 2) //Spool
                    oSetup:SetPropert(PD_ORIENTATION , 2)
                    oSetup:SetPropert(PD_DESTINATION , 1)
                    //oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
                    //oSetup:SetPropert(PD_ORIENTATION , nOrientation)
                    //oSetup:SetPropert(PD_DESTINATION , nLocal)
                    oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
                    oSetup:SetPropert(PD_PAPERSIZE   , 2)

                    if(ExistBlock( "SPNFESETUP" ))
                        Execblock( "SPNFESETUP" , .F. , .F. , {oDanfe, oSetup} )
                    endif
                endif

                if(lJob .or. oSetup:activate() == PD_OK)

                    fwWriteProfString( cSession, "local"      , iif( lJob, "SERVER",;
                        iif(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER","CLIENT")),.t.)
                    
                    fwWriteProfString( cSession, "PRINTTYPE"  , iif(lJob, "PDF"		  ,; 
                        iif(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       )), .t.)
                    
                    fwWriteProfString( cSession, "ORIENTATION", iif(lJob, "LANDSCAPE" ,; 
                        iif(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" )), .t.)

                    oDanfe:setCopies(val(iif(lJob,"1",oSetup:cQtdCopia)))

                    if(lJob .and. (nPar == 1)) .or. (!lJob .and. oSetup:GetProperty(PD_ORIENTATION) == 1)
                        
                        iif(lDanfeII, tssExecRdm("PrtNfeSef", .F., cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,cFilePrint ,/*lIsLoja*/, /*nTipo*/), lMsgVld := .t.)

                    elseif((lJob .and. (nPar == 2) ) .or. !lJob)
                        iif(lDanfeIII, tssExecRdm("DANFE_P1", .F., cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/ ), lMsgVld := .t.)
                    Endif
                endif
            endif
        
            if(!lJob)
                if (lMsgVld)
                    Help(NIL, NIL,"Fonte de impressão do DANFE não compilado.", NIL,; 
                            "Acesse o portal do cliente baixe, os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente",;
                            1, 0, NIL, NIL, NIL, NIL, NIL, {"Fonte não compilado"})
                endif
            endif
        endif

        FreeObj(oDanfe)
        FreeObj(oSetup)
return 

/*/{Protheus.doc} setChaveNfe
Carrega as chaves NFE á serem 
filtradas na impressão.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function setChaveNfe()

    while((cAliasTemp)->(!eof()))

        if(empty(cChaveNfe))
            cChaveNfe := alltrim((cAliasTemp)->CHAVE_NFE)
        else
            cChaveNfe += "|"+alltrim((cAliasTemp)->CHAVE_NFE)
        endif

        (cAliasTemp)->(dbSkip())    
    enddo

    (cAliasTemp)->(dbCloseArea())

return 

/*/{Protheus.doc} getChaveNfe
Busca as chaves NFE á serem 
filtradas na impressão.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function getChaveNfe()
    local cSql := ""
    local lRet := .t.

        cSql += " SELECT " + CRLF
        cSql += "     SF2.F2_CHVNFE AS CHAVE_NFE " + CRLF
        cSql += " FROM "+RetSqlName("SF2")+" SF2 (NOLOCK) " + CRLF
        cSql += " WHERE 1 = 1 AND  " + CRLF
        cSql += "     SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND  " + CRLF
        cSql += "     SF2.F2_TRANSP BETWEEN ? AND ? AND " + CRLF
        cSql += "     SF2.F2_DOC BETWEEN ? AND ? AND  " + CRLF
        
        if(!empty(cSerieNF))
            cSql += "     SF2.F2_SERIE = ? AND  " + CRLF
        endif

        cSql += "     SF2.F2_EMISSAO BETWEEN ? AND ? AND  " + CRLF
        cSql += "     "+RetSQLDel("SF2")+" " + CRLF
        cSql += " ORDER BY 1 " + CRLF

        oStatement := FWExecStatement():new(cSql)
		oStatement:setString(1,cTranspDe)
		oStatement:setString(2,cTranspAte)
        oStatement:setString(3,cNFiscalDe)
        oStatement:setString(4,cNFiscalAte)

        if(empty(cSerieNF))
            oStatement:setDate(5,dDataDe)
            oStatement:setDate(6,dDataAte)
        else
            oStatement:setString(5,cSerieNF)
            oStatement:setDate(6,dDataDe)
            oStatement:setDate(7,dDataAte)
        endif

		cAliasTemp := oStatement:openAlias() 
        
        (cAliasTemp)->(dbGoTop())

        if(empty((cAliasTemp)->CHAVE_NFE))
            lRet := .f.
            (cAliasTemp)->(dbCloseArea())
        endif

return lRet

/*/{Protheus.doc} imprimeEtiqueta
Realiza a impressão da etiqueta.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function imprimeEtiqueta()
	local cIdEnt	 := getCfgEntidade()
	local cUrl		 := ""
    local lRet		 := .t.
	local lUsaColab	 := .f.

        if(!empty(cIdEnt))
            lUsaColab := UsaColaboracao("1")
            if(!lUsaColab)
                cUrl := Padr( GetNewPar("MV_SPEDURL",""), 250 )
            endif

            if(tssHasRdm("ImpDfEtq"))
                
                Pergunte("NFDANFETIQ",.f.)
                
                mv_par01 := cNFiscalDe  
                mv_par02 := cNFiscalAte 
                mv_par03 := cSerieNF
                mv_par04 := dDataDe 
                mv_par05 := dDataAte
                mv_par06 := nTipoOperacao
                mv_par07 := nImpressora
                mv_par08 := cImpressora

                tssExecRdm("ImpDfEtq", .T., {cUrl, cIdEnt, lUsaColab} )
            else		
                Help(NIL, NIL,"Fonte não compilado.", NIL,; 
                    "Fonte de geração do DANFE simplificado etiqueta não compilado.",;
                    1, 0, NIL, NIL, NIL, NIL, NIL,; 
                    {"Acesse o portal do cliente, baixe o DanfeEtiqueta.PRW e compile em seu ambiente."})
                lRet := .F.
            endif
        endif
        
return 

/*/{Protheus.doc} imprimeEtiqueta
Realiza o carregamento das 
perguntas.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function setPergunta(nTipoImp)
    cTranspDe  := mv_par01
    cTranspAte := mv_par02
    cNFiscalDe      := mv_par03
    cNFiscalAte     := mv_par04
    cSerieNF   := mv_par05
    dDataDe            := mv_par06
    dDataAte           := mv_par07

    if(nTipoImp == IMP_ETIQUETA)
        nTipoOperacao := val(mv_par08)
        nImpressora   := val(mv_par09)
        cImpressora   := mv_par10
    endif
return 

/*/{Protheus.doc} getPergunta
Carrega os parâmetros para o 
usuário.
@type  Static Function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function getPergunta(nTipoImp)
	local aParBox 	  := {}
    local aImpressora := {"1=Termica","2=Normal"}
    local aTpDoc      := {"1=Entrada","2=Saída"}
	local lRet	  	  := .t.

		aadd( aParBox,{1, "Transportadora de"	,space(tamsx3("A1_COD")[1])	    ,"", "", "SA4"  ,"",  80,.F.})
		aadd( aParBox,{1, "Transportadora até"	,space(tamsx3("A1_COD")[1])	    ,"", "", "SA4"  ,"",  80,.F.})
		aadd( aParBox,{1, "Nota Fiscal de"	    ,space(tamsx3("F2_DOC")[1])	    ,"", "", "SF2"  ,"",  80,.F.})
		aadd( aParBox,{1, "Nota Fiscal até"	    ,space(tamsx3("F2_DOC")[1])	    ,"", "", "SF2"	,"",  80,.F.})
        aadd( aParBox,{1, "Serie"	            ,space(tamsx3("F2_SERIE")[1])	,"", "", ""     ,"",  80,.F.})
        aadd( aParBox,{1, "Data de"             ,criavar("F2_EMISSAO")	        ,"", "", ""	    ,"",  80,.F.})
		aadd( aParBox,{1, "Data até"            ,criavar("F2_EMISSAO")	        ,"", "", ""	    ,"",  80,.F.})
        
        if(nTipoImp == IMP_ETIQUETA)
            aadd( aParBox,{2, "Tipo Operação"   ,aTpDoc[02],aTpDoc,80,".t.", .f.})
            aadd( aParBox,{2, "Tipo Impressora" ,aImpressora[02],aImpressora,80,".t.", .f.})
            aadd( aParBox,{1, "Impressora" ,space(6),"", "","CB5IMP","",80,.f.})
        endif

		if(!ParamBox(aParBox,"Impressão DANFE",nil,,,,,,,"IMPDANFE",.t.,.t.))
			lRet := .f.
		endif

return lRet

/*/{Protheus.doc} showMessage
Mosta a mensagem de erro e solução.
@type function
@author Raphael Koury Giusti
@since 08/11/2023
/*/
static function showMessage()  	
	help(nil, nil, FwFilialName(), nil, cMsg, 1, 0, nil, nil, nil, nil, nil, {cSolucao})
return
