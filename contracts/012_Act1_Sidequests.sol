// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/MapContract.sol";

import { IEquipmentContract } from "./005_EquipmentContract.sol";

import "./libraries/Utils.sol";

contract Act1Sidequests is MapContract
{
    using ComputedStats for ComputedStats.Stats;

    enum Events
    {
        SHIELD_REWARD
    }
    
    address public EQUIPMENT_CONTRACT_ADDRESS;
    address public ACT1_MILESTONES_CONTACT_ADDRESS;
    
    IEquipmentContract _equipmentContract;
    IMapContract _mainMap;
    
    uint public constant LUMBERYARD_QUEST_INDEX = 1;
    uint public WOODEN_SHIELD_ID;
    mapping(uint => bool) _woodenShieldClaimed;
    
    uint[] private _cooldowns = [1,2,3,4,5,6];
    mapping(uint => uint[]) private _activeAfter;
    
    constructor(address authContractAddress) MapContract(authContractAddress, 5)
    {}
    
    function setEquipmentContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        EQUIPMENT_CONTRACT_ADDRESS = newAddress;
        _equipmentContract = IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS);
    }
    
    function setMainMapContractAddress(address mainMapContract) public onlyGM(msg.sender)
    {
        ACT1_MILESTONES_CONTACT_ADDRESS = mainMapContract;
        _mainMap = IMapContract(ACT1_MILESTONES_CONTACT_ADDRESS);
    }
    
    function setCooldowns(uint[] memory newCooldowns) public onlyGM(msg.sender)
    {
        _cooldowns = newCooldowns;
    }
    
    function setWoodenShieldId(uint _itemTypeId) public onlyGM(msg.sender)
    {
        WOODEN_SHIELD_ID = _itemTypeId;
    }
    
    function _rewardWoodenShield(address playerAddress) private
    {
        _equipmentContract.mintByGame(playerAddress, WOODEN_SHIELD_ID); 
        //emit PostFightEvent(uint(Events.SHIELD_REWARD));
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
    
    function update(Character memory character, uint index, bool victory) public onlyGame(msg.sender) override(IMapContract)
    {
        uint hash = Utils.getHash(character);
        _activeAfter[hash][index] = block.number + _cooldowns[index];
        
        if (index == LUMBERYARD_QUEST_INDEX && !_woodenShieldClaimed[hash] && victory && WOODEN_SHIELD_ID > 0)
        {
            _rewardWoodenShield(character.owner);
            _woodenShieldClaimed[hash] = true;
        }
    }
    
    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        uint hash = Utils.getHash(character);
        bool unlocked = _mainMap.getProgress(character) > index;
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
                stats: ComputedStats.newStats(1, 1, 1) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(1, 1, 1) 
            });
        }
        else if (levelIndex == 1)
        {
            // Orcs
            
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 1) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 1) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(2, 1, 1) 
            });
        }
        else if (levelIndex == 2)
        {
            // Golems 
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.Stats(2, 1, 3, 0, 1, 0, 0, 0).init() 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.Stats(2, 1, 3, 0, 1, 0, 0, 0).init() 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.Stats(2, 1, 3, 0, 1, 0, 0, 0).init() 
            });
        }
        else if (levelIndex == 3)
        {
            // Satyrs
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.newStats(3, 1, 7) 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.newStats(3, 1, 7) 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.newStats(3, 1, 7) 
            });
        }
        else if (levelIndex == 4)
        {
            // Elves
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.Stats(12, 1, 8, 0, 1, 0, 0, 0).init() 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.Stats(12, 1, 8, 0, 1, 0, 0, 0).init() 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.Stats(12, 1, 8, 0, 1, 0, 0, 0).init() 
            });
        }
        else if (levelIndex == 5)
        {
            // Armored Skeletons
            enemies =  new Enemy[](3);
            
            enemies[0] = Enemy({ 
                id: 1, 
                present: true, 
                stats: ComputedStats.Stats(10, 1, 15, 0, 8, 0, 0, 0).init() 
            });
            enemies[1] = Enemy({ 
                id: 2, 
                present: true, 
                stats: ComputedStats.Stats(10, 1, 15, 0, 8, 0, 0, 0).init() 
            });
            enemies[2] = Enemy({ 
                id: 3, 
                present: true, 
                stats: ComputedStats.Stats(10, 1, 15, 0, 8, 0, 0, 0).init() 
            });
        }
    }
}