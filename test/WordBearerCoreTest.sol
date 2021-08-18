// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.

import "../contracts/WordBearerCore.sol";
import "../contracts/WordBearerCharacter.sol";
import "../contracts/WordBearerFight.sol";

contract WordBearerCoreTest 
{
    function beforeAll () public 
    {
 
    }
    
    function checkWinningProposal () public 
    {
        uint actualValue = 1;
        uint expectedValue = 1;
        
        Assert.equal(actualValue, expectedValue, "error message");
    }
    
    function checkWinninProposalWithReturnValue () public view returns (bool) 
    {
        return 0 == 0;
    }
}
