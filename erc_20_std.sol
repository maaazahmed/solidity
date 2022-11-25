// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

abstract contract ERC20_STDD {
    function name() public view virtual returns(string memory)  {}

    function symbol() public view virtual returns(string memory) {}

    function decimals() public view virtual returns(uint) {}

    function totalSupply() public view virtual returns(uint) {}

    function balanceOf(address _owner) public view virtual returns(uint) {}

    function transfer(address _to, uint256 _value) public virtual {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public virtual {}

    function approve(address _spender, uint256 _value) public virtual returns(bool success){}

    function allowance(address _owner, address _spender) public virtual returns(uint reamining) {}



    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract OwnerShip {
     address contractOwner;
     address newOwner;

      event TransferOwnership(address indexed _from, address indexed _to);


     constructor(){
         contractOwner = msg.sender;
     }

    function changeOwner(address  _to_) public  {
        require(contractOwner == msg.sender, "Only Owner can call it!");
        newOwner = _to_;
    }

    function acceptOwner() public {
        require(msg.sender == newOwner, "Only new assigend owner call it!");
        emit TransferOwnership(contractOwner, newOwner);
        contractOwner = newOwner;
        newOwner = address(0);
    }
}



contract MyERC20 is ERC20_STDD,OwnerShip{
    string _name;
    string _symbol;
    uint _decimals;
    uint _totalSupply;

    address _minter; 

    mapping(address => uint256) tokenBalance;


    mapping(address=>mapping(address=>uint)) allowed;

    constructor(address _minter_){
        _name = "Test Token";
        _symbol = "TTC";
        _totalSupply = 1000000;
        _minter = _minter_;
        tokenBalance[_minter] = _totalSupply;
    }

    function name() public view override returns (string memory) {
           return _name;
    }

    function symbol() public view override returns(string memory){
        return _symbol;
    } 


    function decimals() view public override returns(uint){
        return _decimals;
    }


   function totalSupply() view public override returns(uint){
       return _totalSupply;
   }


   function balanceOf(address _owner) view public override returns(uint){
       return tokenBalance[_owner];
   }


   function transfer(address _to, uint _value) public override{
        require(tokenBalance[msg.sender] >= _value, "Insuficent Tokken!");
        tokenBalance[msg.sender] -= _value;
        tokenBalance[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
   }



  function transferFrom(address _from, address _to, uint _value) override public {
      uint allowedBal = allowed[_from][msg.sender];
      require(allowedBal >= _value, "Insuficent Tokken!");
      tokenBalance[_from] -= _value;
      tokenBalance[_to] += _value; 
      emit Transfer(_from, _to, _value);
    //   require(allowed[msg.sender][_from] >= _value, "You cannot send ");
  }



  // Function will be called when  someone allow to spned this token   
  function approve(address _spender_, uint _value) public override returns(bool success) {
      require(tokenBalance[msg.sender]>= _value,"Not Enough Token");
      allowed[msg.sender][_spender_] = _value;
      emit Approval(msg.sender, _spender_, _value);
      return true;
  }


  function allowance(address _owner, address _spender_) view public override returns(uint reamining){
      return allowed[_owner][_spender_];
  }

    
}