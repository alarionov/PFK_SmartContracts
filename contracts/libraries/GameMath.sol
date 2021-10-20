// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

library GameMath
{
    function modify(uint origin, uint value, int8 sign) internal pure returns (uint result)
    {
        result = (sign > 0 || origin > value) ? origin + value : 0;
    }
}