// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Interfaces.sol";
import "./Permissions.sol";

contract BaseContract is Permissions
{
    address public RANDOM_CONTRACT_ADDRESS;
    address public VAULT = address(0x0);
   
    constructor() Permissions()
    {
        VAULT = msg.sender;
    }
    
    function setRandomContractAddress(address newAddress) public onlyGM
    {
        RANDOM_CONTRACT_ADDRESS = newAddress;
    }
    
    function setVaultAddress(address _address) public onlyGM
    {
        VAULT = _address;
    } 
    
    function withdraw() public onlyGM
    {
        payable(VAULT).transfer(address(this).balance);
    }
    
    function random() internal returns (uint seed)
    {
        IRandomContract randomContract = IRandomContract(RANDOM_CONTRACT_ADDRESS);
        seed = randomContract.random();
    }
}