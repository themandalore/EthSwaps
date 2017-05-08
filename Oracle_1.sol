pragma solidity ^0.4.6;

contract Oracle{

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

contract E {

  // "d" is of type "Oracle" which is a contract ^
  Oracle d;

  // Define the Type in this context
  struct DocumentStruct{
    bytes32 name;
    uint value;
  }    

  // For this to work, pass in D's address to E's constructor
  function E(address DContractAddress) {
    d = Oracle(DContractAddress);
  }

  function RetrieveData(bytes32 key) 
    public
    constant
    returns(bytes32, uint) 
  {
    // Declare a temporary "doc" to hold a DocumentStruct
    DocumentStruct memory doc;
    // Get it from the "public" mapping's free getter.
    (doc.name, doc.value) = d.documentStructs(key);
    // return values with a fixed sized layout
    return(doc.name, doc.value);
  }
}