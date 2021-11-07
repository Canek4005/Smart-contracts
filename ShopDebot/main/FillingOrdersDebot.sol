pragma ton-solidity >=0.35.0;


import "InitializationDebot.sol";




contract FillingOrdersDebot is InitializationDebot  {
    

    string _title;
        


    function _menu() internal override {

        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (amountPaid/amountNotPaid/crystalsSpent) tasks",
                    m_summaryOrders.amountPaid,
                    m_summaryOrders.amountNotPaid,
                    m_summaryOrders.crystalsSpent
            ),
            sep,
            [
                MenuItem("Create new order","",tvm.functionId(createOrder)),
                MenuItem("Show orders","",tvm.functionId(getOrders)),
                MenuItem("Delete order","",tvm.functionId(deleteOrder))
            ]
        );


    }

    function createOrder(uint32 index) public {
        index = index;
        
        Terminal.input(tvm.functionId(saveTitle_), "Enter the product name in one line please:", false);
        Terminal.input(tvm.functionId(createOrder_), "Enter the product amount in one line please:", false);
        
    }
    function saveTitle_(string title) public {
        _title=title;
    }

    function createOrder_(string amount) public view {
        (uint256 num,) = stoi(amount);
        optional(uint256) pubkey = 0;
        IOrdersController(m_address).createOrder{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(_title,uint32(num));
    }

    function getOrders(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IOrdersController(m_address).getOrders{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(getOrders_),
            onErrorId: 0
        }();
    }

    function getOrders_(Order[] orders ) public {
        uint32 i;
        if (orders.length > 0 ) {
            Terminal.print(0, "Your orders list:");
            for (i = 0; i < orders.length; i++) {
                Order order = orders[i];
                string completed;
                if (order.isBought) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\"{}   at {}", order.id, completed, order.title,order.amount, order.createdAt));
            }
        } else {
            Terminal.print(0, "Your orders list is empty");
        }
        _menu();
    }

    function deleteOrder(uint32 index) public {
        index = index;
        if (m_summaryOrders.amountPaid + m_summaryOrders.amountNotPaid > 0) {
            Terminal.input(tvm.functionId(deleteOrder_), "Enter order number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no orders to delete");
            _menu();
        }
    }

    function deleteOrder_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IOrdersController(m_address).deleteOrder{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
    
}