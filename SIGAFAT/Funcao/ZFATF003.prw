#INCLUDE "PROTHEUS.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} ZFATF003
    Chamada ponto de entrada pedido de venda para alertar LOTES antigos x LOTES NOVOS 
    @type  Function
    @author Allan R
    @since 17/06/2024
    /*/
User Function ZFATF003()

	Local lRet          := .T.				// Conteudo de retorno
	Local nOpcao        := PARAMIXB[1]	// Opcao de manutencao
	Local aLoteCTL      := aScan(aHeader,{|x| Alltrim(x[2])== "C6_LOTECTL"})	// Array com registros de adiantamentoc
	Local aProd         := aScan(aHeader,{|x| Alltrim(x[2])== "C6_PRODUTO"})
	Local cQuery        := ""
	Local nContI        := 0
    Local cSubject      := "Faturamento rebranding."
    Local cMensagem     := "Esse CLiente/Loja já possui faturamento(s) anterior(es) usando lote rebranding"
    Local cEmail        := SuperGetMv("DUX_EST005",.F.,"evandro.mariano@duxnutrition.com") 
    Local aFiles        := {}
    Local lMensagem     := .T.
    Local cRotina       := "ZFATF003"
    Local aArea         := GetArea()
    Local cAlias        := GetNextAlias()  

	If ( nOpcao == 3 .Or. nOpcao == 4 ) .AND. ALLTRIM(SC5->C5_ZZTIPCL) == 'J' 
		For nContI := 1 To Len(aCols)
			if !Empty(aCols[nConti][aLoteCTL]) .AND. !(Left(Alltrim(aCols[nConti][aLoteCTL]),1) == "R")
                
                If SELECT(cAlias) > 0
	               (cAlias)->(DbCloseArea())
                EndIf

                cQuery := " "
                cQuery += " SELECT TOP 1 * FROM "+RetSqlName("SD2")+" "
                cQuery += " WHERE D2_FILIAL = '" + FWxFilial("SD2") + "' "
                cQuery += " AND D2_CLIENTE = '"+AllTrim(SC5->C5_CLIENTE)+"' " 
                cQuery += " AND D2_LOJA = '"+AllTrim(SC5->C5_LOJACLI)+"' "
                cQuery += " AND D2_COD = '"+Alltrim(aCols[nContI][aProd])+"' " 
                cQuery += " AND SUBSTRING(D2_LOTECTL,1,1) = 'R' " 
                cQuery += " AND D_E_L_E_T_ = ' ' "
				
                DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

                DbSelectArea((cAlias))
                If !((cAlias)->(Eof()))
                    If MsgYesNo("[ ZFATF003 ] - Esse CLiente/Loja já possui faturamento(s) anterior(es) usando lote rebranding, deseja prosseguir ?  ", "Confirma?")
                        cMensagem := cMensagem + " - Produto: "+Alltrim(aCols[nContI][aProd])
                        U_ZGENMAIL(cSubject,cMensagem,cEMail,aFiles,lMensagem,cRotina)
                    Else 
                        lRet := .F.
                    EndIf   
                EndIf
                (cAlias)->(DbCloseArea())   
			EndIf
		Next nContI
	EndIf

    RestArea(aArea)
Return(lRet)


