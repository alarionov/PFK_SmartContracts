// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../libraries/ComputedStats.sol";

enum StatType
{
    Strength,
    Dexterity,
    Constitution,
    Luck,
    Armor
}

struct Equipment
{
    uint armorSetId;
    uint weaponSetId;
    uint shieldId;
}

struct Fight
{
    uint id;
    bytes seed;
    
    ComputedStats.Stats stats;
    
    bool victory;
    uint exp;
}

struct Enemy
{
    uint id;
    bool present;
    ComputedStats.Stats stats;
}

struct Level
{
    bool[3] enemies;
}
