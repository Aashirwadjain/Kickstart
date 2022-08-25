// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CampaignFactory{
    address payable[] public deployedCampaigns;

    function createCampaign(uint _minimumContribution) public {
        address newCampaign = address(new Campaign(_minimumContribution, msg.sender));
        deployedCampaigns.push(payable(newCampaign));
    }

    function getDeployedCampaigns() public view returns (address payable[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {

   address public manager;
   uint public approversCount;
   uint public minimumContribution;
   mapping(address => bool) public approvers;

   struct Request {
       string description;
       uint value;
       address recipient;
       bool complete;
       uint approvalCount;
       mapping(address => bool) approvals;
   }
   uint numRequests = 0;
   mapping(uint => Request) public requests;

   constructor(uint _minimumContribution, address creator) {
       manager = creator;
       minimumContribution = _minimumContribution;
   }

    modifier restricted() {
        require(manager == msg.sender);
        _;
    }

    function contribute () public payable {
        require(msg.value >= minimumContribution);
        if(!approvers[msg.sender]){
            approvers[msg.sender] = true;
            approversCount++;
        }
    }

    function createRequest(string memory _description, uint _value, address _recipient) 
    public 
    restricted {
        Request storage req = requests[numRequests++];
        req.description = _description;
        req.value = _value;
        req.recipient = _recipient;
        req.complete = false;
        req.approvalCount = 0;
    }

    function approveRequest(uint index) public {
        require(approvers[msg.sender]);

        Request storage req = requests[index];
        require(!req.approvals[msg.sender]);

        req.approvalCount++;
        req.approvals[msg.sender] = true;
    }

    function finalizeRequest(uint index) public restricted {
        require(!requests[index].complete);
        require(requests[index].approvalCount > (approversCount / 2));
        payable(requests[index].recipient).transfer(requests[index].value);
        requests[index].complete = true;
    }

    function getSummary() public view returns (
        uint, uint, uint, uint, address
    ) {
        return (
            minimumContribution,
            address(this).balance,
            numRequests,
            approversCount,
            manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return numRequests;
    }

}
