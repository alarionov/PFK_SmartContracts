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
    function getCharacter(address contractaddress, uint tokenId) external view returns (Character memory character);
    function save(Character memory character) external;
}

contract CharacterContract is BaseContract, ICharacterContract
{
    event NewCharacter(Character newCharacter);
    
    mapping(address => mapping(uint => Character)) private _characters;
    
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
            upgrades: 5,
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
    
    function save(Character memory character) public override(ICharacterContract) onlyGame(msg.sender)
    {
        _saveCharacter(character);
    }
}