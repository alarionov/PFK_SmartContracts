// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./abstract/Structures.sol";
import "./abstract/BaseContract.sol";

import { ICharacterContract } from "./002_CharacterContract.sol";
import { IFightContract } from "./003_FightContract.sol";
import { IEquipmentContract } from "./005_EquipmentContract.sol";
import { IMapContract } from "./abstract/MapContract.sol";

import "./libraries/Experience.sol";

interface IFightManagerContract
{
    function conductFight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) external;
}

contract FightManagerContract is BaseContract, IFightManagerContract
{
    using EnumerableSet for EnumerableSet.UintSet;
    using ComputedStats for ComputedStats.Stats;
    using Experience for Character;
    
    address public CHARACTER_CONTRACT_ADDRESS;
    address public FIGHT_CONTRACT_ADDRESS;
    address public EQUIPMENT_CONTRACT;
    
    mapping(address => bool) private _approvedCharacterContracts;
    
    modifier auth(address player, address contractAddress, uint tokenId)
    {
        require(_approvedCharacterContracts[contractAddress], "This contract is not supported");
        require(IERC721(contractAddress).ownerOf(tokenId) == player, "Player should own the character");
        
        _;
    }
    
    constructor(address authContractAddress) BaseContract(authContractAddress)
    {}
    
    /* battle */
    function conductFight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) 
        public
        override(IFightManagerContract)
        auth(msg.sender, characterContractAddress, characterId)
    {
        ICharacterContract characterContract = ICharacterContract(CHARACTER_CONTRACT_ADDRESS);
        IFightContract fightContract = IFightContract(FIGHT_CONTRACT_ADDRESS);
        IMapContract mapContract = IMapContract(mapContractAddress);
        
        Character memory character = _getCharacterWithInventoryStats(characterContractAddress, characterId);
        character.owner = msg.sender;

        require(mapContract.hasAccess(character, index));
    
        Enemy[] memory enemies = mapContract.getEnemies(index);
    
        Fight memory fight = fightContract.conductFight(character, enemies);
    
        character.addExp(fight.exp);
        
        characterContract.save(character);
        mapContract.update(character, index, fight.victory);
    }
    
    function _getCharacterWithInventoryStats(address characterContractAddress, uint characterId) private returns(Character memory character)
    {
        ICharacterContract characterContract = ICharacterContract(CHARACTER_CONTRACT_ADDRESS);
        IEquipmentContract equipmentContract = IEquipmentContract(EQUIPMENT_CONTRACT);
        
        character = characterContract.getCharacter(characterContractAddress, characterId);
        
        ComputedStats.Stats memory bonusStats = equipmentContract.getInventory(character.equipment);
        
        character.stats.add(bonusStats);
    }
}