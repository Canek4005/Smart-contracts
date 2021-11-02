

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObject.sol";
import 'IDyingFromBase.sol';
import 'IAddRemove.sol';

contract BaseStation is GameObject,IAddRemove {
    
    // хранилище адресов подчиненных юнитов
    mapping(uint=>IDyingFromBase) public unitStorage;
    // количество юнитов
    uint public countUnit=0;
    uint static public id;
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
    function GetArmor(uint value) override public checkOwnerAndAccept {
        armor+=value*2;
    }
    //добавить военного юнита на базу
    function AddMilitaryUnitOnBase(IDyingFromBase addressOfUnitContract) external override {
        tvm.accept();
        unitStorage[countUnit]=addressOfUnitContract;
        countUnit++;
    }
    //удалить военного юнита с базы
    function RemoveMilitaryUnitOnBase(IDyingFromBase addressOfUnitContract) external override {
        tvm.accept();
        for(uint8 i =0;i<countUnit;i++){
            if(unitStorage[i]==addressOfUnitContract){
                delete unitStorage[i];
            }
        }
        countUnit--;
    }
    // переопределение самоуничтожения -> Умирает база и забирает всех с собой
    function sendAllAndDestroyMe(address dest) internal override  {
        for(uint i =0;i<countUnit;i++){
            killChildren(IDyingFromBase(unitStorage[i]));
        }
        dest.transfer(1, false, 160);
    }
    // метод уничтожения подчиненных юнитов
    function killChildren(IDyingFromBase child) private {

        child.destroyByBase();
    }

    function GetChildrens() public checkOwnerAndAccept returns(mapping (uint=>IDyingFromBase)) {
        return unitStorage;
    }


}