// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./abstract/BaseContract.sol";

import { Character } from "./002_CharacterContract.sol";

interface IExperienceContract
{
    function addExp(Character memory character, uint exp) external returns (Character memory);
}

contract ExperienceContract is BaseContract, IExperienceContract
{
    event LevelUp(
        address contractAddress, 
        uint tokenId, 
        uint level, 
        uint exp, 
        uint tnl, 
        uint upgradesGiven, 
        uint upgradesTotal);

    uint8[] private _tnl;
    uint8 private _upgradesPerLevel = 5;
    uint8 private _lateProgressModifier = 10;

    constructor(address authContractAddress) BaseContract(authContractAddress)
    {
        _tnl = [
            6, 9, 9, 12, 12, 15, 15, 18, 18, 18, 21, 21, 21, 21, 24, 24, 24, 24, 
            27, 27, 27, 27, 30, 30, 30, 30, 30, 33, 33, 33, 33, 33, 33, 
            36, 36, 36, 36, 36, 36, 39, 39, 39, 39, 39, 39, 
            42, 42, 42, 42, 42, 42, 42, 45, 45, 45, 45, 45, 45, 45, 45, 
            48, 48, 48, 48, 48, 48, 48, 48, 51, 51, 51, 51, 51, 51, 51, 51, 
            54, 54, 54, 54, 54, 54, 54, 54, 54, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 
            60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 
            66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 
            72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 80 ];
    }

    function setTNL(uint8[] memory newTNL) public onlyGM(msg.sender)
    {
        _tnl = newTNL;
    }

    function setTNLByIndex(uint index, uint8 amount) public onlyGM(msg.sender)
    {
        require(index < _tnl.length, "Invalid index");

        _tnl[index] = amount;
    }

    function setUpgradesPerLevel(uint8 amount) public onlyGM(msg.sender)
    {
        _upgradesPerLevel = amount;
    }

    function setLateProgress(uint8 _modifier) public onlyGM(msg.sender)
    {
        _lateProgressModifier = _modifier;
    }

    function tnl() public view returns(uint8[] memory)
    {
        return _tnl;
    }

    function addExp(Character memory character, uint exp) 
        public 
        onlyGame(msg.sender) 
        override(IExperienceContract)
        returns (Character memory)
    {
        if (exp == 0) return character;
        
        character.exp += exp;
        
        while (character.exp >= toNextLevel(character))
        {
            character.exp -= toNextLevel(character);
            character.level += 1;
            character.upgrades += _upgradesPerLevel;

            emit LevelUp(
                character.contractAddress, 
                character.tokenId, 
                character.level, 
                character.exp, 
                toNextLevel(character), 
                _upgradesPerLevel, 
                character.upgrades);
        }

        return character;
    }
    
    function toNextLevel(Character memory character) public view returns(uint amount)
    {
        if (character.level < _tnl.length)
        {
            amount = _tnl[character.level - 1];
        }
        else
        {
            uint baseAmount = _tnl[_tnl.length - 1];
            uint levelDiff = (character.level - _tnl.length);

            amount = baseAmount + _lateProgressModifier * levelDiff;
        }
    }
}