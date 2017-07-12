pragma solidity ^0.4.11;

/*
"json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0",60

*/
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Swap is usingOraclize{
  string public url;
  uint public duration;
  uint public startValue;
  uint public endValue;

event Print(string _name, uint _value);

 function Swap(string _url, uint duration){
      url = _url;
      s_id = oraclize_query("URL",url);
      e_id = oraclize_query(_duration,"URL",url);
  }
 
   function __callback(bytes32 _oraclizeID, uint _result) {
      if(msg.sender != oraclize_cbAddress()) throw;
      if (_oracleID  == s_id){
        startValue = _result;
      }
      else if (_oracleID == e_id){
        endValue = _result;
      }
      else throw;
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

