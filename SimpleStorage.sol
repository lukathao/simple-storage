// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract SimpleStorage {

    //initialized to 0 if value not provided
    //given state of internal if not declared public
    //public visibility means other contracts can read it
    uint256 favoriteNumber;
    bool favoriteBool;

    //structs are ways to define new types of solidity - new class type
    struct People {
        uint256 favoriteNumber;
        string name;
    }

    People[] public people;
    
    //private visibility means can only be called from this smart contract
    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    //view - read off block chain
    //pure - make state change, some type of math
    function retrieve() public view returns(uint256) {
        return favoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        people.push(People({favoriteNumber : _favoriteNumber, name : _name}));
    }

}
