pragma solidity ^0.5.11;

// Contrato de locação
contract Aluguel
{
    string public locador;
    string public locatario;
    uint256 private valor;
    uint256 constant numeroMaximoLegalDeAlugueisParaMulta = 3;
    
    constructor(string memory nomeLocador, string memory nomeLocatario, uint256 valorDoAluguel) public
    {
        locador = nomeLocador;
        locatario = nomeLocatario;
        valor = valorDoAluguel;
    }
    
    function valorAtualDoAluguel() public view returns (uint256) 
    {
        return valor;
    }
    
    function simulaMulta (uint256 mesesRestantes, uint256 totalMesesContrato) public view returns (uint256 valorMulta)
    {
        valorMulta = valor*numeroMaximoLegalDeAlugueisParaMulta;
        valorMulta = valorMulta/totalMesesContrato;
        valorMulta = valorMulta*mesesRestantes;
        return valorMulta;
    }
    
    function reajustaAluguel(uint256 percentualReajuste) public 
    {
        if (percentualReajuste > 20)
        {
            percentualReajuste = 20;
        }
        uint256 valorDoAcrescimo = 0;
        valorDoAcrescimo = ((valor*percentualReajuste)/100);
        valor = valor + valorDoAcrescimo;
    }
    
    function aditamentoValorAluguel (uint256 valorCerto) public
    {
        valor = valorCerto;
    }
    
    function aplicaMulta(uint256 mesesRestantes, uint256 percentual) public
    {
        require (mesesRestantes<30, "Período de contrato inválido");
        for (uint i=1; i<mesesRestantes; i++)
        {
            valor = valor+((valor*percentual)/100);
        }
        
    }
        
    
}   
