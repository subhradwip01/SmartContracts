// SPDX-License-Identifier: UNLICENSE

pragma solidity >=0.5.0 < 0.9.0;

contract EventManagement {
    struct Event{
        address organizer;
        string name;
        uint startDate;
        uint endDate;
        uint price; // In wei
        uint ticketCount;
        uint ticketRemaining;
    }


    mapping(uint=>Event) public events;

    // Mapping person to the particular event id and stiring the quatity of the ticket
    mapping(address=>mapping(uint=>uint)) public tickets;

    uint public nextEventId;

    // Creating event
    function createEvent(string memory name,uint startDate,uint endDate,uint price,uint ticketCount) external{
        require(startDate>block.timestamp,"You cannot organize event for past date");
        require(startDate<endDate,"End date shoud not be less than or equal to start date");
        require(ticketCount>=0,"Your tickets value shoud be postive or geater than zero");

        events[nextEventId]=Event(msg.sender, name, startDate, endDate, price, ticketCount, ticketCount);
        nextEventId++;
    }

    // Buying the ticket
    function buyTicket(uint eventId,uint quantity) external payable{
        require(events[eventId].startDate!=0,"This event does not exist");
        require(events[eventId].endDate>block.timestamp,"This event has already occured");
        Event storage _event = events[eventId];
        require(msg.value==(_event.price*quantity),"Ether is not enough");
        require(_event.ticketRemaining>=quantity,"Not enough tickets available");
        _event.ticketRemaining-=quantity;
        tickets[msg.sender][eventId]+=quantity;
    }

    // Giving ticket as gift to a person
    function transferTicket(uint eventId,uint quantity,address to) external{
        require(events[eventId].startDate!=0,"This event does not exist");
        require(events[eventId].endDate>block.timestamp,"This event has already occured");
        require(tickets[msg.sender][eventId]>=quantity,"You do not have enogh ticket");
        tickets[msg.sender][eventId]-=quantity;
        tickets[to][eventId]+=quantity;
    }
}
