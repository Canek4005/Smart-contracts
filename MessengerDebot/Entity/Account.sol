pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../Entity/Entity.sol";
import "../Moduls/Terminal.sol";
import "../Moduls/Sdk.sol";
import "../Moduls/AddressInput.sol";

contract Account is IAccount {
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

    TvmCell m_RoomStateInit; //image of Room
    //
    mapping(uint=>address) public m_RoomsAddress; // Rooms contracts address
    //
    mapping(uint32 => Room) m_rooms;

    uint256 m_ownerPubkey;

    string m_title;
    string m_nameIn;
    address m_RoomAddress;
    address m_msigAddress;

    constructor(uint256 pubkey,TvmCell imageRoom) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
        m_RoomStateInit = imageRoom;
    }

    function getSummaryAccount() external override view returns (SummaryAccount summaryAccount) {
        summaryAccount = SummaryAccount(m_count);
    }

    function getRooms() external override view returns (Room[] rooms) {
        
        string title;
        string nameIn;
        address addressRoom;

        for((uint32 id, Room room) : m_rooms) {
            title = room.title;
            nameIn = room.nameIn;
            addressRoom = room.addressRoom;
            rooms.push(Room(id, title, nameIn,addressRoom));
       }
    }

    function openRoom(uint id) external override onlyOwner returns(address addressRoom) {
        tvm.accept();
        
        addressRoom =  m_rooms[id].addressRoom; 
        
        }

    function createRoom(string title,string nameIn) external override onlyOwner {
        tvm.accept();
        m_title=title;
        m_nameIn=nameIn;
        deployRoom();
        

    }
    function deployRoom() private {
        TvmCell deployState = tvm.insertPubkey(m_RoomStateInit, m_ownerPubkey);
        m_RoomAddress = address.makeAddrStd(m_count, tvm.hash(deployState));
        Terminal.print(0, format( "Info: your Room contract address is {}", m_RoomAddress));

        Sdk.getAccountType(tvm.functionId(checkSummaryRoom), m_RoomAddress);
    }
    function checkSummaryRoom(int8 acc_type) private{
        if (acc_type == 1) { // acc is active and contract is already deployed
            m_rooms[m_count] = Room(m_count, m_title, m_nameIn,m_RoomAddress);
            m_count++;

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "New room with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditRoom),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your Room contract has enough tokens on its balance"
            ));
            deploy();

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
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(m_RoomAddress, 1000000000, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        // Account: check errors if needed.
        sdkError;
        exitCode;
        creditRoom(m_msigAddress);
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfSummaryRoomIs0), m_RoomAddress);
    }

    function checkIfSummaryRoomIs0(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }


    function deploy() private view {
            
            TvmCell image = tvm.insertPubkey(m_RoomStateInit, m_ownerPubkey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_RoomAddress,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubkey, m_ownerPubkey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }
    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // Account: check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }
    

    function onSuccess() public view {
        Sdk.getAccountType(tvm.functionId(checkSummaryRoom), m_RoomAddress);
        
    }

    function connectToRoom(address value) external override returns(address ad){

        optional(uint256) pubkey = 0;
        IRoom(value).healthCheck{
                abiVer: 2,
                extMsg: true,
                sign: false,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: ad = value,
                onErrorId: value=false
            }(value);
        
    }


    function deleteRoom(uint32 id) external override onlyOwner {
        require(m_rooms.exists(id), 102);
        tvm.accept();
        delete m_rooms[id];
        m_count-=1;
    }

    

    
}