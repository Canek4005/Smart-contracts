

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'GameObject.sol';
import 'BaseStation.sol';

contract MilitaryUnit is GameObject {
    
    //конструктор для военного юнита
    uint public attackPower;

    

    function Attack(IGettingAnAttack enemy) public checkOwnerAndAccept{
        enemy.GetAttack(attackPower, this);
    }
    // юнит получает очки защиты в обычном порядке
    function getArmor(uint value) override public {
        armor+=value*1;
    }
    

}
