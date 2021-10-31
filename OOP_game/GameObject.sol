
import "IGettingAnAttack.sol";
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;



contract GameObject is IGettingAnAttack {
   
    uint private health = 10;
    uint public armor = 0;
    
    
    // модификатор оплаты
    modifier checkOwnerAndAccept{
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }
    
    // получить урон
    function GetAttack(uint value,address abuser) override external checkOwnerAndAccept{
        health-=armor-value;
        Death(abuser);
    }    
    // не пора ли умереть?
    function Death(address killerAddress) private {
        if (isAlive()){
            sendAllAndDestroyMe(killerAddress);
        }
    }
    // проверка на жизнеспособность
    function isAlive() private returns(bool){
        
        return health<=0?false:true;
    }
    // отправка кристаллов киллеру и самоуничтожение
    function sendAllAndDestroyMe(address dest) internal virtual checkOwnerAndAccept {
         
        dest.transfer(1, false, 160);
    }
    // получение очков защиты 
    function getArmor(uint value) virtual public {
        armor+=value;
    }
    

}
