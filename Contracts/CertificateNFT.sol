// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC721/ERC721.sol";

contract CertificateNFT is ERC721 {
    uint256 public nextTokenId;
    address public admin;

    mapping(uint256 => string) private _certificateData;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        admin = msg.sender;
    }

    function mintWithData(address to, string memory data) external {
        require(msg.sender == admin, "Only admin can mint");

        uint256 tokenId = nextTokenId;
        _safeMint(to, tokenId);
        _certificateData[tokenId] = data;

        nextTokenId++;
    }

    function getCertificateData(uint256 tokenId) external view returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return _certificateData[tokenId];
    }
}
