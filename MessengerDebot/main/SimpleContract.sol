pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract SimpleContract {

	uint public m_a;
	

	constructor(uint a) public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);

		
		tvm.accept();
		m_a = a;
		
	}
}