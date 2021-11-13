// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import { AuthRoles, IAuthContract } from "../001_AuthContract.sol";

contract Permissions
{
    address public AUTH_CONTRACT_ADDRESS = address(0x0);
    
    IAuthContract private _authContract;
    
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
    
    constructor(address authContractAddress)
    {
        _setAuthContractAddress(authContractAddress);
    }
    
    function _setAuthContractAddress(address newAddress) private
    {
        AUTH_CONTRACT_ADDRESS = newAddress;
        _authContract = IAuthContract(AUTH_CONTRACT_ADDRESS);
    } 
    
    function setAuthContractAddress(address newAddress) private 
    {
        _setAuthContractAddress(newAddress);
    }
}