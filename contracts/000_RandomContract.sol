// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Counters.sol";

import "./abstract/Permissions.sol";

interface IRandomContract
{
     function random() external returns(uint seed);
}

contract RandomContract is Permissions, IRandomContract
{
    using Counters for Counters.Counter;
    
    Counters.Counter internal _randomNonce;
    
    constructor(address authContractAddress) Permissions(authContractAddress) 
    {}
    
    function random() public onlyGame(msg.sender) override(IRandomContract) returns(uint seed)
    {
        _randomNonce.increment();
        
        seed = uint(keccak256(abi.encodePacked(block.number, block.difficulty, block.timestamp, _randomNonce.current())));
    }
}