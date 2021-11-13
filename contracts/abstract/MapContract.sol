// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./Enemy.sol";
import "./BaseContract.sol";

import { Character } from "../002_CharacterContract.sol";

interface IMapContract
{
    function getProgress(Character memory character) external view returns(uint);
    function hasAccess(Character memory character, uint index) external view returns(bool);
    function getEnemies(uint index) external view returns (Enemy[] memory enemies);
    function update(Character memory character, uint index, bool victory) external;
}

abstract contract MapContract is IMapContract, BaseContract
{
    uint public MAX_LEVEL_INDEX;
    
    event PostFightEvent(uint eventCode);
    
    modifier validIndex(uint index)
    {
        require(index <= MAX_LEVEL_INDEX, "Invalid level index");
        
        _;
    }
    
    constructor(address authContractAddress, uint maxLeveIndex) BaseContract(authContractAddress)
    {
        MAX_LEVEL_INDEX = maxLeveIndex;
    }
}