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

'''This is a contract on Ropsten with 2 contracts deployed
0x16c73e20ba46a20ecd6a78b5040d49b2358c5366
0xd812626afd1c5a38f7428b23d8142d9e87bf544b
'''

from web3 import Web3
import json
from web3.providers.rpc import HTTPProvider
contractAddress = '0x3c7bec02bd4fa73dce24413d2a13c02e1a91e858'
web3 = Web3(HTTPProvider('https://ropsten.infura.io'))
with open('factory.json', 'r') as abi_definition:
    abi = json.load(abi_definition)
print (web3.eth.blockNumber)

#abi is swap API created from factory
fContract = web3.eth.contract(abi,contractAddress)
print (fContract.abi)
print ('Creator',fContract.call().creator)
print ('Contracts',fContract.call().newContracts)
var1 = fContract.call()._oracleName
var2 = fContract.call().oracleName

print()
print ('var1',var1)
print()
print ('var2',var2)
print()
print ('OracleName',fContract.call())

wei_balance = web3.eth.getBalance(contractAddress)
print(wei_balance)

print(fContract.call().oracleID)
print(fContract.call()._creator)
print(fContract.call().newContracts)

'''
print (fContract)
fInstance = fContract.at([contractAddress])
fInstance.call().newContracts()'''




def getSwaps(state,number,factory):
	#get list of contracts created from factory and loop through
	with open('SwapsList.csv','a') as fd:
		writer = csv.writer(fd)
		writer.writerow(['currentState','counterparty1','counterparty2','notional','s_long','margin1','margin2','oracleID','oracleName','startDate','endDate','creator','cancellable','cancel'])
	for i in factory:
		'''sCI = sContract.at(saddress);
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
			with open('SwapsList.csv','a') as fd:
				writer = csv.writer(fd)
				writer.writerow([str(currentState)
					,str(counterparty1)
					,str(counterparty2)
					,str(notional)
					,str(s_long)
					,str(margin1)
					,str(margin2)
					,str(oracleID)
					,str(oracleName)
					,str(startDate)
					,str(endDate)
					,str(creator)
					,str(cancellable)
					,str(cancel)])
				


			#make array and append it to file.  
			#create dataframe?  of all open contracts'''


'''Have a contract to create new swaps'''



#Get list of all new swaps (all new contracts)




#Loop through those contracts backwards and build out orderbook