pragma solidity ^0.4.0;

contract i_SomeLibrary {

    uint[] public values;

    function getValue(uint initialValue) public returns(uint);

    function getValues() public returns(uint);

    function storeValue(uint value) public;

}
