// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../libraries/ComputedStats.sol";

struct Enemy
{
    uint id;
    bool present;
    ComputedStats.Stats stats;
}