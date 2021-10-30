// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

contract GameManager is BaseContract, IGameManagerContract
{
    using EnumerableSet for EnumerableSet.UintSet;
    
    mapping(address => bool) private _approvedCharacterContracts;
    
    modifier auth(address player, address contractAddress, uint tokenId)
    {
        require(_approvedCharacterContracts[contractAddress], "This contract is not supported");
        require(IERC721(contractAddress).ownerOf(tokenId) == player, "Player should own the character");
        
        _;
    }
    
    constructor() BaseContract()
    {
        GAME_MANAGER_CONTRACT_ADDRESS = address(this);
    }
    
    /* battle */
    function conductFight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) 
        external
        override(IGameManagerContract)
        auth(msg.sender, characterContractAddress, characterId)
    {
        ICharacterContract characterContract = ICharacterContract(CHARACTER_CONTRACT_ADDRESS);
        IFightContract fightContract = IFightContract(FIGHT_CONTRACT_ADDRESS);
        IMapContract mapContract = IMapContract(mapContractAddress);
    
        Character memory character = characterContract.getCharacter(characterContractAddress, characterId);

        require(mapContract.hasAccess(character, index));
    
        Enemy[] memory enemies = mapContract.getEnemies(index);
    
        Fight memory fight = fightContract.conductFight(character, enemies);
    
        mapContract.update(character, index, fight.victory);
        characterContract.addExp(characterContractAddress, characterId, fight.exp);
    }
}