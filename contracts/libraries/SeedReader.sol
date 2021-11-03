// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

library SeedReader 
{
    struct Seed
    {
        uint8 index;
        bytes raw;
        uint8[] rolls;
    }
    
    function init(Seed memory seed, uint256[4] memory parts) internal pure
    {
        bytes memory raw = abi.encodePacked(parts);
        uint8[] memory rolls = new uint8[](raw.length);
        
        for (uint i = rolls.length; i > 0; --i)
        {
            rolls[rolls.length - i] = uint8(raw[i-1]);
        }
        
        seed.index = 0;
        seed.raw = raw;
        seed.rolls = rolls;
    }
    
    function read(Seed memory seed, uint8 d) internal pure returns (uint8 roll)
    {
        require(seed.index < seed.rolls.length, "Seed doesn't have any more rolls");
        
        roll = seed.rolls[seed.index] % d;
        
        seed.index += 1;
    }
}