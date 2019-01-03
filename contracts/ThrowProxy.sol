pragma solidity ^0.5.0;

// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bytes public data;

  constructor(address _target) public {
    target = _target;
  }

  //prime the data using the fallback function.
  function() external{
    data = msg.data;
  }

  function execute() public returns (bool) {
    (bool r, bytes memory b) = target.call(data);
    return r;
  }
}