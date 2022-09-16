// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./TechnoLimeFactory.sol";

abstract contract TechnoLimeFactoryDealer {
    TechnoLimeFactory private _factory;

    modifier OnlyFactoryTechnoLime (TechnoLime lime){
        require(_factory.isLimeGenuine(lime), "Only TechnoLimes made in Factory are accepted by dealer");
        _;
    }

    constructor(TechnoLimeFactory factory){
        _factory = factory;
    }

    function technoLimeFactory() public view returns (TechnoLimeFactory){
        return _factory;
    }
}