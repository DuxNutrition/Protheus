#include "protheus.ch"

/*
=====================================================================================
Programa.: AfterLogin
Autor....: Evandro A Mariano dos Santos
Data.....: 15/07/2024
Descricao / Objetivo: Ponto de Entrada para adicionar relatorio personalizado.
                        da Ordem de Serviço.
Doc. Origem:
Solicitante: Compras
Uso......: Dux
Obs......:
=====================================================================================
*/
 
User Function AfterLogin()

//Local cId	        := ParamIXB[1]
//Local cNome         := ParamIXB[2]

	If !( IsBlind() ) //interface com o usuário

        /*If FwCodEmp() == "2020" //GRUPO BARUERI

            If ( "_PRD" $ AllTrim(GetEnvServer()) .And. !( "SP" $ AllTrim(GetEnvServer()) ) )

                Final("Grupo Barueri acessar o ambiente ABDHDU_PRD_CAOASP")

            EndIf
            
        ElseIf FwCodEmp() == "2010" //GRUPO MONTADORA

            If ( "_PRD" $ AllTrim(GetEnvServer()) .And. "SP" $ AllTrim(GetEnvServer()) ) 
                
                Final("Grupo Montadora acessar o ambiente ABDHDU_PRD")

            EndIf

        EndIf*/
        
        SetKey( K_SH_F2, {|| u_ZCFGF002() } )
                    
    EndIf
     
Return()
