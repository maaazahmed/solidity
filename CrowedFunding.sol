// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    mapping(address => uint) public contributors;
    address public manager;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributor;
    uint public minimumContribution;

    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numRequest;

    constructor(uint _deadline, uint _traget) {
        deadline = _deadline;
        target = _traget;
        manager = msg.sender;
        minimumContribution = 100 wei;
    }

    function sendEth() public payable {
        require(deadline > block.timestamp, "deadline has passed.");
        require(
            msg.value >= minimumContribution,
            "min contribution is not met"
        );
        if (contributors[msg.sender] == 0) {
            noOfContributor++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function refund() public {
        require(
            block.timestamp > deadline && raisedAmount < target,
            "You are not aligble for refund0"
        );
        require(contributors[msg.sender] > 0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }


    modifier onlyManager (){
         require(msg.sender == manager, "Only admin can create request");
         _;
    }

    function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager{
         Request storage newRequest; 
         newRequest = requests[numRequest];
         numRequest++;
         newRequest.description = _description;
         newRequest.recipient = _recipient;
         newRequest.value = _value;
         newRequest.noOfVoters = 0;
         newRequest.completed = false;
    }



    function voterRequest(uint _requestNo) public{
       require(contributors[msg.sender] > 0, "You must be a contributer !");
       Request storage thisRequest = requests[_requestNo];
       require(thisRequest.voters[msg.sender] == false, "You already have voted!");
       thisRequest.voters[msg.sender] = true;
       thisRequest.noOfVoters++;
    }


    function mackPayment(uint _requestNo) public onlyManager{
        require(raisedAmount>= target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "the request has been completed!");
        require(thisRequest.noOfVoters > noOfContributor/2, "Mejorty dosnot support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

    }
}
