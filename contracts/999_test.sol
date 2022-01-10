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

    function check() public view returns(uint cooldown)
    {
        ICharacterContract characterContract = ICharacterContract(0x3fe426a48FA4Fb7Ca7c650A64dC8F6405448BcD7);
        Character memory character = characterContract.getCharacter(0x5cAa53913fC48aCdbD2825CA06Ed8C9A16EbBaFe, 3031);

        ISideQuest map = ISideQuest(0x638F92422bad6Bb3F7561fc632Bb13339e870094);
               
        cooldown = map.getCooldowns(character)[0];
    }

    function timestamp() public view returns(uint ts)
    {
        ts = block.timestamp;
    }
}