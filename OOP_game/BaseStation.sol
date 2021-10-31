

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObject.sol";

contract BaseStation is GameObject {
    
    mapping(uint=>address) unitStorage;
    uint private countUnit=0;

    // конструктор для базы
    constructor() public {
        // Check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and
        // message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        // The current smart contract agrees to buy some gas to finish the
        // current transaction. This actions required to process external
        // messages, which bring no value (henceno gas) with themselves.
        tvm.accept();

        
    }

    // база получает двойные очки защиты
    function getArmor(uint value) override public {
        armor+=value*2;
    }
    //добавить военного юнита на базу
    function AddMilitaryUnitOnBase(address addressOfUnitContract) public checkOwnerAndAccept{
        unitStorage[countUnit]=addressOfUnitContract;
        countUnit++;
    }
    // переопределение самоуничтожения -> Умирает база и наносит колоссальный урон всем своим юнитам
    function sendAllAndDestroyMe(address dest) internal override checkOwnerAndAccept {
        for(uint i =0;i<countUnit;i++){
            killChildren(IGettingAnAttack(unitStorage[i]), dest);
        }
        dest.transfer(1, false, 160);
    }
    function killChildren(IGettingAnAttack child,address killer) private checkOwnerAndAccept{
        child.GetAttack(100000,killer);
    }


}