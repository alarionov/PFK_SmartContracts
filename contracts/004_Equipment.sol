// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

//import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

//import "./libraries/GameMath.sol";
import "./libraries/ComputedStats.sol";

contract CharacterContract is BaseContract, IEquipmentContract, ERC721Enumerable
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
    
    modifier existingToken(uint tokenId)
    {
        require(_exists(tokenId), "Token doesn't exist");
        
        _;
    }
    
    constructor() ERC721("Equipment", "EQPMT")
    {
        EQUIPMENT_CONTRACT = address(this);
        
        _itemTypes[0] = ItemType({ id: 0, name: "Empty", bonusStats: ComputedStats.zeroStats() });
        _itemToType[0] = 0;
    }
    
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
    
    function mintByGame(address player, uint itemType) public onlyGame returns(uint tokenId)
    {
        tokenId = totalSupply() + 1;
        
        _itemToType[tokenId] = itemType;
        
        _safeMint(player, tokenId);
    }
    
    function getInventory(Equipment memory equipment) public view returns(ComputedStats.Stats memory bonusStats)
    {
        bonusStats = ComputedStats.zeroStats();
        
        _accumulateBonus(bonusStats, equipment.armorSetId);
        _accumulateBonus(bonusStats, equipment.weaponSetId);
        _accumulateBonus(bonusStats, equipment.shieldId);
    }
    
    function _accumulateBonus(ComputedStats.Stats memory bonusStats, uint itemId) private view existingToken(itemId)
    {
        uint typeId = _itemToType[itemId];
        
        ItemType memory itemType = _itemTypes[typeId];
        
        bonusStats.add(itemType.bonusStats);
    }
    
    function getItem(uint tokenId) public view existingToken(tokenId) returns(ItemType memory itemType)
    {
        itemType = _itemTypes[_itemToType[tokenId]];
    }
}