// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import { IMapContract } from "./abstract/MapContract.sol";
import { Character, ICharacterContract } from "./002_CharacterContract.sol";

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

    function checkChar(uint token) public view returns(uint con, uint hp)
    {
        ICharacterContract charContract = ICharacterContract(0x0D374dd4C9D2b6b2046698f0E82Af45230E4703a);
        Character memory character = charContract.getCharacter(0x59d05A0857bc55Eafe8BC49228b681025ffaC2E2, token);

        character.stats = character.stats.init();

        con = character.stats.constitution;
        hp = character.stats.health;
    }
}