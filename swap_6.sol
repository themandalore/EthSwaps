pragma solidity ^0.4.13;


contract Factory {
    address[] public newContracts;
    address public creator;
    address public oracleID;
    bytes32 public oracleName;
    modifier onlyOwner{require(msg.sender == creator); _;}
    event Print(address _name, address _value);

    function Factory (bytes32 _oracleName, address _oracleID){
        creator = msg.sender;  
        oracleName = _oracleName;
        oracleID = _oracleID;
    }

    function createContract () payable returns (address){
        require(msg.value >= .01 * 1000000000000000000);
        address newContract = new Swap(oracleID,oracleName,msg.sender,creator);
        newContracts.push(newContract);
        Print(msg.sender,newContract);
        return newContract;
    } 
    function withdrawFee() onlyOwner {
        creator.transfer(this.balance);
    }
}

contract Oracle{
    address private owner;
    event Print(string _name, uint _value);
    modifier onlyOwner{require(msg.sender == owner);_;}
    struct DocumentStruct{bytes32 name; uint value;}
    mapping(bytes32 => DocumentStruct) public documentStructs;
    
    function Oracle(){
        owner = msg.sender;
    }
    function StoreDocument(bytes32 key,bytes32 name, uint value) onlyOwner returns (bool success) {
        documentStructs[key].value = value;
        documentStructs[key].name = name;
        Print(bytes32ToString(name),value);
        return true;
    }

    function RetrieveData(bytes32 key) public constant returns(uint) {
        var d = documentStructs[key].value;
        return d;
    }
      function RetrieveName(bytes32 key) public constant returns(string) {
        bytes32 d = documentStructs[key].name;
        return bytes32ToString(d);
    }
    
    function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
}
}

contract Swap {
  enum SwapState {open,started,ended}
  SwapState public currentState;
  address public counterparty1;
  address public counterparty2;
  uint public notional;
  bool public long;
  uint public margin1;
  uint public margin2;
  address public oracleID;
  bytes32 public oracleName;
  bytes32 public startDate;
  bytes32 public endDate;
  address public creator;
  uint public cancel;

  mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) {require(expectedState == currentState);_;}

Oracle d;

  function Swap(address OAddress, bytes32 oname,address _cpty1, address _creator){
      d = Oracle(OAddress);
      oracleID = OAddress;
      oracleName = oname;
      creator = _creator;
      counterparty1 = _cpty1;
    
  }
  
  function CreateSwap(bool ECP, uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate) payable {
      require(ECP);
      require (msg.sender == counterparty1);
      require(msg.value == mul(_margin,1000000000000000000));
      cancel = 0;
      margin1 = _margin;
      margin2 = _margin2;
      notional = _notional;
      long = _long;
      currentState = SwapState.open;
      endDate = _endDate;
      startDate = _startDate;
      require(notional >= _margin);
      require(endDate >= _startDate);
  }
  mapping(address => bool) paid;
  function EnterSwap(bool ECP) onlyState(SwapState.open) payable returns (bool) {
      require(ECP);
      require(msg.value >= mul(margin2,1000000000000000000));
      require(this.balance >= margin1);
      counterparty2 = msg.sender;
      currentState = SwapState.started;
      paid[counterparty1] = false;
      paid[counterparty2] = false;
      return true;
  }
  

  mapping(uint => uint) shares;

  function PaySwap() onlyState(SwapState.started) returns (bool){
    uint startValue = RetrieveData(startDate);
    uint endValue = RetrieveData(endDate);
    uint lmargin = long ? margin1 : margin2;
    uint smargin = long ? margin2 : margin1;
    uint p1=div(mul(100,endValue),startValue);
    uint p2=div(mul(100,smargin),notional);
    uint p3=div(mul(100,lmargin),notional);
    if (sub(p1,p2) >= 100){shares[1] = div(this.balance,1000000000000000000); shares[2] = 0;}
    else if (add(p3,p1)  <= 100){shares[1] = 0; shares[2] =div(this.balance,1000000000000000000);}
    else {
          if (p1<100){
              uint i = mul(sub(100,p1),10);
              shares[1] = i;
              shares[2] = sub(add(lmargin,smargin),i);
          }
          
          if (p1 > 100){
               uint j = mul(sub(p1,100),10);
               shares[2] = j;
               shares[1] = sub(add(lmargin,smargin),j);
          }
      }
    uint lvalue = mul(shares[1],1000000000000000000);
    uint svalue =mul(shares[2],1000000000000000000);
    var endName = RetrieveName(endDate);
    require(endName == oracleName);
    if (msg.sender == counterparty1 && paid[counterparty1] == false){
        if (long){counterparty1.transfer(lvalue);paid[counterparty1] = true;}
        else if (!long){counterparty1.transfer(svalue); paid[counterparty1] = true;}
    }
    else if (msg.sender == counterparty2 && paid[counterparty2] == false){
        if(!long){counterparty2.transfer(lvalue);paid[counterparty2] = true;}
        else if (long){counterparty2.transfer(svalue); paid[counterparty2] = true;}
    }
    if (paid[counterparty1] && paid[counterparty2]){currentState = SwapState.ended;}
    return true;
  }
  function Exit(){
    require(currentState != SwapState.ended);
    if (currentState == SwapState.open){
    if (msg.sender == counterparty1) selfdestruct(counterparty1);
    }

  else if (currentState == SwapState.started){
    var c = msg.sender == counterparty1 ? 1 : 0;
    var d = msg.sender == counterparty2 ? 2 : 0;
    var e = cancel + c + d;
    cancel = c + d;
    if (e > 2){
      if (msg.sender == counterparty1){ 
        counterparty2.transfer(margin1);
        counterparty1.transfer(margin2);
        selfdestruct(counterparty1);
      }
      if (msg.sender == counterparty2){ 
        counterparty1.transfer(margin1);
        counterparty2.transfer(margin2);
        selfdestruct(counterparty1);
      }

    }
  }

}


  struct DocumentStruct{bytes32 name; uint value;}

  function RetrieveData(bytes32 key) public constant returns(uint) {
    DocumentStruct memory doc;
    (doc.name,doc.value) = d.documentStructs(key);
    return doc.value;
  }
    function RetrieveName(bytes32 key) public constant returns(bytes32) {
    DocumentStruct memory doc;
    (doc.name,doc.value) = d.documentStructs(key);
    return doc.name;
  }


  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }



}

/*Tests:
Remix:
    true, 100, 100, 1000, true, 20170614, 20170617  -20170614,"BTCUSD",1000  -  20170617,"BTCUSD",1050


TestRPC

Truffle 

Testnet

Mainnet


To test: 
all exit scenarios
Negative Gain
Zero out pos / neg gains
Errors -- big numbers, non oracle values, all margin values, enormous notionals

*/
