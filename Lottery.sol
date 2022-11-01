// SPDX-License-Identifier: GPL-3.0


pragma solidity >= 0.7.7 < 0.9.0;


contract Lottery {
 address public manager;
 address payable[] public participants;

 constructor(){
     manager = msg.sender;
 }
 

 receive() external payable {
    require(msg.value == 1 ether);
    participants.push(payable(msg.sender));  
 }

 function getBalance() public view returns(uint){
    require(msg.sender == manager);
    return payable(this).balance;
 }

 function random() view public returns(uint){
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
 }
 
 function selectWinner() public {
     require(msg.sender == manager);
     require(participants.length >=2);
     uint rn = random();
     address payable winner; 
     uint index = rn % participants.length;
     winner = participants[index];
     winner.transfer(getBalance());      
     participants = new address payable[](0); 
 }
 
}