// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";

contract Act1Sidequests is IMapContract
{
    address public ACT1_MILESTONES_CONTACT_ADDRESS;
    
    constructor ()
    {
    }
    
    function setMainMapContract(address mainMapContract) public
    {
        ACT1_MILESTONES_CONTACT_ADDRESS = mainMapContract;
    }
    
    function getProgress(Character memory character) public view override(IMapContract) returns(uint)
    {
        return 0;
    }
    
    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        return true;
    }
    
    function getEnemies(uint levelIndex) public view override(IMapContract) returns (Enemy[] memory enemies)
    {
        enemies = new Enemy[](1);
    }
}