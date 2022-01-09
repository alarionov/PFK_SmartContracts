// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import { IExternalCharacterContract } from "./001_AuthContract.sol";

contract PurrOwnership is IExternalCharacterContract, Ownable
{
    mapping(uint => address) private _owners;
    
    address public Authority;

    constructor()
    {
    }

    function setAuthority(address newAddress) public onlyOwner
    {
        Authority = newAddress;
    }
    
    function ownerOf(uint token) public view returns(address owner)
    {
        owner = _owners[token];
    }

    function setOwner(address owner, uint token) public onlyOwner
    {
        _owners[token] = owner; 
    }

    function verify(address owner, uint token, bytes memory signature) public
    {
        bytes32 messageHash = getMessageHash(owner, token);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        bool verified = recoverSigner(ethSignedMessageHash, signature) == Authority;

        require(verified, "Unauthorized signer");

        _owners[token] = owner;
    }

    function getMessageHash(address owner, uint token) public pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked(owner, token));
    }
    
    function getEthSignedMessageHash(bytes32 messageHash) public pure returns (bytes32 signedMessage)
    {
        signedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
        
    function recoverSigner(bytes32 ethSignedMessageHash, bytes memory signature) public pure returns (address signer)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);

        signer = ecrecover(ethSignedMessageHash, v, r, s);
    }
    
    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
} 