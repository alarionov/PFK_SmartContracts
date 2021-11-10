// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/Structures.sol";
import "./abstract/BaseContract.sol";

import "./libraries/ComputedStats.sol";

interface IEquipmentManagerContract
{
    function equip(Character memory character, ItemSlot slot, uint itemId) external;
    function uneqip(Character memory character, ItemSlot slot) external;
}

contract EquipmentManager is BaseContract, IEquipmentManagerContract
{
    constructor(address authContractAddress) BaseContract(authContractAddress)
    {}
    
    function equip(Character memory character, ItemSlot slot, uint itemId) public onlyGame(msg.sender) override(IEquipmentManagerContract)
    {
        /*
        require(ownerOf(itemId) == character.owner, "You don't own the item");
        
        ItemType memory itemType = itemTypeByItemId(itemId);
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
        */
    }
    
    /*
    function _equipArmor(Character memory character, uint itemId) private
    {
        if (character.equipment.armorSetId != 0)
        {
            _unequipArmor(character);
        }
        
        _transfer(character.owner, address(this), itemId);
        
        character.equipment.armorSetId = itemId;
    }
    
    function _equipWeapon(Character memory character, uint itemId) private
    {
        if (character.equipment.weaponSetId != 0)
        {
            _unequipWeapon(character);
        }
        
        _transfer(character.owner, address(this), itemId);
        
        character.equipment.weaponSetId = itemId;
    }
    
    function _equipShield(Character memory character, uint itemId) private
    {
        if (character.equipment.shieldId != 0)
        {
            _unequipShield(character);
        }
        
        _transfer(character.owner, address(this), itemId);
        
        character.equipment.shieldId = itemId;
    }
    
    */
    
    function uneqip(Character memory character, ItemSlot slot) public onlyGame(msg.sender) override(IEquipmentManagerContract)
    {
        /*
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
        */
    }
    
    /*
    function _unequipArmor(Character memory character) private
    {
        uint itemId = character.equipment.armorSetId;
        
        require(itemId != 0, "You do not wear any armor");
        require(ownerOf(itemId) == address(this), "The item is not on the contract");
        
        _transfer(address(this), character.owner, itemId);
        
        character.equipment.armorSetId = 0;
    }
    
    function _unequipWeapon(Character memory character) private
    {
        uint itemId = character.equipment.weaponSetId;
        
        require(itemId != 0, "You do not wear any armor");
        require(ownerOf(itemId) == address(this), "The item is not on the contract");
        
        _transfer(address(this), character.owner, itemId);
        
        character.equipment.weaponSetId = 0;
    }
    
    function _unequipShield(Character memory character) private
    {
        uint itemId = character.equipment.shieldId;
        
        _unequipItem(character.owner, itemId);
        
        character.equipment.shieldId = 0;
    }
    */
}