
contract Oracle{
  function Oracle();
  function update(bytes32 newCurrent);
  function current()constant returns(bytes32 current);
}