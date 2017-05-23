pragma solidity ^0.4.6;

contract Oracle{
///Add protection (only me and with a password)

  // This is a Type
  struct DocumentStruct{
    // Not possible to pass strings between contracts at this time
    bytes32 name;
    uint value;
  }

  // This is a namespace where we will store docs of Type DocumentStruct
  mapping(bytes32 => DocumentStruct) public documentStructs;

  // Set values in storage
  function StoreDocument(bytes32 key, bytes32 name, uint value) returns (bool success) {
   documentStructs[key].name  = name;
   documentStructs[key].value = value;
   return true;
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

	modifier onlyState(SwapState expectedState) { if (expectedState == currentState) {_;} else {throw; } }

	function Swap(){
		creator = msg.sender;
		currentState = SwapState.available;
	}
	
	Oracle d;

	function CreateSwap(uint _notional, bool _long, address _oracleID, bytes32 _startDate, bytes32 _endDate) onlyState(SwapState.available) payable returns (bool) {
		margin = msg.value;
		counterparty1 = msg.sender;
		notional = _notional;
		long = _long;
		currentState = SwapState.open;
		endDate = _endDate;
		oracleID = _oracleID;
		startValue = RetrieveData(_startDate);
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

		var endValue = RetrieveData(endDate);
		var change = notional * (startValue - endValue) / startValue;
		var lvalue = change >= margin ? (this.balance) : (margin + change);
		var svalue = change <= -margin ? (this.balance) : (margin - change);
		if (lvalue > 0 ){
			if (long){
				counterparty1.send(lvalue);
			}
			else{
				counterparty2.send(lvalue);
			}
		}
		if (svalue > 0){
			if (long){
				counterparty2.send(svalue);
			}
			else{
				counterparty1.send(svalue);
			}
		}
		currentState = SwapState.ended;
		return true;
	}


	 struct DocumentStruct{
	    bytes32 name;
	    uint value;
	  }    

	  function RetrieveData(bytes32 key) 
	    public
	    constant
	    returns(uint) 
	  {
	    var d = Oracle(oracleID);
	    DocumentStruct memory doc;
	    (doc.name, doc.value) = d.documentStructs(key);
	    return doc.value;
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
