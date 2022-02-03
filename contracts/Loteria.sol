pragma solidity ^0.4.0;

contract Loteria {
    address dono;
    string nomeDoDono;
    uint inicio;
    
    struct Sorteio {
        uint data;
        uint numeroSorteado;
        address remetente;
        uint countPalpites;
    }
    
    Sorteio[] sorteios;
    
    mapping (address => uint) palpites;
    address[] palpiteiros;
    address[] ganhadores;
    
    constructor(string _nome) public{
        dono = msg.sender;
        nomeDoDono = _nome;
        inicio = now;
        
    }
    
    modifier apenasDono() {
        require (msg.sender == dono, "Apenas o dono do contrato pode fazer isso.");
        _;
        
    }
    
    modifier excetoDono() {
        require (msg.sender != dono, "O dono do contrato não pode fazer isso.");
        _;
    }
    
    event TrocoEnviado(address pagante, uint troco);
    event PalpiteRegistrado(address remetente, uint palpite);
    
    function enviarPalpite(uint palpiteEnviado) payable public excetoDono() {
        require (palpiteEnviado >= 1 && palpiteEnviado <= 4, "Você tem que escolher um número entre 1 e 4");
        
        require (palpites[msg.sender] == 0, "Apenas um palpite pode ser enviado por sorteio.");
        
        require (msg.value >= 1 ether, "A taxa para palpitar é 1 ether");
        //calcula e envia troco
        uint troco = msg.value - 1 ether;
        if (troco > 0){
            msg.sender.transfer(troco);
            emit TrocoEnviado(msg.sender, troco);
        }
        
        //registra o palpite
        palpites[msg.sender] = palpiteEnviado;
        palpiteiros.push(msg.sender);
        emit PalpiteRegistrado(msg.sender, palpiteEnviado);
        
        }
        
        function verificaMeuPalpite() view public returns (uint palpite){
            require (palpites[msg.sender] > 0, "Você não tem palpite ainda para esse sorteio");
            return palpites[msg.sender];
        }
        
        function contarPalpites() view public returns(uint count){
            return palpiteiros.length;
        }
        
        event SorteioPostado(uint resultado);
        event PremiosEnviados(uint premioTotal, uint premioIndividual);
        
        function sortear() public apenasDono() returns(uint8 _numeroSorteado){
            require (now > inicio + 1 minutes, "O sorteio só pode ser feito depois de um intervalo de 1 min");
            require (palpiteiros.length >= 1, "Um minimo de 1 pessoa é exigida para sortear");
            
            //sortear um numeroSorteado
            uint8 numeroSorteado = 2;
            
            sorteios.push(Sorteio({
                data: now,
                numeroSorteado: numeroSorteado,
                remetente: msg.sender,
                countPalpites: palpiteiros.length
                
            }));
            emit SorteioPostado(numeroSorteado);
        
            //procura ganhadores
        
            for (uint p=0; p < palpiteiros.length; p++){
                address palpiteiro = palpiteiros[p];
                if (palpites[palpiteiro] == numeroSorteado){
                    ganhadores.push(palpiteiro);
                }
                delete palpites[palpiteiro];
            
            }
        
            uint premioTotal = address(this).balance;
        
            if (ganhadores.length > 0){
                uint premioIndividual = premioTotal / ganhadores.length;
                for(p=0;p<ganhadores.length;p++){
                    ganhadores[p].transfer(premioIndividual);
                }
                emit PremiosEnviados(premioTotal, premioIndividual);
            }
            
            //resetar o SorteioPostado
            delete palpiteiros;
            delete ganhadores;
            
            return numeroSorteado;
    
            }   
            
        function kill () public apenasDono(){
            dono.transfer(address(this).balance);
        }
        
    }