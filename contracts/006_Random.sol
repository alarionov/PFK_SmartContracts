// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./openzeppelin-contracts/contracts/utils/Counters.sol";

import "./abstract/Interfaces.sol";
import "./abstract/Permissions.sol";

contract Random is Permissions, RandomContract
{
    using Counters for Counters.Counter;
    
    Counters.Counter internal _randomNonce;
    
    constructor() Permissions() 
    {
        
    }
    
    function random() public onlyWB override(RandomContract) returns(uint seed)
    {
        _randomNonce.increment();
        
        seed = uint(keccak256(abi.encodePacked(block.number, block.difficulty, block.timestamp, _randomNonce.current())));
    }
}