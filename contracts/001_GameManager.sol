// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./abstract/Structures.sol";
import "./abstract/Interfaces.sol";
import "./abstract/BaseContract.sol";

contract GameManager is BaseContract, IGMContract
{
    using EnumerableSet for EnumerableSet.UintSet;
    
    constructor() BaseContract()
    {
        GAME_MANAGER_CONTRACT_ADDRESS = address(this);
    }
    
    /* Character creation and modification */
    function registerCharacter(address tokenContractAddress) external
    {
        address player = msg.sender;
    }
    
    /* battle */
    function fight(address mapContractAddress) external 
    {
        address player = msg.sender;
        
        ICharacterContract characterContract = ICharacterContract(CHARACTER_CONTRACT_ADDRESS);
        IFightContract fightContract = IFightContract(FIGHT_CONTRACT_ADDRESS);
        IMapContract mapContract = IMapContract(mapContractAddress);
    
        //characterContract.addExp(player, fight.oldState.tokenId, fight.score);
    }
}