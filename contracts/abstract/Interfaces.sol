// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Structures.sol";

interface IRandomContract
{
     function random() external returns(uint seed);
}

interface IGMContract
{
}

interface ICharacterContract
{
    function getCharacter(address contractaddress, uint _id) external returns (Character memory character);
    function addExp(address player, address contractaddress, uint tokenId, uint exp) external;
}

interface IFightContract
{
    //function conductFight(PlayerState memory state, bool[] memory buffs) external returns (Fight memory); 
}

interface IMapContract
{
    function getEnemies(uint index) external view returns (Enemy[] memory enemies);
}