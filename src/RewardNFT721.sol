// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title RewardNFT721
/// @notice ERC-721 NFT awarded to stakers who reach specific tiers.
/// @dev Only the authorized minter (StakingVault) can mint. Owner can update the minter.
contract RewardNFT721 is ERC721, Ownable {
    /// @notice The address authorized to mint reward NFTs (typically the StakingVault).
    address public minter;

    /// @dev Auto-incrementing token ID counter.
    uint256 private _nextTokenId;

    // ─── Events ────────────────────────────────────────────────────────────────

    event MinterUpdated(address indexed oldMinter, address indexed newMinter);

    // ─── Errors ────────────────────────────────────────────────────────────────

    error OnlyMinter();
    error ZeroAddress();

    // ─── Modifiers ─────────────────────────────────────────────────────────────

    modifier onlyMinter() {
        if (msg.sender != minter) revert OnlyMinter();
        _;
    }

    // ─── Constructor ───────────────────────────────────────────────────────────

    constructor(string memory name_, string memory symbol_, address initialOwner)
        ERC721(name_, symbol_)
        Ownable(initialOwner)
    {}

    // ─── Admin ─────────────────────────────────────────────────────────────────

    /// @notice Set or update the minter address. Only callable by the owner.
    /// @param newMinter The address to grant minting rights to.
    function setMinter(address newMinter) external onlyOwner {
        if (newMinter == address(0)) revert ZeroAddress();
        address oldMinter = minter;
        minter = newMinter;
        emit MinterUpdated(oldMinter, newMinter);
    }

    // ─── Minting ───────────────────────────────────────────────────────────────

    /// @notice Mint a new reward NFT to the specified recipient. Only callable by the minter.
    /// @param to The address receiving the NFT.
    /// @return tokenId The ID of the newly minted token.
    function mint(address to) external onlyMinter returns (uint256 tokenId) {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }
}
