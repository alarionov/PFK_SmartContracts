// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/Enemy.sol";
//import "./abstract/BaseContract.sol";

//import { ICharacterContract } from "./002_CharacterContract.sol";
//import { Fight, IFightContract } from "./003_FightContract.sol";
//import { IEquipmentContract } from "./005_EquipmentContract.sol";

import { IMapContract } from "./abstract/MapContract.sol";

//import "./libraries/Experience.sol";
import "./libraries/ComputedStats.sol";

contract Test
{
    using ComputedStats for ComputedStats.Stats;

    constructor()
    {}

    function check(address mapAddress, uint index) public view returns(Enemy[] memory)
    {
        IMapContract map = IMapContract(mapAddress);
        Enemy[] memory enemies = map.getEnemies(index);       

        for (uint i = 0; i < enemies.length; ++i)
        {
            require(enemies[i].stats.alive(), "Enemy should be alive");
        }

        return enemies;
    }
}