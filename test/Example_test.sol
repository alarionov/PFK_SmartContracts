// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.

//import "../contracts/3_Ballot.sol";
import "../contracts/002_CharacterContract.sol";

contract ExampleTest 
{
    CharacterContract characterContract;    

    function beforeAll () public 
    {
    }
    
    function checkWinningProposal () public 
    {
        Character character = characterContract.getCharacter("0x0", 1);
        //Assert.equal(1, 1, "proposal at index 0 should be the winning proposal");
        //Assert.equal(ballotToTest.winnerName(), bytes32("candidate1"), "candidate1 should be the winner name");
    }
}