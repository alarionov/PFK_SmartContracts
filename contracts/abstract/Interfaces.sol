// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./Structures.sol";
import "../libraries/ComputedStats.sol";

interface IRandomContract
{
     function random() external returns(uint seed);
}

interface ICharacterContract
{
    function getCharacter(address contractaddress, uint tokenId) external returns (Character memory character);
    function save(Character memory character) external;
}

interface IFightContract
{
    function conductFight(Character memory character, Enemy[] memory enemies) external returns (Fight memory); 
}

interface IFightManagerContract
{
    function conductFight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) external;
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
    function mintByGame(address player, uint itemType) external returns(uint tokenId);
    function forcedTransfer(address from, address to, uint itemId) external;
}

interface IEquipmentManagerContract
{
    function equip(Character memory character, ItemSlot slot, uint itemId) external;
    function uneqip(Character memory character, ItemSlot slot) external;
}