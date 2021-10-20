// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

contract GameManager is BaseContract, IGMContract
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
    
    /* Character creation and modification */
    function registerCharacter(address tokenContractAddress, uint tokenId) external auth(msg.sender, tokenContractAddress, tokenId)
    {
        address player = msg.sender;
    }
    
    /* battle */
    function fight(address mapContractAddress, uint index, address characterContractAddress, uint characterId) 
        external
        override(IGMContract)
        auth(msg.sender, characterContractAddress, characterId)
    {
        address player = msg.sender;
        
        ICharacterContract characterContract = ICharacterContract(CHARACTER_CONTRACT_ADDRESS);
        IFightContract fightContract = IFightContract(FIGHT_CONTRACT_ADDRESS);
        IMapContract mapContract = IMapContract(mapContractAddress);
    
        Character memory character = characterContract.getCharacter(characterContractAddress, characterId);

        require(mapContract.hasAccess(character, index));
    
        //characterContract.addExp(player, fight.oldState.tokenId, fight.score);
    }
}