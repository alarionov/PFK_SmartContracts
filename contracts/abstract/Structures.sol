// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

enum StatType
{
    Strength,
    Dexterity,
    Constitution,
    Luck,
    Armor
}

struct Stats
{
    uint strength;
    uint dexterity;
    uint constitution;
    uint luck;
    uint armor;
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
    
    Stats stats;
    Equipment equipment;
}

struct Fight
{
    uint id;
    bytes seed;
    
    Stats stats;
    
    bool[] buffs;
    bool victory;
}

struct Enemy
{
    uint id;
    Stats stats;
}

struct Level
{
    bool[3] enemies;
}
