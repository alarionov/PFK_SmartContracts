// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

enum AuthRoles
{
    Nobody,
    ExternalCharacterContract,
    GameContract,
    GameMaster
}

interface IAuthContract
{
    function setRole(address participant, AuthRoles role) external;
    function getRole(address participant) external view returns(AuthRoles role);
    function validate(address player, address contractAddress, uint tokenId) external view;
}

interface IExternalCharacterContract
{
    function ownerOf(uint tokenId) external view returns(address owner); 
}

contract AuthContract is IAuthContract
{
    mapping(address => AuthRoles) public ContractRoles;
    
    constructor()
    {
        _setRole(msg.sender, AuthRoles.GameMaster);
    }
    
    function _setRole(address participant, AuthRoles role) private
    {
        ContractRoles[participant] = role;
    }
    
    function setRole(address participant, AuthRoles role) public
    {
        require(getRole(msg.sender) == AuthRoles.GameMaster, "Only Game Master can set character contracts");
        
        _setRole(participant, role);
    }
    
    function getRole(address participant) public view returns(AuthRoles role)
    {
        role = ContractRoles[participant];
    }

    function validate(address player, address contractAddress, uint tokenId) public view
    {
        require(getRole(contractAddress) == AuthRoles.ExternalCharacterContract, "This contract is not supported");
        require(IExternalCharacterContract(contractAddress).ownerOf(tokenId) == player, "Player should own the character");
    }
}