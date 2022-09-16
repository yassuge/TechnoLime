// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./Ownable.sol";

contract Receiver is Ownable{
    constructor() payable{}
    
    receive() external payable {}

    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}