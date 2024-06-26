// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./abstract/MapContract.sol";

import "./libraries/Utils.sol";

contract Act1Milestones is MapContract
{
    using ComputedStats for ComputedStats.Stats;

    event Milestone(uint index);

    mapping(uint => uint) private _progressions;
    
    constructor(address authContractAddress) MapContract(authContractAddress, 6)
    {}
    
    function getProgress(Character memory character) 
        public 
        view 
        override(IMapContract)
        returns(uint)
    {
        return _getProgress(character);
    }
    
    function _getProgress(Character memory character) private view returns(uint)
    {
        uint hash = Utils.getHash(character);
        return _progressions[hash];
    }

    function resetProgress(Character memory character) public override(MapContract)
    {
        _authContract.validate(msg.sender, character.contractAddress, character.tokenId);
        
        uint hash = Utils.getHash(character);
        _progressions[hash] = 0;
    }

    function hasAccess(Character memory character, uint index) public view override(IMapContract) returns(bool)
    {
        return _getProgress(character) == index;
    }
    
    function update(Character memory character, uint index, bool victory) public onlyGame(msg.sender) override(IMapContract)
    {
        if (victory && index <= MAX_LEVEL_INDEX)
        {
            uint hash = Utils.getHash(character);
            _progressions[hash] = index + 1;
            emit Milestone(_progressions[hash]);
        }
    }
    
    function getEnemies(uint levelIndex) 
        public 
        view 
        override(IMapContract)
        validIndex(levelIndex)
        returns (ComputedStats.Stats[] memory enemies)
    {
        // uint strength, uint dexterity, uint constitution, uint luck, uint armor
        
        if (levelIndex == 0)
        {
            enemies =  new ComputedStats.Stats[](1);
            
            enemies[0] = ComputedStats.newStats(1, 1, 1);
        }
        else if (levelIndex == 1)
        {
            enemies =  new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.newStats(1, 1, 1);
            enemies[1] = ComputedStats.newStats(1, 1, 1);
            enemies[2] = ComputedStats.newStats(1, 1, 1); 
        }
        else if (levelIndex == 2)
        {
            enemies =  new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.newStats(1, 1, 1);
            enemies[1] = ComputedStats.Stats(2, 1, 3, 0, 1, 0, 0, 0).init(); 
            enemies[2] = ComputedStats.newStats(1, 1, 1);
        }
        else if (levelIndex == 3)
        {
            enemies =  new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.Stats(5, 1, 5, 0, 1, 0, 0, 0).init();
            enemies[1] = ComputedStats.Stats(5, 1, 5, 0, 1, 0, 0, 0).init();
            enemies[2] = ComputedStats.Stats(5, 1, 5, 0, 1, 0, 0, 0).init();
        }
        else if (levelIndex == 4)
        {
            enemies =  new ComputedStats.Stats[](3);
            
            enemies[0] = ComputedStats.newStats(8, 1, 12);
            enemies[1] = ComputedStats.newStats(8, 1, 12);
            enemies[2] = ComputedStats.newStats(8, 1, 12); 
        }
        else if (levelIndex == 5)
        {
            enemies =  new ComputedStats.Stats[](2);
            
            enemies[0] = ComputedStats.Stats(18, 1, 12, 0, 2, 0, 0, 0).init();
            enemies[1] = ComputedStats.Stats(15, 1, 15, 0, 5, 0, 0, 0).init(); 
        }
        else if (levelIndex == 6)
        {
            enemies = new ComputedStats.Stats[](1);
            
            enemies[0] = ComputedStats.Stats(35, 1, 50, 0, 10, 0, 0, 0).init();
        }
    }
}