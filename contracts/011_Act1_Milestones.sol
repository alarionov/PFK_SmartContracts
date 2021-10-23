// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";

contract Act1Milestones is IMapContract
{
    uint public MAX_LEVEL_INDEX = 7;
    
    mapping(uint => uint) private _progressions;
    
    constructor ()
    {
    }
    
    function getProgress(Character memory character) 
        public 
        view 
        override(IMapContract)
        returns(uint)
    {
        return _getProgress(character);
    }
    
    function _getProgress(Character memory character) private view returns(uint)
    {
        uint hash = uint(keccak256(abi.encodePacked(character.contractAddress, character.tokenId)));
        return _progressions[hash];
    }
    
    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        return _getProgress(character) == index;
    }
    
    function getEnemies(uint levelIndex) public view override(IMapContract) returns (Enemy[] memory enemies)
    {
        require(levelIndex < MAX_LEVEL_INDEX, "Invalid level index");
        
        if (levelIndex == 0)
        {
            enemies =  new Enemy[](1);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1, 0, 0) 
            });
        }
        else if (levelIndex == 1)
        {
            
        }
        else if (levelIndex == 2)
        {
            
        }
        else if (levelIndex == 3)
        {
            
        }
        else if (levelIndex == 4)
        {}
        else if (levelIndex == 5)
        {}
        else if (levelIndex == 6)
        {}
    }
}