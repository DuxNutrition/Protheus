#INCLUDE "totvs.ch"
#INCLUDE "parmtype.ch"
/*/{Protheus.doc} DUXFAT01
    (long_description)
    @type  Function
    @author Mayara Dias
    @since 08/03/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function DUXFAT01()

	Local aProd     	:= PARAMIXB[1]
	Local cMensCli  	:= PARAMIXB[2]
	Local cMensFis  	:= PARAMIXB[3]
	Local aDest     	:= PARAMIXB[4]
	Local aNota     	:= PARAMIXB[5]
	Local aInfoItem 	:= PARAMIXB[6]
	Local aDupl     	:= PARAMIXB[7]
	Local aTransp   	:= PARAMIXB[8]
	Local aEntrega  	:= PARAMIXB[9]
	Local aRetirada 	:= PARAMIXB[10]
	Local aVeiculo  	:= PARAMIXB[11]
	Local aReboque  	:= PARAMIXB[12]
	Local aNfVincRur	:= PARAMIXB[13]
	Local aEspVol   	:= PARAMIXB[14]
	Local aNfVinc   	:= PARAMIXB[15]
	Local AdetPag   	:= PARAMIXB[16]
	Local aObsCont  	:= PARAMIXB[17]
	Local aProcRef  	:= PARAMIXB[18]
	Local aMed			:= PARAMIXB[19]
	Local aLote 		:= PARAMIXB[20]
	Local aICMS			:= PARAMIXB[21]
    Local aIPI			:= PARAMIXB[22]
    Local aICMSST		:= PARAMIXB[23]
    Local aPIS			:= PARAMIXB[24]
    Local aPISST		:= PARAMIXB[25]
    Local aCOFINS		:= PARAMIXB[26]
    Local aCOFINSST		:= PARAMIXB[27]
    Local aISSQN		:= PARAMIXB[28]
	Local aTotal		:= PARAMIXB[29]
    local aICMSZFM		:= PARAMIXB[30]
    local aICMUFDest	:= PARAMIXB[31]
	Local aNfe      	:= PARAMIXB
	Local aRetorno		:= {}
	Local aArea			:= GetArea()
	Local i         	:= 0
	Local cProduto  	:= ""
	local cNota			:= aNota[2]
	local cSerie		:= aNota[1]
	Local cTPNf			:= aNota[4]
	Local cClifor		:= PARAMIXB[32]
	Local cLoja			:= PARAMIXB[33]
	Local lAglutProd    := iif(posicione("SA1",1,xFilial("SA1") +;
												 padr(PARAMIXB[32],tamsx3("A1_COD")[1]) +;
												 padr(PARAMIXB[33],tamsx3("A1_LOJA")[1]),;
												 "A1_XAGPRNF") == "S",.t.,.f.)
	Private cLote   := ""
	Private cValid	:= ""
	Private nQuant	:= 0
	Private cFabric  := ""

	lNfEntrada:=(aNFE[5,4]=="0")
	lNfSaida  :=(aNFE[5,4]=="1")

	IF lNfSaida .AND. SF2->F2_TIPO $ "B/D"

		For i:=1 to Len(aProd)
			cProduto := aProd[i][2]
			aProd[i][25] := /*" - "*/ + retDadosProd(cNota,cSerie,cProduto,cTPNf,aInfoItem[i][4],i,@aLote)
			aLote[i]:={cLote,nQuant,cfabric,cValid,""}
		Next

	ENDIF

	if(lNfSaida .and. lAglutProd)
		aglutinaProdutos(cNota,;
						 cSerie,;
						 cClifor,;
						 cLoja,;
						 @aProd,;
						 @aICMS,;
						 @aIPI,;
						 @aICMSST,;
						 @aPIS,;
						 @aPISST,;
						 @aCOFINS,;
						 @aCOFINSST,;
						 @aISSQN,;
						 @aICMSZFM,;
						 @aICMUFDest,;
						 aInfoItem)
	endif

	aadd(aRetorno,aProd)
	aadd(aRetorno,cMensCli)
	aadd(aRetorno,cMensFis)
	aadd(aRetorno,aDest)
	aadd(aRetorno,aNota)
	aadd(aRetorno,aInfoItem)
	aadd(aRetorno,aDupl)
	aadd(aRetorno,aTransp)
	aadd(aRetorno,aEntrega)
	aadd(aRetorno,aRetirada)
	aadd(aRetorno,aVeiculo)
	aadd(aRetorno,aReboque)
	aadd(aRetorno,aNfVincRur)
	aadd(aRetorno,aEspVol)
	aadd(aRetorno,aNfVinc)
	aadd(aRetorno,AdetPag)
	aadd(aRetorno,aObsCont)
	aadd(aRetorno,aProcRef)
	aadd(aRetorno,aMed)
	aadd(aRetorno,aLote)
	
	aadd(aRetorno , aICMS)
	aadd(aRetorno , aIPI)
	aadd(aRetorno , aICMSST)
	aadd(aRetorno , aPIS)
	aadd(aRetorno , aPISST)
	aadd(aRetorno , aCOFINS)
	aadd(aRetorno , aCOFINSST)
	aadd(aRetorno , aISSQN)
	aadd(aRetorno , aTotal)
	aadd(aRetorno , aICMSZFM)
	aadd(aRetorno , aICMUFDest)

	RestArea(aArea)

