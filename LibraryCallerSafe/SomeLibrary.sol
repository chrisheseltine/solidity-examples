pragma solidity ^0.4.0;

// should we be doing something to enforce i_SomeLibrary?
contract SomeLibrary {

    uint[] public values;

    function getValue(uint initial) returns(uint) public {
        return initial + 150;
    }

    function getValues() returns(uint) public {
        return values.length;
    }

    function storeValue(uint value) public {
        values.push(value);
    }

}
