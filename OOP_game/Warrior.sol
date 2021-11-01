

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'MilitaryUnit.sol';



contract Warrior is MilitaryUnit {
    
    constructor(IAddRemove bs) public {
        // Check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and
        // message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        // The current smart contract agrees to buy some gas to finish the
        // current transaction. This actions required to process external
        // messages, which bring no value (henceno gas) with themselves.
        tvm.accept();

        _bs=bs;

        // Вызов у станции функции добавления юнита
        _bs.AddMilitaryUnitOnBase(IDyingFromBase(this));

        
    }
    
    // Получение силы атаки
    function GetAttackPower(uint value) public checkOwnerAndAccept{
        attackPower = value;
    }

    

}
