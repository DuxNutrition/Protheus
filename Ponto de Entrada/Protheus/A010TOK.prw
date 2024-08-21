#include 'protheus.ch'
/*/{Protheus.doc} A010TOK
	
	Ponto de Entrada para validar inclus�o/altera��o de Produtos
	- Verifica preenchimento de campos obrigat�rios conforme o Tipo de Produto 
	- Executa outras valida��es Universais TOTVS IP

@author CI RESULT - Luciano Corr�a
@since 20/03/2007
@version Protheus 12.1.33
@param
@return lRet, logical, Indica se passou por todas valida��es
@example
/*/
User Function A010TOk()

	Local lRet	:= .T.
	Local cCpoObrig	:= ''
	Local nCampo
	Local aCampos	:= StrToArray( GetMv( 'CI_OBRIG' + M->B1_TIPO, .F., '' ), '/' )

	For nCampo := 1 to Len( aCampos )
		
		If SB1->( FieldPos( aCampos[ nCampo ] ) ) > 0 .and. ;
			Empty( &( 'M->' + aCampos[ nCampo ] ) )
			
			cCpoObrig	+= RetTitle( aCampos[ nCampo ] ) + Chr(10)
		EndIf
		
	Next nCampo

	If !Empty( cCpoObrig )
		
		Help( " ", 1, "OBRIGAT",, cCpoObrig, 4 )
		
		lRet	:= .F.
	EndIf

	// 17/01/2023 - Valida��es Universais TOTVS IP
	if (!IsBlind())
		If ExistBlock("TIPAC005",.F.,.T.)
			
			lRet := ExecBlock("TIPAC005",.F.,.T.,{})
		Endif
	endif 

Return lRet 
