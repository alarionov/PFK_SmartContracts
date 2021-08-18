// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./Interfaces.sol";

contract Permissions
{
    address public GAME_MASTER = address(0x0);
    
    
    address public CORE_CONTRACT_ADDRESS = address(0x0);
    address public CHARACTER_CONTRACT_ADDRESS = address(0x0);
    address public FIGHT_CONTRACT_ADDRESS = address(0x0);
    
    modifier onlyGM ()
    {
        require(msg.sender == GAME_MASTER, "Can be called only by GM");
        _;
    }
    
    modifier onlyFC
    {
        require(msg.sender == FIGHT_CONTRACT_ADDRESS, "Can be called only by the Fight Contract");
        _;
    }
    
    modifier onlyCore()
    {
        require(msg.sender ==  CORE_CONTRACT_ADDRESS, "Can be called only from the Core Contract");
        _;
    }
    
    modifier onlyWB()
    {
        require(
            msg.sender == GAME_MASTER ||
            msg.sender == CORE_CONTRACT_ADDRESS ||
            msg.sender == CHARACTER_CONTRACT_ADDRESS ||
            msg.sender == FIGHT_CONTRACT_ADDRESS,
            "Only WB contracts can call this method");
        _;
    }
    
    constructor()
    {
        GAME_MASTER = msg.sender;
    }
    
     function setGameMasterAddress(address newGM) public onlyGM
    {
        GAME_MASTER = newGM;
    } 
    
    function setCoreContractAddress(address _address) public onlyGM
    {
        CORE_CONTRACT_ADDRESS = _address;
    } 
    
    function setFightContractAddress(address _address) public onlyGM
    {
        FIGHT_CONTRACT_ADDRESS = _address;
    } 
    
    function setCharacterContractAddress(address _address) public onlyGM
    {
        CHARACTER_CONTRACT_ADDRESS = _address;
    } 
    
}