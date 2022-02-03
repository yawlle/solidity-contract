pragma solidity ^0.4.0;

contract GuardaLoteria {
    uint16 numeroSorteado; //0 a 65525
    uint numeroSorteadoGrande; 
    
    uint16 contadorDeSorteios;
    address dono;
    
    constructor(uint16 numeroInicial) public{
        numeroSorteado = numeroInicial;
        contadorDeSorteios = 65530;
        dono = msg.sender;
    }
    
    function set(uint enviado) public payable {
        numeroSorteadoGrande = enviado;
        numeroSorteado = uint16(enviado);
        
        require (msg.sender == dono, "apenas o dono pode setar");
        require (contadorDeSorteios + 1 > contadorDeSorteios, "overflow no contador");
        require (numeroSorteado == numeroSorteadoGrande, "overflor no numero");
        
        contadorDeSorteios++;
    }
    
    function get() public view returns (uint _numero, uint _numeroSorteadoGrande, uint16 _contador, address _dono, address _contrato, uint _saldo){
        return (numeroSorteado,
        numeroSorteadoGrande,
        contadorDeSorteios,
        dono,
        this,
        address(this).balance);
    }
}