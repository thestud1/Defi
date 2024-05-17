// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract SimpleStorage{
    uint256 public favoriteNumber;

    function store(uint256 i) public{
        favoriteNumber = i;
    }

}