// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

import {SeedReader} from "./libraries/SeedReader.sol";
import {ComputedStats} from "./libraries/ComputedStats.sol";

contract FightContract is BaseContract, IFightContract
{
    using SeedReader for SeedReader.Seed;
    using ComputedStats for ComputedStats.Stats;
    
    uint8 private MAX_FIGHT_ACTIONS = 10;

    address public MAP_CONTRACT_ADDRESS;
    
    constructor () BaseContract()
    {
        FIGHT_CONTRACT_ADDRESS = address(this);
    }
    
    function setMapContractAddress(address newAddress) public onlyGM
    {
        MAP_CONTRACT_ADDRESS = newAddress;
    } 
    
    function conductFight(Character memory character, Enemy[] memory enemies) external override(IFightContract) onlyGame returns (Fight memory fight) 
    {
        character.stats.init();
        
        SeedReader.Seed memory seed;
        seed.init([random(), random(), random(), random()]);
        
        fight = Fight({
            id: 0,
            seed: seed.raw,
            stats: character.stats,
            victory: false,
            exp: 0
        });
        
        (fight.victory, fight.exp) = _fight(seed, character, enemies);
        
        if (character.stats.getHealth() == 0)
        {
            fight.exp = fight.exp >> 2;
        }
        
        return fight;
    }

    
    function _fight(SeedReader.Seed memory seed, Character memory character, Enemy[] memory enemies) private view returns (bool victory, uint exp)
    {
        exp = 0;
        
        for (uint step = 0; step < MAX_FIGHT_ACTIONS; ++step)
        {
            uint8 index = seed.read(uint8(enemies.length));
            
            require(index < enemies.length, "Invalid target selected");
            
            Enemy memory target = enemies[index];
            
            require(target.stats.alive(), "Target should be alive");
            
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
    ) private pure returns (uint exp)
    {
        exp = 0;
        
        bool hit;
        bool crit;
        
        hit = seed.read(2) > 0;
        crit = seed.read(2) > 0;
        
        if (hit) target.applyDamage(attacker.attack, crit);
        if (!target.alive()) exp += target.health;
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