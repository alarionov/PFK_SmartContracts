// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import { IExternalCharacterContract } from "./001_AuthContract.sol";

contract PurrOwnership is IExternalCharacterContract, Ownable
{
    event OwnershipChange(address owner, uint token, uint timestamp);

    struct Ownership
    {
        address owner;
        uint timestamp;
    }

    mapping(uint => Ownership) private _owners;
    
    address public Authority;

    address public DefaultOwner = address(0x0);

    uint public SignatureTTL = 15 * 60; // 15 minutes
    uint public OwnershipTLL = 24 * 60 * 60; // 24 hours

    constructor()
    {
    }

    function setAuthority(address newAddress) public onlyOwner
    {
        Authority = newAddress;
    }

    function setTLL(uint signatureTLL, uint ownershipTLL) public onlyOwner
    {
        SignatureTTL = signatureTLL;
        OwnershipTLL = ownershipTLL;
    }
    
    function ownerOf(uint token) public view returns(address owner)
    {
        Ownership memory ownership = _owners[token];
        
        owner = 
            block.timestamp < ownership.timestamp + OwnershipTLL ? 
                ownership.owner : DefaultOwner;
    }

    function ownershipOf(uint token) public view returns(address owner, uint timestamp)
    {
        Ownership memory ownership = _owners[token];
        owner = ownership.owner;
        timestamp = ownership.timestamp; 
    }

    function setOwner(address owner, uint token) public onlyOwner
    {
         _setOwner(owner, token);
    }

    function _setOwner(address owner, uint token) private
    {
        _owners[token] = Ownership({owner: owner, timestamp: block.timestamp});

        emit OwnershipChange(owner, token, block.timestamp);
    }

    function verify(address owner, uint token, uint timestamp, bytes memory signature) public
    {
        require(block.timestamp < timestamp + SignatureTTL, "Signature expired");

        bytes32 messageHash = getMessageHash(owner, token, timestamp);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        bool verified = recoverSigner(ethSignedMessageHash, signature) == Authority;

        require(verified, "Unauthorized signer");

        _setOwner(owner, token);
    }

    function getMessageHash(address owner, uint token, uint timestamp) public pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked(owner, token, timestamp));
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