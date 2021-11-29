// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {IExternalCharacterContract} from "./001_AuthContract.sol";

contract PurrOwnership is IExternalCharacterContract
{
    mapping(uint => address) private _owners;
    
    constructor()
    {
    }
    
    function ownerOf(uint tokenId) public view returns(address owner)
    {
        owner = _owners[tokenId];
    }
    
    function setOwner(address owner, uint tokenId) public
    {
        _owners[tokenId] = owner;
    }
    
    function getMessageHash(address owner, uint tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner, tokenId));
    }
    
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32 signedMessage)
    {
        signedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    
    function verify(address _signer, address owner, uint tokenId, bytes memory signature) public pure returns (bool verified) 
    {
        bytes32 messageHash = getMessageHash(owner, tokenId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        verified = recoverSigner(ethSignedMessageHash, signature) == _signer;
    }
    
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address signer)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        signer = ecrecover(_ethSignedMessageHash, v, r, s);
    }
    
    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }
} 