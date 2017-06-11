'''pragma solidity ^0.4.11;

contract Oracle{
    address private owner;
    event Print(string _name, uint _value);
    modifier onlyOwner{if (msg.sender != owner){throw;}else{_;}}
    struct DocumentStruct{bytes32 name; uint value;}
    mapping(bytes32 => DocumentStruct) public documentStructs;
    
    function Oracle(){
        owner = msg.sender;
        var  zz = 999;
        Print('Success',zz);
    }
    function StoreDocument(bytes32 key,bytes32 name, uint value) onlyOwner returns (bool success) {
        documentStructs[key].value = value;
        documentStructs[key].name = name;
        Print(bytes32ToString(name),value);
        return true;
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
'''
true = True
false = False
abi='[{"constant":true,"inputs":[{"name":"","type":"bytes32"}],"name":"documentStructs","outputs":[{"name":"name","type":"bytes32"},{"name":"value","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"x","type":"bytes32"}],"name":"bytes32ToString","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"key","type":"bytes32"},{"name":"name","type":"bytes32"},{"name":"value","type":"uint256"}],"name":"StoreDocument","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_name","type":"string"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Print","type":"event"}]'
contractAddress = '0x03e127e882c49a55b70275ba0c94c50c268b1183'

from web3 import Web3
import json
from web3.providers.rpc import HTTPProvider



web3 = Web3(HTTPProvider('https://ropsten.infura.io'))

abi1 = json.loads(abi)
print (web3.eth.blockNumber)
bytecode = web3.eth.getCode(contractAddress)
print (bytecode)
oContract = web3.eth.contract(abi1)
print (oContract)
oCI = oContract.at(contractAddress)
oCI.

#abi is swap API created from factory
sContract = web3.eth.contract(abi);

def getSwaps(state,number,factory)
	#get list of contracts created from factory and loop through
	for i in factory:
		sCI = sContract.at(saddress);
		print (sCI.currentState.call())
		if sCI.currentState.call() = state:
			currentState = sCI.currentState.call()
			counterparty1 = sCI.counterparty1.call()
			counterparty2 = sCI.counterparty2.call()
			notional = sCI.notional.call()
			s_long = sCI.long.call()
			margin1 = sCI.margin1.call()
			margin2 = sCI.margin2.call()
			oracleID = sCI.oracleID.call()
			oracleName = sCI.oracleName.call()
			startDate = sCI.startDate.call()
			endDate	= sCI.endDate.call()
			creator = sCI.creator.call()
			cancellable = sCI.cancellable.call()
			cancel = sCI.cancel.call()


			#make array and append it to file.  
			#create dataframe?  of all open contracts


'''Have a contract to create new swaps'''



#Get list of all new swaps (all new contracts)




#Loop through those contracts backwards and build out orderbook