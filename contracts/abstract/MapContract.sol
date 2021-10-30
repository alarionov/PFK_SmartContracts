// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./BaseContract.sol";
import {IMapContract} from "./Interfaces.sol";
import {Enemy} from "./Structures.sol";

abstract contract MapContract is IMapContract, BaseContract
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