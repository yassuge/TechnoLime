// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract TechnoLime {
    string public id;
    string public description;

    constructor(string memory _id, string memory _desc) {
        id = _id;
        description = _desc;
    }
}