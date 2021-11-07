pragma ton-solidity >=0.35.0;


import "InitializationDebot.sol";




contract PaingOrdersDebot is InitializationDebot  {


    uint32 m_orderId;
    uint m_cost;

    
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
                
                MenuItem("Show orders","",tvm.functionId(getOrders)),
                MenuItem("Pay order","",tvm.functionId(payOrder)),
                MenuItem("Delete order","",tvm.functionId(deleteOrder))
            ]
        );


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
                if (Order.isBought) {
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


    function payOrder(uint32 index) public {
        index = index;
        if (m_summaryOrders.amountNotPaid > 0) {
            Terminal.input(tvm.functionId(payOrder_), "Enter order number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no orders to pay");
            _menu();
        }
    }

    function payOrder_(string value) public {
        (uint256 num,) = stoi(value);
        m_orderId = uint32(num);
        
        Terminal.input(tvm.functionId(payOrder__), "Enter order cost:", false);
    }

    function payOrder__(uint cost) public view {
        (uint256 num,) = stoi(value);
        m_cost = uint(num);
        AddressInput.get(tvm.functionId(pay),"Select a wallet for payment. We will ask you to sign two transactions");

        optional(uint256) pubkey = 0;
        IOrdersController(m_address).buyOrder{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_taskId, m_cost);
        
    }

    function pay(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        ITransactable(m_msigAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(m_address, m_cost, false, 3, empty);
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