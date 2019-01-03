pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "../contracts/SupplyChainWrapper.sol";
import "../contracts/ThrowProxy.sol";

contract TestSupplyChain {

    uint public initialBalance = 1 ether;
    SupplyChainWrapper sc;
    ThrowProxy throwproxy;
    SupplyChainUser seller;
    SupplyChainUser buyer;
    SupplyChainUser owner;

    constructor() public payable{}

    function beforeAll() public{
        Assert.equal(address(this).balance, 1 ether, "Contract was not deployed with initial balance of 1 ether");

        //sc = new SupplyChain();
        //sc = SupplyChain(DeployedAddresses.SupplyChain());    
        sc = SupplyChainWrapper(DeployedAddresses.SupplyChainWrapper());    
        throwproxy = new ThrowProxy(address(sc)); 

        seller = new SupplyChainUser();
        buyer = (new SupplyChainUser).value(100)();
    }
    
    function testConstructor() public{
        Assert.equal(sc.skuCount(), 0, "SKU count should be initialized to 0.");
        Assert.equal(sc.owner(), msg.sender, "The owner of the contract should be initialized.");
    }
    
    // This adds an item with price 10 wei
    function testAddItem() public {
        string memory name = "The Item";
        uint price = 10 wei;
        uint expectedSKU = 0;
        uint expectedState = 0;
        address expectedSeller = address(seller);
        address expectedBuyer = address(0);

        seller.addItem(sc, name, price);
        
        (string memory _name, uint _sku, uint _price, uint _state, address _seller, address _buyer) = sc.fetchItem(expectedSKU);

        Assert.equal(_name, name, "Name of the item does not match the expected value");
        Assert.equal(_sku, expectedSKU, "The SKU of the item does not match the expected value");
        Assert.equal(_price, price, "The price of the item does not match the expected value");
        Assert.equal(_state, expectedState, "The state of the item does not match the expected value");
        Assert.equal(_seller, expectedSeller, "The seller address of the item does not match the expected value");
        Assert.equal(_buyer, expectedBuyer, "The buyer address of the item does not match the expected value (0)");
    }

    // Ship Item
    function testShipItemVerifyCaller() public {
        //string memory expectedName = "The Item";
        uint expectedSKU = 0;
        //uint expectedState = 1;
        uint sellerInitBalance = address(seller).balance;
        uint buyerInitBalance = address(buyer).balance;
        
        Assert.equal(sellerInitBalance, 0, "Buyer initial balance should be 0.");
        Assert.equal(buyerInitBalance, 100, "Buyer initial balance should be 100 wei.");
        
        (string memory _name, uint _sku, uint _price, uint _state, address _seller, address _buyer) = sc.fetchItem(expectedSKU);
        Assert.equal(_state, 0, "Item should be in state ForSale");
        
        buyer.buyItem(sc, 0, 10);
        (_name, _sku, _price, _state, _seller, _buyer) = sc.fetchItem(expectedSKU);
        Assert.equal(_state, 1, "Item should be in state Sold");
        
        //Even if the seller ships the item the test will return False (??)
        seller.shipItem(SupplyChainWrapper(address(throwproxy)), 0);

        // If we ship it without the throwproxy then its ok!
        //seller.shipItem(sc, 0);
        (_name, _sku, _price, _state, _seller, _buyer) = sc.fetchItem(expectedSKU);
        Assert.equal(_state, 2, "Item should be in state Shipped");
        

        bool r = throwproxy.execute.gas(200000)();
        Assert.isFalse(r, "Should be false because the it is not the seller that is shipping the item");

    }

    // buyItem

    // test for failure if user does not send enough funds
    // test for purchasing an item that is not for Sale

    // function testBuyItemNotEnoughFunds() public {
    //     string memory expectedName = "The Item";
    //     uint expectedSKU = 0;
    //     uint expectedState = 1;
    //     uint sellerInitBalance = address(seller).balance;
    //     uint buyerInitBalance = address(buyer).balance;
        
    //     Assert.equal(sellerInitBalance, 0, "Buyer initial balance should be 0.");
    //     Assert.equal(buyerInitBalance, 100, "Buyer initial balance should be 100 wei.");
        
    //     buyer.buyItem(SupplyChain(address(throwproxy)), 0, 1);
    //     bool r = throwproxy.execute.gas(200000)();
    //     Assert.isFalse(r, "Should be false because not enough functionds were sent!");
    // }

    

    function() external{
    }
}

contract SupplyChainUser {

    constructor() public payable{}

    // Functions for the seller
    function addItem(SupplyChain _supplyChain, string memory _item, uint _price) public returns (bool) {
        
        return _supplyChain.addItem(_item, _price);
    }

    function shipItem(SupplyChainWrapper _supplyChain, uint _sku) public {
        
        _supplyChain.callShipItem(_sku);
        //_supplyChain.shipItem(_sku);
    }

    // Functions for the buyer
    function buyItem(SupplyChain _supplyChain, uint _sku, uint amount) public{
         
        _supplyChain.buyItem.value(amount)(_sku);

    }

    function receiveItem(SupplyChain _supplyChain, uint _sku) public {

        _supplyChain.receiveItem(_sku);
    }

    function() external payable{
    }
}

