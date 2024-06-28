#include 'totvs.ch'
/*/{Protheus.doc} NextCod
	
	Função para codificação sequencial 

@author CI RESULT - Luciano Corrêa
@since 21/05/2013
@version Protheus 12.1.33
@param cAlias, character, Alias da Tabela
@param cContraDom, character, Contradomínio do Gatilho (uso em MVC)
@return cRet, character, Dado para o Contradomínio do Gatilho
@example

	Gatilho A1_CGC -> A1_COD -> U_NextCod("SA1") se Empty(M->A1_CGC)
	Gatilho A1_CGC -> A1_LOJA -> U_NextCod("SA1", "A1_LOJA") se Empty(M->A1_CGC)
	Gatilho A2_CGC -> A2_COD -> U_NextCod("SA2") se Empty(M->A2_CGC)
	Gatilho A2_CGC -> A2_LOJA -> U_NextCod("SA1", "A2_LOJA") se Empty(M->A1_CGC)
	Gatilho B1_TIPO -> B1_COD -> U_NextCod("SB1")
	Gatilho B1_GRUPO -> B1_COD -> U_NextCod("SB1")
	Gatilho B1_ZTAM -> B1_COD -> U_NextCod("SB1")
	Gatilho B1_ZSAB -> B1_COD -> U_NextCod("SB1")
/*/
User Function NextCod( cAlias, cContraDom )

	Local cRet				:= ''
	Local aArea				:= GetArea()

	Default cContraDom		:= ""

	If cAlias == 'SA1'
		
		If Empty( M->A1_CGC )	// clientes estrangeiros...

			BeginSql Alias 'SA1TMP'

			select max( A1_COD ) A1_COD
			from %Table:SA1% SA1
			where SA1.%NotDel%
			 and A1_FILIAL = %xFilial:SA1%
			 and A1_COD between 'EX' and 'EXZZZZZZZ'

			EndSql

			M->A1_COD	:= 'EX' + StrZero( Val( SubStr( SA1TMP->A1_COD, 3 ) ) + 1, 7 )
			M->A1_LOJA	:= '0001'
			
			SA1TMP->( dbCloseArea() )
			
		ElseIf Len( AllTrim( M->A1_CGC ) ) == 11	// pessoa física...
			
			// se estiver configurado para permitir duplicidade de CPF, deve tratar a sequência da loja...

			BeginSql Alias 'SA1TMP'

			select max( A1_COD ) A1_COD, max( A1_LOJA ) A1_LOJA
			from %Table:SA1% SA1
			where SA1.%NotDel%
			 and A1_FILIAL = %xFilial:SA1%
			 and A1_CGC = %Exp:M->A1_CGC%
			
			EndSql

			M->A1_COD	:= Left( M->A1_CGC, 9 )
			M->A1_LOJA	:= StrZero( Val( SA1TMP->A1_LOJA ) + 1, 4 )
			
			SA1TMP->( dbCloseArea() )
			
		Else
			M->A1_COD	:= SubStr( M->A1_CGC, 1, 8 )
			M->A1_LOJA	:= SubStr( M->A1_CGC, 9, 4 )
		EndIf

		// em formulário MVC não atualizou outros campos além do retorno do gatilho...
		If ValType( cContraDom ) == 'C' .and. cContraDom == 'A1_LOJA'
			
			cRet	:= M->A1_LOJA
		Else		
			cRet	:= M->A1_COD
		EndIf

	ElseIf cAlias == 'SA2'
		
		If Empty( M->A2_CGC )	// clientes estrangeiros...

			BeginSql Alias 'SA2TMP'

			select max( A2_COD ) A2_COD
			from %Table:SA2% SA2
			where SA2.%NotDel%
			 and A2_FILIAL = %xFilial:SA2%
			 and A2_COD between 'EX' and 'EXZZZZZZZ'
			
			EndSql

			M->A2_COD	:= 'EX' + StrZero( Val( SubStr( SA2TMP->A2_COD, 3 ) ) + 1, 7 )
			M->A2_LOJA	:= '0001'
			
			SA2TMP->( dbCloseArea() )
			
		ElseIf Len( AllTrim( M->A2_CGC ) ) == 11	// pessoa física...
			
			// se estiver configurado para permitir duplicidade de CPF, deve tratar a sequência da loja...

			BeginSql Alias 'SA2TMP'

			select max( A2_COD ) A2_COD, max( A2_LOJA ) A2_LOJA
			from %Table:SA2% SA2
			where SA2.%NotDel%
			 and A2_FILIAL = %xFilial:SA2%
 			 and A2_CGC = %Exp:M->A2_CGC%

			EndSql

			M->A2_COD	:= Left( M->A2_CGC, 9 )
			M->A2_LOJA	:= StrZero( Val( SA2TMP->A2_LOJA ) + 1, 4 )
			
			SA2TMP->( dbCloseArea() )
			
		Else
			M->A2_COD	:= SubStr( M->A2_CGC, 1, 8 )
			M->A2_LOJA	:= SubStr( M->A2_CGC, 9, 4 )
		EndIf
		
		// em formulário MVC não atualizou outros campos além do retorno do gatilho...
		If ValType( cContraDom ) == 'C' .and. cContraDom == 'A2_LOJA'
			
			cRet	:= M->A2_LOJA
		Else		
			cRet	:= M->A2_COD
		EndIf
		
	ElseIf cAlias == 'SB1'
		
		If M->B1_TIPO == 'PA'
			IF cContraDom=='B1_XCODPAI'

				M->B1_XCODPAI	:= M->B1_GRUPO + M->B1_ZTAM
				cRet			:= M->B1_XCODPAI

			ElseIF cContraDom=='B1_XNIVEL'

				M->B1_XNIVEL	:= GetPrdPai(M->B1_XCODPAI)
				cRet			:= M->B1_XNIVEL

			Else

				M->B1_COD	:= M->B1_GRUPO + M->B1_ZTAM + M->B1_ZSAB
				cRet		:= M->B1_COD

			EndIF

		Else

			IF cContraDom=='B1_XCODPAI'

				cRet			:= ""

			ElseIF cContraDom=='B1_XNIVEL'

				cRet			:= ""

			Else

				BeginSql Alias 'SB1TMP'

				select max( B1_COD ) B1_COD
				from %Table:SB1% SB1
				where SB1.%NotDel%
				and B1_FILIAL = %xFilial:SB1%
				and B1_TIPO <> 'PA'
				and B1_GRUPO = %Exp:M->B1_GRUPO%
				and (B1_GRUPO <> '8401' or B1_COD < '8401999') //Add por Paulo Rafael em 10-04-2023
				
				EndSql
				M->B1_COD	:= PadR( M->B1_GRUPO + StrZero( Val( SubStr( SB1TMP->B1_COD, 5 ) ) + 1, 4 ), Len( M->B1_COD ) )
				//M->B1_COD	:= M->B1_GRUPO + StrZero( Val( SubStr( SB1TMP->B1_COD, 5 ) ) + 1, 4 ) //comentado por Paulo Rafael em 10-04-2023
				cRet		:= M->B1_COD

				SB1TMP->( dbCloseArea() )
			EndIF
		EndIf

	EndIf

	RestArea( aArea )

Return cRet

Static Function GetPrdPai(cCodPai)

Local cNivel	:= '2'

Default cCodPai := ""

	IF !Empty(cCodPai)

		BeginSql Alias 'SB1TMP'

			select count( * ) QUANTIDADE
			from %Table:SB1% SB1
			where SB1.%NotDel%
			and B1_FILIAL = %xFilial:SA1%
			and B1_XCODPAI = %exp:Alltrim(cCodPai)%

		EndSql

		IF SB1TMP->QUANTIDADE == 0 
			cNivel 	:= '1'
		else
			cNivel	:= '2'
		EndIF
				
		SB1TMP->( dbCloseArea() )
	EndIF

Return(cNivel)


