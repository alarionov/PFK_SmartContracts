// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

struct BaseStats
{
    uint attack;
    uint health;
    uint armour;
}

struct Character
{
    uint id;
    uint character;
    
    BaseStats stats;

    bool alive;
    bool exists;
    
    uint season;
    
    uint level;
    uint exp;
    
    uint8 upgrades;
}

struct PlayerState
{
    uint tokenId;
    uint level;
    uint difficulty;
}

struct Fight
{
    uint id;
    uint season;
    bytes seed;
    uint score;
    BaseStats stats;
    PlayerState oldState;
    PlayerState newState;
    bool[] buffs;
    bool victory;
    bool died;
}

struct Skeleton
{
    uint id;
    BaseStats stats;
}

struct Level
{
    bool[3] active_skeletons;
}

enum SpellType
{
    // COMMON (1 word)
    // +1 attack
    Enchant,
    
    // +5 health
    FalseLife,
    
    // +1 armour
    Shield,
    
    // UNCOMMON (2 words)
    
    
    // RARE (3 words)
    // always crit
    CriticalStrike,
    
    // +1 attack +5 health + 1 armour
    Bless,
    
    
    // EPIC (4 words)
    // 1 damage to an enemy when they attack
    Reflect,
    
    // heal +1 if damage an enemy and crit
    Vampirism,
    
    
    // LEGENDARY (5words), depletable, 1 charge
    // do not die if die
    Salvation
}

struct Spell
{
    string name;
    uint[] words;
}

struct LeaderboardRecord
{
    address player;
    uint score;
}