// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {StakeToken} from "../src/StakeToken.sol";
import {RewardNFT721} from "../src/RewardNFT721.sol";
import {RewardBadge1155} from "../src/RewardBadge1155.sol";
import {StakingVault} from "../src/StakingVault.sol";
import {TierManager} from "../src/TierManager.sol";

/// @title Deploy
/// @notice Deploys the full Open Stake system: token, NFT contracts, vault, and configures tiers.
/// @dev Run with: forge script script/Deploy.s.sol --rpc-url <RPC> --broadcast --verify
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("Deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy StakeToken (or use existing ERC-20 address from env)
        address stakingTokenAddr = vm.envOr("STAKING_TOKEN", address(0));
        StakeToken stakeToken;

        if (stakingTokenAddr == address(0)) {
            stakeToken = new StakeToken("Open Stake Token", "OST", deployer);
            stakingTokenAddr = address(stakeToken);
            console2.log("StakeToken deployed:", stakingTokenAddr);
        } else {
            console2.log("Using existing staking token:", stakingTokenAddr);
        }

        // 2. Deploy RewardNFT721
        RewardNFT721 rewardNFT = new RewardNFT721("Open Stake Reward", "OSR", deployer);
        console2.log("RewardNFT721 deployed:", address(rewardNFT));

        // 3. Deploy RewardBadge1155
        string memory badgeUri = vm.envOr("BADGE_URI", string("https://api.openstake.xyz/badges/{id}.json"));
        RewardBadge1155 rewardBadge = new RewardBadge1155(badgeUri, "Open Stake Badge", "OSB", deployer);
        console2.log("RewardBadge1155 deployed:", address(rewardBadge));

        // 4. Deploy StakingVault
        StakingVault vault = new StakingVault(IERC20(stakingTokenAddr), rewardNFT, rewardBadge, deployer);
        console2.log("StakingVault deployed:", address(vault));

        // 5. Grant minter roles to vault
        rewardNFT.setMinter(address(vault));
        rewardBadge.setMinter(address(vault));
        console2.log("Minter roles granted to vault");

        // 6. Configure default tiers
        vault.addTier(
            TierManager.Tier({
                minStakeAmount: 100 ether,
                minDuration: 7 days,
                grantsNFT721: false,
                grantsNFT1155: true,
                nft1155TokenId: 1,
                name: "Bronze"
            })
        );

        vault.addTier(
            TierManager.Tier({
                minStakeAmount: 500 ether,
                minDuration: 30 days,
                grantsNFT721: false,
                grantsNFT1155: true,
                nft1155TokenId: 2,
                name: "Silver"
            })
        );

        vault.addTier(
            TierManager.Tier({
                minStakeAmount: 1000 ether,
                minDuration: 90 days,
                grantsNFT721: true,
                grantsNFT1155: true,
                nft1155TokenId: 3,
                name: "Gold"
            })
        );

        console2.log("Tiers configured: Bronze, Silver, Gold");

        vm.stopBroadcast();
    }
}
