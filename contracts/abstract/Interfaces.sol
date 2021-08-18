// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Structures.sol";

interface Word
{
    function getWord(uint id) external view returns (string memory word);
    function ownerOf(uint tokenId) external view returns (address owner);
}

interface RandomContract
{
     function random() external returns(uint seed);
}

interface CoreContract
{
    function getCurrentSeason() external view returns (uint season);
}

interface CharacterContract
{
    function getCharacter(uint _id) external returns (Character memory character);
    function createCharacter(address player, uint character) external returns (uint newTokenId);
    function killCharacter(address player, uint tokenId) external;
    function addExp(address player, uint tokenId, uint exp) external;
    function applyBuffs(BaseStats memory stats, bool[] memory buffs) external pure returns(BaseStats memory);
}

interface FightContract
{
    function conductFight(PlayerState memory state, bool[] memory buffs) external returns (Fight memory); 
}

interface FightTokenContract
{
    function mint(address player, Fight memory fight) external;
    function getFight(uint tokenId) external view returns (Fight memory);
}

interface MapContract
{
    function getSkeletons(uint level, uint difficulty) external view returns (Skeleton[] memory skeletons);
    function getNextLevel(uint level, uint difficulty) external view returns (uint nextLevel, uint nextDifficulty);
}