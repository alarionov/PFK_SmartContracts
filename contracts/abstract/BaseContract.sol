// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./Permissions.sol";

import { IRandomContract } from "../000_RandomContract.sol";

contract BaseContract is Permissions
{
    address public RANDOM_CONTRACT_ADDRESS;
    IRandomContract internal _randomContract;
   
    constructor(address authContractAddress) Permissions(authContractAddress)
    {
    }
    
    function setRandomContractAddress(address newAddress) public onlyGM(msg.sender)
    {
        RANDOM_CONTRACT_ADDRESS = newAddress;
        _randomContract = IRandomContract(RANDOM_CONTRACT_ADDRESS);
    }
    
    function random() internal returns (uint seed)
    {
        seed = _randomContract.random();
    }
}