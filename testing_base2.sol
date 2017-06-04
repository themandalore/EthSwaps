pragma solidity ^0.4.11;

contract Oracle{
    address private owner;
    event Print(string _name, uint _value);
    modifier onlyOwner{if (msg.sender != owner){throw;}else{_;}}
    function Oracle(){owner = msg.sender;}
    struct DocumentStruct{bytes32 name; uint value;}
    mapping(bytes32 => DocumentStruct) public documentStructs;

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
      function RetrieveName(bytes32 key) public constant returns(bytes32) {
        var d = documentStructs[key].name;
        Print(d,"00");
        return d;
     }
}

contract Swap {
  enum SwapState {available,open,started,ended}
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

function Swap(address OAddress, bytes32 oname){
    d = Oracle(OAddress);
    oracleID = OAddress;
    oracleName = oname;
    creator = msg.sender;
    currentState = SwapState.available;
    cancel = 0;
}

function Exit(){
   if (currentState == SwapState.available){
    if (msg.sender == creator) selfdestruct(creator);
    }
  else if (currentState == SwapState.open){
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

Oracle d;

  function CreateSwap(uint _margin, uint _margin2, uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate,bool _cancellable) onlyState(SwapState.available) payable returns (bool) {
    cancellable = _cancellable;
      margin1 = msg.value;
      margin2 = _margin2;
      counterparty1 = msg.sender;
      notional = _notional;
      long = _long;
      currentState = SwapState.open;
      endDate = _endDate;
      startDate = _startDate;
      Print('Margin- ',margin1);
      log0("Testing Log");
      //Validators:
      if (margin1 != _margin * 1000000000000000000){throw;}
      if (notional < _margin){throw;}
      if (endDate < _startDate){throw;}


      return true;
  }

  function EnterSwap() onlyState(SwapState.open) payable returns (bool) {
      if(msg.value == margin2) {
          counterparty2 = msg.sender;
          currentState = SwapState.started;
          return true;
      } else {throw;}
  }

  function PaySwap() onlyState(SwapState.started) returns (bool){
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
      var startValue = RetrieveData(startDate);
      var endValue = RetrieveData(endDate);
      var endName = RetrieveName(endDate);
     Print("Endvalue - ", endValue);
      var change = (mul(notional,(endValue - startValue)) / startValue) * 1000000000000000000; //convert wei to ETH
      var lmargin = long ? margin1 : margin2;
      var smargin = long ? margin2 : margin1;
      var lvalue = smargin - change < 0 ? (this.balance) : (lmargin + change);
      var svalue = lmargin + change < 0 ? (this.balance) : (smargin - change);
      //Validators:
            if(svalue + lvalue != this.balance){throw;}
            if(endName != oracleName){throw;}

    Print ("Change - ", change);
    Print("Lvalue - ", lvalue);
    Print("Svalue - ", svalue);
    if (msg.sender == counterparty1 && counterparty1 != creator){
        if (long && lvalue > 0 ){if (counterparty1.send(lvalue)){counterparty1 = creator;}}
        else if (!long && svalue > 0){if (counterparty1.send(svalue)){counterparty1 = creator;}}
    }
      if (msg.sender == counterparty2 && counterparty2 != creator){
        if(!long && lvalue > 0 ){if (counterparty2.send(lvalue)){counterparty2 = creator;}}
        else if (long && svalue > 0){if (counterparty2.send(svalue)){counterparty2 = creator;}}
    }
      if (this.balance ==0){currentState = SwapState.ended;}
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
      return true;
  }


  struct DocumentStruct{bytes32 name; uint value;}

  function RetrieveData(bytes32 key) public constant returns(uint) {
    DocumentStruct memory doc;
    doc.value = d.documentStructs(key);
    return doc.value;
  }
    function RetrieveName(bytes32 key) public constant returns(bytes32) {
    DocumentStruct memory doc;
    doc.name = d.documentStructs(key);
    return doc.name;
  }

  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

}