pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "InitDebot.sol";

import "../Entity/RoomContract.sol";


contract MessengerDebot is InitDebot  {
    

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Messenger Debot";
        version = "0.1.1 alfa";
        publisher = "gently.whitesnow@outlook.com";
        key = "Messaging bot";
        author = "https://t.me/gently_whitesnow";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Messenger DeBot, with my help you can create a chat contract-room .";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    string _title;

    string _alias;

    address m_openedRoomAddress;

    address m_RoomAddress;
    function _menu() internal override {
        
        string sep = '----------------------------------------';
        Menu.select(
            format(
                
                "You have {} room(-s)",
                    m_summaryAccount.rooms 
            ),
            sep,
            [
                MenuItem("Show list rooms","",tvm.functionId(getRooms)),
                MenuItem("Open room from the list","",tvm.functionId(openRoom)),
                MenuItem("Connect to a room not on the list","",tvm.functionId(connectToRoom)),
                MenuItem("Create room","",tvm.functionId(createRoom)),
                MenuItem("Delete room","",tvm.functionId(deleteRoom))
                
            ]
        );


    }


    function getRooms(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IAccount(m_AccountAddress).getRooms{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(getRooms_),
            onErrorId: 0
        }();
    }

    function getRooms_(Room[] rooms ) public {
        uint32 i;
        if (rooms.length > 0 ) {
            Terminal.print(0, "Your rooms list:");
            for (i = 0; i < rooms.length; i++) {
                Room room = rooms[i];
                        
                Terminal.print(0, format("{} {} your name: {} \n room address: {}", room.id, room.title,room.nameIn, room.addressRoom));
            }
        } else {
            Terminal.print(0, "Your rooms list is empty");
        }
        _menu();
    }

    function openRoom(uint32 index) public{
        index = index;
        if (m_summaryAccount.rooms  > 0) {
            Terminal.input(tvm.functionId(openRoom_), "Enter room number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no rooms to open");
            _menu();
        }
    }
    

    function openRoom_(string value) view public {
        (uint num,) = stoi(value);
        
        openRoom__(uint32(num));
    }

    function openRoom__(uint32 value) public view {
               
        optional(uint256) pubkey = 0;
        IAccount(m_AccountAddress).openRoom{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccessOpen),
                onErrorId: tvm.functionId(onError)
            }(value);
    }
    function onSuccessOpen(address room) public{
        m_openedRoomAddress = room;
        _getSummaryChating(tvm.functionId(setSummaryChating));
        
    }

    function connectToRoom(uint32 index) public{
        index = index;
        
        AddressInput.get(tvm.functionId(connectToRoom_), "Enter room address:");
        
    }
    function connectToRoom_(address value) public view{
            
        optional(uint256) pubkey = 0;
        IRoom(m_AccountAddress).healthCheck{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccessConnect),
                onErrorId: tvm.functionId(onError)
            }(value);
    }
    
    
    function onSuccessConnect(address room) public {
        m_openedRoomAddress=room;
        _getSummaryChating(tvm.functionId(setSummaryChating));        
    }
    

    function createRoom(uint32 index) public {
        index = index;
        
        Terminal.input(tvm.functionId(saveTitle_), "Enter the room name :", false);
        
        
    }
    function saveTitle_(string value) public {
        _title=value;
        Terminal.print(0, format( "How will you be called in the room of {}?", value));
        Terminal.input(tvm.functionId(saveAlias_), "Enter your alias:", false);
    }
    function saveAlias_(string value) public {
        _alias=value;
        CreateRoom_();
    }

    function createRoom__(Room value) public view {
        
        optional(uint256) pubkey = 0;
        IAccount(m_AccountAddress).createRoom{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(value);
    }
    uint id = 10;
    function CreateRoom_() private {
        
        TvmBuilder salt;
        salt.store(this);
        TvmCell codeRoom = tvm.setCodeSalt(m_RoomCode, salt.toCell());
        m_RoomStateInit =tvm.buildStateInit({contr: RoomContract,varInit: {_id: id},code: m_RoomCode});
        id+=1;
        
        
        // tvm.accept();
        // TvmCell stateInit = tvm.buildStateInit(m_RoomCode, m_RoomData);
		// m_RoomAddress = new RoomContract{stateInit: stateInit, value: 100000000}(m_masterPubKey);
        m_RoomAddress = address.makeAddrStd(0, tvm.hash(m_RoomStateInit));
        
        Terminal.print(0, format( "Info: your Room contract address is {}", m_RoomAddress));

        Sdk.getAccountType(tvm.functionId(checkSummaryRoom), m_RoomAddress);
    }
    function checkSummaryRoom(int8 acc_type) public{
        if (acc_type == 1) { // acc is active and contract is already deployed
            createRoom__(Room(m_summaryAccount.rooms, _title, _alias,m_RoomAddress));
            

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "New room with an initial balance of 1 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditRoom),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your Room contract has enough tokens on its balance"
            ));
            deployRoom();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, "Can not continue: room is frozen");
        }
    }
    function creditRoom(address value) public {
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
            callbackId: tvm.functionId(waitBeforeDeployRoom),
            onErrorId: tvm.functionId(onErrorRepeatCreditRoom)  // Just repeat if something went wrong
        }(m_RoomAddress, 1000000000, false, 3, empty);
    }

    function onErrorRepeatCreditRoom(uint32 sdkError, uint32 exitCode) public {
        // Account: check errors if needed.
        sdkError;
        exitCode;
        creditRoom(m_msigAddress);
    }


    function waitBeforeDeployRoom() public  {
        Sdk.getAccountType(tvm.functionId(checkIfSummaryRoomIs0), m_RoomAddress);
    }

    function checkIfSummaryRoomIs0(int8 acc_type) public {
        if (acc_type ==  0) {
            deployRoom();
        } else {
            waitBeforeDeployRoom();
        }
    }


    function deployRoom() private view {
            
            TvmCell image = m_RoomStateInit;
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_RoomAddress,
                callbackId: tvm.functionId(onSuccessDeployRoom),
                onErrorId:  tvm.functionId(onErrorRepeatDeployRoom),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubkey, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }
    function onErrorRepeatDeployRoom(uint32 sdkError, uint32 exitCode) public view {
        // Account: check errors if needed.
        sdkError;
        exitCode;
        deployRoom();
    }
    

    function onSuccessDeployRoom() public{
        Sdk.getAccountType(tvm.functionId(checkSummaryRoom), m_RoomAddress);
        
    }

    

    function deleteRoom(uint32 index) public {
        index = index;
        if (m_summaryAccount.rooms  > 0) {
            Terminal.input(tvm.functionId(deleteRoom_), "Enter room number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no rooms to delete");
            _menu();
        }
    }

    function deleteRoom_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IAccount(m_AccountAddress).deleteRoom{
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

    

        


    

    // Working inside room

    SummaryChating m_summaryChating;

    function _getSummaryChating(uint32 answerId) private view {
        optional(uint256) none;
        IRoom(m_openedRoomAddress).getSummaryChating{
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
    function setSummaryChating(SummaryChating summaryChating) public {
        m_summaryChating = summaryChating;
        __menu();
    }
    

    function __menu() private {
        
        string sep = '----------------------------------------';
        

        

        Menu.select(
            format(
                "You history: \n {}",
                    m_summaryChating.message 
            ),
            sep,
            [
                MenuItem("Send message","",tvm.functionId(sendMessage)),
                MenuItem("Clean history","",tvm.functionId(cleanHistory)),
                MenuItem("Escape from the room","",tvm.functionId(closeRoom))               
                
            ]
        );


    }

    function sendMessage(uint32 index) public {
        index = index;
        
        Terminal.input(tvm.functionId(sendMessage_), "Enter your message :", false);
        
        
    }
    
    function sendMessage_(string value) public view {
        optional(uint256) pubkey = 0;
        IRoom(m_openedRoomAddress).sendMessage{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccessSend),
                onErrorId: tvm.functionId(onErrorSend)
            }(value);
    }

    function onSuccessSend() public {
        
        _getSummaryChating(tvm.functionId(setSummaryChating));
        
    }

    function onErrorSend(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Send message failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _getSummaryChating(tvm.functionId(setSummaryChating));
        
    }
    
    function cleanHistory(uint32 index) public {
        index = index;
        if (m_summaryChating.message=="") {
            ConfirmInput.get(tvm.functionId(cleanHistory__),"do you really want to erase history?");
            
        } else {
            Terminal.print(0, "Sorry, you have no message in room");
            _getSummaryChating(tvm.functionId(setSummaryChating));
        }
    }
    function cleanHistory_(bool value) view private{
        if (value)
        {
            cleanHistory__();
        }
        else
        {
            _getSummaryChating(tvm.functionId(setSummaryChating));
        }
    }

    function cleanHistory__() public view {
                
        optional(uint256) pubkey = 0;
        IRoom(m_openedRoomAddress).cleanHistory{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccessSend),
                onErrorId: tvm.functionId(onErrorSend)
            }();
    }

    function closeRoom() public {
        Terminal.print(0, "You leave the room ...");
        m_openedRoomAddress = m_AccountAddress;
        onSuccess();
        
    }


}