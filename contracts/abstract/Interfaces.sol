// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./Structures.sol";

interface IRandomContract
{
     function random() external returns(uint seed);
}

interface IGameManagerContract
{
    function registerCharacter(address contractaddress, uint tokenId) external;
    function fight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) external;
}

interface ICharacterContract
{
    function getCharacter(address contractaddress, uint tokenId) external returns (Character memory character);
    function addExp(address contractaddress, uint tokenId, uint exp) external;
}

interface IFightContract
{
    function conductFight(Character memory player, Enemy[] memory enemies) external returns (Fight memory); 
}

interface IMapContract
{
    function hasAccess(Character memory character, uint index) external view returns(bool);
    function getEnemies(uint index) external view returns (Enemy[] memory enemies);
}