pragma ton-solidity >=0.35.0;

struct Order{
    uint32 id;
    string title;
    uint32 amount;
    uint64 createdAt;
    bool isBought;
    uint cost;    
}

struct SummaryOrders{
    uint32 amountPaid;
    uint32 amountNotPaid;
    uint crystalsSpent;
}

interface ITransactable {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}


abstract contract HasConstructorWithPubkey {
   constructor(uint256 pubkey) public {}
}

interface IOrdersController {
   function getSummaryOrders() external returns (SummaryOrders);
   function createOrder(string title,uint32 amount) external;
   function deleteOrder(uint32 id) external;
   function payOrder(uint32 id, uint128 cost) external;
   function getOrders() external returns (Order[] orders);
}


