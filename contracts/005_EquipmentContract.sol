// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./abstract/Structures.sol";
import "./abstract/BaseContract.sol";

import "./libraries/ComputedStats.sol";

interface IEquipmentContract
{
    function getInventory(Equipment memory equipment) external view returns(ComputedStats.Stats memory bonusStats);
    function mintByGame(address player, uint itemType) external returns(uint tokenId);
    function forcedTransfer(address from, address to, uint itemId) external;
}

contract EquipmentContract is BaseContract, IEquipmentContract, ERC721Enumerable
{
    using ComputedStats for ComputedStats.Stats;
    
    struct ItemType 
    {
        uint id;
        string name;
        ItemSlot slot;
        ComputedStats.Stats bonusStats;
    }

    mapping(uint => ItemType) _itemTypes;
    mapping(uint => uint) _itemToType;
    
    modifier existingToken(uint tokenId)
    {
        require(_exists(tokenId), "Token doesn't exist");
        
        _;
    }
    
    constructor(address authContractAddress) BaseContract(authContractAddress) ERC721("Equipment", "EQPMT")
    {
        _itemTypes[0] = ItemType({ id: 0, name: "Empty", slot: ItemSlot.Any, bonusStats: ComputedStats.zeroStats() });
        _itemToType[0] = 0;
    }
    
    function setItemParameters(
        uint id, 
        string memory name, 
        ItemSlot slot,
        uint strength, 
        uint dexterity, 
        uint constitution, 
        uint luck, 
        uint armor
    ) public onlyGame(msg.sender)
    {
        ComputedStats.Stats memory stats = ComputedStats.newStats(strength, dexterity, constitution, luck, armor);
        _itemTypes[id] = ItemType({ id: id, name: name, slot: slot, bonusStats: stats });
    }
    
    function mintByGame(address player, uint itemType) public onlyGame(msg.sender) returns(uint tokenId)
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
    
    function forcedTransfer(address from, address to, uint itemId) public onlyGame(msg.sender)
    {
        require(itemId != 0, "Invalid item id");
        require(ownerOf(itemId) == address(from), "Invalid owner");
        
        _transfer(from, to, itemId);
    }
    
    function itemTypeByItemId(uint itemId) private view returns(ItemType memory itemType)
    {
        itemType = _itemTypes[_itemToType[itemId]];
    }
}