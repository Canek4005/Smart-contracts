pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract SimpleContract {

	uint public m_a;
	

	constructor(uint a) public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);

		// NOTE: To protect from deploying this contract by hacker it's good idea to check msg.sender. See 17_SimpleWallet.sol
		tvm.accept();
		m_a = a;
		
	}
}