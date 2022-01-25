// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "hardhat/console.sol";

import { IMapContract } from "./abstract/MapContract.sol";
import { Character, ICharacterContract } from "./002_CharacterContract.sol";
import { IExperienceContract } from "./002_ExperienceContract.sol";
import { Equipment } from "./005_EquipmentContract.sol";

import "./libraries/ComputedStats.sol";

interface ISideQuest
{
     function getCooldowns(Character memory character) external view returns(uint[6] memory cooldowns);
}

contract Test
{
    using ComputedStats for ComputedStats.Stats;

    constructor()
    {}

    function check() public pure returns(uint attack, uint health)
    {
        uint strength = 2;
        uint dexterity = 3; 
        uint constitution = 4;
        
        ComputedStats.Stats memory stats = ComputedStats.newStats(strength, dexterity, constitution);

        attack = stats.attack;
        health = stats.health;
    }

    function moveZero(uint from, uint step) public pure returns(uint asnwer)
    {
        asnwer = from >> step;
    }

    function checkChar() public returns(uint level, uint exp)
    {
        Character memory character = Character({
            exists: true,
            contractAddress: address(0x0),
            tokenId: 1,
            owner: address(0x0),
            level: 1,
            exp: 0,
            upgrades: 5,
            stats: ComputedStats.defaultStats(),
            equipment: Equipment(0,0,0)
        });

        character.stats = character.stats.init();

        console.log("level: ", character.level);
        console.log("exp: ", character.exp);

        IExperienceContract expContract = IExperienceContract(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
        character = expContract.addExp(character, 10);

        console.log("level: ", character.level);
        console.log("exp: ", character.exp);

        level = character.level;
        exp = character.exp;
    }
}