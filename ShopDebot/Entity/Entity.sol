pragma ton-solidity >=0.35.0;

struct Order{
    uint32 id;
    string title;
    uint32 amount;
    uint createdDate;
    bool isBought;
    int generalCost;    
}

struct SummaryOrders{
    uint32 amountPaid;
    uint32 amountNotPaid;
    uint mainCost;
}

interface ITransactable {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}


abstract contract HasConstructorWithPubkey {
   constructor(uint256 pubkey) public {}
}

interface IListOfOrders {
   function createTask(string text) external;
   function updateTask(uint32 id, bool done) external;
   function deleteTask(uint32 id) external;
   function getTasks() external returns (Order[] orders);
   function getStat() external returns (SummaryOrders);
}


