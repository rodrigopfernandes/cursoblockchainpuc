pragma solidity 0.5.12;

contract Mutuo
{
    address payable contrato;
    string mutuante;
    uint anosMutuante;
    address payable carteiraMutuante;
    string mutuario;
    uint anosMutuario;
    address payable carteiraMutuario;
    address payable carteiraCaucao;
    uint valorMutuado;
    uint taxaJurosRemuneratorios;
    uint prazo;
    uint jurosRemuneratorios;
    uint multa;
    uint taxaJurosMoratorios;
    uint caucao;
    uint saldoDevedor;
    uint totalJuros;
    uint atraso;
    
    constructor
    (string memory nomeMutuante,
    uint idadeMutuante,
    address payable contaMutuante,
    string memory nomeMutuario,
    uint idadeMutuario,
    address payable contaMutuario,
    uint percentualJuros,
    uint prazoEmMeses,
    uint percentualCaucao,
    uint percentualMulta,
    uint percentualMora) 
    public payable
    {
        require (idadeMutuante >= 16 && idadeMutuario >= 16 && msg.value > 0 && contaMutuante == msg.sender,
        "Ambas as partes devem ser capazes e contrato deve ser implantado pelo mutuante com o valor emprestado");
        mutuante = nomeMutuante;
        anosMutuante = idadeMutuante;
        carteiraMutuante = contaMutuante;
        mutuario = nomeMutuario;
        anosMutuario = idadeMutuario;
        carteiraMutuario = contaMutuario; 
        valorMutuado = msg.value;
        taxaJurosRemuneratorios = percentualJuros;
        prazo = prazoEmMeses;
        multa = msg.value/percentualMulta;
        taxaJurosMoratorios = percentualMora;
        caucao = ((msg.value * percentualCaucao) / 100);
        jurosRemuneratorios = ((msg.value * percentualJuros) / 100) * prazoEmMeses;
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
        require (msg.value == caucao, "Valor da caução deve ser exatamente o valor estipulado no lançamento do contrato");
        carteiraCaucao = msg.sender;
    }
    
    function totalDevido (uint mesesEmAtraso) public view returns (uint)
    {
        if (mesesEmAtraso > 0)
        {
             return (mesesEmAtraso * (((valorMutuado * taxaJurosRemuneratorios) / 100) + ((valorMutuado * taxaJurosMoratorios) / 100))) + multa - caucao;
        }
        
        else
        {
            return saldoDevedor;
        }
    }
    
    function jurosDevidos (uint mesesEmAtraso) public view returns (uint)
    {
        if (mesesEmAtraso == 0) 
        {
            return jurosRemuneratorios;
        }
        
        else
        {
            return totalJuros;
        }
        
    }
    
    function pagamento(uint mesesEmAtraso) public payable returns (string memory)
    {
        if (mesesEmAtraso == 0)
        {
            require (msg.value == saldoDevedor, "Pagamento deve ser exatamente o valor devido");
            saldoDevedor = saldoDevedor - msg.value;
            carteiraMutuante.transfer(msg.value);
            carteiraCaucao.transfer(address(this).balance);
        }
        
        else
        {
            for (uint i = 0; i < mesesEmAtraso; i++ )
            {
                saldoDevedor += ((valorMutuado * taxaJurosRemuneratorios) / 100) + ((valorMutuado * taxaJurosMoratorios) / 100);
            }
            
            saldoDevedor += multa - caucao;
            require (msg.value == saldoDevedor, "Pagamento deve ser exatamente o valor devido");
            saldoDevedor -= msg.value;
            carteiraMutuante.transfer(msg.value + address(this).balance);
        }
        
    }
}
