// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./Ownable.sol";

contract TechnoLime {
    string id;
    string description;

    constructor(string memory _id, string memory _desc) {
        id = _id;
        description = _desc;
    }
}

contract TechnoLimeFactory is Ownable {
    event NewTechnoLimeLog(address _creator, string _id, string _description);

    TechnoLime[] private _technoLimes;
    mapping(string => bool) private _isLimeCreated;

    // accessors
    function getTechnoLimes() public view returns (TechnoLime[] memory){
        return _technoLimes;
    }

    function getTechnoLimesCount() public view returns (uint _count) {
        _count = _technoLimes.length;
    }

    // creator function
    function createTechnoLime(string calldata _id, string calldata _desc) public onlyOwner {
        require(!_isLimeCreated[_id], "TechnoLime already exists");

        _isLimeCreated[_id] = true;
        _technoLimes.push(new TechnoLime(_id, _desc));
        emit NewTechnoLimeLog(owner(), _id, _desc);
    }
}