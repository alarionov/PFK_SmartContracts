// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";

import "./abstract/Interfaces.sol";
import "./abstract/Permissions.sol";

contract RandomContract is Permissions, IRandomContract
{
    using Counters for Counters.Counter;
    
    Counters.Counter internal _randomNonce;
    
    constructor() Permissions() 
    {}
    
    function random() public onlyGame override(IRandomContract) returns(uint seed)
    {
        _randomNonce.increment();
        
        seed = uint(keccak256(abi.encodePacked(block.number, block.difficulty, block.timestamp, _randomNonce.current())));
    }
}