
/* To do:
Update to 4.13
*/
pragma solidity ^0.4.13;


contract Factory {
    address[] public newContracts;
    address public creator;
    modifier onlyOwner{require(msg.sender == creator); _;}
    event Print(address _name, address _value);
    event Print2(uint _name);

    function Factory (){
        creator = msg.sender;  
    }

    function createContract () payable returns (address){
        require(msg.value >= .01 * 1000000000000000000);
        Print2(this.balance);
        address newContract = new Swap(msg.sender,creator);
        newContracts.push(newContract);
        Print(msg.sender,newContract);
        Print2(this.balance);
        return newContract;
    } 
    function withdrawFee() onlyOwner {
        creator.transfer(this.balance);
    }
}

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Swap is usingOraclize{
  enum SwapState {open,started,ready,ended}
  SwapState public currentState;
  address public long_party;
  address public short_party;
  uint public notional;
  uint public lmargin
  uint public smargin
  string public url;
  uint public duration;
  uint public startValue;
  uint public endValue;
  bytes32 s_id;
  bytes32 e_id;
  address public creator;
  uint public cancel;
  bool long;
  address party;


  event Print(string _name, uint _value);
    mapping(address => uint256) balances;

modifier onlyState(SwapState expectedState) { if (expectedState == currentState) {_;} else {throw; } }

  function Swap(address _cpty1, address _creator){
      creator = _creator;
      party = _cpty1;
  }

 
  function CreateSwap(string _url, uint _duration, uint _margin, uint _margin2, uint _notional, bool _long) payable {
      require (msg.sender == party);
      require(msg.value == mul(_margin,1000000000000000000));
      url = _url;
      cancel = 0;
      notional = _notional;
      long = _long;
      currentState = SwapState.open;
      duration = _duration;
      if (long){long_party = msg.sender;
        lmargin = mul(_margin,1000000000000000000);
        smargin = mul(_margin2,1000000000000000000);}
      else {short_party = msg.sender;
        smargin = mul(_margin,1000000000000000000);
        lmargin = mul(_margin2,1000000000000000000);
      }
      Print('Margin- ',margin1);
      log0("Testing Log");
      //Validators:
  }
  mapping(address => bool) paid;
  function EnterSwap() onlyState(SwapState.open) payable returns (bool) {
      if (long) {short_party = msg.sender;
      require(msg.value >= smargin);
        }
      else {long_party = msg.sender;
      require(msg.value >=lmargin);
        }
      paid[long_party] = false;
      paid[short_party] = false;
      s_id = oraclize_query("URL",url);
      e_id = oraclize_query(duration,"URL",url);
      currentState = SwapState.started;
      return true;
  }

    function __callback(bytes32 _oraclizeID, uint _result) {
      require(msg.sender == oraclize_cbAddress());
      if (_oraclizeID  == s_id){
        startValue = mul(_result, 100000);
      }
      else if (_oraclizeID == e_id){
        endValue = mul(_result,100000);
        currentState = SwapState.ready;
      }
      else throw;
    }
  

  mapping(uint => uint) shares;


  function PaySwap() onlyState(SwapState.ready) returns (bool){
    Print("Counterparty1 Balance - ", long_party.balance);
    Print("Counterparty2 Balance - ", short_party.balance);
    Print("Contract Balance - ", this.balance);
    Print("Endvalue - ", endValue);
    uint p1=div(mul(1000,RetrieveData(endDate)),RetrieveData(startDate));
        if (p1 == 1000){
            shares[1] = lmargin;
            shares[2] = smargin;
        }
          if (p1<1000){
              if(mul(sub(1000,p1),1000000000000000000)>lmargin){shares[1] = 0; shares[2] =this.balance;}
              shares[1] = mul(mul(sub(1000,p1),notional),div(1000000000000000000,1000));
              shares[2] = this.balance -  shares[1];
          }
          
          else if (p1 > 1000){
               if(mul(sub(p1,1000),1000000000000000000)>smargin){shares[2] = 0; shares[1] =this.balance;}
               shares[2] = mul(mul(sub(1000,p1),notional),div(1000000000000000000,1000));
               shares[1] = this.balance - mul(shares[2],div(1000000000000000000,1000));
          }
    Print("Lvalue - ", lvalue);
    Print("Svalue - ", svalue);
      //Validators:
  if (msg.sender == long_party && paid[long_party] == false){
        paid[long_party] = true;long_party.send(shares[1]);
    }
    else if (msg.sender == short_party && paid[short_party] == false){
        paid[short_party] = true;short_party.send(shares[2]);
    }
    if (paid[long_party] && paid[short_party]){currentState = SwapState.ended;}
    return true;
    Print("Counterparty1 Balance - ", long_party.balance);
    Print("Counterparty2 Balance - ", short_party.balance);
    Print("Contract Balance - ", this.balance);
    return true;
  }
  function Exit(){
    require(currentState != SwapState.ended);
    if (currentState == SwapState.open){
    if (msg.sender == party) selfdestruct(party);
    }

  else if (currentState == SwapState.started){
    var c = msg.sender == long_party ? 1 : 0;
    var d = msg.sender == short_party ? 2 : 0;
    var e = cancel + c + d;
    cancel = c + d;
    if (e > 2){
      if (msg.sender == short_party){ 
        long_party.send(lmargin);
        short_party.send(smargin);
      }
      else if (msg.sender == long_party){ 
        short_party.send(smargin);
        long_party.send(lmargin);
        }

      }
    }

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
