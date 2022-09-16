// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Receiver {
    constructor() payable{}
    
    receive() external payable {}

    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}