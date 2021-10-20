// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";

contract Map is IMapContract
{
    Enemy[3] private _skeletons; 
    Level[7] private _levels;
    
    constructor ()
    {
    }
    
    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        return true;
    }
    
    function getEnemies(uint levelIndex) public view override(IMapContract) returns (Enemy[] memory skeletons)
    {
        require(levelIndex < _levels.length, "Invalid level index");
        
        Level memory level = _levels[levelIndex];
        
        uint total = 0;
        
        skeletons = new Enemy[](total);
        
        uint index = 0;
    }
}