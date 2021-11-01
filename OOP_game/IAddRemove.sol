

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'IDyingFromBase.sol';
// This is class that describes you smart contract.
interface IAddRemove {
    

    function AddMilitaryUnitOnBase(IDyingFromBase addressOfUnitContract) external ;
        
    function RemoveMilitaryUnitOnBase(IDyingFromBase addressOfUnitContract) external ;
}
