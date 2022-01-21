// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./BaseContract.sol";

import "../libraries/ComputedStats.sol";

import { Character } from "../002_CharacterContract.sol";

interface IMapContract
{
    function getProgress(Character memory character) external view returns(uint);
    function resetProgress(Character memory character) external;
    function hasAccess(Character memory character, uint index) external view returns(bool);
    function getEnemies(uint index) external view returns (ComputedStats.Stats[] memory enemies);
    function update(Character memory character, uint index, bool victory) external;
}

abstract contract MapContract is IMapContract, BaseContract
{
    uint public MAX_LEVEL_INDEX;
    
    modifier validIndex(uint index)
    {
        require(index <= MAX_LEVEL_INDEX, "Invalid level index");
        
        _;
    }
    
    constructor(address authContractAddress, uint maxLeveIndex) BaseContract(authContractAddress)
    {
        MAX_LEVEL_INDEX = maxLeveIndex;
    }

    function resetProgress(Character memory character) public virtual override
    {} 
}