//SPDX-License-Identifier:MIT
pragma solidity ^0.8.31;

interface IERC20 {
    function transfer (address,uint256) external returns (bool);
    function transferFrom (address,address,uint256) external returns (bool);
}

contract CrowdFund {

    event Launch (
        uint256 id,
        address indexed  creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt);
    event Cancel (uint256 id);
    event Pledge (uint256 id, address indexed caller, uint256 amount);
    event unPledge (uint256 id, address indexed caller, uint256 amount);
    event Claim (uint256 id);
    event Refund (uint256 id, address indexed caller, uint256 amount);

    struct Campaign{
        // The campaign creator
        address creator;
        //Total amount of tokens to raise
        uint256 goal;
        //Total amount pledged
        uint256 pledged;
        //Timestamp of start of campaign
        uint32 startAt;
        //Timestamp of end of campaign
        uint32 endAt;
        //True if goal was reached and the creator has claimed the tokens
        bool claimed;
    }
    IERC20 public immutable token;
    //Toal count of campaigns created
    //It is also used to generate id for new campaigns
    uint256 public count;
    //Mapping from id => campaign
    mapping (uint256 => Campaign) public campaigns;
    //Mapping from campaign id => pledger => amout pledged
    mapping (uint256 => mapping (address => uint256)) public pledgedAmount;

    constructor (address _token){
        token =IERC20(_token);
    }

    function launch (uint256 _goal, uint32 _startAt, uint32 _endAt) external {
        require (_startAt >= block.timestamp, "stratAt < now");
        require (_endAt > _startAt, "endAt < startAt");
        require (_endAt <= _startAt + 120 days, "endAt > maxDuration");

        count +=1;
        campaigns [count] = Campaign ({
            creator:msg.sender,
            goal:_goal,
            pledged:0,
            startAt:_startAt,
            endAt:_endAt,
            claimed:false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }
    function cancel (uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require (campaign.creator == msg.sender, "Not Creator");
        require (block.timestamp < campaign.startAt, "Already Started");

        delete campaigns[_id];
        emit Cancel(_id);
    }
    function pledge (uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        // Campaign strted but not ended yet
        require (block.timestamp >= campaign.startAt, "Not Started");
        require (block.timestamp <= campaign.endAt, "Has Ended");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge (_id, msg.sender, _amount);
    }
    function unpledge (uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require (block.timestamp <= campaign.endAt, "Has Ended");

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit unPledge (_id, msg.sender, _amount);
    }
    function claim (uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require (msg.sender == campaign.creator, "Not Creator");
        require (block.timestamp <= campaign.endAt, "Has Ended");
        require (campaign.pledged >= campaign.goal, "pledged < goal");
        require (!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit Claim (_id);
    }
    function refund (uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require (block.timestamp > campaign.endAt, "Not Ended");
        require (campaign.pledged < campaign.goal, "pldged >= goal");

        uint256 balance = pledgedAmount[_id][msg.sender];
        //Reentrancy Attack
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, balance);

        emit Refund (_id, msg.sender, balance);

    }
}