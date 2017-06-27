pragma solidity ^0.4.11;


contract Factory {
    address[] public newContracts;
    address public creator;
    address public oracleID;
    bytes32 public oracleName;
    modifier onlyOwner{if (msg.sender != creator){throw;}else{_;}}
    event Print(address _name, address _value);
    event Print2(uint _name);

    function Factory (bytes32 _oracleName, address _oracleID){
        creator = msg.sender;  
        oracleName = _oracleName;
        oracleID = _oracleID;
    }

    function createContract () payable returns (address){
        if (msg.value < .01 * 1000000000000000000){throw;}
        Print2(this.balance);
        address newContract = new Swap(oracleID,oracleName,msg.sender,creator);
        newContracts.push(newContract);
        Print(oracleID,newContract);
        Print2(this.balance);
        return newContract;
    } 
    function withdrawFee() onlyOwner {
        creator.transfer(this.balance);
    }
}

contract Oracle{
    address private owner;
    event Print(string _name, uint _value);
    modifier onlyOwner{if (msg.sender != owner){throw;}else{_;}}
    struct DocumentStruct{bytes32 name; uint value;}
    mapping(bytes32 => DocumentStruct) public documentStructs;
    
    function Oracle(){
        owner = msg.sender;
        var  zz = 0;
        Print('Success',zz);
    }
    function StoreDocument(bytes32 key,bytes32 name, uint value) onlyOwner returns (bool success) {
        documentStructs[key].value = value;
        documentStructs[key].name = name;
        return true;
    }

    function RetrieveData(bytes32 key) public constant returns(uint) {
        var d = documentStructs[key].value;
        Print('data',d);
        return d;
    }
      function RetrieveName(bytes32 key) public constant returns(string) {
        var d = documentStructs[key].name;
        var e = bytes32ToString(d);
        var  x = 0;
        Print(e,x);
        return e;
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


  event Print(string _name, uint _value);
    mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) { if (expectedState == currentState) {_;} else {throw; } }
modifier onlyCreator{if (msg.sender != creator){throw;}else{_;}}



Oracle d;

  function Swap(address OAddress, bytes32 oname,address _cpty1, address _creator){
      d = Oracle(OAddress);
      oracleID = OAddress;
      oracleName = oname;
      creator = _creator;
      counterparty1 = _cpty1;
    
  }
  
  function CreateSwap(bool ECP, uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate) payable {
      if(!ECP){throw;}
      if(msg.sender != counterparty1){throw;}
      if(msg.value != mul(_margin,1000000000000000000)){throw;}
      cancel = 0;
      margin1 = _margin;
      margin2 = _margin2;
      notional = _notional;
      long = _long;
      currentState = SwapState.open;
      endDate = _endDate;
      startDate = _startDate;
      Print('Margin- ',margin1);
      log0("Testing Log");
      //Validators:
      if (notional < _margin){throw;}
      if (endDate < _startDate){throw;}
  }
  mapping(address => bool) paid;
  function EnterSwap(bool ECP) onlyState(SwapState.open) payable returns (bool) {
      if(!ECP){throw;}
      if(msg.value == mul(margin2,1000000000000000000)) {
          if (this.balance < margin1) {throw;}
          counterparty2 = msg.sender;
          currentState = SwapState.started;
          paid[counterparty1] = false;
          paid[counterparty2] = false;
          return true;
      } else {throw;}
  }
  

  mapping(uint => uint) shares;


  function PaySwap() onlyState(SwapState.started) returns (bool){
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
      uint startValue = RetrieveData(startDate);
      uint endValue = RetrieveData(endDate);
    Print("Endvalue - ", endValue);
      uint lmargin = long ? margin1 : margin2;
      uint smargin = long ? margin2 : margin1;
      Print('Test',100*endValue/startValue);
      Print('Test2',100*smargin/notional);
      uint p1=div(mul(100,endValue),startValue);
      uint p2=div(mul(100,smargin),notional);
      uint p3=div(mul(100,lmargin),notional);
      if (sub(p1,p2) >= 100){shares[1] = div(this.balance,1000000000000000000); shares[2] = 0;}
      else if (add(p3,p1)  <= 100){shares[1] = 0; shares[2] =div(this.balance,1000000000000000000);}
      else {shares[2] = div(mul(smargin,sub(200,p1)),100);shares[1] = div(mul(lmargin,p1),100);}
    uint lvalue = mul(shares,1000000000000000000);
    uint svalue =mul(shares[2],1000000000000000000);
    Print ("Change - ", div(mul(100,endValue),startValue));
    Print("Lvalue - ", lvalue);
    Print("Svalue - ", svalue);
      //Validators:
      var endName = RetrieveName(endDate);
      if(endName != oracleName){throw;}
    if (msg.sender == counterparty1 && paid[counterparty1] == false){
        Print('Good1',lvalue);
        if (long){Print('GoodLvalue',lvalue); counterparty1.transfer(lvalue);paid[counterparty1] = true;}
        else if (!long){counterparty1.transfer(svalue); paid[counterparty1] = true;}
    }
    else if (msg.sender == counterparty2 && paid[counterparty2] == false){
        Print('Goods',svalue);
        if(!long){counterparty2.transfer(lvalue);paid[counterparty2] = true;}
        else if (long){ Print('Good2s',svalue); counterparty2.transfer(svalue); paid[counterparty2] = true;}
    }
    if (paid[counterparty1] && paid[counterparty2]){currentState = SwapState.ended;}
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
    return true;
  }
  function Exit(){
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
  else if (currentState == SwapState.ended){throw;}

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

    function test() payable{
        uint notional = 1000;
        uint lmargin = 100;
        uint smargin = 100;
        uint endValue = 950;
        uint startValue = 1000;

      uint p1=div(mul(100,endValue),startValue);
      uint p2=div(mul(100,smargin),notional);
      uint p3=div(mul(100,lmargin),notional);
        Print('p1',p1);
        Print('p2',p2);
        Print('p3',p3);
      if (sub(p1,p2) >= 100){shares[1] = 9999; shares[2] = 0;}
      else if (add(p3,p1)  <= 100){shares[1] = 0; shares[2] =8888;}
      else {shares[2] = div(mul(smargin,sub(200,p1)),100);shares[1] = div(mul(lmargin,p1),100);}
    Print ('Short',shares[2]);
    Print('Long',shares[1]);
        uint lvalue = mul(shares[1],1000000000000000000);
    uint svalue = mul(shares[2],1000000000000000000);
    Print('l',lvalue);
    Print('s',svalue);
    Print('val',(msg.value));
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
100, 100, 1000, true, 20170614, 20170617  -20170614,"BTCUSD",1000  -  20170617,"BTCUSD",1050

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