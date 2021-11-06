// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Structures.sol";
import "../libraries/ComputedStats.sol";

interface IRandomContract
{
     function random() external returns(uint seed);
}

interface IGameManagerContract
{
    function conductFight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) external;
}

interface ICharacterContract
{
    function getCharacter(address contractaddress, uint tokenId) external returns (Character memory character);
    function addExp(address contractaddress, uint tokenId, uint exp) external;
}

interface IFightContract
{
    function conductFight(Character memory character, Enemy[] memory enemies) external returns (Fight memory); 
}

interface IMapContract
{
    function getProgress(Character memory character) external view returns(uint);
    function hasAccess(Character memory character, uint index) external view returns(bool);
    function getEnemies(uint index) external view returns (Enemy[] memory enemies);
    function update(Character memory character, uint index, bool victory) external;
}

interface IEquipmentContract
{
    function getInventory(Equipment memory equipment) external view returns(ComputedStats.Stats memory bonusStats);
    function getBonusStats(uint tokenId) external view returns(ComputedStats.Stats memory stats);
}