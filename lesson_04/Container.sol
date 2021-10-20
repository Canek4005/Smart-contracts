

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "IContainer.sol";

// This is class that describes you smart contract.
contract Container is IContainer {
    

    int _storage;
    

  
    
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

    function aboutMe () public pure returns (string) {
        return 'IAmContainer';
    }
       
    function putValue(int value) public override {

        _storage = value;
    }

    function getValue() public view returns(int s) {
        return _storage;
    }
}
