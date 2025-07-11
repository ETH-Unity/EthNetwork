// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DocumentSigner {
    // Emitted when someone signs a document
    event DocumentSigned(address indexed signer, bytes32 indexed docHash, uint256 timestamp);

    // Stores the timestamp of when an address signed a specific document hash
    // signatures[docHash][signer] = timestamp
    mapping(bytes32 => mapping(address => uint256)) public signatures;

    // Sign a document by providing its hash
    function signDocument(bytes32 docHash) public {
        require(signatures[docHash][msg.sender] == 0, "Already signed");
        signatures[docHash][msg.sender] = block.timestamp;
        emit DocumentSigned(msg.sender, docHash, block.timestamp);
    }

    // Check if an address has signed a specific document
    function hasSigned(bytes32 docHash, address signer) public view returns (bool) {
        return signatures[docHash][signer] != 0;
    }
}
