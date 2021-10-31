

import 'MilitaryUnit.sol';
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;



contract Archer is MilitaryUnit {
    
    
    function getArmor(uint value) override internal {
        armor+= value;
    }

    function getAttackPower(uint value) internal {
        attackPower = value;
    }

}