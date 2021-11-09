// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../abstract/Structures.sol";

library Experience 
{
    function tnl() public pure returns(uint8[151] memory _tnl)
    {
        _tnl = [
            6, 9, 9, 12, 12, 15, 15, 18, 18, 18, 21, 21, 21, 21, 24, 24, 24, 24, 
            27, 27, 27, 27, 30, 30, 30, 30, 30, 33, 33, 33, 33, 33, 33, 
            36, 36, 36, 36, 36, 36, 39, 39, 39, 39, 39, 39, 
            42, 42, 42, 42, 42, 42, 42, 45, 45, 45, 45, 45, 45, 45, 45, 
            48, 48, 48, 48, 48, 48, 48, 48, 51, 51, 51, 51, 51, 51, 51, 51, 
            54, 54, 54, 54, 54, 54, 54, 54, 54, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 
            60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 
            66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 
            72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 80 ];
    }

    function addExp(Character memory character, uint exp) public pure 
    {
        if (exp == 0) return;
        
        character.exp += exp;
        
        while (character.exp >= toNextLevel(character))
        {
            character.exp -= toNextLevel(character);
            character.level += 1;
            character.upgrades += 1;
        }
    }
    
    function toNextLevel(Character memory character) public pure returns(uint amount)
    {
        uint8[151] memory _tnl = tnl();
        
        if (character.level < _tnl.length)
        { 
            amount = _tnl[character.level - 1];
        }
        else
        {
            amount = _tnl[_tnl.length - 1]  + 10 * (character.level - _tnl.length);
        }
    }
}