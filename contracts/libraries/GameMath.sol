// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

library GameMath
{
    function one() internal pure returns(uint)
    {
        return 1;
    }

    function modify(uint origin, uint value, int8 sign) internal pure returns (uint result)
    {
        result = (sign > 0 || origin > value) ? origin + value : 0;
    }
}