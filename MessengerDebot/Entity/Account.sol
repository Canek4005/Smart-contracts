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

    
    
    mapping(uint32 => Room) m_rooms;

    uint256 m_ownerPubkey;

    

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
        
    }

    function getSummaryAccount() external override view returns (SummaryAccount summaryAccount) {
        summaryAccount = SummaryAccount(m_count);
    }



    function getRooms() external override returns (Room[] rooms) {
        
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

    function openRoom(uint32 id) external override onlyOwner returns(address addressRoom) {
        require(m_rooms.exists(id), 404);
        tvm.accept();        
        addressRoom =  m_rooms[id].addressRoom; 
        
        }

    function createRoom(Room value) external override onlyOwner {
        tvm.accept();
        
        m_rooms[m_count]=value;
        m_count++;
        
    }
    


    function deleteRoom(uint32 id) external override onlyOwner {
        require(m_rooms.exists(id), 404);
        tvm.accept();
        delete m_rooms[id];
        m_count-=1;
    }

    

    
}