Return aRetorno

Static Function retDadosProd(cDoc,cSerie,cProduto,cTipo,cItem,i,aLote)
	local cRet 		:= ""
	Local cQuery 	:= ""
	local cAlias	:= getNextAlias()
	

	if Alltrim(cTipo) == "1"
		cQuery := "SELECT SD2.D2_LOTECTL LOTECTL, SD2.D2_DTVALID DTVALID, SD2.D2_QUANT QUANT, SD2.D2_DFABRIC DTFABRIC" +CRLF
		cQuery += "	FROM SF2010 SF2 "+CRLF
		cQuery += "		INNER JOIN SD2010 SD2 ON " + CRLF
		cQuery += "		   SF2.F2_FILIAL =	SD2.D2_FILIAL " + CRLF
		cQuery += "			AND	SF2.F2_DOC = SD2.D2_DOC " + CRLF
		cQuery += "			AND SF2.F2_SERIE = SD2.D2_SERIE " + CRLF
		cQuery += "			AND SF2.F2_CLIENTE = SD2.D2_CLIENTE " + CRLF
		cQuery += "			AND SF2.F2_LOJA = SD2.D2_LOJA " + CRLF
		cQuery += "			AND SD2.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN SC6010 SC6 ON " + CRLF
		cQuery += "		   SC6.C6_FILIAL =	SD2.D2_FILIAL " + CRLF
		cQuery += "			AND	SC6.C6_NUM = SD2.D2_PEDIDO " + CRLF
		cQuery += "			AND SC6.C6_ITEM = SD2.D2_ITEMPV " + CRLF
		cQuery += "			AND SC6.D_E_L_E_T_ = ' '" + CRLF
		cQuery += "		INNER JOIN SC9010 SC9 ON " + CRLF
		cQuery += "		   SC9.C9_FILIAL =	SD2.D2_FILIAL " + CRLF
		cQuery += "			AND	SC9.C9_PEDIDO = SD2.D2_PEDIDO " + CRLF
		cQuery += "			AND SC9.C9_NFISCAL = SD2.D2_DOC " + CRLF
		cQuery += "			AND SC9.C9_ITEM = SC6.C6_ITEM " + CRLF
		cQuery += "			AND SC9.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "	WHERE 1=1 " + CRLF
		cQuery += "	AND SF2.D_E_L_E_T_ 	= ''" + CRLF
		cQuery += "	AND SF2.F2_FILIAL 	= '"+xFilial("SF2")+"'" + CRLF
		cQuery += "	AND SD2.D2_FILIAL 	= '"+xFilial("SD2")+"'" + CRLF
		cQuery += "	AND SC6.C6_FILIAL 	= '"+xFilial("SC6")+"'" + CRLF
		cQuery += "	AND SF2.F2_DOC = '"+cDoc+"'" + CRLF
		cQuery += "	AND SF2.F2_SERIE = '"+cSerie+"'" + CRLF
		cQuery += "	AND SD2.D2_COD = '"+cProduto+"'" + CRLF
		cQuery += "	AND SD2.D2_ITEM = '" + cItem + "'" + CRLF
	endif

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)
	DbSelectArea(cAlias)

	if !(cAlias)->(Eof())
		If !Empty(((cAlias))->LOTECTL)
			cRet += IIf(!Empty(((cAlias))->LOTECTL),+"Lote: "+AllTrim(((cAlias))->LOTECTL),"")
			cRet += " " + AllTrim(IIF(Empty((cAlias)->DTVALID),"","Validade: "+dtoc(stod((cAlias)->DTVALID))))
			cRet += " " + AllTrim(IIF(Empty((cAlias)->QUANT),"","Quantidade: "+CVALTOCHAR((cAlias)->QUANT)))
			cLote:=IIf(!Empty(((cAlias))->LOTECTL),AllTrim(((cAlias))->LOTECTL),"")
			nQuant:=IIf(!Empty(((cAlias)->QUANT)),((cAlias)->QUANT),)
			cValid:=IIF(!Empty((cAlias)->DTVALID),stod((cAlias)->DTVALID),)
			cFabric:=IIF(!Empty((cAlias)->DTFABRIC),stod((cAlias)->DTFABRIC),)
		EndIf
	endif
	(cAlias)->(DbCloseArea())

