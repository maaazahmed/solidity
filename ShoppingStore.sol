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

    struct Carts {
        address storeAddress;
        uint productId;
        uint quantity;
        uint total;
    }

    mapping(address=>StoresList) public storesList; 
    
    mapping(address=>mapping(uint=>Carts)) public cartList;
    

    constructor(){
        manager = msg.sender;
    }

    modifier onlyManager (){
       require(msg.sender == manager, "Only manager can perform this task.");
       _;
    }


    function createStore(string memory _storeName) public payable {
        require(msg.sender != manager , "You are manager you cant create store with current address.");
        require(msg.value == 100 wei, "You have to pay 100 wei fee to create a new store");
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


   function addToCart(address buer_address, uint _productId, address _storeAddress ,uint _quantity ) public {
        StoresList storage fineStore =  storesList[_storeAddress]; 
        require(fineStore.owner  == _storeAddress , "Ivalid store!");
        require(fineStore.products[_productId].quantity >= _quantity, "Out of stock");
        Carts storage cart = cartList[buer_address][_productId];
        cart.storeAddress = _storeAddress;
       cart.productId = _productId;
       cart.quantity = _quantity;
      cart.total += cartList[buer_address][_productId-1].total;
   }


    function purchaseNow(uint[] memory cartItems) public payable {
         uint totalAmount = cartList[msg.sender][cartItems[cartItems.length-1]].total; 
         uint reamining = totalAmount;
         require(msg.value >= totalAmount, "You did not pay enough amount of ether" );
        for(uint index = 0; index < cartItems.length; index++){
             Carts storage crt = cartList[msg.sender][cartItems[index]];
             Products storage prd = storesList[crt.storeAddress].products[cartItems[index]]; 
             require(crt.quantity >= prd.quantity, "Out of stock.");
             address payable sendEth  = payable(crt.storeAddress);
             uint payableAmout = (reamining - prd.price) - reamining;
             reamining = reamining - prd.price;
        }    


    }
}