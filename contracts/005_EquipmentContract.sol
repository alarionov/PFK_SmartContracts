// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/BaseContract.sol";

import "./libraries/ComputedStats.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

enum ItemSlot
{
    Any,
    Armor,
    Weapon,
    Shield
}

struct ItemType 
{
    uint id;
    string name;
    ItemSlot slot;
    ComputedStats.Stats bonusStats;
}

struct Equipment
{
    uint armorSetId;
    uint weaponSetId;
    uint shieldId;
}

interface IEquipmentContract
{
    function getInventory(Equipment memory equipment) external view returns(ComputedStats.Stats memory bonusStats);
    function mintByGame(address player, uint itemType) external returns(uint tokenId);
    function forcedTransfer(address from, address to, uint itemId) external;
    function getItemTypeByItemId(uint tokenId) external view returns(ItemType memory itemType);
}

contract EquipmentContract is BaseContract, IEquipmentContract, ERC721Enumerable
{
    using ComputedStats for ComputedStats.Stats;
    
    mapping(uint => ItemType) _itemTypes;
    mapping(uint => uint) _itemToType;
    
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
        ComputedStats.Stats memory stats = ComputedStats.Stats({
            strength: strength,
            dexterity: dexterity,
            constitution: constitution,
            luck: luck,
            armor: armor,
            attack: 0,
            health: 0,
            takenDamage: 0
        });

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
        
        bonusStats = _accumulateBonus(bonusStats, equipment.armorSetId);
        bonusStats = _accumulateBonus(bonusStats, equipment.weaponSetId);
        bonusStats = _accumulateBonus(bonusStats, equipment.shieldId);
    }
    
    function _accumulateBonus(ComputedStats.Stats memory bonusStats, uint itemId) 
        private 
        view 
        returns(ComputedStats.Stats memory)
    {
        uint typeId = _itemToType[itemId];
        
        ItemType memory itemType = _itemTypes[typeId];
        
        return bonusStats.add(itemType.bonusStats);
    }
    
    function getItem(uint tokenId) public view returns(ItemType memory itemType)
    {
        itemType = _itemTypes[_itemToType[tokenId]];
    }
    
    function forcedTransfer(address from, address to, uint itemId) public onlyGame(msg.sender)
    {
        require(itemId > 0, "Invalid item id");
        require(ownerOf(itemId) == from, "Invalid owner");
        
        _transfer(from, to, itemId);
    }
    
    function getItemTypeByItemId(uint itemId) public view override(IEquipmentContract) returns(ItemType memory itemType)
    {
        itemType = _itemTypes[_itemToType[itemId]];
    }
}