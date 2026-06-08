// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {StakeToken} from "../src/StakeToken.sol";
import {RewardNFT721} from "../src/RewardNFT721.sol";
import {RewardBadge1155} from "../src/RewardBadge1155.sol";
import {StakingVault} from "../src/StakingVault.sol";
import {TierManager} from "../src/TierManager.sol";

contract StakingVaultTest is Test {
    StakeToken public token;
    RewardNFT721 public nft;
    RewardBadge1155 public badge;
    StakingVault public vault;

    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 constant STAKE_AMOUNT = 1000 ether;
    uint256 constant BRONZE_DURATION = 7 days;
    uint256 constant SILVER_DURATION = 30 days;
    uint256 constant GOLD_DURATION = 90 days;

    function setUp() public {
        vm.startPrank(admin);

        // Deploy token
        token = new StakeToken("Stake Token", "STK", admin);

        // Deploy reward contracts
        nft = new RewardNFT721("Reward NFT", "RNFT", admin);
        badge = new RewardBadge1155("https://api.example.com/badges/{id}.json", "Reward Badge", "RBDG", admin);

        // Deploy vault
        vault = new StakingVault(IERC20(address(token)), nft, badge, admin);

        // Grant minter roles to vault
        nft.setMinter(address(vault));
        badge.setMinter(address(vault));

        // Configure tiers
        vault.addTier(
            TierManager.Tier({
                minStakeAmount: 100 ether,
                minDuration: BRONZE_DURATION,
                grantsNFT721: false,
                grantsNFT1155: true,
                nft1155TokenId: 1,
                name: "Bronze"
            })
        );

        vault.addTier(
            TierManager.Tier({
                minStakeAmount: 500 ether,
                minDuration: SILVER_DURATION,
                grantsNFT721: false,
                grantsNFT1155: true,
                nft1155TokenId: 2,
                name: "Silver"
            })
        );

        vault.addTier(
            TierManager.Tier({
                minStakeAmount: 1000 ether,
                minDuration: GOLD_DURATION,
                grantsNFT721: true,
                grantsNFT1155: true,
                nft1155TokenId: 3,
                name: "Gold"
            })
        );

        // Mint tokens to test users
        token.mint(alice, 10_000 ether);
        token.mint(bob, 10_000 ether);

        vm.stopPrank();

        // Approve vault for both users
        vm.prank(alice);
        token.approve(address(vault), type(uint256).max);

        vm.prank(bob);
        token.approve(address(vault), type(uint256).max);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_stake_basic() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        (uint256 amount, uint256 stakedAt,) = vault.stakes(alice);
        assertEq(amount, STAKE_AMOUNT);
        assertEq(stakedAt, block.timestamp);
        assertEq(vault.totalStaked(), STAKE_AMOUNT);
        assertEq(token.balanceOf(address(vault)), STAKE_AMOUNT);
    }

    function test_stake_emitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit StakingVault.Staked(alice, STAKE_AMOUNT, STAKE_AMOUNT);
        vault.stake(STAKE_AMOUNT);
    }

    function test_stake_multipleDeposits_weightedTimestamp() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        // Warp 10 days
        vm.warp(block.timestamp + 10 days);

        // Stake same amount again
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        (uint256 amount, uint256 stakedAt,) = vault.stakes(alice);
        assertEq(amount, 2 * STAKE_AMOUNT);
        // Effective stakedAt should be 5 days ago (weighted average)
        assertEq(block.timestamp - stakedAt, 5 days);
    }

    function test_stake_revertsOnZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert(StakingVault.ZeroAmount.selector);
        vault.stake(0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UNSTAKING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_unstake_full() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.prank(alice);
        vault.unstake(STAKE_AMOUNT);

        (uint256 amount,,) = vault.stakes(alice);
        assertEq(amount, 0);
        assertEq(vault.totalStaked(), 0);
        assertEq(token.balanceOf(alice), 10_000 ether);
    }

    function test_unstake_partial() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        uint256 unstakeAmount = 400 ether;
        vm.prank(alice);
        vault.unstake(unstakeAmount);

        (uint256 amount, uint256 stakedAt,) = vault.stakes(alice);
        assertEq(amount, STAKE_AMOUNT - unstakeAmount);
        // Timestamp should remain the same for partial unstake
        assertEq(stakedAt, block.timestamp);
        assertEq(vault.totalStaked(), STAKE_AMOUNT - unstakeAmount);
    }

    function test_unstake_emitsEvent() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.prank(alice);
        vm.expectEmit(true, false, false, true);
        emit StakingVault.Unstaked(alice, 500 ether, 500 ether);
        vault.unstake(500 ether);
    }

    function test_unstake_revertsOnZeroAmount() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.prank(alice);
        vm.expectRevert(StakingVault.ZeroAmount.selector);
        vault.unstake(0);
    }

    function test_unstake_revertsIfNotStaking() public {
        vm.prank(alice);
        vm.expectRevert(StakingVault.NotStaking.selector);
        vault.unstake(100 ether);
    }

    function test_unstake_revertsIfInsufficientStake() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.prank(alice);
        vm.expectRevert(StakingVault.InsufficientStake.selector);
        vault.unstake(STAKE_AMOUNT + 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TIER PROGRESSION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_tierProgression_bronzeAfter7Days() public {
        vm.prank(alice);
        vault.stake(100 ether);

        // Before 7 days — no tier
        vm.warp(block.timestamp + 6 days);
        (uint256 tierId, bool eligible,) = vault.getUserTier(alice);
        assertFalse(eligible);

        // After 7 days — Bronze
        vm.warp(block.timestamp + 1 days);
        (tierId, eligible,) = vault.getUserTier(alice);
        assertTrue(eligible);
        assertEq(tierId, 0); // Bronze is tier 0
    }

    function test_tierProgression_silverAfter30Days() public {
        vm.prank(alice);
        vault.stake(500 ether);

        vm.warp(block.timestamp + SILVER_DURATION);
        (uint256 tierId, bool eligible, string memory name) = vault.getUserTier(alice);
        assertTrue(eligible);
        assertEq(tierId, 1); // Silver
        assertEq(name, "Silver");
    }

    function test_tierProgression_goldAfter90Days() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.warp(block.timestamp + GOLD_DURATION);
        (uint256 tierId, bool eligible, string memory name) = vault.getUserTier(alice);
        assertTrue(eligible);
        assertEq(tierId, 2); // Gold
        assertEq(name, "Gold");
    }

    function test_tierProgression_insufficientAmount() public {
        // Stake only 50 ether — below all tier minimums
        vm.prank(alice);
        vault.stake(50 ether);

        vm.warp(block.timestamp + GOLD_DURATION);
        (, bool eligible,) = vault.getUserTier(alice);
        assertFalse(eligible);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD CLAIMING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_claimReward_bronze_mintsERC1155() public {
        vm.prank(alice);
        vault.stake(100 ether);

        vm.warp(block.timestamp + BRONZE_DURATION);

        vm.prank(alice);
        vault.claimReward();

        // Should have received 1155 badge with tokenId=1
        assertEq(badge.balanceOf(alice, 1), 1);
        // Should NOT have received 721
        assertEq(nft.balanceOf(alice), 0);
        // Tier should be marked as claimed
        assertTrue(vault.hasClaimed(alice, 0));
    }

    function test_claimReward_gold_mintsBoth() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.warp(block.timestamp + GOLD_DURATION);

        vm.prank(alice);
        vault.claimReward();

        // Gold grants both NFT-721 and ERC-1155 badge
        assertEq(nft.balanceOf(alice), 1);
        assertEq(badge.balanceOf(alice, 3), 1);
        assertTrue(vault.hasClaimed(alice, 2));
    }

    function test_claimSpecificTier() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.warp(block.timestamp + GOLD_DURATION);

        // Claim Bronze specifically (even though Gold is available)
        vm.prank(alice);
        vault.claimSpecificTier(0);
        assertEq(badge.balanceOf(alice, 1), 1);
        assertTrue(vault.hasClaimed(alice, 0));

        // Claim Silver
        vm.prank(alice);
        vault.claimSpecificTier(1);
        assertEq(badge.balanceOf(alice, 2), 1);
        assertTrue(vault.hasClaimed(alice, 1));

        // Claim Gold
        vm.prank(alice);
        vault.claimSpecificTier(2);
        assertEq(nft.balanceOf(alice), 1);
        assertEq(badge.balanceOf(alice, 3), 1);
        assertTrue(vault.hasClaimed(alice, 2));
    }

    function test_claimReward_revertsOnDoubleClaim() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + GOLD_DURATION);

        vm.prank(alice);
        vault.claimReward();

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(StakingVault.TierAlreadyClaimed.selector, 2));
        vault.claimReward();
    }

    function test_claimReward_revertsIfNoEligibleTier() public {
        vm.prank(alice);
        vault.stake(50 ether);
        vm.warp(block.timestamp + GOLD_DURATION);

        vm.prank(alice);
        vm.expectRevert(StakingVault.NoEligibleTier.selector);
        vault.claimReward();
    }

    function test_claimReward_revertsIfNotStaking() public {
        vm.prank(alice);
        vm.expectRevert(StakingVault.NotStaking.selector);
        vault.claimReward();
    }

    function test_claimReward_persistsAfterUnstakeAndRestake() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + GOLD_DURATION);

        // Claim Gold
        vm.prank(alice);
        vault.claimReward();

        // Full unstake
        vm.prank(alice);
        vault.unstake(STAKE_AMOUNT);

        // Re-stake and wait Gold duration again
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + GOLD_DURATION);

        // Should still be marked as claimed — cannot re-claim
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(StakingVault.TierAlreadyClaimed.selector, 2));
        vault.claimReward();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIMABLE TIERS VIEW TEST
    // ═══════════════════════════════════════════════════════════════════════════

    function test_getClaimableTiers() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.warp(block.timestamp + GOLD_DURATION);

        uint256[] memory tiers = vault.getClaimableTiers(alice);
        assertEq(tiers.length, 3); // Bronze, Silver, Gold all claimable

        // Claim Bronze
        vm.prank(alice);
        vault.claimSpecificTier(0);

        tiers = vault.getClaimableTiers(alice);
        assertEq(tiers.length, 2); // Silver, Gold remaining
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN TIER MANAGEMENT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_addTier_onlyOwner() public {
        TierManager.Tier memory tier = TierManager.Tier({
            minStakeAmount: 2000 ether,
            minDuration: 180 days,
            grantsNFT721: true,
            grantsNFT1155: true,
            nft1155TokenId: 4,
            name: "Diamond"
        });

        vm.prank(alice);
        vm.expectRevert();
        vault.addTier(tier);

        vm.prank(admin);
        uint256 tierId = vault.addTier(tier);
        assertEq(tierId, 3);
        assertEq(vault.getTierCount(), 4);
    }

    function test_updateTier() public {
        TierManager.Tier memory updated = TierManager.Tier({
            minStakeAmount: 200 ether,
            minDuration: 14 days,
            grantsNFT721: true,
            grantsNFT1155: true,
            nft1155TokenId: 1,
            name: "Bronze+"
        });

        vm.prank(admin);
        vault.updateTier(0, updated);

        TierManager.Tier memory stored = vault.getTier(0);
        assertEq(stored.minStakeAmount, 200 ether);
        assertEq(stored.minDuration, 14 days);
        assertEq(stored.name, "Bronze+");
    }

    function test_removeTier() public {
        vm.prank(admin);
        vault.removeTier(0);

        assertEq(vault.getTierCount(), 2);
    }

    function test_addTier_revertsOnInvalidParams() public {
        TierManager.Tier memory invalid = TierManager.Tier({
            minStakeAmount: 0,
            minDuration: 0,
            grantsNFT721: false,
            grantsNFT1155: false,
            nft1155TokenId: 0,
            name: "Invalid"
        });

        vm.prank(admin);
        vm.expectRevert(TierManager.InvalidTierParams.selector);
        vault.addTier(invalid);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_unstakeBeforeAnyTier_noReward() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        // Unstake after 1 day (before Bronze at 7 days)
        vm.warp(block.timestamp + 1 days);
        vm.prank(alice);
        vault.unstake(STAKE_AMOUNT);

        (, bool eligible,) = vault.getUserTier(alice);
        assertFalse(eligible);
    }

    function test_multipleUsers_independentProgress() public {
        vm.prank(alice);
        vault.stake(STAKE_AMOUNT);

        vm.warp(block.timestamp + 15 days);

        vm.prank(bob);
        vault.stake(STAKE_AMOUNT);

        // Alice should have 15 days progress, Bob 0
        assertEq(vault.getStakeDuration(alice), 15 days);
        assertEq(vault.getStakeDuration(bob), 0);

        // Warp another 15 days
        vm.warp(block.timestamp + 15 days);

        // Alice: 30 days (Silver eligible), Bob: 15 days (Bronze eligible)
        (uint256 aliceTier, bool aliceEligible,) = vault.getUserTier(alice);
        (uint256 bobTier, bool bobEligible,) = vault.getUserTier(bob);

        assertTrue(aliceEligible);
        assertEq(aliceTier, 1); // Silver
        assertTrue(bobEligible);
        assertEq(bobTier, 0); // Bronze
    }

    function test_getStakeDuration_returnsZeroIfNotStaking() public {
        assertEq(vault.getStakeDuration(alice), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_stakeAndUnstake(uint256 stakeAmt, uint256 unstakeAmt) public {
        stakeAmt = bound(stakeAmt, 1, 10_000 ether);
        unstakeAmt = bound(unstakeAmt, 1, stakeAmt);

        vm.prank(alice);
        vault.stake(stakeAmt);

        vm.prank(alice);
        vault.unstake(unstakeAmt);

        (uint256 remaining,,) = vault.stakes(alice);
        assertEq(remaining, stakeAmt - unstakeAmt);
        assertEq(token.balanceOf(address(vault)), stakeAmt - unstakeAmt);
    }
}
