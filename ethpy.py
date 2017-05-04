from ethjsonrpc import EthJsonRpc  # to use Parity-specific methods, import ParityEthJsonRpc

base_address = "0xbb1588c5debc2871cd8852c4bd6c6e4cb1d9fe15"
c = EthJsonRpc('127.0.0.1', 8545)
print (c.net_version())
print (c.web3_clientVersion())
print (c.net_listening())
print (c.net_peerCount())
print (c.eth_mining())
print (c.eth_gasPrice())

contract_addr = "0xc1bba31875a1a66eb4794e6e4dd07811fb58b5c5"
my_addr = str(c.eth_coinbase())
print my_addr
tx = c.call_with_transaction(my_addr, contract_addr, 'pushByte(string)', ['Hello, world'])
print (tx)

results = c.call(contract_addr, 'getdata()', [], ['string'])
print(results)