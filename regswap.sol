
contract Swap {

	struct Counterparty1 {
		address public constant Counterparty1;
		enum State { Type1, Type2, Type3, Non_ECP } State public ECP_Flag_1;
		uint Margin1;
		uint Margin2;
		bool Long;
		}
	struct Counterparty2 {
		address public constant Counterparty2;
		enum State { Type1, Type2, Type3, Non_ECP } State public ECP_Flag_2;
	}
  
  uint256 public Notional;
  string public OracleID;
  uint public Duration;
  bool public Cancellations;
  bool ended;
  string public Creator; ///contract hash with creator nonce
///Basic swap contract
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);

//take margin from party1 and place it on the blockchain
function Swap (address Owner, bool ECP_Flag_1, uint256 Notional, uint256 Margin, address OracleID, uint256 duration, bool Cancellations) {
	if (ECP_Flag_1 = Non_ECP ) throw;
	if (balances[Owner] < Margin) return;
	//take money into contract


}

//take margin from party2 and place it on the blockchain
function EnterSwap (address Counterparty2 bool 	ECP_Flag_2) {
	if (ended) throw;
	if (ECP_Flag_1 = Non_ECP ) throw;
	if (ECP_Flag_2 = Non_ECP ) throw;
	if (Counterparty2 = Counterparty1) throw;
	StartValue = OracleValue * Notional;
	//take money into contract and start the swap



}

//Calculate payments and pay at the end of the swap
function PaySwap () {
	if (ECP_Flag_1 = Non_ECP ) throw;
	if (ECP_Flag_2 = Non_ECP ) throw;
	if (ended) throw;
	if (now > StartDate + Duration) {
            // Get current value of swap and pay out max of margin or oraclevalue * notional
            EndValue = OracleValue * Notional;
            if (msg.sender = Counterparty1){
            	if (long){
            		if (EndValue - StartValue > margin2) {
             			payement = margin2;
            		}
             		else {
             			payment = EndValue - StartValue;
             		}
             		if (payment <=0) throw;
             	}
             	else{
             		if (StartValue- EndValue > margin2) {
             			payement = margin2;
            		}
             		else {
             			payment = StartValue - EndValue;
             		}
             		if (payment <=0) throw;
             	}
             	Counterparty1.send(payment);
             else{
            	if (!long){
            		if (EndValue - StartValue > margin1) {
             			payement = margin1;
            		}
             		else {
             			payment = EndValue - StartValue;
             		}
             		if (payment <=0) throw;
             	}
             	else{
             		if (StartValue- EndValue > margin1) {
             			payement = margin1;
            		}
             		else {
             			payment = StartValue - EndValue;
             		}
             		if (payment <=0) throw;
             	}
             	Counterparty2.send(payment);
            ended = true;
        		}
       		}
        }
}

function ExitSwap () {
	if (Cancellations = False) throw;
	if (ended) throw;



}


function(){
	throw;
}

}