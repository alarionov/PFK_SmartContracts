// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

import "./libraries/GameMath.sol";
import "./libraries/ComputedStats.sol";

contract CharacterContract is BaseContract, ICharacterContract
{
    event NewCharacter(Character newCharacter);
    event NewStats(ComputedStats.Stats newStats, uint remainigUpgrades);
    event LevelUp(uint level, uint exp, uint tnl, uint upgradesGiven, uint upgradesTotal);
    
    mapping(address => mapping(uint => Character)) private _characters;
    
    uint[] private _tnl = [6, 9, 9, 12, 12, 15, 15, 18, 18, 18, 21, 21, 21, 21, 24, 24, 24, 24, 27, 27, 27, 27, 30, 30, 30, 30, 30, 33, 33, 33, 33, 33, 33, 36, 36, 36, 36, 36, 36, 39, 39, 39, 39, 39, 39, 42, 42, 42, 42, 42, 42, 42, 45, 45, 45, 45, 45, 45, 45, 45, 48, 48, 48, 48, 48, 48, 48, 48, 51, 51, 51, 51, 51, 51, 51, 51, 54, 54, 54, 54, 54, 54, 54, 54, 54, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 80];

    modifier upgradable(address player, address contractAddress, uint tokenId)
    {
        Character memory character = _characters[contractAddress][tokenId];
        
        require(character.upgrades > 0, "No upgrades available");
        
        _;
    }
    
    constructor() BaseContract()
    {
        CHARACTER_CONTRACT_ADDRESS = address(this);
    }
    
    function _defaultCharacter(address contractAddress, uint tokenId) private pure returns (Character memory character)
    {
        ComputedStats.Stats memory stats = ComputedStats.Stats({
            strength: 1,
            dexterity: 1,
            constitution: 1,
            luck: 0,
            armor: 0,
            attack: 0,
            health: 0,
            takenDamage: 0 
        });
        
        character = Character({
            exists: true,
            contractAddress: contractAddress,
            tokenId: tokenId,
            level: 1,
            exp: 0,
            upgrades: 0,
            stats: stats,
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
    
    function toNextLevel(uint level) public view returns(uint amount)
    {
        require(level > 0, "Level should be greater than zero");
        
        if (level < _tnl.length)
        { 
            amount = _tnl[level - 1];
        }
        else
        {
            amount = _tnl[_tnl.length - 1]  + 10 * (level - _tnl.length);    
        }
        
    }
    
    /* Upgrades */
    function upgrade(address contractAddress, uint tokenId, StatType stat) external 
        onlyGame
        upgradable(msg.sender, contractAddress, tokenId)
    {
        require(stat >= StatType.Strength && stat <= StatType.Constitution, "Invalid stat type");
        
        Character memory character = _characters[contractAddress][tokenId];
        
        _upgrade(character, stat, 1);
        
        emit NewStats(character.stats, character.upgrades);
    }
    
    function modifyStats(address contractAddress, uint tokenId, StatType stat, uint value) external onlyGame 
    {
        Character memory character = _characters[contractAddress][tokenId];
        
        _upgrade(character, stat, value);
        
        emit NewStats(character.stats, character.upgrades);
    }
    
    function _upgrade(Character memory character, StatType stat, uint value) private pure
    {
        character.upgrades -= value;
        
        if (stat == StatType.Strength)
        {
            character.stats.strength += value;    
        }
        else if (stat == StatType.Dexterity)
        {
            character.stats.dexterity += value;
        }
        else if (stat == StatType.Constitution)
        {
            character.stats.dexterity += value;
        }
        else if (stat == StatType.Luck)
        {
            character.stats.dexterity += value;
        }
        else if (stat == StatType.Armor)
        {
            character.stats.dexterity += value;
        }
    }
    
    function _modify(Character memory character, StatType stat, uint value, int8 sign) private pure
    {
        if (stat == StatType.Strength)
        {
            character.stats.strength = GameMath.modify(character.stats.strength, value, sign);
        }
        else if (stat == StatType.Dexterity)
        {
            character.stats.dexterity = GameMath.modify(character.stats.dexterity, value, sign);
        }
        else if (stat == StatType.Constitution)
        {
            character.stats.constitution = GameMath.modify(character.stats.constitution, value, sign);
        }
        else if (stat == StatType.Luck)
        {
            character.stats.luck = GameMath.modify(character.stats.luck, value, sign);
        }
        else if (stat == StatType.Armor)
        {
            character.stats.armor = GameMath.modify(character.stats.armor, value, sign);
        }
    }
    
    function addExp(address contractAddress, uint tokenId, uint exp) 
        external 
        override(ICharacterContract) 
        onlyGame 
    {
        if (exp == 0) return;
        
        Character memory character = _getStoredOrDefaultCharacter(contractAddress, tokenId);
        
        character.exp += exp;
        
        while (character.exp >= toNextLevel(character.level))
        {
            character.exp -= toNextLevel(character.level);
            character.level += 1;
            character.upgrades += 1;
            
            emit LevelUp(
                character.level, 
                character.exp,
                toNextLevel(character.level),
                1,
                character.upgrades);
        }
        
        _saveCharacter(character);
    }
}