pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../Entity/Entity.sol";

contract RoomContract is IRoom {
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 102 - order not found
     */

    

    string message="";
    uint256 static _id;

    uint256 m_ownerPubkey;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function healthCheck(address addressRoom) external override returns(address addressRoomOut) {
        addressRoomOut=addressRoom;
    }

   function getSummaryChating() external override returns (SummaryChating summary){
       
       summary = SummaryChating(message);
   }
   function sendMessage(string title) external override{
       tvm.accept();       
       message=message+title+"\n";
   }
   function cleanHistory() external override{
       tvm.accept();
       message ="";
   }
   
}