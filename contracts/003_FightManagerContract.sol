// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./abstract/BaseContract.sol";

import { Character, ICharacterContract } from "./002_CharacterContract.sol";
import { Fight, IFightContract } from "./003_FightContract.sol";
import { IEquipmentContract } from "./005_EquipmentContract.sol";
import { IMapContract } from "./abstract/MapContract.sol";
import { IExperienceContract } from "./002_ExperienceContract.sol";

import "./libraries/ComputedStats.sol";

interface IFightManagerContract
{
    function conductFight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) external;
}

contract FightManagerContract is BaseContract, IFightManagerContract
{
    using EnumerableSet for EnumerableSet.UintSet;
    using ComputedStats for ComputedStats.Stats;

    address public CHARACTER_CONTRACT_ADDRESS;
    address public FIGHT_CONTRACT_ADDRESS;
    address public EQUIPMENT_CONTRACT_ADDRESS;
    address public EXPERIENCE_CONTRACT_ADDRESS;
    
    ICharacterContract private _characterContract;
    IFightContract private _fightContract;
    IEquipmentContract private _equipmentContract;
    IExperienceContract private _experienceContract;
    
    constructor(address authContractAddress) BaseContract(authContractAddress)
    {}
    
    function setCharacterContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        CHARACTER_CONTRACT_ADDRESS = newAddress;
        _characterContract = ICharacterContract(CHARACTER_CONTRACT_ADDRESS);
    }
    
    function setFightContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        FIGHT_CONTRACT_ADDRESS = newAddress;
        _fightContract = IFightContract(FIGHT_CONTRACT_ADDRESS);
    }
    
    function setEquipmentContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        EQUIPMENT_CONTRACT_ADDRESS = newAddress;
        _equipmentContract = IEquipmentContract(EQUIPMENT_CONTRACT_ADDRESS);
    }

    function setExperienceContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        EXPERIENCE_CONTRACT_ADDRESS = newAddress;
        _experienceContract = IExperienceContract(EXPERIENCE_CONTRACT_ADDRESS);
    }
    
    function conductFight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) 
        public
        override(IFightManagerContract)
        auth(msg.sender, characterContractAddress, characterId)
    {
        IMapContract mapContract = IMapContract(mapContractAddress);
        
        Character memory character = _getCharacterWithInventoryStats(characterContractAddress, characterId);

        require(character.stats.alive(), "Character should be alive");

        require(mapContract.hasAccess(character, index), "Character doesn't have the access to this level");
    
        ComputedStats.Stats[] memory enemies = mapContract.getEnemies(index);

        for (uint i = 0; i < enemies.length; ++i)
        {
            require(enemies[i].alive(), "Enemy should be alive");
        }

        Fight memory fight = _fightContract.conductFight(character, enemies);

        character = _experienceContract.addExp(character, fight.exp);
        
        _characterContract.save(character);
        mapContract.update(character, index, fight.victory);
    }
    
    
    function _getCharacterWithInventoryStats(address characterContractAddress, uint characterId) 
        private 
        view 
        returns(Character memory character)
    {
        character = _characterContract.getCharacter(characterContractAddress, characterId);
        
        ComputedStats.Stats memory bonusStats = _equipmentContract.getInventory(character.equipment);
        
        character.stats = character.stats.add(bonusStats);
    }
}