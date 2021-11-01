

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'GameObject.sol';
import 'BaseStation.sol';
import 'IDyingFromBase.sol';

contract MilitaryUnit is GameObject,IDyingFromBase {
    
    
    uint public attackPower;

    //ссылка на базу
    IAddRemove public _bs;
    
    
    // атаковать противника по адресу
    function Attack(IGettingAnAttack enemy) public checkOwnerAndAccept{
        enemy.GetAttack(attackPower, this);
    }

    // юнит получает очки защиты в обычном порядке
    function GetArmor(uint value) override public checkOwnerAndAccept {
        armor+=value*1;
    }
    
    // гибель от атаки
    function sendAllAndDestroyMe(address dest) internal override  {

        _bs.RemoveMilitaryUnitOnBase(this);
        dest.transfer(1, false, 160);

    }

    // гибель от базы
    function destroyByBase() external override  {

        require(msg.sender==_bs , 500);
        address dest = _bs;
        dest.transfer(1, false, 160);

    }
    

}
