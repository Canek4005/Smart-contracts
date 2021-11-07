pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "InitializationDebot.sol";




contract FillingOrdersDebot is InitializationDebot  {
    

    string _title;

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shop DeBot Filling";
        version = "0.1.0";
        publisher = "gently.whitesnow@outlook.com";
        key = "Shop list manager";
        author = "https://t.me/gently_whitesnow";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Shop DeBot Filling.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }    


    function _menu() internal override {

        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (amountPaid/amountNotPaid/crystalsSpent) orders",
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
        
        
    }
    function saveTitle_(string value) public {
        _title=value;
        Terminal.print(0, format( "How much {} do you need?", value));
        Terminal.input(tvm.functionId(createOrder_), "Enter the product amount:", false);
    }

    function createOrder_(string value) public view {
        (uint256 num,) = stoi(value);
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
                Terminal.print(0, format("{} {}  \"{}\" {} amount  at {}", order.id, completed, order.title,order.amount, order.createdAt));
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