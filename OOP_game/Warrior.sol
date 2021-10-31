

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'MilitaryUnit.sol';

contract Warrior is MilitaryUnit {
    
    
   

    function getAttackPower(uint value) internal {
        attackPower = value;
    }

    function getArmor(uint value) override internal {
        armor+=value*1;
    }

}
