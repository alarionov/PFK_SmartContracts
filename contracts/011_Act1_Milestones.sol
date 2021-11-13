// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/MapContract.sol";

import "./libraries/Utils.sol";

contract Act1Milestones is MapContract
{
    mapping(uint => uint) private _progressions;
    
    constructor(address authContractAddress) MapContract(authContractAddress, 6)
    {}
    
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
        uint hash = Utils.getHash(character);
        return _progressions[hash];
    }
    
    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        return _getProgress(character) == index;
    }
    
    function update(Character memory character, uint index, bool victory) public onlyGame(msg.sender) override(IMapContract)
    {
        if (victory)
        {
            uint hash = Utils.getHash(character);
            _progressions[hash] = index + 1;
        }
    }
    
    function getEnemies(uint levelIndex) 
        public 
        view 
        override(IMapContract)
        validIndex(levelIndex)
        returns (Enemy[] memory enemies)
    {
        // uint strength, uint dexterity, uint constitution, uint luck, uint armor
        
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
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1, 0, 0) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1, 0, 0) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1, 0, 0) 
            });
        }
        else if (levelIndex == 2)
        {
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1, 0, 0) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 3, 0, 1) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1, 0, 0) 
            });
        }
        else if (levelIndex == 3)
        {
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(5, 1, 5, 0, 1) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(5, 1, 5, 0, 1) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(5, 1, 5, 0, 1) 
            });
        }
        else if (levelIndex == 4)
        {
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(8, 1, 12, 0, 0) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(8, 1, 12, 0, 0) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(8, 1, 12, 0, 0) 
            });
        }
        else if (levelIndex == 5)
        {
            enemies =  new Enemy[](2);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(18, 1, 12, 0, 2) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(15, 1, 15, 0, 5) 
            });
        }
        else if (levelIndex == 6)
        {
            enemies =  new Enemy[](1);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(35, 1, 50, 0, 10) 
            });
        }
    }
}