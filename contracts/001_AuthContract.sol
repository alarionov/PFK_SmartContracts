// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

enum AuthRoles
{
    Nobody,
    GameContract,
    CharacterContract,
    GameMaster
}

interface IAuthContract
{
    function setRole(address contractAddress, AuthRoles role) external;
    function validate(address player, address contractAddress, uint tokenId) external view;
    function role(address _address) external view returns(AuthRoles _role);
}

contract AuthContract is IAuthContract
{
    mapping(address => AuthRoles) public ContractRoles;
    
    constructor()
    {
        _setRole(msg.sender, AuthRoles.GameMaster);
    }
    
    function _setRole(address contractAddress, AuthRoles _role) private
    {
        ContractRoles[contractAddress] = _role;
    }
    
    function setRole(address contractAddress, AuthRoles _role) public
    {
        require(role(msg.sender) == AuthRoles.GameMaster, "Only Game Master can set character contracts");
        
        _setRole(contractAddress, _role);
    }
    
    function validate(address player, address contractAddress, uint tokenId) public view
    {
        require(role(contractAddress) == AuthRoles.CharacterContract, "This contract is not supported");
        //require(IERC721(contractAddress).ownerOf(tokenId) == player, "Player should own the character");
    }
    
    function role(address _address) public view returns(AuthRoles _role)
    {
        _role = ContractRoles[_address];
    }
    
    
    
    
}