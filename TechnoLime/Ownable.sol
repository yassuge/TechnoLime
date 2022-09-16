// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

// inspired from https://github.com/OpenZeppelin/openzeppelin-test-helpers/blob/master/contracts/Ownable.sol

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(isOwner(), "only owner can invoke thic call");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns(address) {
        return _owner;
    }

    function isOwner() public view returns(bool){
        return (msg.sender == _owner);
    }

    function transferOwnership(address _to) public onlyOwner {
        require(_to != address(0), "Null address given");
        require(_to != _owner, "Ownershup transfer not making sense");
        emit OwnershipTransferred(_owner, _to);
        _owner = _to;
    }
}