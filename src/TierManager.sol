// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title TierManager
/// @notice Abstract contract that manages configurable reward tiers for the staking system.
/// @dev Inherit this in StakingVault to gain tier CRUD and eligibility logic.
abstract contract TierManager is Ownable {
    /// @notice Represents a single reward tier.
    struct Tier {
        uint256 minStakeAmount; // Minimum tokens staked to qualify
        uint256 minDuration; // Minimum seconds staked to qualify
        bool grantsNFT721; // Whether this tier grants a unique ERC-721 reward
        bool grantsNFT1155; // Whether this tier grants an ERC-1155 badge
        uint256 nft1155TokenId; // The ERC-1155 token ID for the badge (if applicable)
        string name; // Human-readable tier name (e.g. "Bronze", "Gold")
    }

    /// @dev Array of all tiers, ordered by the admin. Index = tier ID.
    Tier[] internal _tiers;

    // ─── Events ────────────────────────────────────────────────────────────────

    event TierAdded(uint256 indexed tierId, string name);
    event TierUpdated(uint256 indexed tierId, string name);
    event TierRemoved(uint256 indexed tierId);

    // ─── Errors ────────────────────────────────────────────────────────────────

    error TierDoesNotExist(uint256 tierId);
    error InvalidTierParams();

    // ─── Admin Functions ───────────────────────────────────────────────────────

    /// @notice Add a new tier. Only callable by the owner.
    /// @param tier The tier configuration to add.
    /// @return tierId The index of the newly created tier.
    function addTier(Tier calldata tier) external onlyOwner returns (uint256 tierId) {
        if (tier.minStakeAmount == 0 && tier.minDuration == 0) revert InvalidTierParams();

        _tiers.push(tier);
        tierId = _tiers.length - 1;

        emit TierAdded(tierId, tier.name);
    }

    /// @notice Update an existing tier. Only callable by the owner.
    /// @param tierId The index of the tier to update.
    /// @param tier The new tier configuration.
    function updateTier(uint256 tierId, Tier calldata tier) external onlyOwner {
        if (tierId >= _tiers.length) revert TierDoesNotExist(tierId);
        if (tier.minStakeAmount == 0 && tier.minDuration == 0) revert InvalidTierParams();

        _tiers[tierId] = tier;

        emit TierUpdated(tierId, tier.name);
    }

    /// @notice Remove a tier by swapping with the last element and popping.
    /// @dev This changes the ID of the last tier — use with caution if users reference tier IDs.
    /// @param tierId The index of the tier to remove.
    function removeTier(uint256 tierId) external onlyOwner {
        if (tierId >= _tiers.length) revert TierDoesNotExist(tierId);

        uint256 lastIndex = _tiers.length - 1;
        if (tierId != lastIndex) {
            _tiers[tierId] = _tiers[lastIndex];
        }
        _tiers.pop();

        emit TierRemoved(tierId);
    }

    // ─── View Functions ────────────────────────────────────────────────────────

    /// @notice Returns the highest tier a user qualifies for given their stake amount and duration.
    /// @param amount The amount of tokens staked.
    /// @param duration The number of seconds the tokens have been staked.
    /// @return tierId The index of the highest eligible tier (type(uint256).max if none).
    /// @return eligible Whether the user qualifies for any tier.
    function getEligibleTier(uint256 amount, uint256 duration) public view returns (uint256 tierId, bool eligible) {
        uint256 highestScore;
        tierId = type(uint256).max;

        for (uint256 i = 0; i < _tiers.length; i++) {
            Tier storage tier = _tiers[i];

            if (amount >= tier.minStakeAmount && duration >= tier.minDuration) {
                // Score: sum of requirements — higher requirements = higher tier
                uint256 score = tier.minStakeAmount + tier.minDuration;
                if (score > highestScore) {
                    highestScore = score;
                    tierId = i;
                    eligible = true;
                }
            }
        }
    }

    /// @notice Get the total number of configured tiers.
    function getTierCount() external view returns (uint256) {
        return _tiers.length;
    }

    /// @notice Get the configuration of a specific tier.
    /// @param tierId The index of the tier.
    function getTier(uint256 tierId) external view returns (Tier memory) {
        if (tierId >= _tiers.length) revert TierDoesNotExist(tierId);
        return _tiers[tierId];
    }

    /// @notice Get all configured tiers.
    function getAllTiers() external view returns (Tier[] memory) {
        return _tiers;
    }
}
