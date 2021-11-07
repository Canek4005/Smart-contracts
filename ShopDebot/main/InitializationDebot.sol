pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../Moduls/Debot.sol";
import "../Moduls/Terminal.sol";
import "../Moduls/Sdk.sol";
import "../Moduls/Menu.sol";
import "../Moduls/AddressInput.sol";
import "../Moduls/Upgradable.sol";
import "../Moduls/ConfirmInput.sol";

import "../Entity/Entity.sol";



abstract contract InitializationDebot is Debot,Upgradable  {
    
    
    bytes m_icon;

    TvmCell m_OrdersControllerCode; // OrdersController contract code
    TvmCell m_OrdersControllerData;
    TvmCell m_OrdersControllerStateInit;
    address m_address;  // OrdersController contract address
    SummaryOrders m_summaryOrders;
    uint32 m_orderId;    // Task id for update. I didn't find a way to make this var local
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  200000000;  // Initial OrdersController contract balance

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    

    function setOrdersControllerCode(TvmCell code,TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_OrdersControllerCode = code;
        m_OrdersControllerData = data;
        m_OrdersControllerStateInit =tvm.buildStateInit(code,data);
    }

    

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a OrdersController  ...");
            
            TvmCell deployState = tvm.insertPubkey(m_OrdersControllerStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your OrdersController contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkSummaryOrders), m_address);

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkSummaryOrders(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            _getSummaryOrders(tvm.functionId(setSummaryOrders));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a OrdersController list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your OrdersController contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    function _getSummaryOrders(uint32 answerId) private view {
        optional(uint256) none;
        IOrdersController(m_address).getSummaryOrders{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }
    function setSummaryOrders(SummaryOrders summaryOrders) public {
        m_summaryOrders = summaryOrders;
        _menu();
    }


    function creditAccount(address value) public {
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
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        // OrdersController: check errors if needed.
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfSummaryOrdersIs0), m_address);
    }

    function checkIfSummaryOrdersIs0(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }


    function deploy() private view {
            
            TvmCell image = tvm.insertPubkey(m_OrdersControllerStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubkey, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }
    
    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // OrdersController: check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }
    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function onSuccess() public view {
        _getSummaryOrders(tvm.functionId(setSummaryOrders));
    }

    function _menu() internal virtual {}

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
        
}