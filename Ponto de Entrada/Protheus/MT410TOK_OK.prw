#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT410TOK
Ponto de entrada para efetuar validaÃ§Ãµes na inclusÃ£o de pedido de 
vendas.
@version P12.1.27
@ return lRet
/*/
//-------------------------------------------------------------------
User Function MT410TOK()
	
    Local lRet 	:= .t.
    Local aParam := PARAMIXB
    Local cPedidoPJ := M->C5_ZZNUMPJ

    Local nPosAjust 	:= aScan(aHeader ,{ |x| AllTrim(x[2])== "C6_ZAJUSIT"	})
    Local nPosBloq		:= aScan(aHeader ,{ |x| AllTrim(x[2])== "C6_ZBLOQ"	    })
    Local nPosRecno		:= aScan(aHeader ,{ |x| AllTrim(x[2])== "C6_REC_WT"	    })
    Local nPosResi		:= aScan(aHeader ,{ |x| AllTrim(x[2])== "C6_BLQ"	    })
    Local nI            := 0
    Local nOper         := PARAMIXB[1]

    
    _aItLibC6 := {}
    
    If !(IsInCallStack("U_WSVTEX46") .Or. "WSVTEX" $ FunName())
    
        // Validacoes Universais TOTVS IP
        If ExistBlock("TIPAC008",.F.,.T.)
            lRet := ExecBlock("TIPAC008",.F.,.T.,{})
        Endif
        
        // Validacao do campo C5_ZZNUMPJ
        If ExistBlock("DUXFAT02") .AND. INCLUI .AND. !Empty(cPedidoPJ)
            lRet:=ExecBlock("DUXFAT02", .F., .F., aParam)
        EndIf

        //Alimenta váriavel publica para liberação/ eliminação de residuos. 
        // Alterado em 17/04/2023 Daniel Neumann - CI Result
        If lRet 	
            SA1->(DbSetOrder(1))
            If nOper == 4 .And. SC5->C5_TIPO == "N" /*.And. SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)) .And. SA1->A1_PESSOA == 'J' */ .And. VALTYPE( _aItLibC6 ) == "A"
            
                For nI := 1 To Len(aCols)

                    If !aCols[nI][(Len(aHeader) + 1)] .And. aCols[nI][nPosResi] != "R" .And. aCols[nI][nPosRecno] > 0

                        AADD(_aItLibC6, {aCols[nI][nPosRecno], aCols[nI][nPosBloq], aCols[nI][nPosAjust]})  //_aItLibC6 declarada como publica no PE M410GET
                    EndIf 
                Next nI 
            EndIf 
        EndIf

    EndIf

Return lRet
