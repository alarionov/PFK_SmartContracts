// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

enum AuthRoles
{
    Nobody,
    GameContract,
    GameMaster
}

interface IAuthContract
{
    function validate() external view returns(bool result);
    function role(address _address) external view returns(AuthRoles _role);
}

contract AuthContract is IAuthContract
{
    mapping(address => AuthRoles) public ContractRoles;
    
    constructor()
    {}
    
    function validate() public view returns(bool result)
    {}
    
    function role(address _address) public view returns(AuthRoles _role)
    {
        _role = ContractRoles[_address];
    }
}