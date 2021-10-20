// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

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

struct Character
{
    bool exists;
    
    address contractAddress;
    uint tokenId;
    
    uint level;
    uint exp;
    uint upgrades;
    
    ComputedStats.Stats stats;
    Equipment equipment;
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
    ComputedStats.Stats stats;
}

struct Level
{
    bool[3] enemies;
}
