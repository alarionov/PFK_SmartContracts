// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/Enemy.sol";
import "./abstract/BaseContract.sol";

import "./libraries/SeedReader.sol";
import "./libraries/ComputedStats.sol";

import { Character } from "./002_CharacterContract.sol";

struct Fight
{
    uint id;
    bytes seed;
    
    ComputedStats.Stats stats;
    
    bool victory;
    uint exp;
}

interface IFightContract
{
    function conductFight(Character memory character, Enemy[] memory enemies) external returns (Fight memory); 
}

contract FightContract is BaseContract, IFightContract
{
    using SeedReader for SeedReader.Seed;
    using ComputedStats for ComputedStats.Stats;
    
    event FightDetails(Fight fight);

    uint8 private MAX_FIGHT_ACTIONS = 10;
    
    constructor(address authContractAddress) BaseContract(authContractAddress)
    {}
    
    function conductFight(Character memory character, Enemy[] memory enemies) 
        external 
        override(IFightContract) 
        onlyGame(msg.sender) 
        returns(Fight memory fight) 
    {
        SeedReader.Seed memory seed = SeedReader.init([random(), random(), random(), random()]);
        
        fight = Fight({
            id: 0,
            seed: seed.raw,
            stats: character.stats,
            victory: false,
            exp: 0
        });
        
        (fight.victory, fight.exp) = _fight(seed, character, enemies);
        
        if (!character.stats.alive())
        {
            fight.exp = fight.exp >> 2;
        }
        
        emit FightDetails(fight);

        return fight;
    }
    
    function _fight(SeedReader.Seed memory seed, Character memory character, Enemy[] memory enemies) 
        private view returns(bool victory, uint exp)
    {
        exp = 0;
        
        for (uint step = 0; step < MAX_FIGHT_ACTIONS; ++step)
        {
            uint8 index;
            (seed.index, index) = seed.read(uint8(enemies.length));
            
            Enemy memory target = enemies[index];
            
            exp += _processAttack(seed, character.stats, target.stats);
            
            enemies = _recountEnemies(enemies);
            
            if (enemies.length == 0) return (true, exp);
            
            for (uint i = 0; i < enemies.length; ++i)
            {
                _processAttack(seed, enemies[i].stats, character.stats);
                
                if (!character.stats.alive()) return (false, 0);
            }
        }

        victory = false;
    }
    
    function _processAttack(
        SeedReader.Seed memory seed, 
        ComputedStats.Stats memory attacker, 
        ComputedStats.Stats memory target
    ) private pure returns(uint exp)
    {
        exp = 0;
        
        uint8 hitChance;
        uint8 critChance;
        
        (seed.index, hitChance) = seed.read(128);
        (seed.index, critChance) = seed.read(128);

        bool hit = hitChance < target.hitChance(attacker);
        bool crit = critChance < target.critChance(attacker);
        
        if (hit) 
            target.takenDamage += target.applyDamage(attacker.attack, crit);
        
        if (!target.alive()) 
            exp += target.health;
    }
    
    function _recountEnemies(Enemy[] memory enemies) private pure returns (Enemy[] memory newEnemies)
    {
        uint aliveCount = 0;
        
        for (uint i = 0; i < enemies.length; ++i)
        {
            if (enemies[i].stats.alive()) aliveCount += 1;
        }
        
        newEnemies = new Enemy[](aliveCount);
        
        uint index = 0;
        for (uint i = 0; i < enemies.length; ++i)
        {
            require(i < enemies.length, "Index is out of scope: enemies");
            
            if (enemies[i].stats.alive())
            {
                require(index < newEnemies.length, "Index is out of scope: new enemies");
                newEnemies[index] = enemies[i];
                index += 1;
            }
        }
    }
}