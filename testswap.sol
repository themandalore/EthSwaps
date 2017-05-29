pragma solidity ^0.4.6;

contract Swap {
	address public counterparty1;
	address public counterparty2;
	uint public notional;
	uint public margin;

	function Swap(uint _notional)  payable{
		margin = msg.value;
		counterparty1 = msg.sender;
		notional = _notional;
	}

	function EnterSwap()  payable returns (bool) {

		if(msg.value == margin) {
     		counterparty2 = msg.sender;
      		return true;
	    } else {
	      throw;
	    }
	}

	function PaySwap(address winner) returns (bool){

		winner.send(this.balance);
		return true;
	}

}