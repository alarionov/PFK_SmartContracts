// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "../abstract/Structures.sol";

library ComputedStats 
{
    struct Stats
    {
        uint strength;
        uint dexterity;
        uint constitution;
        uint luck;
        uint armor;
        
        /* computed stats */
        uint attack;
        uint health;
        uint takenDamage;
    }
    
    function defaultStats() public pure returns (Stats memory stats)
    {
        stats = Stats({
            strength: 1,
            dexterity: 1,
            constitution: 1,
            luck: 0,
            armor: 0,
        
            attack: 0,
            health: 0,
            takenDamage: 0 
        });
    }
    
    function zero() public pure returns (Stats memory stats)
    {
        stats = Stats({
            strength: 0,
            dexterity: 0,
            constitution: 0,
            luck: 0,
            armor: 0,
        
            attack: 0,
            health: 0,
            takenDamage: 0 
        });
    }
    
    function newStats(uint strength, uint dexterity, uint constitution, uint luck, uint armor) 
        public 
        pure 
        returns (Stats memory stats)
    {
        stats = Stats({
            strength: strength,
            dexterity: dexterity,
            constitution: constitution,
            luck: luck,
            armor: armor,
            attack: 0,
            health: 0,
            takenDamage: 0
        });
    }
    
    function init(Stats memory stats) public pure
    {
        stats.attack = computeAttack(stats);
        stats.health = computeHealth(stats);
        stats.takenDamage = 0;
    }
    
    function computeAttack(Stats memory stats) public pure returns(uint attack)
    {
        attack = stats.strength;
    }
    
    function computeHealth(Stats memory stats) public pure returns(uint health)
    {
        health = stats.constitution * 3;
    }
    
    function getHealth(Stats memory stats) public pure returns(uint)
    {
        return stats.health > stats.takenDamage ? stats.health - stats.takenDamage : 0;
    }
    
    function applyDamage(Stats memory stats, uint damage, bool crit) public pure
    {
        if  (!crit)
        {
            if (damage < stats.armor) 
                return;
                    
            damage -= stats.armor;
        }
        
        stats.takenDamage += damage;
    }
    
    function alive(Stats memory stats) public pure returns(bool)
    {
        return getHealth(stats) > 0;
    }
    
    function hitChance(Stats memory target, Stats memory attacker) public pure returns(uint)
    {
        int top = int(attacker.dexterity) - int(target.dexterity);
        int bottom = int(target.dexterity + attacker.dexterity);
        return uint(64 + 64 * top / bottom);
    }
    
    function critChance(Stats memory target, Stats memory attacker) public pure returns(uint)
    {
        int top = int(attacker.luck) - int(target.luck);
        int bottom = int(target.luck + attacker.luck);
        int chance = 32 + 96 * top / bottom;
        
        if (chance < 0 ) chance = 0;
        
        return uint(chance);
    }
}