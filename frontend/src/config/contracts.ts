// Contract addresses — update these after deployment
// For local Anvil, run the deploy script and paste addresses here.

export const CONTRACTS = {
  stakingVault: (process.env.NEXT_PUBLIC_VAULT_ADDRESS || "0x0000000000000000000000000000000000000000") as `0x${string}`,
  stakingToken: (process.env.NEXT_PUBLIC_TOKEN_ADDRESS || "0x0000000000000000000000000000000000000000") as `0x${string}`,
  rewardNFT: (process.env.NEXT_PUBLIC_NFT_ADDRESS || "0x0000000000000000000000000000000000000000") as `0x${string}`,
  rewardBadge: (process.env.NEXT_PUBLIC_BADGE_ADDRESS || "0x0000000000000000000000000000000000000000") as `0x${string}`,
} as const;
