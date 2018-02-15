pragma solidity ^0.4.0;

contract mortal {
    /* Define variable owner of the type address */
    address owner;

    /* This function is executed at initialization and sets the owner of the contract */
    function mortal() public {
      owner = msg.sender;
    }

    /* Function to recover the funds on the contract */
    public function kill() { if (msg.sender == owner) selfdestruct(owner); }
}

contract greeter is mortal {
    /* Define variable greeting of the type string */
    string greeting;

    /* This runs when the contract is executed */
    public function greeter(string _greeting) public {
        greeting = _greeting;
    }

    /* Main function */
    public function greet() constant returns (string) {
        return greeting;
    }
}
