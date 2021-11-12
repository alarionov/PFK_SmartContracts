// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/BaseContract.sol";

import "./libraries/ComputedStats.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { ItemSlot, ItemType, IEquipmentContract } from "./005_EquipmentContract.sol";
import { Character, ICharacterContract } from "./002_CharacterContract.sol";

interface IEquipmentManagerContract
{
    function equip(Character memory character, ItemSlot slot, uint itemId) external;
    function uneqip(Character memory character, ItemSlot slot) external;
}

contract EquipmentManagerContract is BaseContract, IEquipmentManagerContract
{
    address public EQUIPMENT_CONTRACT_ADDRESS = address(0x0);
    address public CHARACTER_CONTRACT_ADDRESS = address(0x0);
    
    constructor(address authContractAddress) BaseContract(authContractAddress)
    {
    }
    
    function equip(Character memory character, ItemSlot slot, uint itemId) public onlyGame(msg.sender) override(IEquipmentManagerContract)
    {
        require(IERC721(EQUIPMENT_CONTRACT_ADDRESS).ownerOf(itemId) == character.owner, "You don't own the item");
        
        ItemType memory itemType = IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS).getItemTypeByItemId(itemId);
        require(slot == itemType.slot || itemType.slot == ItemSlot.Any, "Invalid slot type for an item ");
        
        if (slot == ItemSlot.Armor)
        {
            _equipArmor(character, itemId);
        }
        
        if (slot == ItemSlot.Weapon)
        {
            _equipWeapon(character, itemId);
        }
        
        if (slot == ItemSlot.Shield)
        {
            _equipShield(character, itemId);
        }
        
        ICharacterContract(CHARACTER_CONTRACT_ADDRESS).save(character);
    }
    
    function _equipArmor(Character memory character, uint itemId) private
    {
        
        if (character.equipment.armorSetId != 0)
        {
            _unequipArmor(character);
        }
        
        IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS).forcedTransfer(character.owner, EQUIPMENT_CONTRACT_ADDRESS, itemId);
        
        character.equipment.armorSetId = itemId;
    }
    
    function _equipWeapon(Character memory character, uint itemId) private
    {
        if (character.equipment.weaponSetId != 0)
        {
            _unequipWeapon(character);
        }
        
        IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS).forcedTransfer(character.owner, address(this), itemId);
        
        character.equipment.weaponSetId = itemId;
    }
    
    function _equipShield(Character memory character, uint itemId) private
    {
        if (character.equipment.shieldId != 0)
        {
            _unequipShield(character);
        }
        
        IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS).forcedTransfer(character.owner, address(this), itemId);
        
        character.equipment.shieldId = itemId;
    }
    
    function uneqip(Character memory character, ItemSlot slot) public onlyGame(msg.sender) override(IEquipmentManagerContract)
    {
        if (slot == ItemSlot.Armor)
        {
            _unequipArmor(character);
        }
        
        if (slot == ItemSlot.Weapon)
        {
            _unequipWeapon(character);
        }
        
        if (slot == ItemSlot.Shield)
        {
            _unequipShield(character);
        }
        
        ICharacterContract(CHARACTER_CONTRACT_ADDRESS).save(character);
    }
    
    function _unequipItem(address player, uint itemId) private
    {
        require(itemId != 0, "You do not wear this item");
        require(
            IERC721(EQUIPMENT_CONTRACT_ADDRESS).ownerOf(itemId) == EQUIPMENT_CONTRACT_ADDRESS, 
            "The item is not on the Equipment Contract");
        
        IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS).forcedTransfer(EQUIPMENT_CONTRACT_ADDRESS, player, itemId);
    }
    
    function _unequipArmor(Character memory character) private
    {
        uint itemId = character.equipment.armorSetId;
        
        _unequipItem(character.owner, itemId);
        
        character.equipment.armorSetId = 0;
    }
    
    function _unequipWeapon(Character memory character) private
    {
        
        uint itemId = character.equipment.weaponSetId;
        
       _unequipItem(character.owner, itemId);
        
        character.equipment.weaponSetId = 0;
    }
    
    function _unequipShield(Character memory character) private
    {
        uint itemId = character.equipment.shieldId;
        
        _unequipItem(character.owner, itemId);
        
        character.equipment.shieldId = 0;
    }
}