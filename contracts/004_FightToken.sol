// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./openzeppelin-contracts/contracts/utils/Counters.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/Permissions.sol";

contract FightToken is FightTokenContract, Permissions, ERC721
{
    using Counters for Counters.Counter;
    
    event FightEvent(Fight fight);
    
    Counters.Counter private _tokenIds;

    mapping(uint => Fight) private _fights;
    
    constructor () Permissions() ERC721("Fight", "FIGHT")
    {}
    
    function mint(address player, Fight memory fight) public onlyCore override(FightTokenContract)
    {
        _tokenIds.increment();

        fight.id = _tokenIds.current();
        
        _fights[fight.id] = fight;
        
        emit FightEvent(fight);
        
        _mint(player, fight.id);
    }
    
    function getFight(uint tokenId) public view override(FightTokenContract) returns (Fight memory)
    {
        return _fights[tokenId];
    }
}