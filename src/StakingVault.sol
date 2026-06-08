// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {TierManager} from "./TierManager.sol";
import {RewardNFT721} from "./RewardNFT721.sol";
import {RewardBadge1155} from "./RewardBadge1155.sol";

/// @title StakingVault
/// @notice Core staking contract: users stake ERC-20 tokens and unlock tiered rewards (NFTs/badges)
///         based on stake amount and duration. Inherits TierManager for flexible tier configuration.
contract StakingVault is TierManager, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ─── State ─────────────────────────────────────────────────────────────────

    /// @notice The ERC-20 token users stake.
    IERC20 public immutable stakingToken;

    /// @notice The ERC-721 contract used for unique reward NFTs.
    RewardNFT721 public immutable rewardNFT;

    /// @notice The ERC-1155 contract used for badge rewards.
    RewardBadge1155 public immutable rewardBadge;

    /// @notice Information about a user's stake.
    struct StakeInfo {
        uint256 amount;         // Total tokens currently staked
        uint256 stakedAt;       // Effective timestamp (adjusted on partial unstake)
        uint256 lastClaimedTier; // Highest tier ID already claimed (type(uint256).max = none claimed)
    }

    /// @notice Mapping of user address to their stake information.
    mapping(address => StakeInfo) public stakes;

    /// @notice Tracks which specific tier IDs a user has already claimed (tierId => claimed).
    mapping(address => mapping(uint256 => bool)) public tierClaimed;

    /// @notice Total tokens staked across all users.
    uint256 public totalStaked;

    // ─── Events ────────────────────────────────────────────────────────────────

    event Staked(address indexed user, uint256 amount, uint256 totalStaked);
    event Unstaked(address indexed user, uint256 amount, uint256 remaining);
    event RewardClaimed(address indexed user, uint256 indexed tierId, bool nft721Minted, bool nft1155Minted);
    event TierUnlocked(address indexed user, uint256 indexed tierId, string tierName);

    // ─── Errors ────────────────────────────────────────────────────────────────

    error ZeroAmount();
    error InsufficientStake();
    error NoEligibleTier();
    error TierAlreadyClaimed(uint256 tierId);
    error NotStaking();

    // ─── Constructor ───────────────────────────────────────────────────────────

    /// @param _stakingToken The ERC-20 token to stake.
    /// @param _rewardNFT The ERC-721 reward contract.
    /// @param _rewardBadge The ERC-1155 badge contract.
    /// @param _admin The admin/owner address for tier management.
    constructor(
        IERC20 _stakingToken,
        RewardNFT721 _rewardNFT,
        RewardBadge1155 _rewardBadge,
        address _admin
    ) TierManager() Ownable(_admin) {
        stakingToken = _stakingToken;
        rewardNFT = _rewardNFT;
        rewardBadge = _rewardBadge;
    }

    // ─── Staking ───────────────────────────────────────────────────────────────

    /// @notice Stake tokens into the vault.
    /// @param amount The number of tokens to stake.
    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        StakeInfo storage info = stakes[msg.sender];

        // If user already has a stake, calculate a weighted-average timestamp
        // to fairly account for the new deposit without resetting progress.
        if (info.amount > 0) {
            uint256 existingWeight = info.amount * (block.timestamp - info.stakedAt);
            // New deposit has zero duration so its weight is 0.
            // New effective stakedAt = now - (existingWeight / newTotalAmount)
            uint256 newTotal = info.amount + amount;
            uint256 effectiveElapsed = existingWeight / newTotal;
            info.stakedAt = block.timestamp - effectiveElapsed;
        } else {
            info.stakedAt = block.timestamp;
            info.lastClaimedTier = type(uint256).max; // sentinel: nothing claimed
        }

        info.amount += amount;
        totalStaked += amount;

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, info.amount);
    }

    /// @notice Unstake tokens (partial or full withdrawal).
    /// @dev Partial unstake adjusts the effective stakedAt proportionally to preserve
    ///      fair reward calculation for the remaining tokens.
    /// @param amount The number of tokens to withdraw.
    function unstake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        StakeInfo storage info = stakes[msg.sender];
        if (info.amount == 0) revert NotStaking();
        if (amount > info.amount) revert InsufficientStake();

        if (amount == info.amount) {
            // Full unstake — reset everything
            info.amount = 0;
            info.stakedAt = 0;
            // Note: claimed tiers remain recorded to prevent re-claiming after re-staking
        } else {
            // Partial unstake — adjust timestamp proportionally
            // The remaining tokens retain the original elapsed time.
            // No timestamp adjustment needed: remaining tokens have been staked since info.stakedAt.
            info.amount -= amount;
        }

        totalStaked -= amount;
        stakingToken.safeTransfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount, info.amount);
    }

    // ─── Rewards ───────────────────────────────────────────────────────────────

    /// @notice Claim the reward for the highest tier the caller currently qualifies for.
    /// @dev Users must claim each tier individually. Cannot double-claim the same tier.
    function claimReward() external nonReentrant {
        StakeInfo storage info = stakes[msg.sender];
        if (info.amount == 0) revert NotStaking();

        uint256 duration = block.timestamp - info.stakedAt;
        (uint256 tierId, bool eligible) = getEligibleTier(info.amount, duration);

        if (!eligible) revert NoEligibleTier();
        if (tierClaimed[msg.sender][tierId]) revert TierAlreadyClaimed(tierId);

        // Mark tier as claimed
        tierClaimed[msg.sender][tierId] = true;
        info.lastClaimedTier = tierId;

        Tier storage tier = _tiers[tierId];

        bool nft721Minted;
        bool nft1155Minted;

        // Mint ERC-721 if tier grants it
        if (tier.grantsNFT721) {
            rewardNFT.mint(msg.sender);
            nft721Minted = true;
        }

        // Mint ERC-1155 badge if tier grants it
        if (tier.grantsNFT1155) {
            rewardBadge.mint(msg.sender, tier.nft1155TokenId, 1);
            nft1155Minted = true;
        }

        emit TierUnlocked(msg.sender, tierId, tier.name);
        emit RewardClaimed(msg.sender, tierId, nft721Minted, nft1155Minted);
    }

    /// @notice Claim a specific tier's reward (not just the highest eligible).
    /// @param tierId The tier to claim.
    function claimSpecificTier(uint256 tierId) external nonReentrant {
        StakeInfo storage info = stakes[msg.sender];
        if (info.amount == 0) revert NotStaking();
        if (tierId >= _tiers.length) revert TierDoesNotExist(tierId);
        if (tierClaimed[msg.sender][tierId]) revert TierAlreadyClaimed(tierId);

        Tier storage tier = _tiers[tierId];
        uint256 duration = block.timestamp - info.stakedAt;

        // Verify eligibility for this specific tier
        if (info.amount < tier.minStakeAmount || duration < tier.minDuration) {
            revert NoEligibleTier();
        }

        // Mark tier as claimed
        tierClaimed[msg.sender][tierId] = true;
        if (info.lastClaimedTier == type(uint256).max || tierId > info.lastClaimedTier) {
            info.lastClaimedTier = tierId;
        }

        bool nft721Minted;
        bool nft1155Minted;

        if (tier.grantsNFT721) {
            rewardNFT.mint(msg.sender);
            nft721Minted = true;
        }

        if (tier.grantsNFT1155) {
            rewardBadge.mint(msg.sender, tier.nft1155TokenId, 1);
            nft1155Minted = true;
        }

        emit TierUnlocked(msg.sender, tierId, tier.name);
        emit RewardClaimed(msg.sender, tierId, nft721Minted, nft1155Minted);
    }

    // ─── View Functions ────────────────────────────────────────────────────────

    /// @notice Get the current tier a user qualifies for (without claiming).
    /// @param user The address to check.
    /// @return tierId The eligible tier ID (type(uint256).max if none).
    /// @return eligible Whether the user qualifies for any tier.
    /// @return tierName The name of the eligible tier (empty if none).
    function getUserTier(address user) external view returns (uint256 tierId, bool eligible, string memory tierName) {
        StakeInfo storage info = stakes[user];
        if (info.amount == 0) return (type(uint256).max, false, "");

        uint256 duration = block.timestamp - info.stakedAt;
        (tierId, eligible) = getEligibleTier(info.amount, duration);

        if (eligible) {
            tierName = _tiers[tierId].name;
        }
    }

    /// @notice Get the staking duration (in seconds) for a user.
    /// @param user The address to check.
    function getStakeDuration(address user) external view returns (uint256) {
        StakeInfo storage info = stakes[user];
        if (info.amount == 0) return 0;
        return block.timestamp - info.stakedAt;
    }

    /// @notice Check if a user has claimed a specific tier.
    /// @param user The address to check.
    /// @param tierId The tier ID.
    function hasClaimed(address user, uint256 tierId) external view returns (bool) {
        return tierClaimed[user][tierId];
    }

    /// @notice Get all unclaimed tiers the user is eligible for.
    /// @param user The address to check.
    /// @return tierIds Array of eligible unclaimed tier IDs.
    function getClaimableTiers(address user) external view returns (uint256[] memory tierIds) {
        StakeInfo storage info = stakes[user];
        if (info.amount == 0) return tierIds;

        uint256 duration = block.timestamp - info.stakedAt;
        uint256 count;

        // First pass: count eligible unclaimed tiers
        for (uint256 i = 0; i < _tiers.length; i++) {
            if (
                info.amount >= _tiers[i].minStakeAmount
                    && duration >= _tiers[i].minDuration
                    && !tierClaimed[user][i]
            ) {
                count++;
            }
        }

        // Second pass: populate array
        tierIds = new uint256[](count);
        uint256 idx;
        for (uint256 i = 0; i < _tiers.length; i++) {
            if (
                info.amount >= _tiers[i].minStakeAmount
                    && duration >= _tiers[i].minDuration
                    && !tierClaimed[user][i]
            ) {
                tierIds[idx++] = i;
            }
        }
    }
}
