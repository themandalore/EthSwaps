
pragma solidity ^0.4.6;
///add safe math?
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

  address public Counterparty1;
  uint public Margin1;
  uint public Margin2;
  bool public Long;
  address public Counterparty2;
  uint256 public Notional;
  address public OracleID;
  bytes32 public EndDate;
  bool public Cancellations;
  string public SwapState; //use open,started,ended
  string public Creator; ///contract hash with creator nonce
  uint256 public StartValue;

 Oracle oracle;

///Basic swap contract
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);

//take margin from party1 and place it on the blockchain
function Swap (address _Owner, uint256 _Notional, uint256 _Margin1, uint256 _Margin2, address _OracleID, bytes32 _EndDate, bool _Cancellations) {
  if (balanceOf(_Owner) < Margin1) throw;
  SwapState = "open";
  Counterparty1  = _Owner;
    Notional = _Notional;
    if (msg.value < _Margin1) throw;
    else Margin1 = _Margin1;
    if (msg.value > _Margin1) {
       var ref = msg.value - Margin1;
       msg.sender.transfer(ref);
      }
    Margin2 = _Margin2;
    OracleID = _OracleID;
    EndDate = _EndDate;
    Cancellations = _Cancellations;
  //take money into contract
}

//take margin from party2 and place it on the blockchain
function EnterSwap (address Counterparty2, bytes32 _startDate) {
  if (Counterparty2 == Counterparty1) throw;
  if (msg.value < Margin2) throw;
    else Margin2 = Margin2;
    if (msg.value > Margin2) {
       var ref = msg.value - Margin2;
       msg.sender.transfer(ref);
  SwapState = "started";
  var OracleValue = RetrieveData(_startDate);
  StartValue = OracleValue * Notional;

  //take money into contract and start the swap
} }

//Calculate payments and pay at the end of the swap
function PaySwap () {
  var OracleValue = RetrieveData(EndDate);
  if (OracleValue >0) {
            // Get current value of swap and pay out max of margin or oraclevalue * notional
            var EndValue = OracleValue * Notional;
            if (msg.sender == Counterparty1){
              if (Long){
                var change = EndValue - StartValue;
                var payment = change > Margin2 ? Margin2 : change;
                if (payment <=0) throw;
                Counterparty1.transfer(payment);
              }
              else{
                var change1 = StartValue - EndValue;
                var payment1 = change1 > Margin2 ? Margin2 : change1;
                if (payment1 <=0) throw;
                Counterparty1.transfer(payment1);
              }
              
            }
             else{
              if (!Long){
          var change2 = StartValue-EndValue;
                var payment2 = change > Margin1 ? Margin1 : change2;
                if (payment2 <=0) throw;
                Counterparty2.transfer(payment2);
              }
              else{
                var change3 = EndValue-StartValue;
                var payment3 = change3 > Margin1 ? Margin1 : change3;
                if (payment3 <=0) throw;
                Counterparty2.transfer(payment3);
              }
              }

            SwapState = "ended";
            }
}

function ExitSwap () {
  if (!Cancellations) throw;
    Counterparty1.transfer(Margin1);
    Counterparty2.transfer(Margin2);
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
    oracle = Oracle(OracleID);
    DocumentStruct memory doc;
    (doc.name, doc.value) = oracle.documentStructs(key);
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

function(){
  throw;
}

}