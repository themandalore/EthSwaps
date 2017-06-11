pragma solidity ^0.4.11;


contract Factory {
    address[] public newContracts;
    address public creator;
    address public oracleID;
    string public oracleName;
    modifier onlyOwner{if (msg.sender != creator){throw;}else{_;}}

    function Factory (string _oracleName, address _oracleID){
        creator = msg.sender;  
        oracleName = _oracleName;
        oracleID = _oracleID;
    }

    function createContract (bytes32 name, uint _feemargin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate,bool _cancellable) returns (address){
        if (msg.value < _feemargin * 1000000000000000000){throw;}
        var _margin = _feemargin * 9975/10000 ;
        address newContract = new Swap(creator,oracleID,oracleName,_margin,_margin2,_notional,_long,_startDate,_endDate,_cancellable);
        newContracts.push(newContract);
        newContract.send(_margin);
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

  function Swap(address _creator,address OAddress, bytes32 oname, uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate,bool _cancellable) payable {
      d = Oracle(OAddress);
      oracleID = OAddress;
      oracleName = oname;
      creator = _creator;
      cancel = 0;
      cancellable = _cancellable;
      margin1 = _margin*1000000000000000000;
      margin2 = _margin2 *1000000000000000000;
      counterparty1 = msg.sender;
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
    Print("Contract Balance - ", this.balance);

      var startValue = RetrieveData(startDate);
      var endValue = RetrieveData(endDate);
      var endName = RetrieveName(endDate);
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
            if(endName != oracleName){throw;}


    if (msg.sender == counterparty1 && counterparty1 != creator){
        if (long && lvalue > 0 ){if (counterparty1.send(lvalue)){counterparty1 = creator;}}
        else if (!long && svalue > 0){if (counterparty1.send(svalue)){counterparty1 = creator;}}
    }
    else if (msg.sender == counterparty2 && counterparty2 != creator){
        if(!long && lvalue > 0 ){if (counterparty2.send(lvalue)){counterparty2 = creator;}}
        else if (long && svalue > 0){if (counterparty2.send(svalue)){counterparty2 = creator;}}
    }
     if (this.balance ==0){currentState = SwapState.ended;}
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
    var d1 = counterparty1.balance;
    var d2 = counterparty2.balance;
    Print("C1 Change -",d1-c1);
    Print("C2 Change -",d2-c2);
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