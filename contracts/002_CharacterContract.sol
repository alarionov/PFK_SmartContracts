// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;


import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

import {GameMath} from "./libraries/GameMath.sol";

contract CharacterContract is BaseContract, ICharacterContract
{
    event NewCharacter(Character newCharacter);
    event NewStats(Stats newStats, uint remainigUpgrades);
    event LevelUp(uint level, uint exp, uint tnl, uint upgradesGiven, uint upgradesTotal);
    
    mapping(address => bool) private _approvedContracts;
    mapping(address => mapping(uint => Character)) private _characters;
    
    uint[] private _tnl = [6, 9, 9, 12, 12, 15, 15, 18, 18, 18, 21, 21, 21, 21, 24, 24, 24, 24, 27, 27, 27, 27, 30, 30, 30, 30, 30, 33, 33, 33, 33, 33, 33, 36, 36, 36, 36, 36, 36, 39, 39, 39, 39, 39, 39, 42, 42, 42, 42, 42, 42, 42, 45, 45, 45, 45, 45, 45, 45, 45, 48, 48, 48, 48, 48, 48, 48, 48, 51, 51, 51, 51, 51, 51, 51, 51, 54, 54, 54, 54, 54, 54, 54, 54, 54, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 80];

    modifier owns(address player, address contractAddress, uint tokenId)
    {
        require(_approvedContracts[contractAddress], "This contract is not supported");
        require(IERC721(contractAddress).ownerOf(tokenId) == player, "Player should own the character");
        
        _;
    }
    
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
    
    function getCharacter(address contractAddress, uint tokenId) external view override(ICharacterContract) returns (Character memory character)
    {
        character = _characters[contractAddress][tokenId];
    }
    
    function toNextLevel(uint level) public view returns(uint)
    {
        require(level > 0, "Level should be greater than zero");
        
        if (level < _tnl.length)
        { 
            return _tnl[level - 1];
        }
        
        uint base_tnl = _tnl[_tnl.length - 1];
        
        return base_tnl + 10 * (level - _tnl.length);
    }
    
    /* Upgrades */
    function upgrade(address contractAddress, uint tokenId, StatType stat) external 
        owns(msg.sender, contractAddress, tokenId)  
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

    function createCharacter(address contractAddress, uint tokenId) external 
        owns(msg.sender, contractAddress, tokenId)
        returns (uint newTokenId)
    {
        newTokenId = tokenId;
        
        _characters[contractAddress][newTokenId] = 
            Character({
                contractAddress: contractAddress,
                tokenId: tokenId,
                exists: true,
                level: 1,
                exp: 0,
                upgrades: 0,
                stats: Stats({ 
                    strength: 1, 
                    dexterity: 1, 
                    constitution: 3, 
                    luck: 0, 
                    armor: 0 
                }),
                equipment: Equipment({
                    armorSetId: 0,
                    weaponSetId: 0,
                    shieldId: 0
                })
            }); 
            
        emit NewCharacter(_characters[contractAddress][newTokenId]);
    }
    
    function addExp(address player, address contractAddress, uint tokenId, uint exp) external override(ICharacterContract)
        onlyGame 
        owns(player, contractAddress, tokenId)
    {
        require(exp >= 0, "Exp should be a positive number");
        
        Character storage character = _characters[contractAddress][tokenId];
        
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
    }
}