// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./openzeppelin-contracts/contracts/utils/Counters.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

contract WordBearer is BaseContract, CharacterContract, ERC721
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    event Born(Character newCharacter);
    event Died(uint characterId);
    event NewStats(BaseStats newStats, uint remainigUpgrades);
    event LevelUp(uint level, uint exp, uint tnl, uint upgradesGiven, uint upgradesTotal);
    
    mapping(uint => Character) private _characters;
    
    uint[] private _tnl = [6, 9, 9, 12, 12, 15, 15, 18, 18, 18, 21, 21, 21, 21, 24, 24, 24, 24, 27, 27, 27, 27, 30, 30, 30, 30, 30, 33, 33, 33, 33, 33, 33, 36, 36, 36, 36, 36, 36, 39, 39, 39, 39, 39, 39, 42, 42, 42, 42, 42, 42, 42, 45, 45, 45, 45, 45, 45, 45, 45, 48, 48, 48, 48, 48, 48, 48, 48, 51, 51, 51, 51, 51, 51, 51, 51, 54, 54, 54, 54, 54, 54, 54, 54, 54, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 69, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 80];
    
    modifier upgradable(address player, uint tokenId)
    {
        require(ownerOf(tokenId) == player, "Player should own the character");
        
        Character memory character = _characters[tokenId];
        require(character.upgrades > 0, "No upgrades available");
        
        _;
    }
    
    modifier ownedAndAlive(address player, uint tokenId)
    {
        require(ownerOf(tokenId) == player, "Player should own the character");
        
        Character storage character = _characters[tokenId];
        
        require(character.exists, "Character doesn't exist");
        require(character.alive, "Character is dead already");
        
        _;
    }
    
    constructor() BaseContract()  ERC721("Char", "CHAR")
    {
        CHARACTER_CONTRACT_ADDRESS = address(this);
    }
    
    function _beforeTokenTransfer(address from, address to, uint tokenId) internal view override(ERC721) 
    {
        // ignore if mint
        if (from == address(0x0)) return;
        
        Character memory character = _characters[tokenId];
        
        require(character.exists, "Character should exist");
        
        CoreContract coreContract = CoreContract(CORE_CONTRACT_ADDRESS);
        uint season = coreContract.getCurrentSeason();
        
        require(!character.alive || character.season < season, "Can't transfer alive character from the active season");    
    }
    
    
    function getCharacter(uint _tokenId) external view override(CharacterContract) returns (Character memory character)
    {
        character = _characters[_tokenId];
    }
    
    function toNextLevel(uint level) public view returns(uint)
    {
        require(level > 0, "Level should be greater than zero");
        
        if (level < _tnl.length)
        { 
            return _tnl[level - 1];
        }
        
        uint base_tnl = _tnl[_tnl.length - 1];
        
        return base_tnl + 10 * (level - _tnl.length);
    }
    
    function upgradeAttack(uint tokenId) external upgradable(msg.sender, tokenId)
    {
        Character storage character = _characters[tokenId];
        character.stats.attack += 1;
        character.upgrades -= 1;
        
        emit NewStats(character.stats, character.upgrades);
    }
    
    function upgradeHealth(uint tokenId) external upgradable(msg.sender, tokenId)
    {
        Character storage character = _characters[tokenId];
        character.stats.health += 3;
        character.upgrades -= 1;
        
        emit NewStats(character.stats, character.upgrades);
    }
    
    function upgradeArmour(uint tokenId) external upgradable(msg.sender, tokenId)
    {
        Character storage character = _characters[tokenId];
        character.stats.armour += 1;
        character.upgrades -= 1;
        
        emit NewStats(character.stats, character.upgrades);
    }
    
    function createCharacter(address player, uint character) external onlyCore override(CharacterContract) returns (uint newTokenId)
    {
        _tokenIds.increment();
        
        newTokenId = _tokenIds.current();
        
        CoreContract coreContract = CoreContract(CORE_CONTRACT_ADDRESS);
        uint season = coreContract.getCurrentSeason();
        
        _characters[newTokenId] = 
            Character({
                id: newTokenId,
                character: character,
                stats: BaseStats(1,3,0),
                alive: true,
                exists: true,
                season: season,
                level: 1,
                exp: 0,
                upgrades: 1
            }); 
            
        emit Born(_characters[newTokenId]);
        
        _mint(player, newTokenId);
    }
    
    function killCharacter(address player, uint tokenId) external onlyCore ownedAndAlive(player, tokenId) override(CharacterContract) 
    {
        emit Died(tokenId);
        
        _characters[tokenId].alive = false;    
    }
    
    function addExp(address player, uint tokenId, uint exp) external onlyCore ownedAndAlive(player, tokenId) override(CharacterContract)
    {
        require(exp >= 0, "Exp should be a positive number");
        
        Character storage character = _characters[tokenId];
        
        character.exp += exp;
        
        while (character.exp >= toNextLevel(character.level))
        {
            character.exp -= toNextLevel(character.level);
            character.level += 1;
            character.upgrades += 1;
            
            emit LevelUp(
                character.level, 
                character.exp,
                toNextLevel(character.level),
                1,
                character.upgrades);
        }
    }
    
    function applyBuffs(BaseStats memory stats, bool[] memory buffs) public pure override(CharacterContract) returns(BaseStats memory)
    {
        if (buffs[uint(SpellType.Enchant)])
        {
            stats.attack += 1;
        }
        
        if (buffs[uint(SpellType.FalseLife)])
        {
            stats.health += 3;
        }
        
        if (buffs[uint(SpellType.Shield)])
        {
            stats.armour += 1;
        }
        
        if (buffs[uint(SpellType.Bless)])
        {
            stats.attack += 1;
            stats.health += 3;
            stats.armour += 1;
        }
        
        return stats;
    }
}