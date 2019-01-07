pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    uint public initialBalance = 1 ether;
    SupplyChain sc;
    SupplyChainUser seller;
    SupplyChainUser buyer;
    SupplyChainUser owner;

    constructor() public payable{}

    function beforeAll() public{
        Assert.equal(address(this).balance, 1 ether, "Contract was not deployed with initial balance of 1 ether");

        //sc = new SupplyChain();
        sc = SupplyChain(DeployedAddresses.SupplyChain());    
        
        seller = new SupplyChainUser();
        buyer = (new SupplyChainUser).value(100)();

        //Add two items 0 and 1
        seller.addItem(sc, "Item0", 10);
        seller.addItem(sc, "Item1", 10);
        //buy item 1 so that it is in state Sold
        buyer.buyItem(address(sc), 1, 10);

        //Sanity check Item0
        (string memory _name, uint _sku, uint _price, uint _state, address _seller, address _buyer) = sc.fetchItem(0);
        Assert.equal(_name, "Item0", "Name of the item does not match the expected value");
        Assert.equal(_sku, 0, "The SKU of the item does not match the expected value");
        Assert.equal(_price, 10, "The price of the item does not match the expected value");
        Assert.equal(_state, 0, "The state of the item does not match the expected value");
        Assert.equal(address(_seller), address(seller), 
                     "The seller address of the item does not match the expected value");
        Assert.equal(address(_buyer), address(0), 
                     "The buyer address of the item does not match the expected value (0)");
        //Sanity check Item1
        (_name, _sku, _price, _state, _seller, _buyer) = sc.fetchItem(1);
        Assert.equal(_name, "Item1", "Name of the item does not match the expected value");
        Assert.equal(_sku, 1, "The SKU of the item does not match the expected value");
        Assert.equal(_price, 10, "The price of the item does not match the expected value");
        Assert.equal(_state, 1, "The state of the item does not match the expected value");
        Assert.equal(address(_seller), address(seller), 
                     "The seller address of the item does not match the expected value");
        Assert.equal(address(_buyer), address(buyer), 
                     "The buyer address of the item does not match the expected value (0)");
    }

    // buyItem

    // test for failure if user does not send enough funds
    function testBuyItemNotEnoughFunds() public {
        uint sku = 0;
        (bool ok, ) = address(buyer).call(
            abi.encodeWithSignature("buyItem(address,uint256,uint256)", address(sc), sku, 1));
        
        Assert.isFalse(ok, "Should be false because not enough funds were sent!");
    }

    // test for purchasing an item that is not for Sale
    function testBuyItemNotForSale() public {
        uint sku = 1;
        
        (bool ok, ) = address(buyer).call(
            abi.encodeWithSignature("buyItem(address,uint256,uint256)", address(sc), sku, 10));
        
        Assert.isFalse(ok, "Should be false because item is already Sold!");
    }
    
    // shipItem

    // test for calls that are made by not the seller
    function testShipItemNotSeller() public {
        uint sku = 1;
        
        (bool ok, ) = address(buyer).call(
            abi.encodeWithSignature("shipItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(ok, "Should be false because the it is not the seller that is shipping the item");
    }

    // test for trying to ship an item that is not marked Sold
    function testShipItemNotSold() public {
        uint sku = 0;
        
        (bool ok, ) = address(seller).call(
            abi.encodeWithSignature("shipItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(ok, "Should be false because the item is not sold yet.");
    }
    
    // receiveItem

    // test calling the function on an item not marked Shipped
    function testReceiveItemNotShipped() public {
        uint sku = 1;

        (bool ok, ) = address(buyer).call(
            abi.encodeWithSignature("receiveItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(ok, "Should be false because the item is notshipped.");
    }

    
    // test calling the function from an address that is not the buyer
    function testReceiveItemNotBuyer() public {
        uint sku = 1;

        seller.shipItem(address(sc),sku);
        (bool ok, ) = address(seller).call(
            abi.encodeWithSignature("receiveItem(address,uint256)", address(sc), sku));
        
        Assert.isFalse(ok, "Should be false because it is not the buyer.");
    }

    function() external{
    }
}

contract SupplyChainUser {

    constructor() public payable{}

    // Functions for the seller
    function addItem(SupplyChain _supplyChain, string memory _item, uint _price) public returns (bool) {
        
        return _supplyChain.addItem(_item, _price);
    }

    function shipItem(address _supplyChain, uint _sku) public {
        SupplyChain tsc = SupplyChain(_supplyChain);
        tsc.shipItem(_sku);
    }

    // Functions for the buyer
    function buyItem(address _supplyChain, uint _sku, uint amount) public{
         SupplyChain tsc = SupplyChain(_supplyChain);
        tsc.buyItem.value(amount)(_sku);

    }

    function receiveItem(address _supplyChain, uint _sku) public {
        SupplyChain tsc = SupplyChain(_supplyChain);
        tsc.receiveItem(_sku);
    }

    function() external payable{
        //revert("Reverted transaction on SupplyChainUser");
    }
}

