

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'GameObject.sol';
import 'BaseStation.sol';

contract MilitaryUnit is GameObject {
    
    //конструктор для военного юнита
    uint public attackPower;

    constructor(BaseStation bs) public {
        // Check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and
        // message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        // The current smart contract agrees to buy some gas to finish the
        // current transaction. This actions required to process external
        // messages, which bring no value (henceno gas) with themselves.
        tvm.accept();

        // Вызов у станции функции добавления юнита
        bs.AddMilitaryUnitOnBase(this);

        
    }
    function Attack(IGettingAnAttack enemy) public checkOwnerAndAccept{
        enemy.GetAttack(attackPower, this);
    }
    // юнит получает очки защиты в обычном порядке
    function getArmor(uint value) override internal {
        armor+=value*1;
    }
    

}
