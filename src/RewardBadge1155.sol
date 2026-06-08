// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title RewardBadge1155
/// @notice ERC-1155 badge tokens awarded to stakers who reach specific tiers.
/// @dev Each tier maps to a token ID. Only the authorized minter (StakingVault) can mint.
contract RewardBadge1155 is ERC1155, Ownable {
    /// @notice The address authorized to mint badges (typically the StakingVault).
    address public minter;

    /// @notice Human-readable name for the collection.
    string public name;

    /// @notice Symbol for the collection.
    string public symbol;

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

    /// @param uri_ Base metadata URI (e.g. "https://api.example.com/badges/{id}.json").
    /// @param name_ Collection name.
    /// @param symbol_ Collection symbol.
    /// @param initialOwner The admin/owner address.
    constructor(string memory uri_, string memory name_, string memory symbol_, address initialOwner)
        ERC1155(uri_)
        Ownable(initialOwner)
    {
        name = name_;
        symbol = symbol_;
    }

    // ─── Admin ─────────────────────────────────────────────────────────────────

    /// @notice Set or update the minter address. Only callable by the owner.
    /// @param newMinter The address to grant minting rights to.
    function setMinter(address newMinter) external onlyOwner {
        if (newMinter == address(0)) revert ZeroAddress();
        address oldMinter = minter;
        minter = newMinter;
        emit MinterUpdated(oldMinter, newMinter);
    }

    /// @notice Update the base URI for metadata. Only callable by the owner.
    /// @param newUri The new base URI.
    function setURI(string calldata newUri) external onlyOwner {
        _setURI(newUri);
    }

    // ─── Minting ───────────────────────────────────────────────────────────────

    /// @notice Mint a badge to a recipient. Only callable by the minter.
    /// @param to The address receiving the badge.
    /// @param id The token ID representing the tier badge.
    /// @param amount Number of badges to mint (typically 1).
    function mint(address to, uint256 id, uint256 amount) external onlyMinter {
        _mint(to, id, amount, "");
    }

    /// @notice Batch-mint multiple badge types. Only callable by the minter.
    /// @param to The address receiving the badges.
    /// @param ids Array of token IDs.
    /// @param amounts Array of amounts per token ID.
    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts) external onlyMinter {
        _mintBatch(to, ids, amounts, "");
    }
}
