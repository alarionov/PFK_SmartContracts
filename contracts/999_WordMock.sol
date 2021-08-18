// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

contract WordMock  
{
    address private owner = address(0x0);
    
    string[] private words;
    
    constructor()
    {
        owner = msg.sender;
        
        words.push("aza");
        words.push("baza");
        words.push("kaza");
        words.push("zazaza");
        words.push("kek-");
         
    }
    
    function setOwner(address newOwner) public 
    {
        owner = newOwner;
    }
    
    function ownerOf(uint tokenId) public view returns (address wordOwner)
    {
        wordOwner = owner;
    }
    
    function getWord(uint tokenId) public view returns (string memory word) 
    {
        return words[tokenId];
    }
}