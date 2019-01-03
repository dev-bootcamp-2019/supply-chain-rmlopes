//Workaround for the ThrowProxy pattern
//https://stackoverflow.com/questions/50806620/testing-smart-contract-requires-in-truffle-transaction-reverted-if-function-isn
pragma solidity ^0.5.0;

import "../contracts/SupplyChain.sol";

contract SupplyChainWrapper is SupplyChain(){
    function callShipItem(uint _sku) public{
        shipItem(_sku);
    }

    //function() external{

    //}
}
