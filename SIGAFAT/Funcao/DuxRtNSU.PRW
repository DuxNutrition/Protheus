#INCLUDE 	"TOTVS.CH"
#INCLUDE 	"TBICONN.CH"
#INCLUDE 	"TBICODE.CH"
#INCLUDE 	"PARMTYPE.CH"
#INCLUDE 	"TOPCONN.CH"

/*
=====================================================================================
Programa.:              DuxRtNSU
Autor....:              Atos
Data.....:              Não Há
Descricao / Objetivo:   Não Há
Doc. Origem:            GAP
Solicitante:            Dux
Uso......:              
Obs......:
=====================================================================================
*/ 

User Function DuxRtNSU(cOrder,ADADOS,_ACABEC)

Local cAliasTRB	:= GetNextAlias()
Local cExtRef := ALLTRIM(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("EXTERNAL_REFERENCE"))})])
Local cShipID := ALLTRIM(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("SHIPPING_ID"))})])
Local cPackID := ALLTRIM(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("PACK_ID"))})])
Local cSourceID := ALLTRIM(ADADOS[ASCAN(_ACABEC, {  |X| UPPER(ALLTRIM(X))== UPPER(ALLTRIM("SOURCE_ID"))})])

If !Empty(ALLTRIM(cOrder)) .OR. !Empty(ALLTRIM(cExtRef)) .OR. !Empty(ALLTRIM(cShipID)) .OR. !Empty(ALLTRIM(cPackID)) .OR. !Empty(ALLTRIM(cSourceID)) 
    cQuery := " SELECT C5_XPEDLV "
    cQuery += " FROM "
    cQuery += RETSQLNAME("SC5") + " SC5 "
    cQuery += " WHERE "
    cQuery += " SC5.D_E_L_E_T_ <> '*' "
    cQuery += " AND "
    cQuery += " ("
    If !Empty(ALLTRIM(cOrder))
        cQuery += " (SC5.C5_XPEDLV like '%"+ALLTRIM(cOrder)+"%' "
    else
         cQuery += " ( "   
    Endif

    If !Empty(ALLTRIM(cExtRef)) .and. !Empty(ALLTRIM(cOrder))
        cQuery += " OR SC5.C5_XPEDLV like '%"+ALLTRIM(cExtRef)+"%' "
    elseif !Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cOrder))
         cQuery += " SC5.C5_XPEDLV like '%"+ALLTRIM(cExtRef)+"%' "   
    else  
        cQuery += " "   
    ENDIF

    If (!Empty(ALLTRIM(cShipID)) .and. !Empty(ALLTRIM(cExtRef))) .OR. ( !Empty(ALLTRIM(cShipID)) .and. Empty(ALLTRIM(cExtRef)) .and. !Empty(ALLTRIM(cOrder)))
        cQuery += " OR SC5.C5_XPEDLV like '%"+ALLTRIM(cShipID)+"%' "
    elseif !Empty(ALLTRIM(cShipID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cOrder))
        cQuery += " SC5.C5_XPEDLV like '%"+ALLTRIM(cShipID)+"%' "
    else
         cQuery += " "   
    ENDIF

    If (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cShipID))) .OR.;
         (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cExtRef)))  .OR.;
         (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cOrder))) 
        cQuery += " OR SC5.C5_XPEDLV like '%"+ALLTRIM(cPackID)+"%' "
    ELSEIF  !Empty(ALLTRIM(cPackID)) .and. Empty(ALLTRIM(cShipID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cOrder))
        cQuery += " SC5.C5_XPEDLV like '%"+ALLTRIM(cPackID)+"%' "
    ELSE
        cQuery += " "  
    ENDIF

    If (!Empty(ALLTRIM(cSourceID)) .AND. !Empty(ALLTRIM(cPackID))) .OR.;
        (!Empty(ALLTRIM(cSourceID)) .AND. !Empty(ALLTRIM(cShipID))) .OR.;  
        (!Empty(ALLTRIM(cSourceID)) .AND. !Empty(ALLTRIM(cExtRef))) .OR.;    
        (!Empty(ALLTRIM(cSourceID)) .AND. !Empty(ALLTRIM(cOrder))) 
        cQuery += " OR SC5.C5_XPEDLV like '%"+ALLTRIM(cSourceID)+"%') "
    ELSEIF !Empty(ALLTRIM(cSourceID)) .AND. Empty(ALLTRIM(cPackID)) .and. Empty(ALLTRIM(cShipID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cOrder))
        cQuery += " SC5.C5_XPEDLV like '%"+ALLTRIM(cSourceID)+"%') "
    ELSE
        cQuery += " ) "  
    ENDIF
    
    
    If !Empty(ALLTRIM(cOrder))
        cQuery += " OR (SC5.C5_XTRSCT3 like '%"+ALLTRIM(cOrder)+"%' "

        If !Empty(ALLTRIM(cExtRef)) 
            cQuery += " OR SC5.C5_XTRSCT3 like '%"+ALLTRIM(cExtRef)+"%' "
        ELSE
            cQuery += " "  
        ENDIF

        If !Empty(ALLTRIM(cShipID))
            cQuery += " OR SC5.C5_XTRSCT3 like '%"+ALLTRIM(cShipID)+"%' "
        ELSE
            cQuery += " "  
        ENDIF

        If !Empty(ALLTRIM(cPackID))
            cQuery += " OR SC5.C5_XTRSCT3 like '%"+ALLTRIM(cPackID)+"%' "
        ELSE
            cQuery += " "  
        ENDIF
        If !Empty(ALLTRIM(cSourceID))
            cQuery += " OR SC5.C5_XTRSCT3 like '%"+ALLTRIM(cSourceID)+"%') "
        ELSE
             cQuery += " ) "      
        ENDIF
    ELSEIF !Empty(ALLTRIM(cExtRef)) .OR. !Empty(ALLTRIM(cShipID)) .OR. !Empty(ALLTRIM(cPackID)) .OR.  !Empty(ALLTRIM(cSourceID))
        cQuery += " OR ( "
        If !Empty(ALLTRIM(cExtRef)) 
            cQuery += " SC5.C5_XTRSCT3 like '%"+ALLTRIM(cExtRef)+"%' "
        ELSE
            cQuery += " "      
        ENDIF
        If !Empty(ALLTRIM(cShipID)) .and. !Empty(ALLTRIM(cExtRef)) 
            cQuery += " OR SC5.C5_XTRSCT3 like '%"+ALLTRIM(cShipID)+"%' "
        elseif !Empty(ALLTRIM(cShipID)) .and. Empty(ALLTRIM(cExtRef)) 
            cQuery += " SC5.C5_XTRSCT3 like '%"+ALLTRIM(cShipID)+"%' "
        else
            cQuery += " "     
        ENDIF

        If (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cExtRef))) .or. ;
            (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cShipID)))
            cQuery += " OR SC5.C5_XTRSCT3 like '%"+ALLTRIM(cPackID)+"%' "
        elseif !Empty(ALLTRIM(cPackID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cShipID))
            cQuery += " SC5.C5_XTRSCT3 like '%"+ALLTRIM(cPackID)+"%' "    
        else
            cQuery += " "        
        ENDIF

        If (!Empty(ALLTRIM(cSourceID)) .and. !Empty(ALLTRIM(cExtRef))) .or. ;
            (!Empty(ALLTRIM(cSourceID))  .and. !Empty(ALLTRIM(cShipID))) .or. ;
            (!Empty(ALLTRIM(cSourceID))  .and. !Empty(ALLTRIM(cPackID))) 
            cQuery += " OR SC5.C5_XTRSCT3 like '%"+ALLTRIM(cSourceID)+"%') "
        ELSEIF !Empty(ALLTRIM(cSourceID)) .and. Empty(ALLTRIM(cExtRef)) .AND. Empty(ALLTRIM(cShipID)) .AND. Empty(ALLTRIM(cPackID))
            cQuery += " SC5.C5_XTRSCT3 like '%"+ALLTRIM(cSourceID)+"%') "
        ELSE
            cQuery += " ) "
        ENDIF
    ELSE
        cQuery += " "      
    ENDIF

    If !Empty(ALLTRIM(cOrder))
        cQuery += " OR (SC5.C5_XNSU like '%"+ALLTRIM(cOrder)+"%' "
        If !Empty(ALLTRIM(cExtRef))
            cQuery += " OR SC5.C5_XNSU like '%"+ALLTRIM(cExtRef)+"%' "
        ELSE
            cQuery += " "     
        ENDIF
        If !Empty(ALLTRIM(cShipID))
            cQuery += " OR SC5.C5_XNSU like '%"+ALLTRIM(cShipID)+"%' "
        ELSE
            cQuery += " "
        ENDIF
        If !Empty(ALLTRIM(cPackID))
            cQuery += " OR SC5.C5_XNSU like '%"+ALLTRIM(cPackID)+"%' "
        ELSE
            cQuery += " "
        ENDIF
        If !Empty(ALLTRIM(cSourceID))
            cQuery += " OR SC5.C5_XNSU like '%"+ALLTRIM(cSourceID)+"%') "
         ELSE
            cQuery += ")"
        ENDIF
    elseif  !Empty(ALLTRIM(cExtRef)) .OR. !Empty(ALLTRIM(cShipID)) .OR. !Empty(ALLTRIM(cPackID)) .OR.  !Empty(ALLTRIM(cSourceID)) 
         cQuery += " OR ( "
        If !Empty(ALLTRIM(cExtRef))
            cQuery += " SC5.C5_XNSU like '%"+ALLTRIM(cExtRef)+"%' "
        ELSE
            cQuery += " "
        ENDIF
        If !Empty(ALLTRIM(cShipID)) .and. !Empty(ALLTRIM(cExtRef))
            cQuery += " OR SC5.C5_XNSU like '%"+ALLTRIM(cShipID)+"%' "
        elseif !Empty(ALLTRIM(cShipID)) .and.  Empty(ALLTRIM(cExtRef))
            cQuery += " SC5.C5_XNSU like '%"+ALLTRIM(cShipID)+"%' "
        ELSE
            cQuery += " "    
        ENDIF
        If (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cExtRef)) ) .or.;
            (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cShipID)) ) 
            cQuery += " OR SC5.C5_XNSU like '%"+ALLTRIM(cPackID)+"%' "
        elseif !Empty(ALLTRIM(cPackID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cShipID))
            cQuery += " SC5.C5_XNSU like '%"+ALLTRIM(cPackID)+"%' "  
        ELSE
            cQuery += " " 
        ENDIF
        If  (!Empty(ALLTRIM(cSourceID)) .and. !Empty(ALLTRIM(cExtRef)) ) .or.;
            (!Empty(ALLTRIM(cSourceID)) .and. !Empty(ALLTRIM(cShipID)) )  .or.;
            (!Empty(ALLTRIM(cSourceID)) .and. !Empty(ALLTRIM(cPackID)) ) 
            cQuery += " OR SC5.C5_XNSU like '%"+ALLTRIM(cSourceID)+"%') "
        elseif !Empty(ALLTRIM(cSourceID)) .and. Empty(ALLTRIM(cPackID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cShipID))
            cQuery += " SC5.C5_XNSU like '%"+ALLTRIM(cSourceID)+"%') "
        ELSE
            cQuery += ")"     
        ENDIF
    Else
        cQuery += " "      
    Endif

    If !Empty(ALLTRIM(cOrder))
        cQuery += " OR (SC5.C5_XAUTHID like '%"+ALLTRIM(cOrder)+"%' "
        If !Empty(ALLTRIM(cExtRef))
            cQuery += " OR SC5.C5_XAUTHID like '%"+ALLTRIM(cExtRef)+"%' "
        ELSE
            cQuery += " " 
        ENDIF
        If !Empty(ALLTRIM(cShipID))
            cQuery += " OR SC5.C5_XAUTHID like '%"+ALLTRIM(cShipID)+"%' "
        ELSE
            cQuery += " " 
        ENDIF
        If !Empty(ALLTRIM(cPackID))
            cQuery += " OR SC5.C5_XAUTHID like '%"+ALLTRIM(cPackID)+"%' "
        ELSE
            cQuery += " " 
        ENDIF
        If !Empty(ALLTRIM(cSourceID))
            cQuery += " OR SC5.C5_XAUTHID like '%"+ALLTRIM(cSourceID)+"%') "
        ELSE
            cQuery += ")" 
        ENDIF
    elseif !Empty(ALLTRIM(cExtRef)) .OR. !Empty(ALLTRIM(cShipID)) .OR. !Empty(ALLTRIM(cPackID)) .OR.  !Empty(ALLTRIM(cSourceID)) 
        cQuery += " OR ( "
        If !Empty(ALLTRIM(cExtRef))
            cQuery += " SC5.C5_XAUTHID like '%"+ALLTRIM(cExtRef)+"%' "
        ELSE
            cQuery += " " 
        ENDIF
        If !Empty(ALLTRIM(cShipID)) .and. !Empty(ALLTRIM(cExtRef))
            cQuery += " OR SC5.C5_XAUTHID like '%"+ALLTRIM(cShipID)+"%' "
        elseif !Empty(ALLTRIM(cShipID)) .and. Empty(ALLTRIM(cExtRef))
            cQuery += " SC5.C5_XAUTHID like '%"+ALLTRIM(cShipID)+"%' "
        else
            cQuery += " " 
        ENDIF
        If (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cExtRef)) ) .or.;
            (!Empty(ALLTRIM(cPackID)) .and. !Empty(ALLTRIM(cShipID)) ) 
            cQuery += " OR SC5.C5_XAUTHID like '%"+ALLTRIM(cPackID)+"%' "
        elseif !Empty(ALLTRIM(cPackID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cShipID))
           cQuery += " SC5.C5_XAUTHID like '%"+ALLTRIM(cPackID)+"%' "
        ELSE
            cQuery += " " 
        ENDIF

        If (!Empty(ALLTRIM(cSourceID)) .and. !Empty(ALLTRIM(cExtRef)) ) .or.;
            (!Empty(ALLTRIM(cSourceID)) .and. !Empty(ALLTRIM(cShipID)) )  .or.;
            (!Empty(ALLTRIM(cSourceID)) .and. !Empty(ALLTRIM(cPackID)) ) 
            cQuery += " OR SC5.C5_XAUTHID like '%"+ALLTRIM(cSourceID)+"%') "
        elseif  !Empty(ALLTRIM(cSourceID)) .and. Empty(ALLTRIM(cPackID)) .and. Empty(ALLTRIM(cExtRef)) .and. Empty(ALLTRIM(cShipID))
            cQuery += " SC5.C5_XAUTHID like '%"+ALLTRIM(cSourceID)+"%') "
        else
            cQuery += ")"         
        ENDIF 
    Else
        cQuery += " "      
    Endif

    cQuery += ")"

    DBUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), (cAliasTRB), .F., .T.)

    (cAliasTRB)->(DBSelectArea(cAliasTRB))
    (cAliasTRB)->(DBGoTop())
    if !(cAliasTRB)->(EOF())
        cOrder :=  ALLTRIM((cAliasTRB)->C5_XPEDLV)
    endif 

    If Select(cAliasTRB) > 0
        (cAliasTRB)->(DBCloseArea())
    EndIf
ENDIF
return(cOrder)
