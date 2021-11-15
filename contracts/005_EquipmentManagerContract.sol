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
    address public CHARACTER_CONTRACT_ADDRESS = address(0x0);
    address public EQUIPMENT_CONTRACT_ADDRESS = address(0x0);
    
    ICharacterContract _characterContract;
    IEquipmentContract _equipmentContract;
    IERC721 _equipmentERC721Contract;
    
    constructor(address authContractAddress) BaseContract(authContractAddress)
    {
    }
    
    function setCharacterContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        CHARACTER_CONTRACT_ADDRESS = newAddress;
        _characterContract = ICharacterContract(CHARACTER_CONTRACT_ADDRESS);
    }
    
    function setEquipmentContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        EQUIPMENT_CONTRACT_ADDRESS = newAddress;
        _equipmentContract = IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS);
        _equipmentERC721Contract = IERC721(EQUIPMENT_CONTRACT_ADDRESS);
    }
    
    function equip(Character memory character, ItemSlot slot, uint itemId) public onlyGame(msg.sender) override(IEquipmentManagerContract)
    {
        require(_equipmentERC721Contract.ownerOf(itemId) == character.owner, "You don't own the item");
        
        ItemType memory itemType = _equipmentContract.getItemTypeByItemId(itemId);
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
        
        _characterContract.save(character);
    }
    
    function _equipArmor(Character memory character, uint itemId) private
    {
        
        if (character.equipment.armorSetId != 0)
        {
            _unequipArmor(character);
        }
        
        _equipmentContract.forcedTransfer(character.owner, EQUIPMENT_CONTRACT_ADDRESS, itemId);
        
        character.equipment.armorSetId = itemId;
    }
    
    function _equipWeapon(Character memory character, uint itemId) private
    {
        if (character.equipment.weaponSetId != 0)
        {
            _unequipWeapon(character);
        }
        
        _equipmentContract.forcedTransfer(character.owner, address(this), itemId);
        
        character.equipment.weaponSetId = itemId;
    }
    
    function _equipShield(Character memory character, uint itemId) private
    {
        if (character.equipment.shieldId != 0)
        {
            _unequipShield(character);
        }
        
        _equipmentContract.forcedTransfer(character.owner, address(this), itemId);
        
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
        
        _characterContract.save(character);
    }
    
    function _unequipItem(address player, uint itemId) private
    {
        require(itemId != 0, "You do not wear this item");
        require(
            _equipmentERC721Contract.ownerOf(itemId) == EQUIPMENT_CONTRACT_ADDRESS, 
            "The item is not on the Equipment Contract");
        
        _equipmentContract.forcedTransfer(EQUIPMENT_CONTRACT_ADDRESS, player, itemId);
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