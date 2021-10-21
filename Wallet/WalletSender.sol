
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This is class that describes you smart contract.
contract WalletSender {
    /*
     Exception codes:
      100 - message sender is not a wallet owner.
      101 - invalid transfer value.
     */

    /// @dev Contract constructor.
    constructor() public {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }


    modifier checkOwnerAndAccept {
        
        require(msg.pubkey() == tvm.pubkey(), 100);

		tvm.accept();
		_;
	}

    /// @dev Allows to transfer tons to the destination account.
    /// @param dest Transfer target address.
    /// @param value Nanotons value to transfer.
    /// @param bounce Flag that enables bounce message in case of target contract error.
    function sendPaymentTransaction(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept {
         

        dest.transfer(value, bounce, 0);
    }
    function sendWithoutPaymentTransaction(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept {
         

        dest.transfer(value, bounce, 64);
    }
    function sendAllAndDestroyMe(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept {
         

        dest.transfer(value, bounce, 160);
    }
}
