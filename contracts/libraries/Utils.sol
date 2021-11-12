// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../abstract/Structures.sol";

library Utils 
{
    function getHash(Character memory character) public pure returns (uint hash)
    {
        hash = uint(keccak256(abi.encodePacked(character.contractAddress, character.tokenId)));
    }
}