Return(cRet)

/*/{Protheus.doc} aglutinaProdutos()
Aglutina os produtos.
@type  Static Function
@author Raphael Koury Giusti
@since 01/11/2023
/*/
Static Function aglutinaProdutos(cDoc,cSerie,cClifor,cLoja,;
								 aProd,aICMS,aIPI,aICMSST,aPIS,aPISST,aCOFINS,;
								 aCOFINSST,aISSQN,aICMSZFM,aICMUFDest,aInfoItem)
	local cProduto	    := "" as character
	local cItem		    := "" as character
	local cNumPV 	    := "" as character
	local cItemPV 	    := "" as character
	local nCont 	    := 0  as numeric
	local nG 		    := 0  as numeric
    local nPos          := 0  as numeric
    local nCampo        := 0  as numeric
    local aLoteProd     := {} as array
    local aProdAgrp     := {} as array
    local aImpAgrp      := {} as array
    local aICMSZF		:= {} as array
	default aInfoItem   := {}

		for nCont := 1 to len(aProd)
		   
			cProduto	:= aProd[nCont,02]
			cItem		:= aInfoItem[nCont,04]
			cNumPV 		:= aInfoItem[nCont,01]
			cItemPV		:= aInfoItem[nCont,02]
								
			dbSelectArea("SD2")
			SD2->(dbSetOrder(3))
			SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
			aadd(aProd[nCont],SD2->D2_CF)
			
			nPos := aScan(aProdAgrp , {|Registro| Registro[02]+Registro[len(aProd[nCont])] ==;
                                        aProd[nCont,02]+aProd[nCont,len(aProd[nCont])] })
	    	             
			if(nPos == 0)
				aadd( aProdAgrp , aProd[nCont] )
                aadd( aICMSZF	, {aProd[nCont,02], iif(Empty(aICMSZFM[nCont]), 0, aICMSZFM[nCont][1]), iif(Empty(aICMSZFM[nCont]), "", aICMSZFM[nCont][2] )})

				if(!empty(SD2->D2_LOTECTL))
					aadd( aLoteProd , { SD2->D2_COD,;				
					                    alltrim(SD2->D2_LOTECTL)})	
				endif
			else
                aICMSZF[nPos][2]	+= iif(Empty(aICMSZFM[nCont]), 0, aICMSZFM[nCont][1])

				aProdAgrp[nPos,09]	+= aProd[nCont,09] 
				aProdAgrp[nPos,10]	+= aProd[nCont,10] 
				aProdAgrp[nPos,12]	+= aProd[nCont,12] 
				aProdAgrp[nPos,13]	+= aProd[nCont,13] 
				aProdAgrp[nPos,16]	:= aProd[nCont,16] 
				aProdAgrp[nPos,26]  += aProd[nCont,26]
				aProdAgrp[nPos,31]  += aProd[nCont,31]
				aProdAgrp[nPos,32]	+= aProd[nCont,32]
				aProdAgrp[nPos,15]	+= aProd[nCont,15]

				nPos := aScan(aLoteProd , {|Registro| Registro[1] == SD2->D2_COD })
				if(nPos > 0) 
                    if(!(alltrim(SD2->D2_LOTECTL) $ aLoteProd[nPos,02]))
                        if !empty(aLoteProd[nPos,02])
                            aLoteProd[nPos,02] += "," + alltrim(SD2->D2_LOTECTL)
                        else
                            aLoteProd[nPos,02] := alltrim(SD2->D2_LOTECTL)
                        endif
                    endif
				endif
			endif
		next nCont
		
		if(len(aProdAgrp) > 0)
			for nG := 1 to len(aProdAgrp)
				aProdAgrp[nG][1] := cValtoChar(nG)
			next 
			
			aProd 		:= aClone(aProdAgrp)
			aProdAgrp   := {}
		endif

        //02.02-Aglutina os Impostos
	   //--------------------------------------------------------------------
	   //02.02.01 - ICMS
	   //--------------------------------------------------------------------   
	   if(valtype(aICMS) == "A" .and. len(aICMS) > 0)	    
			for nCont := 1 to len(aICMS)
				if(valtype(aICMS[1]) == "A")
					if(len(aICMS[nCont]) > 0) 
					    
						nCampo   := len(aICMS[nCont])
						cProduto := aICMS[nCont,nCampo]
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3)) 
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem)) 
						
						aadd(aICMS[nCont],SD2->D2_CF)
					    	                
						if((len(aImpAgrp) > 0) .and. (len(aImpAgrp[01]) > 0) )
							nPos := aScan( aImpAgrp , {|Registro| iif((len(aICMS[nCont])-1 >= nCampo) .and.; 
                                                                        len(Registro) >= nCampo,;
                                                                        Registro[nCampo] + ;
                                                                        Registro[len(aICMS[nCont])] ==; 
                                                                        aICMS[nCont,nCampo] + ;
                                                                        aICMS[nCont,len(aICMS[nCont])], .F.) } )
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0)
							aadd( aImpAgrp , aICMS[nCont] )
						else
							aImpAgrp[nPos,05] += aICMS[nCont,05]
							aImpAgrp[nPos,07] += aICMS[nCont,07]
							aImpAgrp[nPos,09] += aICMS[nCont,09]
							aImpAgrp[nPos,15] += aICMS[nCont,15]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next nCont
		endif
	   	
		if len(aImpAgrp) > 0
			aICMS 	:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif

		//--------------------------------------------------------------------
	   //02.02.02 - ICMS DIFAL
	   //--------------------------------------------------------------------   
	   if(valtype(aICMUFDest) == "A" .and. len(aICMUFDest) > 0)	    
			for nCont:=1 to len(aICMUFDest)
				if(valtype(aICMUFDest[1]) == "A")
					if(len(aICMUFDest[nCont]) > 0)
					    
						nCampo   := len(aICMUFDest[nCont])
						cProduto := aICMUFDest[nCont,nCampo]
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3)) 
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
						aadd(aICMUFDest[nCont],SD2->D2_CF)
					    	                
						if((len(aImpAgrp) > 0) .and. (len(aImpAgrp[01]) > 0)) 
							nPos 	:= aScan( aImpAgrp , {|Registro| iif((len(aICMUFDest[nCont])-1 >= nCampo) .and.; 
                                                                          len(Registro) >= nCampo,; 
                                                                          Registro[nCampo] + ;
                                                                          Registro[len(aICMUFDest[nCont])] == ;
                                                                          aICMUFDest[nCont,nCampo] + ;
                                                                          aICMUFDest[nCont,len(aICMUFDest[nCont])], .F.)}) 
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0)
							aadd(aImpAgrp , aICMUFDest[nCont] )
						else
							aImpAgrp[nPos,01] += aICMUFDest[nCont,01]
							aImpAgrp[nPos,07] += aICMUFDest[nCont,07]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next nCont
		endif
	   	
		if len(aImpAgrp) > 0
			aICMUFDest 	:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
			
	   //--------------------------------------------------------------------
	   //02.02.02 - ICMS ST
	   //--------------------------------------------------------------------
	    if(valtype(aICMSST) == "A" .and. len(aICMSST) > 0)
			for nCont:=1 to len(aICMSST)
				if(valtype(aICMSST[1]) == "A")
					if(len(aICMSST[nCont]) > 0 )

						nCampo   := len(aICMSST[nCont])
						cProduto := aICMSST[nCont,nCampo]						
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3)) 
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
						aadd(aICMSST[nCont],SD2->D2_CF)
					    	                
						if((len(aImpAgrp) > 0) .and. (len(aICMSST[nCont]) > 0))
							nPos 	:= aScan( aImpAgrp , {|Registro| iif(len(aICMSST[nCont])-1 >= nCampo .and.; 
                                                                         len(Registro) >= nCampo,; 
                                                                         Registro[nCampo] + ;
                                                                         Registro[len(aICMSST[nCont])] == ;
                                                                         aICMSST[nCont,nCampo] + ;
                                                                         aICMSST[nCont,len(aICMSST[nCont])], .F.)})
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0)
							aadd( aImpAgrp , aICMSST[nCont] )
						else
							aImpAgrp[nPos,05] += aICMSST[nCont,05]
							aImpAgrp[nPos,07] += aICMSST[nCont,07]
							aImpAgrp[nPos,09] += aICMSST[nCont,09]
							aImpAgrp[nPos,13] += aICMSST[nCont,13]
							aImpAgrp[nPos,15] += aICMSST[nCont,15]
							aImpAgrp[nPos,12] += aICMSST[nCont,12]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next nCont
		endif
	   	   
		if(len(aImpAgrp) > 0)
			aICMSST := aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
	
	   //--------------------------------------------------------------------
	   //02.02.03 - IPI                                                      
	   //--------------------------------------------------------------------
	   if((valtype(aIPI) == "A") .and. (len(aIPI) > 0))
	   		aImpAgrp := {}
	   		
	   		for nCont := 1 to len(aProd)
	   			aadd(aImpAgrp, {})
	   		next
	  
		   	for nCont := 1 to len(aIPI)
				if(valtype(aIPI[1]) == "A")
					if(len(aIPI[nCont]) > 0)
						
                        nCampo   	:= len(aIPI[nCont])
						cProduto 	:= aIPI[nCont,nCampo]
						cItem	    := aInfoItem[nCont,04]

						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3))
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
						aadd(aIPI[nCont],SD2->D2_CF)
					   			    						    	               			
						nPos := aScan( aProd , {|Registro| alltrim(Upper(Registro[2])) ==; 
                                                            alltrim(Upper(cProduto))}) 
												
						if(nPos > 0)
					    	if(len(aImpAgrp[nPos]) > 0)
								aImpAgrp[nPos,06]	+= aIPI[nCont,06]
								aImpAgrp[nPos,07]	+= aIPI[nCont,07]
								aImpAgrp[nPos,10] 	+= aIPI[nCont,10]								
							else
								aImpAgrp[nPos]		:= aIPI[nCont]							
							endif
						endif					
					endif
				endif
			next nCont
	    endif
	   
		if len(aImpAgrp) > 0
			aIPI  	:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
			
	    //--------------------------------------------------------------------
	    //02.02.04 - PIS
	    //--------------------------------------------------------------------
	    if((valtype(aPIS) == "A") .and. (len(aPIS) > 0))
			for nCont:=1 to len(aPIS)
				if(valtype(aPIS[1]) == "A")		
					if(len(aPIS[nCont]) > 0) 
					
                    	nCampo   := len(aPIS[nCont]) 
						cProduto := aPIS[nCont,nCampo]	
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3))
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
						aadd(aPIS[nCont],SD2->D2_CF)
					    	                
						if(len(aImpAgrp) > 0)
							nPos 	:= aScan( aImpAgrp , {|Registro| iif(len(aPIS[nCont])-1 >= nCampo .and.; 
                                                                         len(Registro) >= nCampo,; 
                                                                         Registro[nCampo] + ;
                                                                         Registro[len(aPIS[nCont])] == ;
                                                                         aPIS[nCont,nCampo] + ;
                                                                         aPIS[nCont,len(aPIS[nCont])], .F.)})
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0)
							aadd( aImpAgrp , aPIS[nCont] )
						else
							aImpAgrp[nPos,02] += aPIS[nCont,02]
							aImpAgrp[nPos,04] += aPIS[nCont,04]
							aImpAgrp[nPos,05] += aPIS[nCont,05]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next nCont
		endif
	   
		if len(aImpAgrp) > 0
			aPIS  	:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
			
	    //--------------------------------------------------------------------
	    //02.02.05 - PIS ST
	    //--------------------------------------------------------------------
	    if(valtype(aPISST) == "A" .and. len(aPISST) > 0)
			for nCont:=1 to len(aPISST)
				if(valtype(aPISST[1]) == "A")
					if(len(aPISST[nCont]) > 0)
						
                        nCampo   := len(aPISST[nCont])
						cProduto := aPISST[nCont,nCampo]
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3))
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
						aadd(aPISST[nCont],SD2->D2_CF)
					    	                
						if(len(aImpAgrp) > 0)
							nPos := aScan( aImpAgrp , {|Registro| iif(len(aPISST[nCont])-1 >= nCampo .and.; 
                                                                      len(Registro) >= nCampo,; 
                                                                      Registro[nCampo] + ;
                                                                      Registro[len(aPISST[nCont])] ==; 
                                                                      aPISST[nCont,nCampo] + ;
                                                                      aPISST[nCont,len(aPISST[nCont])], .F.)})
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0) 
							aadd( aImpAgrp , aPISST[nCont] )
						else
							aImpAgrp[nPos,02] += aPISST[nCont,02]
							aImpAgrp[nPos,04] += aPISST[nCont,04]
							aImpAgrp[nPos,05] += aPISST[nCont,05]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next nCont
		endif
		  	   
		if(len(aImpAgrp) > 0)
			aPISST 	:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
			
	   	//--------------------------------------------------------------------
	   	//02.02.06 - COFINS
	  	//--------------------------------------------------------------------
	  	if(valtype(aCOFINS) == "A" .and. len(aCOFINS) > 0)
			for nCont:=1 to len(aCOFINS)
				if(valtype(aCOFINS[1]) == "A")
					if(len(aCOFINS[nCont]) > 0)

						nCampo   := len(aCOFINS[nCont])
						cProduto := aCOFINS[nCont,nCampo]
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3))
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
						aadd(aCOFINS[nCont],SD2->D2_CF)
					    	                
						if(len(aImpAgrp) > 0)
							nPos 	:= aScan( aImpAgrp , {|Registro| iif(len(aCOFINS[nCont])-1 >= nCampo .and. len(Registro) >= nCampo, Registro[nCampo]+Registro[len(aCOFINS[nCont])] == aCOFINS[nCont,nCampo]+aCOFINS[nCont,len(aCOFINS[nCont])], .F.) } ) //Procura o Produto no Array de Aglutinados
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0)
							aadd( aImpAgrp , aCOFINS[nCont] )
						else
							aImpAgrp[nPos,02] += aCOFINS[nCont,02]
							aImpAgrp[nPos,04] += aCOFINS[nCont,04]
							aImpAgrp[nPos,05] += aCOFINS[nCont,05]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next 
		endif
	   
		if len(aImpAgrp) > 0
			aCOFINS	:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
			
	    //--------------------------------------------------------------------
	    //02.02.07 - COFINS ST
	    //--------------------------------------------------------------------
	    if(valtype(aCOFINSST) == "A" .and. len(aCOFINSST) > 0)
			for nCont := 1 to len(aCOFINSST)
				if(valtype(aCOFINSST[1]) == "A")
					if(len(aCOFINSST[nCont]) > 0)

						nCampo   := len(aCOFINSST[nCont])
						cProduto := aCOFINSST[nCont,nCampo]	
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3))
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem)) 
						
						aadd(aCOFINSST[nCont],SD2->D2_CF)
					    	                
						if(len(aImpAgrp) > 0)
							nPos := aScan( aImpAgrp , {|Registro| iif(len(aCOFINSST[nCont])-1 >= nCampo .and.; 
                                                                      len(Registro) >= nCampo,; 
                                                                      Registro[nCampo] + ;
                                                                      Registro[len(aCOFINSST[nCont])] == ;
                                                                      aCOFINSST[nCont,nCampo] + ;
                                                                      aCOFINSST[nCont,len(aCOFINSST[nCont])], .F.)})
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0)
							aadd( aImpAgrp , aCOFINSST[nCont] )
						else
							aImpAgrp[nPos,02] += aCOFINSST[nCont,02]
							aImpAgrp[nPos,04] += aCOFINSST[nCont,04]
							aImpAgrp[nPos,05] += aCOFINSST[nCont,05]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next nCont
		endif
	   	
		if(len(aImpAgrp) > 0)
			aCOFINSST:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
			
	   	//--------------------------------------------------------------------
	   	//02.02.08 - ISSQN
	  	//--------------------------------------------------------------------
	  	if(valtype(aISSQN) == "A" .and. len(aISSQN) > 0)
			for nCont:=1 to len(aISSQN)
				if(valtype(aISSQN[1]) == "A")
					if(len(aISSQN[nCont]) > 0)
						
                        nCampo   := len(aISSQN[nCont])
						cProduto := aISSQN[nCont,nCampo]
						cItem	 := aInfoItem[nCont,04]
					
						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1")+cProduto))
						
						dbSelectArea("SD2")
						SD2->(dbSetOrder(3))
						SD2->(dbSeek(xFilial("SD2")+cDoc+cSerie+cClifor+cLoja+cProduto+cItem))
						
						aadd(aISSQN[nCont],SD2->D2_CF)
					    	                
						if(len(aImpAgrp) > 0)
							nPos := aScan( aImpAgrp , {|Registro| iif(len(aISSQN[nCont]) >= nCampo .and.; 
                                                                      len(Registro) >= nCampo, ;
                                                                      Registro[nCampo] + ;
                                                                      Registro[len(aISSQN[nCont])] ==;
                                                                      aISSQN[nCont,nCampo] + ;
                                                                      aISSQN[nCont,len(aISSQN[nCont])], .F.)})
						else
							nPos := 0
						endif
				   	    	
						if(nPos == 0)
							aadd( aImpAgrp , aISSQN[nCont] )
						else
							aImpAgrp[nPos,01] += aISSQN[nCont,01]
							aImpAgrp[nPos,03] += aISSQN[nCont,03]
						endif
					else
						aadd( aImpAgrp , {} )
					endif
				endif
			next 
		endif
	   
		if(len(aImpAgrp) > 0)
			aISSQN	:= aClone(aImpAgrp)
			aImpAgrp:= {}
		endif
		
		aICMSZFM := {}
		for nCont := 1 to len(aICMSZF)
			aadd(aICMSZFM, {aICMSZF[nCont][2], aICMSZF[nCont][3]})
		next
Return 
