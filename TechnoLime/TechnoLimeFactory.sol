// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./Ownable.sol";
import "./TechnoLime.sol";

contract TechnoLimeFactory is Ownable {
    event NewTechnoLimeLog(address _creator, string _id, string _description);

    TechnoLime[] private _technoLimes;
    mapping(string => bool) private _isLimeCreated;
    mapping(string => address) private _technoIDs;

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
        TechnoLime newLime = new TechnoLime(_id, _desc);
        _technoIDs[_id] = address(newLime);
        _technoLimes.push(newLime);
        emit NewTechnoLimeLog(owner(), _id, _desc);
    }
}