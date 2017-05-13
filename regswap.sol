
pragma solidity ^0.4.0;
///add safe math?

contract Swap {
	event ContractStart(address bidder, uint amount); // Event
	event ContractEnd(address bidder, uint amount); // Event 
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	struct Counterparty1 {
		address public constant Counterparty1;
		enum State { Type1, Type2, Type3, Non_ECP } State public ECP_Flag_1;
		uint Margin1;
		uint Margin2;
		bool Long;
		}

	 mapping(bytes32 => Counterparty1) public counterparty1;

	struct Counterparty2 {
		address public constant Counterparty2;
		enum State { Type1, Type2, Type3, Non_ECP } State public ECP_Flag_2;
	}

	mapping(bytes32 => Counterparty2) public counterparty2;
  
  uint256 public Notional;
  address public Oracle;
  uint public EndDate;
  bool public Cancellations;
  bool ended;
  string public Creator; ///contract hash with creator nonce

 ///Get Oracle part

  // "oracle" is of type "Oracle" which is a contract ^
  Oracle oracle;

  // Define the Type in this context
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
    // Declare a temporary "doc" to hold a DocumentStruct
    DocumentStruct memory doc;
    // Get it from the "public" mapping's free getter.
    (doc.name, doc.value) = oracle.documentStructs(key);
    // return values with a fixed sized layout
    var tname = bytes32ToString(doc.name);
    return(tname, doc.value);
  }
  
///Basic swap contract
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);

//take margin from party1 and place it on the blockchain
function Swap (address Owner, bool ECP_Flag_1, uint256 Notional, uint256 Margin, address OracleID, uint256 EndDate, bool Cancellations) {
	if (ECP_Flag_1 == Non_ECP ) throw;
	if (balances[Owner] < Margin) return;
	//take money into contract


}

//take margin from party2 and place it on the blockchain
function EnterSwap (address Counterparty2 bool 	ECP_Flag_2) {
	if (ended) throw;
	if (ECP_Flag_1== Non_ECP ) throw;
	if (ECP_Flag_2 == Non_ECP ) throw;
	if (Counterparty2 == Counterparty1) throw;
	StartValue = OracleValue * Notional;
	//take money into contract and start the swap
}

function transfer(address _to, uint256 _value) returns (bool success){

}
//Calculate payments and pay at the end of the swap
function PaySwap() payable {
	if (ECP_Flag_1 == Non_ECP ) throw;
	if (ECP_Flag_2 == Non_ECP ) throw;
	if (ended) throw;
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
            ended = true;
        		}
       		}
        }
}

function ExitSwap () {
	if (Cancellations == False) throw;
	if (ended) throw;
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