// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";
import "./abstract/SeedReader.sol";

contract FightLogic is BaseContract, FightContract
{
    using SeedReader for SeedReader.Seed;
    
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
    
    function conductFight(PlayerState memory state, bool[] memory buffs) external override(FightContract) onlyCore returns (Fight memory) 
    {
        Skeleton[] memory skeletons = _skeletonsByLevel(state.level, state.difficulty);
        Character memory character = _getCharacter(state.tokenId);
        
        require(skeletons.length > 0, "Skeletons have not been found");
        require(character.exists && character.alive, "Character should exist and be alive");
        
        SeedReader.Seed memory seed;
        seed.init([random(), random(), random(), random()]);
        
        Fight memory fight = _newFight(seed, state, character.stats, buffs);
        
        _applyBuffs(character, buffs);
        
        (fight.victory, fight.score) = _fight(seed, character, buffs, skeletons);
        
        if (fight.victory)
        {
            fight.newState = _increaseLevel(fight.oldState);
        }
        else if (character.stats.health == 0)
        {
            fight.score = fight.score >> 2;
            
            if (!buffs[uint(SpellType.Salvation)])
            {
                fight.died = true;
                fight.newState = PlayerState(0, 0, 0);
            }
        }
        
        return fight;
    }
    
    function _applyBuffs(Character memory character, bool[] memory buffs) private view
    {
        CharacterContract characterContract = CharacterContract(CHARACTER_CONTRACT_ADDRESS);
        character.stats = characterContract.applyBuffs(character.stats, buffs);
    }
    
    function _fight(SeedReader.Seed memory seed, Character memory character, bool[] memory buffs, Skeleton[] memory skeletons) private view returns (bool victory, uint score)
    {
        score = 0;
        
        bool[] memory skeletonBuffs = new bool[](buffs.length);
        
        for (uint step = 0; step < MAX_FIGHT_ACTIONS; ++step)
        {
            uint8 index = seed.read(uint8(skeletons.length));
            
            require(index < skeletons.length, "Invalid target selected");
            
            Skeleton memory target = skeletons[index];
            
            require(target.stats.health > 0, "Target should be alive");
            
            score += _processAttack(seed, character.stats, buffs, target.stats, skeletonBuffs);
            
            skeletons = _recountSkeletons(skeletons);
            
            for (uint i = 0; i < skeletons.length; ++i)
            {
                _processAttack(seed, skeletons[i].stats, skeletonBuffs, character.stats, buffs);
                
                if (character.stats.health == 0) return (false, 0);
            }
            
            skeletons = _recountSkeletons(skeletons);
            
            if (skeletons.length == 0) return (true, score);
        }

        victory = false;
    }
    
    function _processAttack(
        SeedReader.Seed memory seed, 
        BaseStats memory attacker, 
        bool[] memory attackerBuffs, 
        BaseStats memory target,
        bool[] memory targetBuffs
    ) private pure returns (uint score)
    {
        score = 0;
        
        uint hit;
        uint crit;
        
        hit = seed.read(2);
        crit = seed.read(2);
        
        if (attackerBuffs[uint(SpellType.CriticalStrike)])
        {
            crit = 1;
        }
        
        if (hit > 0)
        {
            uint damage = attacker.attack;
            
            if  (crit == 0)
            {
                if (damage < target.armour)
                { 
                    damage = 0;
                }
                else
                {
                    damage -= target.armour;
                }
            }
            
            if (damage > 0)
            {
                if (target.health < damage)
                {
                    score += target.health;
                    target.health = 0;
                }
                else
                {
                    score += damage;
                    target.health -= damage;
                }
                
                if (crit > 0 && attackerBuffs[uint(SpellType.Vampirism)])
                {
                    attacker.health += 1;
                }
                
                if (targetBuffs[uint(SpellType.Reflect)])
                {
                    if (attacker.health > 0)
                    {
                        score += 1;
                        attacker.health -= 1;
                    }
                }
            }
        }
    }
    
    function _recountSkeletons(Skeleton[] memory skeletons) private pure returns (Skeleton[] memory newSkeletons)
    {
        uint aliveCount = 0;
        
        for (uint i = 0; i < skeletons.length; ++i)
        {
            if (skeletons[i].stats.health > 0) aliveCount += 1;
        }
        
        newSkeletons = new Skeleton[](aliveCount);
        
        uint index = 0;
        for (uint i = 0; i < skeletons.length; ++i)
        {
            require(i < skeletons.length, "Index is out of scope: skeletons");
            
            if (skeletons[i].stats.health > 0)
            {
                require(index < newSkeletons.length, "Index is out of scope: new skeletons");
                newSkeletons[index] = skeletons[i];
                index += 1;
            }
        }
    }
    
    function _getCharacter(uint tokenId) private returns (Character memory character)
    {
        CharacterContract characterContract = CharacterContract(CHARACTER_CONTRACT_ADDRESS);
        character = characterContract.getCharacter(tokenId);
    }
    
    function _skeletonsByLevel(uint level, uint difficulty) private view returns (Skeleton[] memory skeletons)
    {
       MapContract mapContract = MapContract(MAP_CONTRACT_ADDRESS);
       skeletons = mapContract.getSkeletons(level, difficulty);
    }
    
    function _increaseLevel(PlayerState memory oldState) private view returns (PlayerState memory newState)
    {
        MapContract mapContract = MapContract(MAP_CONTRACT_ADDRESS);
        
        newState.tokenId = oldState.tokenId;
        (newState.level, newState.difficulty) = mapContract.getNextLevel(oldState.level, oldState.difficulty);
    }
    
    function _newFight(SeedReader.Seed memory seed, PlayerState memory state, BaseStats memory stats, bool[] memory buffs) private view returns (Fight memory)
    {
        CoreContract coreContract = CoreContract(CORE_CONTRACT_ADDRESS);
        uint season = coreContract.getCurrentSeason();
        
        return 
            Fight({
                id: 0,  // will be overriden by token contract 
                season: season,
                seed: seed.raw,
                score: 0,
                stats: BaseStats({
                    attack: stats.attack,
                    health: stats.health,
                    armour: stats.armour
                }),
                oldState: PlayerState(
                    state.tokenId,
                    state.level,
                    state.difficulty),
                newState: PlayerState(
                    state.tokenId,
                    state.level,
                    state.difficulty),
                buffs: buffs,
                victory: false,
                died: false
            });
    }
}