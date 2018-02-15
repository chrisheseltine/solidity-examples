pragma solidity ^0.4.2;

contract CreeCoin {
    // Coin setup
    string public name = "CreeCoin";
    string public symbol = "CRC";
    uint8 public initialSupply = 255;
    uint8 public tokenPriceInEther = 3;
    uint public tokenPriceInWei = tokenPriceInEther * 1 ether;

    // Address & token registry
    address public owner;
    address public mintOwner;
    address public tokenDistributor;
    mapping (address => uint) public tokenBalances;
    uint public totalSupply;

    // Events
    event Minted(address receiver, uint amount, uint newTotalSupply);
    event TokenTransfered(address from, address to, uint amount);
    event TokenBought(address buyer, uint amount);

    // Constants
    address constant private CREATION_ADDRESS = 0x0;

    // this code is only run ONCE on CREATION!!
    function CreeCoin() public {
        // setup owner, minter and distributor roles
        owner = msg.sender;
        mintOwner = owner;
        tokenDistributor = owner;

        // send the initial supply to the owner to be distributed
        tokenBalances[mintOwner] += initialSupply;
    }

    function mint(address receiver, uint amount) public {
        // check caller is mintOwner
        require(msg.sender == mintOwner);

        // mint to receiver address
        tokenBalances[receiver] += amount;
        totalSupply += amount;

        Minted(receiver, amount, totalSupply);
    }

    function transferMintOwnership(address newMintOwner) public {
        // check caller is mintOwner or owner
        require((msg.sender == mintOwner) || (msg.sender == owner));

        // set new mintOwner
        mintOwner = newMintOwner;
    }

    function buyToken() public payable {
        // check that the amount of ether sent is greater than 0
        require(msg.value > 0);
        // check the amount sent is enough for at least one token
        require(msg.value >= tokenPriceInWei);

        // NOTE: balance is automatically updated by the payable modifier

        // calculate tokens to be distributed as integer
        uint numToDistribute = msg.value / tokenPriceInWei;
        // calculate remainder to be refunded, e.g. 7.1eth sent, 1.1eth to be refunded
        uint refundableRemainderInWei = msg.value - (toWei(numToDistribute));

        // distribute token to sender
        distributeToken(msg.sender, numToDistribute);
        // refund the remainder
        msg.sender.transfer(refundableRemainderInWei);

        TokenBought(msg.sender, numToDistribute);
    }

    function distributeToken(address receiver, uint numTokens) private {
        // check for at least one token, if not something went wrong
        require(numTokens > 0);
        // check for balance overflow, causing incorrect tokenBalances value
        require(tokenBalances[receiver] + numTokens > tokenBalances[receiver]);

        // decrement from distributor and increment receiver
        tokenBalances[tokenDistributor] -= numTokens;
        tokenBalances[receiver] += numTokens;
    }

    function transferToken(address receiver, uint transferAmount) public {
        // check if they have enough balance
        require(tokenBalances[msg.sender] >= transferAmount);
        // check that they are not accidentally sending it to the creation address
        require(receiver != CREATION_ADDRESS);
        // check for balance overflow, causing incorrect tokenBalances value
        require(tokenBalances[receiver] + transferAmount > tokenBalances[receiver]);

        // decrement from sender and increment receiver
        // WARN: is it possible for this to fail in between and leave the sender out of pocket?
        tokenBalances[msg.sender] -= transferAmount;
        tokenBalances[receiver] += transferAmount;

        TokenTransfered(msg.sender, receiver, transferAmount);
    }

    function toWei(uint amountInEther) private returns(uint) {
        return amountInEther * 1 ether;
    }
}
