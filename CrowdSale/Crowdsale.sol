pragma solidity 0.4.8;

contract token { function transfer(address receiver, uint amount){  }
                 function mintToken(address target, uint mintedAmount){  }  
                }

contract CrowdSale {
    //tosh-dev: 0x4EF89736C984A3f34aa5b7a9D57457faA837F258
    //main: 0xC8A908F248e930a705A70400146fcF24d3Cc7275
    //toshendra: 0xc8d21EB34E504Ef70AA075eA2a36F21cD3c1B685
    //gadget Coin: 0x80402B7985c4722D35f49dA8E938040cf9D7Ab6C

    // Data structures
    enum State {
        Fundraising,
        Failed,
        Successful,
        Closed
    }
    State public state = State.Fundraising; // initialize on create

    struct Contribution {
        uint amount;
        address contributor;
    }
    Contribution[] contributions;

    // State variables
    
    uint public totalRaised;
    uint public currentBalance;
    uint public deadline;
    uint public completedAt;
    uint public priceInWei;
    uint public fundingMinimumTargetInWei; // required to tip, else everyone gets refund
    uint public fundingMaximumTargetInWei; // Funding will stop if this is reached
    token public tokenReward;
    address public creator;
    address public beneficiary; // creator may be different than recipient
    string campaignUrl;
    byte constant version = 1;

    // Events
    event LogFundingReceived(address addr, uint amount, uint currentTotal);
    event LogWinnerPaid(address winnerAddress);
    event LogFundingSuccessful(uint totalRaised);
    event LogFunderInitialized(
        address creator,
        address beneficiary,
        string url,
        uint _fundingMaximumTargetInEther, 
        uint256 deadline);

    // modifiers
    modifier inState(State _state) {
        if (state != _state) throw;
        _;
    }

     modifier isMinimum() {
        if(msg.value < priceInWei) throw;
        _;
    }

    modifier inMultipleOfPrice() {
        // if contributed ammount is less than 
        // the priceInWei of the token then reject the Contribution
        if(msg.value%priceInWei != 0) throw;
        _;
    }

    modifier isCreator() {
        if (msg.sender != creator) throw;
        _;
    }

    // Wait 1 hour after final contract state before allowing contract destruction
    modifier atEndOfLifecycle() {
        if(!((state == State.Failed || state == State.Successful) && completedAt + 1 hours < now)) {
            throw;
        }
        _;
    }

    // Constructor
    function CrowdSale(
        uint _timeInMinutesForFundraising,
        string _campaignUrl,
        address _ifSuccessfulSendTo,
        uint _fundingMinimumTargetInEther,
        uint _fundingMaximumTargetInEther,
        token _addressOfTokenUsedAsReward,
        uint _etherCostOfEachToken)
    {
        creator = msg.sender;
        beneficiary = _ifSuccessfulSendTo;
        campaignUrl = _campaignUrl;
        fundingMinimumTargetInWei = _fundingMinimumTargetInEther * 1 ether; //convert to wei
        fundingMaximumTargetInWei = _fundingMaximumTargetInEther * 1 ether; //convert to wei
        deadline = now + (_timeInMinutesForFundraising * 1 minutes);
        currentBalance = 0;
        tokenReward = token(_addressOfTokenUsedAsReward);
        priceInWei = _etherCostOfEachToken * 1 ether;
        LogFunderInitialized(
            creator,
            beneficiary,
            campaignUrl,
            fundingMaximumTargetInWei,
            deadline);
    }

    function contribute()
    public
    inState(State.Fundraising) isMinimum() inMultipleOfPrice() payable returns (uint256)
    {
        uint256 amountInWei = msg.value;

        
        contributions.push(
            Contribution({
                amount: msg.value,
                contributor: msg.sender
                }) // use array, so can iterate
            );

        totalRaised += msg.value;
        currentBalance = totalRaised;

        //tokenReward.transfer(msg.sender, amountInWei / priceInWei);

        if(fundingMaximumTargetInWei != 0){
            // for limited token sale
            // fundingMaximumTargetInWei is set to some limited value
            tokenReward.transfer(msg.sender, amountInWei / priceInWei);
        }
        else{
            // for unlimited sale token owner need to change 
            // the admin right from himself to this crowdsale address 
            // and then mint the token out of thin air whenever somebody contribute
            tokenReward.mintToken(msg.sender, amountInWei / priceInWei);
        }

        LogFundingReceived(msg.sender, msg.value, totalRaised);

        

        checkIfFundingCompleteOrExpired();
        return contributions.length - 1; // return id
    }

    function checkIfFundingCompleteOrExpired() {
        
       
        if (fundingMaximumTargetInWei != 0 && totalRaised > fundingMaximumTargetInWei) {
            state = State.Successful;
            LogFundingSuccessful(totalRaised);
            payOut();
            completedAt = now;
            // could incentivize sender who initiated state change here
            } else if ( now > deadline )  {
                if(totalRaised >= fundingMinimumTargetInWei){
                    state = State.Successful;
                    LogFundingSuccessful(totalRaised);
                    payOut();  
                    completedAt = now;
                }
                else{
                    state = State.Failed; // backers can now collect refunds by calling getRefund(id)
                    completedAt = now;
                }
            } 
        
    }

        function payOut()
        public
        inState(State.Successful)
        {
            // Here beneficiary can be the DAO also
            // And if the Token represents the 
            // voting rights of the DAO then any major contributor
            // can takeover the DAO and fetch all the balance to himself
            if(!beneficiary.send(this.balance)) {
                throw;
            }

            state = State.Closed;
            currentBalance = 0;
            LogWinnerPaid(beneficiary);
        }

        function getRefund()
        public
        inState(State.Failed) 
        returns (bool)
        {
            for(uint i=0; i<=contributions.length; i++)
            {
                if(contributions[i].contributor == msg.sender){
                    uint amountToRefund = contributions[i].amount;
                    contributions[i].amount = 0;
                    if(!contributions[i].contributor.send(amountToRefund)) {
                        contributions[i].amount = amountToRefund;
                        return false;
                    }
                    else{
                        totalRaised -= amountToRefund;
                        currentBalance = totalRaised;
                    }
                    return true;
                }
            }
            return false;
        }

        function removeContract()
        public
        isCreator()
        atEndOfLifecycle()
        {
            selfdestruct(msg.sender);
            // creator gets all money that hasn't be claimed
        }

        function () { throw; }
}

