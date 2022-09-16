// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract Ownable {
    address public owner;

    constructor() payable{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner can invoke thic call");
        _;
    }

}