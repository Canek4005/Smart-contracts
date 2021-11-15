pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "InitDebot.sol";




contract MessengerDebot is InitDebot  {
    

    string _title;

    address m_openedRoomAddress;

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
    

    function openRoom_(string value) public {
        (uint num,) = stoi(value);
        
        openRoom__(num);
    }

    function openRoom__(uint value) public view {
               
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
    function onSuccessOpen(address room) public view{
        m_openedRoomAddress = room;
        _getSummaryChating(tvm.functionId(setSummaryChating));
        
    }

    function connectToRoom(uint32 index) public{
        index = index;
        
        AddressInput.get(tvm.functionId(connectToRoom_), "Enter room address:");
        
    }
    function connectToRoom_(address value) public{
        m_openedRoomAddress = value;       
        optional(uint256) pubkey = 0;
        IAccount(m_AccountAddress).connectToRoom{
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
    function onSuccessConnect(address room) public view{
        m_openedRoomAddress = room;
        _getSummaryChating(tvm.functionId(setSummaryChating));
        
    }

    function createRoom(uint32 index) public {
        index = index;
        
        Terminal.input(tvm.functionId(saveTitle_), "Enter the room name :", false);
        
        
    }
    function saveTitle_(string value) public {
        _title=value;
        Terminal.print(0, format( "How will you be called in the room of {}?", value));
        Terminal.input(tvm.functionId(createRoom_), "Enter your alias:", false);
    }

    function createRoom_(string value) public view {
        
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
            }(_title,value);
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
        string letter = "";

        for (uint i; i < m_summaryChating.message.length ;i++){
            string mess = m_summaryChating.message[i];
            letter = letter + mess +"\n";
        }

        Menu.select(
            format(
                "You history: \n {}",
                    letter 
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
                callbackId: tvm.functionId(onSuccessOpen),
                onErrorId: tvm.functionId(onErrorSend)
            }(value);
    }
    function onErrorSend(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _getSummaryChating(tvm.functionId(setSummaryChating));
        
    }
    
    function cleanHistory(uint32 index) public {
        index = index;
        if (m_summaryChating.message.length>0) {
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
                callbackId: tvm.functionId(onSuccessOpen),
                onErrorId: tvm.functionId(onErrorSend)
            }();
    }

    function closeRoom() public {
        Terminal.print(0, "You leave the room ...");
        m_openedRoomAddress = m_AccountAddress;
        onSuccess();
        
    }

    
}