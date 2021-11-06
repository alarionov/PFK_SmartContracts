// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

//import "./libraries/GameMath.sol";
import "./libraries/ComputedStats.sol";

contract CharacterContract is BaseContract, IEquipmentContract, ERC721
{
    using ComputedStats for ComputedStats.Stats;
    
    struct ItemType 
    {
        uint id;
        string name;
        ComputedStats.Stats bonusStats;
    }

    mapping(uint => ItemType) _itemTypes;
    mapping(uint => uint) _itemToType;
    
    constructor() ERC721("Equipment", "EQPMT")
    {}
    
    function setItemParameters(
        uint id, 
        string memory name, 
        uint strength, 
        uint dexterity, 
        uint constitution, 
        uint luck, 
        uint armor
    ) public onlyGame
    {
        ComputedStats.Stats memory stats = ComputedStats.newStats(strength, dexterity, constitution, luck, armor);
        _itemTypes[id] = ItemType({ id: id, name: name, bonusStats: stats });
    }
    
    function getInventory(Equipment memory equipment) public view returns(ComputedStats.Stats memory bonusStats)
    {
        bonusStats = ComputedStats.zeroStats();
        
        _accumulateBonus(bonusStats, equipment.armorSetId);
        _accumulateBonus(bonusStats, equipment.weaponSetId);
        _accumulateBonus(bonusStats, equipment.shieldId);
    }
    
    function _accumulateBonus(ComputedStats.Stats memory bonusStats, uint itemId) private view 
    {
        require(_exists(itemId), "Token doesn't exist");
        
        uint typeId = _itemToType[itemId];
        
        ItemType memory itemType =  _itemTypes[typeId];
        
        bonusStats.add(itemType.bonusStats);
    }
    
    function getBonusStats(uint tokenId) public view override(IEquipmentContract) returns(ComputedStats.Stats memory stats)
    {}
    
}