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



abstract contract InitDebot is Debot,Upgradable  {
    
    
    bytes m_icon;
    // image Account
    TvmCell m_AccountCode; // Account contract code
    TvmCell m_AccountData;
    TvmCell m_AccountStateInit;
    //image Room
    TvmCell m_RoomCode; // Room contract code
    TvmCell m_RoomData;
    TvmCell m_RoomStateInit;
    //
    address m_AccountAddress;  // Account contract address
    
    SummaryAccount m_summaryAccount; 

    
    uint32 m_accountId;    // Task id for update. I didn't find a way to make this var local
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  250000000;  // Initial AccountController contract balance

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    

    function setAccountCode(TvmCell code,TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_AccountCode = code;
        m_AccountData = data;
        m_AccountStateInit =tvm.buildStateInit(code,data);
    }

    function setRoomCode(TvmCell code,TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_RoomCode = code;
        m_RoomData = data;
        m_RoomStateInit =tvm.buildStateInit(code,data);
    }

    

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a Account  ...");
            
            TvmCell deployState = tvm.insertPubkey(m_AccountStateInit, m_masterPubKey);
            m_AccountAddress = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your Account contract address is {}", m_AccountAddress));
            Sdk.getAccountType(tvm.functionId(checkSummaryAccount), m_AccountAddress);

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkSummaryAccount(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and contract is already deployed
            _getSummaryAccount(tvm.functionId(setSummaryAccount));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a Account yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your Account contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_AccountAddress));
        }
    }

    function _getSummaryAccount(uint32 answerId) private view {
        optional(uint256) none;
        IAccount(m_AccountAddress).getSummaryAccount{
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
    function setSummaryAccount(SummaryAccount summaryAccount) public {
        m_summaryAccount = summaryAccount;
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
        }(m_AccountAddress, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        // Account: check errors if needed.
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfSummaryAccountIs0), m_AccountAddress);
    }

    function checkIfSummaryAccountIs0(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }


    function deploy() private view {
            
            TvmCell image = tvm.insertPubkey(m_AccountStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_AccountAddress,
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
        // Account: check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }
    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function onSuccess() public view {
        _getSummaryAccount(tvm.functionId(setSummaryAccount));
    }

    function _menu() internal virtual {}

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
    
        
}