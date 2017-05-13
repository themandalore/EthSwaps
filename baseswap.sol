
pragma solidity ^0.4.6;
///add safe math?

contract Swap {

  address public constant Counterparty1;
  uint public Margin1;
  uint public Margin2;
  bool public Long;
  address public Counterparty2;
  uint256 public Notional;
  address public OracleID;
  uint public EndDate;
  bool public Cancellations;
  string public SwapState; //use open,started,ended
  string public Creator; ///contract hash with creator nonce
  uint256 public StartValue;

 Oracle oracle;

///Basic swap contract
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);

//take margin from party1 and place it on the blockchain
function Swap (address _Owner, uint256 _Notional, uint256 _Margin1, uint256 _Margin2, address _OracleID, uint256 _EndDate, bool _Cancellations) {
	if (length(SwapState) > 0) throw;
	if (balances[_Owner] < Margin) return;
	SwapState = "open";
	counterparty1[1].Counterparty1  = _Owner;
    Notional = _Notional;
    if (msg.value < _Margin1) throw;
    else Margin1 = _Margin1;
    if (msg.value > _Margin1) {
    	 ref = msg.value - Margin1;
    	 msg.sender.transfer(ref);
    	}
    Margin2 = _Margin2;
    OracleID = _OracleID;
    EndDate = _EndDate;
    Cancellations = _Cancellations;
    return true;
	//take money into contract
}

//take margin from party2 and place it on the blockchain
function EnterSwap (address Counterparty2) {
	if (SwapState != "open") throw;
	if (Counterparty2 == Counterparty1) throw;
	if (msg.value < _Margin2) throw;
    else Margin2 = _Margin2;
    if (msg.value > _Margin2) {
    	 ref = msg.value - Margin2;
    	 msg.sender.transfer(ref);
	SwapState = "started";
	StartValue = OracleValue * Notional;
	return true;
	//take money into contract and start the swap
}
}

//Calculate payments and pay at the end of the swap
function PaySwap () {
	if (SwapState == "ended") throw;
	var OracleName, OracleValue = RetrieveData(bytes32 EndDate);
	if (length(OracleName) >0) {
            // Get current value of swap and pay out max of margin or oraclevalue * notional
            EndValue = OracleValue * Notional;
            if (msg.sender == Counterparty1){
            	if (long){
            		var change = EndValue - StartValue;
            		var payment = change > margin2 ? margin2 : change;
             		if (payment <=0) throw;
             	}
             	else{
             		var change = StartValue - EndValue;
            		var payment = change > margin2 ? margin2 : change;
             		if (payment <=0) throw;
             	}
             	Counterparty1.send(payment);
             else{
            	if (!long){
					var change = StartValue-EndValue;
            		var payment = change > margin1 ? margin1 : change;
             		if (payment <=0) throw;
             	}
             	else{
             		var change = EndValue-StartValue;
            		var payment = change > margin1 ? margin1 : change;
             		if (payment <=0) throw;
             	}
             	}
             	Counterparty2.send(payment);
            SwapState = "ended";
        		}
       		}
}

function ExitSwap () {
	if (Cancellations == False) throw;
	if (SwapState == "ended") throw;
		Counterparty1.send(Margin1);
	if (SwapState=="started") {
		Counterparty2.send(Margin2);
	}
	return true;
}

 struct DocumentStruct{
    bytes32 name;
    uint value;
  }    

  function RetrieveData(bytes32 key) 
    public
    constant
    returns(string, uint) 
    oracle = Oracle(OracleID);
  {
    DocumentStruct memory doc;
    (doc.name, doc.value) = oracle.documentStructs(key);
    var tname = bytes32ToString(doc.name);
    return(tname, doc.value);
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

function(){
	throw;
}

}