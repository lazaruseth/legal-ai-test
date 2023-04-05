pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IVerifier {
    function verify(bytes32 documentHash, bytes memory signature) external view returns (bool);
}

contract MyNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping (uint256 => bytes32) private _documentHashes;

    IVerifier private _verifier;

    constructor(address verifierAddress) ERC721("MyNFT", "NFT") {
        _verifier = IVerifier(verifierAddress);
    }

    function mint(address recipient, bytes32 documentHash) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setDocumentHash(newItemId, documentHash);
        return newItemId;
    }

    function transferFrom(address from, address to, uint256 tokenId, bytes memory signature) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(_verifier.verify(_documentHashes[tokenId], signature), "Invalid signature");
        _transfer(from, to, tokenId);
    }

    function setVerifier(address verifierAddress) public onlyOwner {
        _verifier = IVerifier(verifierAddress);
    }

    function setDocumentHash(uint256 tokenId, bytes32 documentHash) public onlyOwner {
        require(_exists(tokenId), "ERC721Metadata: document hash set of nonexistent token");
        _setDocumentHash(tokenId, documentHash);
    }

    function getDocumentHash(uint256 tokenId) public view returns (bytes32) {
        require(_exists(tokenId), "ERC721Metadata: document hash query for nonexistent token");
        return _documentHashes[tokenId];
    }

    function _setDocumentHash(uint256 tokenId, bytes32 documentHash) internal {
        require(_exists(tokenId), "ERC721Metadata: document hash set of nonexistent token");
        _documentHashes[tokenId] = documentHash;
    }
}
