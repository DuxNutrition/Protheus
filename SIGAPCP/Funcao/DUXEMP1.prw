#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "Topconn.ch"
#include "totvs.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} DUXEMP
Função responsável pela alteração do empenho, baseado no que foi transferido para a produção 
tabela customizada (ZD3)
@type function
@version 12.1.2210  
@author vnucc
@since 12/19/2023
/*/
User Function DUXEMP1(cOrdSep,cOP,cCodTrf,nOpc)


	Local nX         := 0
	Local nY		 := 0
	Local nZ		 := 1
	Local aCab       := {}
	Local aLine      := {}
	Local aItens     := {}
	Local aAuto 	 := {}
	Local aLinha 	 := {}
	Local aLineEnder := {}
	Local aEnder     := {}
	Local aErro 	 := {}
	Local aLog		 := {}
	Local lExclui	 := .F.
	Local lMovto	 := .F.

	PRIVATE lMsErroAuto := .F.

	Private nQtdeOri	:= 0

	Default cOrdSep := ''
	Default cOP := ''
	Default cCodTrf := ''
	Default nOpc := 1

	//Processo de Execução Padrão : Deleta empenho > transfere > ajusta empenho
	if nOpc == 1
		Begin Transaction

			//Monta o cabeçalho com o número da OP que será alterada.
			//Necessário utilizar o índice 2 para efetuar a alteração.
			aCab := {{"D4_OP",cOP,NIL},;
				{"INDEX",2,Nil}}

			//Seta o índice da SDC
			SDC->(dbSetOrder(2))

			//Busca os empenhos da SD4 para alterar/excluir.
			SD4->(dbSetOrder(2))
			SD4->(dbSeek(xFilial("SD4")+PadR(cOP,Len(SD4->D4_OP))))

			While SD4->(!Eof()) .And. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4")+PadR(cOP,Len(SD4->D4_OP))
				//Adiciona as informações do empenho, conforme estão na tabela SD4.
				aLine := {}
				For nX := 1 To SD4->(FCount())
					aAdd(aLine,{SD4->(Field(nX)),SD4->(FieldGet(nX)),Nil})
				Next nX

				//Adiciona o identificador LINPOS para identificar que o registro já existe na SD4
				aAdd(aLine,{"LINPOS","D4_COD+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_OPORIG+D4_SEQ",;
					SD4->D4_COD,;
					SD4->D4_TRT,;
					SD4->D4_LOTECTL,;
					SD4->D4_NUMLOTE,;
					SD4->D4_LOCAL,;
					SD4->D4_OPORIG,;
					SD4->D4_SEQ})

				ZD3->(DbSetOrder(2)) //ZD3_FILIAL+ZD3_OP+ZD3_PROD+ZD3_LOTORI

				//Marca o empenho do produto "MP" como Excluído.

				If ZD3->(DbSeek(xFilial("SD4")+SD4->(D4_OP+D4_COD+D4_LOTECTL)))
					If  EMPTY(ZD3->ZD3_FLAG)
						aAdd(aLine,{"AUTDELETA","S",Nil})
					Endif
				EndIf

				//Adiciona as informações do empenho no array de itens.
				aAdd(aItens,aLine)

				//Próximo registro da SD4.
				SD4->(dbSkip())
			End

			//Adiciona um novo empenho
			/*aLine := {}
			aAdd(aLine,{"D4_OP"     ,"00130301001"     ,NIL})
			aAdd(aLine,{"D4_COD"    ,"MP04"            ,NIL})
			aAdd(aLine,{"D4_LOCAL"  ,"01"              ,NIL})
			aAdd(aLine,{"D4_DATA"   ,CtoD("17/09/2018"),NIL})
			aAdd(aLine,{"D4_QTDEORI",5                 ,NIL})
			aAdd(aLine,{"D4_QUANT"  ,5                 ,NIL})
			aAdd(aLine,{"D4_LOTECTL","L1"              ,NIL})
			aAdd(aLine,{"D4_TRT"    ,"004"             ,NIL})
			aAdd(aLine,{"D4_ROTEIRO","01"              ,NIL})
			aAdd(aItens,aLine)*/

			//Executa o MATA381, com a operação de Alteração.

			For nX := 1 to len(aItens)

				nY := aScan(aItens[nX],{|x| x[1] == 'AUTDELETA'})

				If nY > 0  
				 lExclui := .T. //Todos os itens serão excluídos
				else 
				 lExclui := .F. //Alguns itens não serão excluídos
				 Exit
				endif 

			Next nX

			If lExclui
				MSExecAuto({|x,y,z| mata381(x,y,z)},aCab,aItens,5)
			Else
				MSExecAuto({|x,y,z| mata381(x,y,z)},aCab,aItens,4)
			EndIf

			If lMsErroAuto
				aErro := MostraErro()
				lMsErroAuto := .F.
				DisarmTransaction()
				break
			Else
				//Alert("Manutenção no Ajuste de Empenho (Exclusão)")
			EndIf


			aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho


			ZD3->(DbSetOrder(2)) //ZD3_FILIAL+ZD3_OP+ZD3_PROD+ZD3_LOTORI
			ZD3->(DbSeek(xFilial("ZD3")+cOP))
			While ! ZD3->(Eof()) .and. ZD3->(ZD3_FILIAL+ZD3_OP==xFilial("ZD3")+cOP) //PERCORRE A ZD3 para verificar o que pode ser transferido 
				/*If ! ZD3->(ZD3_PROD+ZD3_LOTORI) == cProd+cLote
					ZD3->(DbSkip())
					Loop
				EndIf*/

				If Empty(ZD3->(ZD3_QTDORI-ZD3_QTDDES)) .AND. EMPTY(ZD3->ZD3_FLAG) // ja separado
					//Produto liberado para ser transferido 

					aLinha := {}
					//Origem
					SB1->(DbSeek(xFilial("SB1")+PadR(ZD3->ZD3_PROD, tamsx3('D3_COD') [1])))
					aadd(aLinha,{"ITEM",'00'+cvaltochar(nZ),Nil})
					aadd(aLinha,{"D3_COD", ZD3->ZD3_PROD, Nil}) //Cod Produto origem
					aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
					aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
					aadd(aLinha,{"D3_LOCAL", ZD3->ZD3_LOCORI, Nil}) //armazem origem
					aadd(aLinha,{"D3_LOCALIZ", ZD3->ZD3_ENDORI,Nil}) //Informar endereço origem

					//Destino

					aadd(aLinha,{"D3_COD", ZD3->ZD3_PROD, Nil}) //cod produto destino
					aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino
					aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
					aadd(aLinha,{"D3_LOCAL", ZD3->ZD3_LOCDES, Nil}) //armazem destino
					aadd(aLinha,{"D3_LOCALIZ", ZD3->ZD3_ENDDES,Nil}) //Informar endereço destino

					SB8->(dbSetOrder(3))
					SB8->(DbSeek(xFilial("SB8")+PadR(ZD3->ZD3_PROD, tamsx3('B8_PRODUTO')[1])+;
						PadR(ZD3->ZD3_LOCORI, tamsx3('B8_LOCAL')[1])+;
						PadR(ZD3->ZD3_LOTORI, tamsx3('B8_LOTECTL')[1])))
					aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
					aadd(aLinha,{"D3_LOTECTL", ZD3->ZD3_LOTORI, Nil}) //Lote Origem
					aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
					aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //data validade
					aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
					aadd(aLinha,{"D3_QUANT", ZD3->ZD3_QTDDES, Nil}) //Quantidade
					aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
					aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
					aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

					aadd(aLinha,{"D3_LOTECTL", ZD3->ZD3_LOTDES, Nil}) //Lote destino
					aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
					aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //validade lote destino
					aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

					aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
					aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino

					aAdd(aAuto,aLinha)
					nZ++


				EndIf
				ZD3->(DbSkip())

			end



			MSExecAuto({|x,y| mata261(x,y)},aAuto,3) //transferencia

			If lMsErroAuto

			MostraErro()
			lMsErroAuto := .F.

			aLog := GetAutoGRLog()

			cRet := ""

			For nX := 1 To Len(aLog)
				cRet += aLog[nX]
			Next

			//MEMOWRITE("C:\TEMP\log.txt",cRet)

			DisarmTransaction()
			break
			

			Else

			//Alert("Transferência realizada com sucesso !", "Aviso")

			Endif

			//Ajuste de Empenho desta OP 

			aCab := {{"D4_OP",cOP,NIL}}
			aItens := {}

			ZD3->(DbSetOrder(2)) //ZD3_FILIAL+ZD3_OP+ZD3_PROD+ZD3_LOTORI
			ZD3->(DbSeek(xFilial("ZD3")+cOP))
			While ! ZD3->(Eof()) .and. ZD3->(ZD3_FILIAL+ZD3_OP==xFilial("ZD3")+cOP) //PERCORRE A ZD3 para verificar o que pode ser transferido 
				/*If ! ZD3->(ZD3_PROD+ZD3_LOTORI) == cProd+cLote
					ZD3->(DbSkip())
					Loop
				EndIf*/



				If Empty(ZD3->(ZD3_QTDORI-ZD3_QTDDES)) .AND. EMPTY(ZD3->ZD3_FLAG)  // ja separado
					//Produto liberado para ser transferido 
					RecLock("ZD3",.F.)
					ZD3->ZD3_FLAG := 'P'
					ZD3->ZD3_DTPROC := dDataBase
					ZD3->(MsUnlock())
					//Busca Quantidade Origem de empenho e realiza o ajuste conforme necessário

					nQtdOri := retQtdCB8()
					If (nPos := Ascan(aItens,{ |x| x[2][2]+x[7][2] == ZD3->ZD3_PROD+ZD3->ZD3_LOTDES })) > 0
						aItens[nPos,5,2] += nQtdOri //D4_QTDEORI
						aItens[nPos,6,2] += nQtdOri //D4_QUANT
						aItens[nPos,10,2,1,2,2] += nQtdOri	//DC_QUANT
					Else
					//Adiciona novo empenho com endereço e lote
    					aLine := {}
    					aAdd(aLine,{"D4_OP"     ,cOP     		   	,NIL})
    					aAdd(aLine,{"D4_COD"    ,ZD3->ZD3_PROD      ,NIL})
    					aAdd(aLine,{"D4_LOCAL"  ,ZD3->ZD3_LOCDES    ,NIL})
    					aAdd(aLine,{"D4_DATA"   ,DDATABASE			,NIL})
    					aAdd(aLine,{"D4_QTDEORI",nQtdOri			,NIL})
    					aAdd(aLine,{"D4_QUANT"  ,nQtdOri   			,NIL})
    					aAdd(aLine,{"D4_LOTECTL",ZD3->ZD3_LOTDES    ,NIL})
    					aAdd(aLine,{"D4_TRT"    ,""             	,NIL})
    					aAdd(aLine,{"D4_ROTEIRO",""              	,NIL})

    					//Informações do endereço
    					aEnder     := {}
    					aLineEnder := {}
    					aAdd(aLineEnder,{"DC_LOCALIZ",ZD3->ZD3_ENDDES,Nil})
    					aAdd(aLineEnder,{"DC_QUANT"  ,nQtdOri,Nil})
    					//Primeiro endereço que será utilizado
    					aAdd(aEnder,aLineEnder)

						//Adiciona os endereços na linha do empenho
    					aAdd(aLine,{"AUT_D4_END",aEnder,Nil})
    					//Adiciona a linha do empenho no array de itens.
    					aAdd(aItens,aLine)
					EndIf


				EndIf
				ZD3->(DbSkip())

			end

			//Executa o MATA381, com a operação de Inclusão.
    		MSExecAuto({|x,y,z| mata381(x,y,z)}, aCab, aItens, 3)

			//Cria registros na ZD3 conforme o saldo necessário para retornar a produção.
			//faz um reclock true em cima do array aItens

    		If lMsErroAuto
        		//Se ocorrer erro.
        		MostraErro()
				DisarmTransaction()
				break
    		Else
				FWAlertSuccess("Movimentacao e Ajuste de Empenho realizados com sucesso !", "Aviso")
    		EndIf


		End Transaction
	endif 
	//Processo de retorno da produção, somente transferencia 
	if nOpc == 4
		Begin Transaction

			aadd(aAuto,{'',dDataBase}) //Cabecalho

			ZD3->(DbSetOrder(3)) //ZD3_FILIAL+ZD3_DOCMOV
			If ZD3->(DbSeek(xFilial("ZD3")+cCodTrf))
				While ! ZD3->(Eof()) .and. ZD3->(ZD3_FILIAL+ZD3_DOCMOV==xFilial("ZD3")+cCodTrf) //PERCORRE A ZD3 para verificar o que pode ser transferido 

					If Empty(ZD3->(ZD3_QTDORI-ZD3_QTDDES)) // ja separado
						//Produto liberado para ser transferido 
						If (EMPTY(ZD3->ZD3_FLAG)) //Sem Flag sendo possível para transferir

							RecLock("ZD3",.F.)
							ZD3->ZD3_FLAG := 'P'
							ZD3->ZD3_DTPROC := dDataBase
							ZD3->(MsUnlock())

							aLinha := {}
							//Origem
							SB1->(DbSeek(xFilial("SB1")+PadR(ZD3->ZD3_PROD, tamsx3('D3_COD') [1])))
							aadd(aLinha,{"ITEM",'00'+cvaltochar(nZ),Nil})
							aadd(aLinha,{"D3_COD", ZD3->ZD3_PROD, Nil}) //Cod Produto origem
							aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
							aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
							aadd(aLinha,{"D3_LOCAL", ZD3->ZD3_LOCORI, Nil}) //armazem origem
							aadd(aLinha,{"D3_LOCALIZ", ZD3->ZD3_ENDORI,Nil}) //Informar endereço origem

							//Destino

							aadd(aLinha,{"D3_COD", ZD3->ZD3_PROD, Nil}) //cod produto destino
							aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino
							aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
							aadd(aLinha,{"D3_LOCAL", ZD3->ZD3_LOCDES, Nil}) //armazem destino
							aadd(aLinha,{"D3_LOCALIZ", ZD3->ZD3_ENDDES,Nil}) //Informar endereço destino

							SB8->(dbSetOrder(3))
							SB8->(DbSeek(xFilial("SB8")+PadR(ZD3->ZD3_PROD, tamsx3('B8_PRODUTO')[1])+;
								PadR(ZD3->ZD3_LOCORI, tamsx3('B8_LOCAL')[1])+;
								PadR(ZD3->ZD3_LOTORI, tamsx3('B8_LOTECTL')[1])))
							aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
							aadd(aLinha,{"D3_LOTECTL", ZD3->ZD3_LOTORI, Nil}) //Lote Origem
							aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote origem
							aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //data validade
							aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia
							aadd(aLinha,{"D3_QUANT", ZD3->ZD3_QTDDES, Nil}) //Quantidade
							aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
							aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
							aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

							aadd(aLinha,{"D3_LOTECTL", ZD3->ZD3_LOTDES, Nil}) //Lote destino
							aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
							aadd(aLinha,{"D3_DTVALID", SB8->B8_DTVALID, Nil}) //validade lote destino
							aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

							aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
							aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino

							aAdd(aAuto,aLinha)
							nZ++
							lMovto := .T.
						EndIf
					EndIf
					ZD3->(DbSkip())

				end

				if lMovto
					MSExecAuto({|x,y| mata261(x,y)},aAuto,3) //transferencia
				endif 

				If lMsErroAuto

				//MostraErro()
				//lMsErroAuto := .F.

				aLog := GetAutoGRLog()

				cRet := ""

				For nX := 1 To Len(aLog)
					cRet += aLog[nX]
				Next

				//MEMOWRITE("C:\TEMP\log.txt",cRet)
				VTALERT("Falha na gravacao da transferencia, verifique EMPENHO e/ou LOTE VENCIDO","ERRO",.T.,4000,3) //"Falha na gravacao da transferencia"###"ERRO"

				DisarmTransaction()
				break

				Endif

				If	lMsErroAuto
					VTDispFile(NomeAutoLog(),.t.)
				Endif
			EndIf
		End Transaction

		If  lMovto .and. !lMsErroAuto
			VTALERT("Transferencia realizada com sucesso !", "Aviso",.T.,4000,3)
		Endif
			
	endif 

Return



Static Function  retQtdCB8()

	CB8->(dbSetOrder(4)) //CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
	If CB8->(dbSeek(xFilial("ZD3")+ZD3->(ZD3_ORDSEP+ZD3_ITEM+ZD3_PROD+ZD3_LOCORI+ZD3_ENDORI+ZD3_LOTORI)))
		nQtdOri := CB8->CB8_QTDORI
	Else 
		MSGINFO("Não foi possível localizar a quantidade origem deste empenho na Ordem de Separação: " + allttrim(ZD3_ORDSEP) +;
		" para evitar problemas de empenhos da produção, o processo estará sendo cancelado.")
		DisarmTransaction()
	Endif
	
Return nQtdOri
