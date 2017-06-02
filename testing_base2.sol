pragma solidity ^0.4.11;

/*To fix
figure out transfer vs send
add in exit functionality
add only creator and two counterparties can edit things

*/

contract Oracle{
    address private owner;
    event Print(uint _value);
    modifier onlyOwner{if (msg.sender != owner){throw;}else{_;}}
    function Oracle(){owner = msg.sender;}
    struct DocumentStruct{uint value;}
    mapping(bytes32 => DocumentStruct) public documentStructs;

    function StoreDocument(bytes32 key, uint value) onlyOwner returns (bool success) {
        documentStructs[key].value = value;
        return true;
    }

    function RetrieveData(bytes32 key) public constant returns(uint) {
        var d = documentStructs[key].value;
        Print(d);
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
  uint public margin;
  address public oracleID;
  bytes32 public endDate;
  address public creator;
  uint256 public startValue;

  event Print(string _name, uint _value);
    mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) { if (expectedState == currentState) {_;} else {throw; } }
modifier onlyCreator{if (msg.sender != creator){throw;}else{_;}}

function Swap(address OAddress){
    d = Oracle(OAddress);
    oracleID = OAddress;
    creator = msg.sender;
    currentState = SwapState.available;
}

Oracle d;

  function CreateSwap(uint _notional, bool _long, bytes32 _startDate, bytes32 _endDate) onlyState(SwapState.available) payable returns (bool) {
      margin = msg.value;
      counterparty1 = msg.sender;
      notional = _notional;
      long = _long;
      currentState = SwapState.open;
      endDate = _endDate;
      startValue = RetrieveData(_startDate);
      Print('StartValue- ',startValue);
      Print('Margin- ',margin);
      log0("Testing Log");
      return true;
  }

  function EnterSwap() onlyState(SwapState.open) payable returns (bool) {
      if(msg.value == margin) {
          counterparty2 = msg.sender;
          currentState = SwapState.started;
          return true;
      } else {
        throw;
      }
  }

  function PaySwap() onlyState(SwapState.started) returns (bool){
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
      var endValue = RetrieveData(endDate);
     Print("Endvalue - ", endValue);
      var change = (mul(notional,(endValue - startValue)) / startValue) * 1000000000000000000; //convert wei to ETH
      var lvalue = margin - change < 0 ? (this.balance) : (margin + change);
      var svalue = margin + change < 0 ? (this.balance) : (margin - change);
    Print ("Change - ", change);
    Print("Lvalue - ", lvalue);
    Print("Svalue - ", svalue);
      if (long && lvalue > 0 ){
            counterparty1.send(lvalue);
      }
      else if (lvalue > 0) {
          counterparty2.send(lvalue);
      }
      if (long && svalue > 0){
          counterparty2.send(svalue);
      }
      else if (svalue > 0){
          counterparty1.send(svalue);
      }
      currentState = SwapState.ended;
    Print("Counterparty1 Balance - ", counterparty1.balance);
    Print("Counterparty2 Balance - ", counterparty2.balance);
    Print("Contract Balance - ", this.balance);
      return true;
  }


  struct DocumentStruct{
    uint value;
  }    
  function RetrieveData(bytes32 key) public constant returns(uint) {
    DocumentStruct memory doc;
    doc.value = d.documentStructs(key);
    return doc.value;
  }

  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

}