pragma solidity 0.5.12;

contract Mutuo
{
    address payable carteiraMutuante;
    address payable carteiraMutuario;
    address payable carteiraCaucao;
    uint valorMutuado;
    uint taxaJurosRemuneratorios;
    uint vencimento;
    uint periodoContratado;
    uint jurosRemuneratorios;
    uint multa;
    uint taxaJurosMoratorios;
    uint caucao;
    uint saldoDevedor;
    uint totalJuros;
    bool pago;
    uint atraso;
    uint constant segundosMes = 2592000;
    
    constructor
    (address payable contaMutuante,
    address payable contaMutuario,
    uint percentualJurosMes,
    uint timestampVencimento,
    uint percentualCaucao,
    uint percentualMulta,
    uint percentualMora) 
    public payable
    {
        require (msg.value > 0 && contaMutuante == msg.sender,
        "Contrato deve ser publicado pelo mutuante com o valor emprestado");
        carteiraMutuante = contaMutuante;
        carteiraMutuario = contaMutuario; 
        valorMutuado = msg.value;
        taxaJurosRemuneratorios = percentualJurosMes;
        vencimento = timestampVencimento;
        multa = msg.value / percentualMulta;
        taxaJurosMoratorios = percentualMora;
        caucao = ((msg.value * percentualCaucao) / 100);
        periodoContratado = timestampVencimento - now;
        jurosRemuneratorios = (msg.value * ((percentualJurosMes / 2592000) / 100)) * periodoContratado;
        saldoDevedor = msg.value + jurosRemuneratorios;
        totalJuros = jurosRemuneratorios;
        
        if (percentualCaucao == 0)
        {
            carteiraMutuario.transfer(msg.value);
        }
    }
    
    function valorCaucao () public view returns (uint)
    {
        return caucao;
    }
    
    function depositarCaucao () public payable
    {
        require (msg.value == caucao,
        "Valor da caução deve ser exatamente o valor estipulado na publicação do contrato");
        carteiraMutuario.transfer(address(this).balance - msg.value);
        carteiraCaucao = msg.sender;

    }
    
    function calculaTotalDevido () public view returns (uint)
    {
        if (now > vencimento)
        {
            return saldoDevedor + ((now - vencimento) * (valorMutuado * (taxaJurosRemuneratorios / 2592000) / 100) *
            (valorMutuado * (taxaJurosMoratorios / 2592000) / 100)) + multa - caucao;
        }
        
        else
        {
            return saldoDevedor;
        }
    }
    
    function jurosDevidos () public view returns (uint)
    {
        if (now < vencimento) 
        {
            return jurosRemuneratorios;
        }
        
        else
        {
            return totalJuros;
        }
        
    }
    
    function pagamento() public payable
    {
        if (now <= vencimento)
        {
            require (msg.value == saldoDevedor, "Pagamento deve ser exatamente o valor devido");
            saldoDevedor -= msg.value;
            carteiraMutuante.transfer(msg.value);
            carteiraCaucao.transfer(address(this).balance);
            pago = true;
        }
        
        else
        {
            for (uint i = 0; i < periodoContratado; i++ )
            {
                saldoDevedor += (valorMutuado * (taxaJurosRemuneratorios  / 2592000) / 100) +
                (valorMutuado * (taxaJurosMoratorios / 2592000) / 100);
            }
            
            saldoDevedor += multa - caucao;
            require (msg.value == saldoDevedor, "Pagamento deve ser exatamente o valor devido");
            saldoDevedor -= msg.value;
            carteiraMutuante.transfer(address(this).balance);
            pago = true;
        }
        
    }
    
    function conferirPagamento () public view returns (bool)
    {
        return pago;
    }
}
