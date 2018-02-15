pragma  solidity ^0.4.0;

import "./i_SomeLibrary.sol";

contract LibraryCaller {

    address public owner;
    address private libraryLocation;

    function LibraryCaller(address _libraryLocation) {
        owner = msg.sender;
        libraryLocation = _libraryLocation;
    }

    function getValue(uint value) public returns(uint) {
        return i_SomeLibrary(libraryLocation).getValue(value);
    }

}
