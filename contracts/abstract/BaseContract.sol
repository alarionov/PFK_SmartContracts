// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./Permissions.sol";

import { IRandomContract } from "../000_RandomContract.sol";

contract BaseContract is Permissions
{
    address public RANDOM_CONTRACT_ADDRESS;
   
    constructor(address authContractAddress) Permissions(authContractAddress)
    {
    }
    
    function setRandomContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        RANDOM_CONTRACT_ADDRESS = newAddress;
    }
    
    function random() internal returns (uint seed)
    {
        IRandomContract randomContract = IRandomContract(RANDOM_CONTRACT_ADDRESS);
        seed = randomContract.random();
    }
}