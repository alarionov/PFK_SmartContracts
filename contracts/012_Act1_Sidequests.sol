// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/MapContract.sol";

import { IEquipmentContract } from "./005_EquipmentContract.sol";

import "./libraries/Utils.sol";

contract Act1Sidequests is MapContract
{
    using ComputedStats for ComputedStats.Stats;

    event Cooldown(uint activeAfter);

    uint private constant _NUMBER_OF_LEVELS = 6;

    address public EQUIPMENT_CONTRACT_ADDRESS;
    address public ACT1_MILESTONES_CONTACT_ADDRESS;
    
    IEquipmentContract _equipmentContract;
    IMapContract _mainMap;
    
    uint public constant LUMBERYARD_QUEST_INDEX = 1;
    uint public WOODEN_SHIELD_ID;
    mapping(uint => bool) _woodenShieldClaimed;
    
    uint[_NUMBER_OF_LEVELS] private _cooldowns = [1,2,3,4,5,6];
    mapping(uint => uint[_NUMBER_OF_LEVELS]) private _activeAfter;
    
    constructor(address authContractAddress) MapContract(authContractAddress, _NUMBER_OF_LEVELS - 1)
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
    
    function setCooldowns(uint[_NUMBER_OF_LEVELS] memory newCooldowns) public onlyGM(msg.sender)
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
    }
    
    function getProgress(Character memory character) public pure override(IMapContract) returns(uint)
    {
        return 0;
    }
    
    function getCooldowns(Character memory character) public view returns(uint[_NUMBER_OF_LEVELS] memory cooldowns)
    {
        uint hash = Utils.getHash(character);
        cooldowns = _activeAfter[hash];
    }
    
    function update(Character memory character, uint index, bool victory) 
        public onlyGame(msg.sender) 
        override(IMapContract)
    {
        uint hash = Utils.getHash(character);
        _activeAfter[hash][index] = block.number + _cooldowns[index];
        
        emit Cooldown(_activeAfter[hash][index]);

        if (index == LUMBERYARD_QUEST_INDEX && !_woodenShieldClaimed[hash] && victory && WOODEN_SHIELD_ID > 0)
        {
            _woodenShieldClaimed[hash] = true;
            _rewardWoodenShield(character.owner);
        }
    }
    
    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        bool unlocked;
        try _mainMap.getProgress(character) returns (uint progress)
        {
            unlocked = progress > index;
        }
        catch 
        {
            unlocked = false;
        }

        uint hash = Utils.getHash(character);
        bool active = block.number > _activeAfter[hash][index];

        return unlocked && active;
    }
    
    function getEnemies(uint levelIndex) 
        public view override(IMapContract) 
        validIndex(levelIndex)
        returns (ComputedStats.Stats[] memory enemies)
    {
        if (levelIndex == 0)
        {
            // Goblins
            enemies = new ComputedStats.Stats[](2);
            
            enemies[0] = ComputedStats.newStats(1, 1, 1);
            enemies[1] = ComputedStats.newStats(1, 1, 1);
        }
        else if (levelIndex == 1)
        {
            // Orcs
            enemies = new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.newStats(2, 1, 1);
            enemies[1] = ComputedStats.newStats(2, 1, 1);
            enemies[2] = ComputedStats.newStats(2, 1, 1);
        }
        else if (levelIndex == 2)
        {
            // Golems 
            enemies = new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.Stats(2, 1, 3, 0, 1, 0, 0, 0).init();
            enemies[1] = ComputedStats.Stats(2, 1, 3, 0, 1, 0, 0, 0).init();
            enemies[2] = ComputedStats.Stats(2, 1, 3, 0, 1, 0, 0, 0).init();
        }
        else if (levelIndex == 3)
        {
            // Satyrs
            enemies = new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.newStats(3, 1, 7);
            enemies[1] = ComputedStats.newStats(3, 1, 7); 
            enemies[2] = ComputedStats.newStats(3, 1, 7); 
        }
        else if (levelIndex == 4)
        {
            // Elves
            enemies = new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.Stats(12, 1, 8, 0, 1, 0, 0, 0).init();
            enemies[1] = ComputedStats.Stats(12, 1, 8, 0, 1, 0, 0, 0).init();
            enemies[2] = ComputedStats.Stats(12, 1, 8, 0, 1, 0, 0, 0).init();
        }
        else if (levelIndex == 5)
        {
            // Armored Skeletons
            enemies =  new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.Stats(10, 1, 15, 0, 8, 0, 0, 0).init();
            enemies[1] = ComputedStats.Stats(10, 1, 15, 0, 8, 0, 0, 0).init();
            enemies[2] = ComputedStats.Stats(10, 1, 15, 0, 8, 0, 0, 0).init();
        }
    }
}