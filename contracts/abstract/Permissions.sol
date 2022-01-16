// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import { AuthRoles, IAuthContract } from "../001_AuthContract.sol";

contract Permissions
{
    address public AUTH_CONTRACT_ADDRESS = address(0x0);
    
    IAuthContract internal _authContract;
    
    modifier onlyGame(address _address)
    {
        AuthRoles role = _authContract.role(_address);
        
        require(
            role >= AuthRoles.GameContract,
            "Only game contracts can call this method");
        _;
    }
    
    modifier onlyGM(address _address)
    {
        AuthRoles role = _authContract.role(_address);
        
        require(
            role == AuthRoles.GameMaster,
            "Only Game Master can call this method");
        _;
    }

    modifier auth(address player, address contractAddress, uint tokenId)
    {
        _authContract.validate(player, contractAddress, tokenId);
        _;
    }
    
    constructor(address authContractAddress)
    {
        _setAuthContractAddress(authContractAddress);
    }
    
    function _setAuthContractAddress(address newAddress) private
    {
        AUTH_CONTRACT_ADDRESS = newAddress;
        _authContract = IAuthContract(AUTH_CONTRACT_ADDRESS);
    } 
    
    function setAuthContractAddress(address newAddress) public onlyGM(msg.sender) 
    {
        _setAuthContractAddress(newAddress);
    }
}