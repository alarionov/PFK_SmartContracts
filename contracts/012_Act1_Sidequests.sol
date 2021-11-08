// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/MapContract.sol";
import "./libraries/Utils.sol";

contract Act1Sidequests is MapContract
{
    enum Events
    {
        SHIELD_REWARD
    }
    
    address public ACT1_MILESTONES_CONTACT_ADDRESS;
    
    uint public WOODEN_SHIELD_ID;
    mapping(uint => bool) _woodenShieldClaimed;
    
    
    uint[] private _cooldowns = [1,2,3,4,5,6];
    mapping(uint => uint[]) private _activeAfter;
    
    constructor() MapContract(5)
    {
    }
    
    function setMainMapContract(address mainMapContract) public onlyGame
    {
        ACT1_MILESTONES_CONTACT_ADDRESS = mainMapContract;
    }
    
    function setCooldowns(uint[] memory newCooldowns) public onlyGame
    {
        _cooldowns = newCooldowns;
    }
    
    function setWoodenShieldId(uint _itemTypeId) public onlyGame
    {
        WOODEN_SHIELD_ID = _itemTypeId;
    }
    
    function _rewardWoodenShield(address playerAddress) private
    {
        IEquipmentContract equipmentContract = IEquipmentContract(EQUIPMENT_CONTRACT);
        emit PostFightEvent(uint(Events.SHIELD_REWARD));
    }
    
    function getProgress(Character memory character) public pure override(IMapContract) returns(uint)
    {
        return 0;
    }
    
    function getCooldowns(Character memory character) public view returns(uint[] memory cooldowns)
    {
        uint hash = Utils.getHash(character);
        cooldowns = _activeAfter[hash];
    }
    
    function update(Character memory character, uint index, bool victory) public onlyGame override(IMapContract)
    {
        uint hash = Utils.getHash(character);
        _activeAfter[hash][index] = block.number + _cooldowns[index];
        
        if (!_woodenShieldClaimed[hash] && victory && WOODEN_SHIELD_ID > 0)
        {
            _rewardWoodenShield(character.owner);
            _woodenShieldClaimed[hash] = true;
        }
    }
    
    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        uint hash = Utils.getHash(character);
        bool unlocked = IMapContract(ACT1_MILESTONES_CONTACT_ADDRESS).getProgress(character) > index;
        bool active = _activeAfter[hash][index] < block.number;
        return unlocked && active;
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