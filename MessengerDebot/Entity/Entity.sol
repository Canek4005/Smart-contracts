pragma ton-solidity >=0.35.0;

struct Room{
    uint32 id;
    string title;
    string nameIn;
    address addressRoom;   
}

struct SummaryAccount{
    
    uint32 rooms;
}

struct SummaryChating{
   string message;
}

interface ITransactable {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}


abstract contract HasConstructorWithPubkey {
   constructor(uint256 pubkey) public {}
}



interface IAccount {
   function getSummaryAccount() external view returns (SummaryAccount);//получить саммари по количеству комнат
   function getRooms() external returns (Room[] rooms); // Получить список комнат
   function openRoom(uint32 id) external returns(address addressRoom);// открыть комнату
   function createRoom(Room value) external;//создать комнату
   //function connectToRoom(address addressRoom) external returns(bool value); //подключится к существующей комнате
   function deleteRoom(uint32 id) external;//Удалить комнату
}

interface IRoom {
   function healthCheck(address addressRoom) external returns(address addressRoomOut) ;
   function getSummaryChating() external returns (SummaryChating);
   function sendMessage(string title) external;
   function cleanHistory() external;
   
   
}


