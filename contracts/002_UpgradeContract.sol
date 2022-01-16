// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import { BaseContract } from "./abstract/BaseContract.sol";
import { ComputedStats } from "./libraries/ComputedStats.sol";
import { Character, ICharacterContract } from "./002_CharacterContract.sol";

contract UpgradeContract is BaseContract
{
    using ComputedStats for ComputedStats.Stats;

    event Upgrade(Character character);

    address public CharacterContractAddress;
    ICharacterContract private _characterContract;

    constructor(address authContractAddress) BaseContract(authContractAddress)
    {}

    function setCharacterContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        CharacterContractAddress = newAddress;
        _characterContract = ICharacterContract(CharacterContractAddress);
    }

    function upgrade(address contractAddress, uint token, ComputedStats.Stats memory addedStats) 
        public
        auth(msg.sender, contractAddress, token)
    {
        require(addedStats.armor == 0, "Can't increase armor");
        require(addedStats.luck == 0, "Can't increase luck");

        Character memory character = _characterContract.getCharacter(contractAddress, token);

        uint upgrades = addedStats.strength + addedStats.dexterity + addedStats.constitution;
        require(character.upgrades >= upgrades, "Not enough upgrades");

        character.upgrades -= upgrades;
        character.stats = character.stats.add(addedStats);
        
        _characterContract.save(character);

        emit Upgrade(character);
    }
}