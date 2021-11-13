// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/BaseContract.sol";

import "./libraries/GameMath.sol";
import "./libraries/ComputedStats.sol";

import { Equipment } from "./005_EquipmentContract.sol";

struct Character
{
    bool exists;
    
    address contractAddress;
    uint tokenId;
    address owner;
    
    uint level;
    uint exp;
    uint upgrades;
    
    ComputedStats.Stats stats;
    Equipment equipment;
}

interface ICharacterContract
{
    function getCharacter(address contractaddress, uint tokenId) external returns (Character memory character);
    function save(Character memory character) external;
}

contract CharacterContract is BaseContract, ICharacterContract
{
    event NewCharacter(Character newCharacter);
    event NewStats(ComputedStats.Stats newStats, uint remainigUpgrades);
    event LevelUp(uint level, uint exp, uint tnl, uint upgradesGiven, uint upgradesTotal);
    
    mapping(address => mapping(uint => Character)) private _characters;
    
    modifier upgradable(address player, address contractAddress, uint tokenId)
    {
        Character memory character = _characters[contractAddress][tokenId];
        
        require(character.upgrades > 0, "No upgrades available");
        
        _;
    }
    
    constructor(address authContractAddress) BaseContract(authContractAddress)
    {
    }
    
    function _defaultCharacter(address contractAddress, uint tokenId) private pure returns (Character memory character)
    {
        character = Character({
            exists: true,
            contractAddress: contractAddress,
            tokenId: tokenId,
            owner: address(0x0),
            level: 1,
            exp: 0,
            upgrades: 0,
            stats: ComputedStats.defaultStats(),
            equipment: Equipment(0,0,0)
        });
    }
    
    function _getStoredOrDefaultCharacter(address contractAddress, uint tokenId) private view returns (Character memory character)
    {
        Character memory storedCharacter = _characters[contractAddress][tokenId];
        
        character = storedCharacter.exists ? storedCharacter : _defaultCharacter(contractAddress, tokenId);
    }
    
    function _saveCharacter(Character memory character) private
    {
        _characters[character.contractAddress][character.tokenId] = character;
    }
    
    function getCharacter(address contractAddress, uint tokenId) public view override(ICharacterContract) returns (Character memory character)
    {
        character = _getStoredOrDefaultCharacter(contractAddress, tokenId);
    }
    
    /* Upgrades */
    function upgrade(address contractAddress, uint tokenId, ComputedStats.StatType stat) external 
        onlyGame(msg.sender)
        upgradable(msg.sender, contractAddress, tokenId)
    {
        require(stat >= ComputedStats.StatType.Strength && stat <= ComputedStats.StatType.Constitution, "Invalid stat type");
        
        Character memory character = _characters[contractAddress][tokenId];
        
        _upgrade(character, stat, 1);
        
        emit NewStats(character.stats, character.upgrades);
    }
    
    function modifyStats(address contractAddress, uint tokenId, ComputedStats.StatType stat, uint value) external onlyGame(msg.sender) 
    {
        Character memory character = _characters[contractAddress][tokenId];
        
        _upgrade(character, stat, value);
        
        emit NewStats(character.stats, character.upgrades);
    }
    
    function _upgrade(Character memory character, ComputedStats.StatType stat, uint value) private pure
    {
        character.upgrades -= value;
        
        if (stat == ComputedStats.StatType.Strength)
        {
            character.stats.strength += value;    
        }
        else if (stat == ComputedStats.StatType.Dexterity)
        {
            character.stats.dexterity += value;
        }
        else if (stat == ComputedStats.StatType.Constitution)
        {
            character.stats.dexterity += value;
        }
        else if (stat == ComputedStats.StatType.Luck)
        {
            character.stats.dexterity += value;
        }
        else if (stat == ComputedStats.StatType.Armor)
        {
            character.stats.dexterity += value;
        }
    }
    
    function _modify(Character memory character, ComputedStats.StatType stat, uint value, int8 sign) private pure
    {
        if (stat == ComputedStats.StatType.Strength)
        {
            character.stats.strength = GameMath.modify(character.stats.strength, value, sign);
        }
        else if (stat == ComputedStats.StatType.Dexterity)
        {
            character.stats.dexterity = GameMath.modify(character.stats.dexterity, value, sign);
        }
        else if (stat == ComputedStats.StatType.Constitution)
        {
            character.stats.constitution = GameMath.modify(character.stats.constitution, value, sign);
        }
        else if (stat == ComputedStats.StatType.Luck)
        {
            character.stats.luck = GameMath.modify(character.stats.luck, value, sign);
        }
        else if (stat == ComputedStats.StatType.Armor)
        {
            character.stats.armor = GameMath.modify(character.stats.armor, value, sign);
        }
    }
    
    function save(Character memory character) public override(ICharacterContract) onlyGame(msg.sender)
    {
        _saveCharacter(character);
    }
}