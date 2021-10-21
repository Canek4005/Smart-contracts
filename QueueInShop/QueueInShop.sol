
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract QueueInShop {
    
    string[] public queue;

    
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

    modifier checkOwnerAndAccept {

        require(tvm.pubkey()==msg.pubkey(),102);
        tvm.accept();
        _;
    }

    function enqueue (string data) public checkOwnerAndAccept {

        queue.push(data);

    }
    function dequeue () public checkOwnerAndAccept returns(string)  {
        
        
        require(queue.length>0,404);
        string pop = queue[0];
        string[] maind;
        for(uint256 i=1;i<queue.length;i++){
            maind.push(queue[i]);
        }
        queue = maind;
        return pop;
    }   

}
