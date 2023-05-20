// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract JobReadyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string nftURI =
        "https://ipfs.io/ipfs/QmTNvJFyZnqhvf73Grb4Q7z5u4qWdqQqrkeCVhbXakDHvZ";

    constructor() ERC721("JobReadyNFT", "JRNFT") {}

    function awardUser(address user) external returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(user, newItemId);
        _setTokenURI(newItemId, nftURI);

        _tokenIds.increment();
        return newItemId;
    }
}
