pragma ton-solidity >=0.35.0;

struct Room{
    uint32 id;
    string title;
    uint32 nameIn;
    address addressRoom;   
}

struct SummaryAccount{
    
    uint rooms;
}

struct SummaryChating{
   string[] message;
}

interface ITransactable {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}


abstract contract HasConstructorWithPubkey {
   constructor(uint256 pubkey) public {}
}

interface IAccount {
   function getSummaryAccount() external returns (SummaryAccount);//получить саммари по количеству комнат
   function getRooms() external returns (Room[] rooms); // Получить список комнат
   function openRoom(address addressRoom) external;// открыть комнату
   function connectToRoom(address addressRoom) external; //подключится к существующей комнате
   function createRoom(string title,string nameIn) external;//создать комнату
   function deleteRoom(uint32 id) external;//Удалить комнату
}

interface IRoom {
   function getSummaryChating() external returns (SummaryChating);
   function sendMessage(string title) external;
   function cleanHistory() external;
   function closeRoom() external ;
   
}


