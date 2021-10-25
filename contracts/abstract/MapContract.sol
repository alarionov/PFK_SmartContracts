// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./Interfaces.sol";

abstract contract MapContract is IMapContract
{
    uint public MAX_LEVEL_INDEX;
    
    modifier validIndex(uint index)
    {
        require(index <= MAX_LEVEL_INDEX, "Invalid level index");
        
        _;
    }
    
    constructor(uint maxLeveIndex)
    {
        MAX_LEVEL_INDEX = maxLeveIndex;
    }
}