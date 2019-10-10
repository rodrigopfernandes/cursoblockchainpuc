pragma solidity ^0.5.12;

contract Mutuo
{
    string mutuante;
    uint anosMutuante; 
    string mutuario;
    uint anosMutuario;
    uint valorMutuado;
    uint taxaJurosRemuneratorios;
    uint prazo;
    uint jurosRemuneratorios;
    uint multa;
    uint taxaJurosMoratorios;
    uint saldoDevedor;
    uint atraso;

    constructor (string memory nomeMutuante, uint idadeMutuante, string memory nomeMutuario, uint idadeMutuario, uint valor,
    uint percentualJuros, uint prazoEmMeses, uint percentualMulta, uint percentualMora) public 
    {
        require (idadeMutuante >= 16 && idadeMutuario >= 16, "Ambas as partes devem ser capazes");
        mutuante = nomeMutuante;
        anosMutuante = idadeMutuante;
        mutuario = nomeMutuario;
        anosMutuario = idadeMutuario;
        valorMutuado = valor;
        taxaJurosRemuneratorios = percentualJuros;
        prazo = prazoEmMeses;
        jurosRemuneratorios = ((valor * percentualJuros) / 100) * prazoEmMeses;
        multa = valor/percentualMulta;
        taxaJurosMoratorios = percentualMora;
        saldoDevedor = valorMutuado + jurosRemuneratorios; 
    }
    
    function totalDevido (uint mesesEmAtraso) public view returns (uint)
    {
        if (mesesEmAtraso > 0) {
            return saldoDevedor + multa + (((saldoDevedor * taxaJurosMoratorios)/100)*mesesEmAtraso);
        }
        if (mesesEmAtraso == 0) {
            return saldoDevedor;
        }
    }
    
    function totalJuros () public view returns (uint)
    {
        return jurosRemuneratorios;
    }
    
    function pagamento(uint valorPagamento, uint mesesEmAtraso) public returns (string memory)
    {
        if (mesesEmAtraso > 0 && valorPagamento <= saldoDevedor + multa + ((saldoDevedor * taxaJurosMoratorios)/100) * mesesEmAtraso &&
        atraso < 1) {
            saldoDevedor = (saldoDevedor + multa + (((saldoDevedor * taxaJurosMoratorios)/100)*mesesEmAtraso)) - valorPagamento;
            atraso++;
        }
        
        if (mesesEmAtraso > 0 && valorPagamento <= saldoDevedor + multa + ((saldoDevedor * taxaJurosMoratorios)/100) * mesesEmAtraso &&
        atraso >= 1) {
            saldoDevedor = (saldoDevedor + ((saldoDevedor * taxaJurosMoratorios)/100)*mesesEmAtraso) - valorPagamento;
        }
        
        if (mesesEmAtraso == 0 && valorPagamento <= saldoDevedor) {
            saldoDevedor = saldoDevedor - valorPagamento;
        }
        
        if (mesesEmAtraso > 0 && valorPagamento > saldoDevedor + multa + ((saldoDevedor * taxaJurosMoratorios)/100)*mesesEmAtraso) {
            string memory pagamentoMaior = "O valor de pagamento excede o valor devido";
            return pagamentoMaior;
        }
        
        if (mesesEmAtraso == 0 && valorPagamento > saldoDevedor) {
            string memory pagamentoMaior = "O valor de pagamento excede o valor devido";
            return pagamentoMaior;
        }
    }
    
    /*
    function pagamentoPrazo(uint valorPagamento) public returns (string memory)
    {
        if (valorPagamento > saldoDevedor) {
            string memory pagamentoMaior = "O valor pago excede o valor devido";
            return pagamentoMaior;
        }
        else saldoDevedor = saldoDevedor - valorPagamento;
    }
    
    function pagamentoForaPrazo(uint valorPagamentoForaPrazo, uint mesesEmAtraso) public returns (string memory)
    {
        if (valorPagamentoForaPrazo > saldoDevedor + multa + (taxaJurosMoratorios * mesesEmAtraso * saldoDevedor)) {
            string memory pagamentoMaior = "O valor pago excede o valor devido";
            return pagamentoMaior;
        }
        else saldoDevedor = saldoDevedor - valorPagamentoForaPrazo;
    }
    
    function aplicaMulta(uint mesesEmAtraso) public
    {
        require (mesesEmAtraso > 1);
        saldoDevedor = saldoDevedor + multa + (taxaJurosMoratorios * mesesEmAtraso * saldoDevedor);
    }
    */
}
