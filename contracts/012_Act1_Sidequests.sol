// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/MapContract.sol";

contract Act1Sidequests is MapContract
{
    address public ACT1_MILESTONES_CONTACT_ADDRESS;
    
    constructor() MapContract(5)
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
        require(levelIndex <= MAX_LEVEL_INDEX, "Invalid level index");
        
        // uint strength, uint dexterity, uint constitution, uint luck, uint armor
        
        if (levelIndex == 0)
        {
            // Skeletons
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
        else if (levelIndex == 1)
        {
            // Orcs
            
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 1, 0, 0) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 1, 0, 0) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 1, 0, 0) 
            });
        }
        else if (levelIndex == 2)
        {
            // Golems 
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 3, 0, 1) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 3, 0, 1) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 3, 0, 1) 
            });
        }
        else if (levelIndex == 3)
        {
            // Satyrs
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(3, 1, 7, 0, 0) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(3, 1, 7, 0, 0) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(3, 1, 7, 0, 0) 
            });
        }
        else if (levelIndex == 4)
        {
            // Elves
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(12, 1, 8, 0, 1) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(12, 1, 8, 0, 1) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(12, 1, 8, 0, 1) 
            });
        }
        else if (levelIndex == 5)
        {
            // Armored Skeletons
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(10, 1, 15, 0, 8) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(10, 1, 15, 0, 8) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(10, 1, 15, 0, 8) 
            });
        }
    }
}