// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./Ownable.sol";

abstract contract Sender is Ownable {
    event BalanceSentLog(address sender, address payable receiver, uint amount);

    function sendBalance(address payable _receiver, uint amount) external onlyOwner {
        (bool sent, ) = _receiver.call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit BalanceSentLog(msg.sender, _receiver, amount);
    }
}