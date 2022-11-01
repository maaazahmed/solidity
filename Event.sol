// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.7.0 < 0.9.0;

contract EventContract{
  struct Event{
      address organizer;
      string name;
      uint date;
      uint price;
      uint ticketCount;
      uint ticketRemain;
  }

  mapping(uint=>Event) public events;
  mapping(address=>mapping(uint=>uint)) public tickets;
  uint nextId;

  function createEvent( string memory name, uint date , uint price, uint ticketCount) public{
      require(date>block.timestamp, "You cant organiz event for future!");
      require(ticketCount > 0, "You can organiz event only if you create more then 10 tikcets");
      events[nextId] = Event( msg.sender, name, date, price , ticketCount, ticketCount);
      nextId++;
  }

  function bayTicket(uint id, uint quantity) public payable {
     require(events[id].date != 0, "Event dose not exist" );
     require(events[id].date>block.timestamp, "Event has alrady occured");
     Event storage _event = events[id];
     require(msg.value == (_event.price*quantity), "Ether is not enough");
     require(_event.ticketRemain >= quantity, "Not enough tickets");
     _event.ticketRemain-=quantity;
     tickets[msg.sender][id]+=quantity;
  }
  
  function tansferTickets(uint id, uint quantity, address to ) public {
       require(events[id].date != 0, "event dose note exist");
       require(events[id].date > block.timestamp, "event has already occured" );
       require(tickets[msg.sender][id] >= quantity, "not enough tickets");
       tickets[msg.sender][id]-=quantity;
       tickets[to][id]+=quantity;
  }
} 