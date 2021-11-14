pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../Entity/Entity.sol";

contract Room is IRoom {
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 102 - order not found
     */

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 m_count;

    uint _crystalsSpent = 0;

    mapping(uint32 => Order) m_orders;

    uint256 m_ownerPubkey;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function createOrder(string title,uint32 amount) public onlyOwner {
        tvm.accept();
        m_count++;
        m_orders[m_count] = Order(m_count, title, amount, now, false,0);
    }

    
    function deleteOrder(uint32 id) public onlyOwner {
        require(m_orders.exists(id), 102);
        tvm.accept();
        delete m_orders[id];
    }

    function payOrder(uint32 id, uint128 cost) public onlyOwner {
        optional(Order) order = m_orders.fetch(id);
        require(order.hasValue(), 102);
        tvm.accept();
        Order thisOrder = order.get();
        thisOrder.isBought = true;
        _crystalsSpent += cost;
        m_orders[id] = thisOrder;
    }

    //
    // Get methods
    //

    function getOrders() public view returns (Order[] orders) {
        string title;
        uint32 amount;
        uint64 createdAt;
        bool isBought;
        uint cost;

        for((uint32 id, Order order) : m_orders) {
            title = order.title;
            amount = order.amount;
            isBought = order.isBought;
            createdAt = order.createdAt;
            cost = order.cost;
            orders.push(Order(id, title, amount, createdAt, isBought,cost));
       }
    }

    function getSummaryOrders() public view returns (SummaryOrders summaryOrders) {
        uint32 amountPaid;
        uint32 amountNotPaid;
        

        for((,Order order) : m_orders) {
            if(order.isBought) {
                amountPaid ++;
            } else {
                amountNotPaid ++;
            }
        }
        summaryOrders = SummaryOrders(amountPaid, amountNotPaid,_crystalsSpent);
    }
}