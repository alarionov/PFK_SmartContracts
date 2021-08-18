// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";

contract Map is MapContract
{
    Skeleton[3] private _skeletons; 
    Level[7] private _levels;
    
    constructor ()
    {
        _skeletons[0] = Skeleton(0, BaseStats(1, 1, 0));
        _skeletons[1] = Skeleton(1, BaseStats(2, 1, 0));
        _skeletons[2] = Skeleton(2, BaseStats(2, 3, 1));
        
        _levels[0] = Level([true,  false, false]);
        _levels[1] = Level([false, true,  false]);
        _levels[2] = Level([false, false, true]);
        _levels[3] = Level([true,  true,  false]);
        _levels[4] = Level([true,  false, true]);
        _levels[5] = Level([false, true,  true]);
        _levels[6] = Level([true,  true,  true]);
    }
    
    function getSkeletons(uint levelIndex, uint difficulty) public view override(MapContract) returns (Skeleton[] memory skeletons)
    {
        require(levelIndex < _levels.length, "Invalid level index");
        
        Level memory level = _levels[levelIndex];
        
        uint total = 0;
        
        for (uint i = 0; i < level.active_skeletons.length; ++i)
        {
            if (level.active_skeletons[i]) total += 1;
        }
        
        skeletons = new Skeleton[](total);
        
        uint index = 0;
        
        for (uint i = 0; i < level.active_skeletons.length; ++i)
        {
            if (level.active_skeletons[i])
            {
                Skeleton memory skeleton = _skeletons[i];
                BaseStats memory stats = skeleton.stats;
                
                require(stats.health > 0, "Skeleton should be alive");
                
                skeletons[index] = 
                    Skeleton(
                        skeleton.id, 
                        BaseStats(
                            stats.attack + difficulty, 
                            stats.health + difficulty, 
                            stats.armour + difficulty));
                        
                index += 1;
            }
        }
    }
    
    function getNextLevel(uint level, uint difficulty) public view override(MapContract) returns (uint nextLevel, uint nextDifficulty)
    {
        nextLevel = level + 1;
        
        if (nextLevel < _levels.length)
        {
            nextDifficulty = difficulty;
        }
        else
        {
            nextLevel = 0;
            nextDifficulty = difficulty + 1;
        }
    }
}