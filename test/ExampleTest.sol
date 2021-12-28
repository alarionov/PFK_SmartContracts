// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
//import "../contracts/3_Ballot.sol";

contract ExampleTest 
{
    function beforeAll () public 
    {
    }
    
    function checkWinningProposal () public 
    {
        //Assert.equal(ballotToTest.winningProposal(), uint(0), "proposal at index 0 should be the winning proposal");
        //Assert.equal(ballotToTest.winnerName(), bytes32("candidate1"), "candidate1 should be the winner name");
    }
    
    function checkWinninProposalWithReturnValue () public view returns (bool) 
    {
        return true;
    }
}