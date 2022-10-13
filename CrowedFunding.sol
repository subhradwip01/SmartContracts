// SPDX-License-Identifier: UNLICENSE

pragma solidity >=0.5.0 < 0.9.0;

// Contributor send ether to smart contrcat directly intead of manager of organization
// If manager wants to donat money after reaching the target value , need permission from contributer. If min of 51% contributer said yes, then he can withdraw money
// If it is unable to reach target value withing the time, each contributor will get back his money/ether

contract CrowedFunding {
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributers;

    struct Request {
        string description;
        address payable rcpnt;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters; 
    }

    mapping(uint=>Request) public requests;
    uint public numReq;

    constructor(uint _target,uint _deadline){
        manager=msg.sender;
        target=_target;
        deadline=block.timestamp + _deadline;
        minimumContribution=100 wei;
    }


    function contribute() public payable {
        require(block.timestamp<deadline,"Deadline has crossed");
        require(msg.value>=minimumContribution,"Minimum contribution is not met");
        
        if(contributors[msg.sender]==0){
            noOfContributers++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp> deadline && raisedAmount < target , "You are not eligable to get refund now");
        require(contributors[msg.sender]>0,"You have not cntributed");
        address payable usr= payable(msg.sender);
        usr.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }


    modifier onlyManager {
        require(msg.sender == manager , "Only manager can call this function");
        _;
    }

    function createRequest(string memory _description,address payable _rcpnt, uint _val) public onlyManager {
        Request storage newRequest = requests[numReq];
        numReq++;
        newRequest.description=_description;
        newRequest.rcpnt=_rcpnt;
        newRequest.value=_val;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }

    // Votiing for getting permission to donate money
    function voteRequest(uint _reqId) public {
        require(contributors[msg.sender]>0, "You must be a contributor");
        Request storage req=requests[_reqId];
        require(req.voters[msg.sender]==false,"You have already voted");
        req.voters[msg.sender]=true;
        req.noOfVoters++;
    }

    function makePayement(uint _reqId) public onlyManager{
        require(raisedAmount>=target,"You are unable to rais funding");
        Request storage req = requests[_reqId];
        require(req.completed==false,"This request has been completed");
        require(req.noOfVoters > noOfContributers/2,"This requeset can not be fulfilled as majority does not support");
        req.rcpnt.transfer(req.value);
        req.completed=true;
    }



}
