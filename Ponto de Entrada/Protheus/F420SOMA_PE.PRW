#include "Protheus.ch"        

/*/{Protheus.doc} F420SOMA
O ponto de entrada F420SOMA tem como finalidade retornar o saldo para o titulo na geracao do arquivo CNAB.
@type function
@version 12.1.2310
@author TOTVSIP | Alexandre Luis Eugenio
@since 31/07/2024
@return numeric, saldo do titulo
/*/
User Function F420SOMA()

    Local   lCalcula := .T. //Rotina que irá marcar se calcula ou não a rotina

    Private _valor
    Private _abat
    Private _juros

    if Empty(_cChavSpag)
        //Acrescenta a chave na variável
        _cChavSpag  := (SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_PARCELA+SE2->E2_FORNECE+SE2->E2_LOJA)
        lCalcula    := .T.
    else
        //Caso a chave já exista no fonte, não será calculado novamente, pois na FINA420 o calculo passa duas vezes nesse fonte
        if (SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_PARCELA+SE2->E2_FORNECE+SE2->E2_LOJA) $ _cChavSpag
            lCalcula := .F.
        else
            _cChavSpag  += "/"+(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_PARCELA+SE2->E2_FORNECE+SE2->E2_LOJA)
            lCalcula    := .T. 
        endif
    endif
        
    if lCalcula
        _Abat  := somaabat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,'P',SE2->E2_MOEDA,DDATABASE,SE2->E2_FORNECE,SE2->E2_LOJA)
        _Abat  += SE2->E2_DECRESC 
        _Juros := (SE2->E2_ZZMULTA + SE2->E2_ZZJUROS)
        _Valor := SE2->E2_SALDO - _Abat + _Juros

        //-- Variavel publica declarada no ponto de entrada fa420cri()
        _nTotEnt   += SE2->E2_ZZVLENT
        _nTotAbat  += SE2->E2_DECRESC
        _nTotAcres += _Juros
        _nTotGps   += (SE2->E2_SALDO - SE2->E2_ZZVLENT)
    else
        //Preencho zero para não dar erro caso já tenha sido calcuload o valor desse título.
        _valor := 0
    endif

Return _valor
