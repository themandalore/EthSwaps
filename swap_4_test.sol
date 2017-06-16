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
        creator.send(this.balance);
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
  bool public cancellable;
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
  
  function CreateSwap(uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate,bool _cancellable) payable {
      if(msg.sender != counterparty1){throw;}
      margin1 = _margin*1000000000000000000;
      if(msg.value != margin1){throw;}
      cancel = 0;
      cancellable = _cancellable;
      margin1 = _margin*1000000000000000000;
      margin2 = _margin2 *1000000000000000000;
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

  function EnterSwap() onlyState(SwapState.open) payable returns (bool) {
      if(msg.value == margin2) {
          if (this.balance < margin1) {throw;}
          counterparty2 = msg.sender;
          currentState = SwapState.started;
          return true;
      } else {throw;}
  }

  function PaySwap() onlyState(SwapState.started) returns (bool){
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    var c1 = counterparty1.balance;
    var c2 = counterparty2.balance;
    var c3 = this.balance;
    Print("Contract Balance - ", this.balance);

      var startValue = RetrieveData(startDate);
      var endValue = RetrieveData(endDate);
    Print("Endvalue - ", endValue);
     /*works up to here*/
      var change = ((notional*(endValue - startValue)) / startValue) * 1000000000000000000; //convert wei to ETH
      var lmargin = long ? margin1 : margin2;
      var smargin = long ? margin2 : margin1;
      var lvalue = smargin - change < 0 ? (this.balance) : (lmargin + change);
      var svalue = lmargin + change < 0 ? (this.balance) : (smargin - change);
    Print ("Change - ", change);
    Print("Lvalue - ", lvalue);
    Print("Svalue - ", svalue);
      //Validators:
    if (msg.sender == counterparty1 && counterparty1 != creator){
        Print('Good1',lvalue);
        if (long && lvalue > 0 ){Print('GoodLvalue',lvalue); counterparty1.send(lvalue); if (this.balance == c3 - lvalue){counterparty1 = creator; Print('GoodLong',lvalue);}}
        else if (!long && svalue > 0){counterparty1.send(svalue); if (this.balance == c3 - svalue){counterparty1 = creator;}}
    }
    else if (msg.sender == counterparty2 && counterparty2 != creator){
        Print('Goods',svalue);
        if(!long && lvalue > 0 ){counterparty2.send(lvalue); if (this.balance == c3 - lvalue){counterparty2 = creator;}}
        else if (long && svalue > 0){ Print('Good2s',svalue); counterparty2.send(svalue); if (this.balance == c3 - svalue){counterparty2 = creator;  Print('Good3s',svalue);}}
    }
     if (this.balance ==0){currentState = SwapState.ended;}
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
    var d1 = counterparty1.balance;
    var d2 = counterparty2.balance;
    return true;
  }
  function Exit(){
     if (currentState == SwapState.open){
    if (msg.sender == counterparty1) selfdestruct(counterparty1);
  }

  else if (currentState == SwapState.started){
      if (!cancellable){throw;}
    var c = msg.sender == counterparty1 ? 1 : 0;
    var d = msg.sender == counterparty2 ? 2 : 0;
    var e = cancel + c + d;
    if (e > 2){
      counterparty1.send(margin1);
      counterparty2.send(margin2);
      selfdestruct(creator);
    }else {
      cancel = c +d;
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


}

/*Tests:
Remix:

TestRPC

Truffle 

Testnet

Mainnet

*/