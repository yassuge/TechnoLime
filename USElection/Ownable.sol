// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract Ownable {
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "only owner can invoke");
        _;
    }
}