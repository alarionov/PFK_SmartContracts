// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library ComputedStats 
{
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
        /* trainable */
        uint strength;
        uint dexterity;
        uint constitution;

        /* from equipment */
        uint luck;
        uint armor;
        
        /* computed stats */
        uint attack;
        uint health;
        uint takenDamage;
    }
   
    function copy(Stats memory stats) public pure returns (Stats memory)
    {
        return Stats({
            strength: stats.strength,
            dexterity: stats.dexterity,
            constitution: stats.constitution,
            luck: stats.luck,
            armor: stats.armor,
            attack: stats.attack,
            health: stats.health,
            takenDamage: stats.takenDamage
        });
    }

    function newStats(uint strength, uint dexterity, uint constitution) 
        public 
        pure 
        returns (Stats memory)
    {
        return init(Stats({
            strength: strength,
            dexterity: dexterity,
            constitution: constitution,
            luck: 0,
            armor: 0,
            attack: 0,
            health: 0,
            takenDamage: 0
        }));
    }
    
    function defaultStats() public pure returns(Stats memory)
    {
        return newStats(1, 1, 1);
    }
    
    function zeroStats() public pure returns(Stats memory)
    {
        return newStats(0, 0, 0);
    }
    
    function init(Stats memory stats) public pure returns(Stats memory)
    {
        stats.attack = computeAttack(stats);
        stats.health = computeHealth(stats);
        stats.takenDamage = 0;

        return stats;
    }
    
    function add(Stats memory one, Stats memory another) public pure returns(Stats memory)
    {
        one.strength += another.strength;
        one.dexterity += another.dexterity;
        one.constitution += another.constitution;
        one.luck += another.luck;
        one.armor += another.armor;

        return one;
    }
    
    function getHealth(Stats memory stats) public pure returns(uint)
    {
        return stats.health > stats.takenDamage ? stats.health - stats.takenDamage : 0;
    }
    
    function applyDamage(Stats memory stats, uint damage, bool crit) public pure returns(uint)
    {
        if (crit) 
            return damage;

        if (damage < stats.armor) 
            return 0;
                    
        return damage - stats.armor;
    }
    
    function alive(Stats memory stats) public pure returns(bool)
    {
        return getHealth(stats) > 0;
    }
    
    function hitChance(Stats memory target, Stats memory attacker) public pure returns(uint)
    {
        return calculateChance(64, 64, int(attacker.dexterity), int(target.dexterity));
    }
    
    function critChance(Stats memory target, Stats memory attacker) public pure returns(uint)
    {
        return calculateChance(32, 96, int(attacker.luck), int(target.luck));
    }
    
    function calculateChance(int base, int bonus, int from, int to) internal pure returns(uint)
    {
        int top = from - to;
        int bottom = from + to;
        
        if (bottom == 0) return uint(base);
        
        int chance = base + bonus * top / bottom;
        
        if (chance < 0) chance = 0;
        
        return uint(chance);
    }

    function computeAttack(Stats memory stats) internal pure returns(uint attack)
    {
        attack = stats.strength;
    }
    
    function computeHealth(Stats memory stats) internal pure returns(uint health)
    {
        health = stats.constitution;
    }
}