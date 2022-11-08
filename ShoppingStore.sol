// SPDX-License-Identifier: GPL-3.0


pragma solidity >= 0.7.0 < 0.9.0;


contract DCStore {
   address public manager;
    struct Products {
       string productName;
       uint price; 
       uint quantity;
    }

    struct StoresList {
        string storeName;
        address  owner;
        uint itemID;
        mapping(uint=>Products) products;
    }

    mapping(address=>StoresList) public storesList; 
    

    constructor(){
        manager = msg.sender;
    }

    modifier onlyManager (){
       require(msg.sender == manager, "Only manager can perform this task.");
       _;
    }


    function createStore(string memory _storeName) public payable {
        require(msg.sender != manager , "You are manager you cant create store with current address.");
        require(msg.value == 1 ether, "You have to pay 10 wei fee to create a new store");
        address payable sendFee = payable(manager);
        StoresList storage newStore = storesList[msg.sender];
        newStore.storeName = _storeName;
        newStore.owner = msg.sender;
        sendFee.transfer(msg.value);
    }

    function getContractBalance () public view onlyManager returns(uint){
        return address(this).balance;
    }


    function createPorduct(string memory _proName, uint _price,  uint _quantity) public {
           StoresList storage myStore = storesList[msg.sender];
           Products storage  newProduct = myStore.products[myStore.itemID]; 
           newProduct.productName = _proName;
           newProduct.price = _price;
           newProduct.quantity = _quantity;
           myStore.itemID++;
    }
  
}