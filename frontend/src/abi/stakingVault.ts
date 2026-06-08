export const stakingVaultAbi = [
  {
    type: "constructor",
    inputs: [
      { name: "_stakingToken", type: "address" },
      { name: "_rewardNFT", type: "address" },
      { name: "_rewardBadge", type: "address" },
      { name: "_admin", type: "address" },
    ],
    stateMutability: "nonpayable",
  },
  // ─── Read Functions ──────────────────────────────────────────────────────
  {
    type: "function",
    name: "stakingToken",
    inputs: [],
    outputs: [{ name: "", type: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "rewardNFT",
    inputs: [],
    outputs: [{ name: "", type: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "rewardBadge",
    inputs: [],
    outputs: [{ name: "", type: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "totalStaked",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "owner",
    inputs: [],
    outputs: [{ name: "", type: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "stakes",
    inputs: [{ name: "", type: "address" }],
    outputs: [
      { name: "amount", type: "uint256" },
      { name: "stakedAt", type: "uint256" },
      { name: "lastClaimedTier", type: "uint256" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "tierClaimed",
    inputs: [
      { name: "", type: "address" },
      { name: "", type: "uint256" },
    ],
    outputs: [{ name: "", type: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getUserTier",
    inputs: [{ name: "user", type: "address" }],
    outputs: [
      { name: "tierId", type: "uint256" },
      { name: "eligible", type: "bool" },
      { name: "tierName", type: "string" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getStakeDuration",
    inputs: [{ name: "user", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "hasClaimed",
    inputs: [
      { name: "user", type: "address" },
      { name: "tierId", type: "uint256" },
    ],
    outputs: [{ name: "", type: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getClaimableTiers",
    inputs: [{ name: "user", type: "address" }],
    outputs: [{ name: "tierIds", type: "uint256[]" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getAllTiers",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "tuple[]",
        components: [
          { name: "minStakeAmount", type: "uint256" },
          { name: "minDuration", type: "uint256" },
          { name: "grantsNFT721", type: "bool" },
          { name: "grantsNFT1155", type: "bool" },
          { name: "nft1155TokenId", type: "uint256" },
          { name: "name", type: "string" },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getTier",
    inputs: [{ name: "tierId", type: "uint256" }],
    outputs: [
      {
        name: "",
        type: "tuple",
        components: [
          { name: "minStakeAmount", type: "uint256" },
          { name: "minDuration", type: "uint256" },
          { name: "grantsNFT721", type: "bool" },
          { name: "grantsNFT1155", type: "bool" },
          { name: "nft1155TokenId", type: "uint256" },
          { name: "name", type: "string" },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getTierCount",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getEligibleTier",
    inputs: [
      { name: "amount", type: "uint256" },
      { name: "duration", type: "uint256" },
    ],
    outputs: [
      { name: "tierId", type: "uint256" },
      { name: "eligible", type: "bool" },
    ],
    stateMutability: "view",
  },
  // ─── Write Functions ─────────────────────────────────────────────────────
  {
    type: "function",
    name: "stake",
    inputs: [{ name: "amount", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "unstake",
    inputs: [{ name: "amount", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "claimReward",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "claimSpecificTier",
    inputs: [{ name: "tierId", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  // ─── Admin Functions ─────────────────────────────────────────────────────
  {
    type: "function",
    name: "addTier",
    inputs: [
      {
        name: "tier",
        type: "tuple",
        components: [
          { name: "minStakeAmount", type: "uint256" },
          { name: "minDuration", type: "uint256" },
          { name: "grantsNFT721", type: "bool" },
          { name: "grantsNFT1155", type: "bool" },
          { name: "nft1155TokenId", type: "uint256" },
          { name: "name", type: "string" },
        ],
      },
    ],
    outputs: [{ name: "tierId", type: "uint256" }],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "updateTier",
    inputs: [
      { name: "tierId", type: "uint256" },
      {
        name: "tier",
        type: "tuple",
        components: [
          { name: "minStakeAmount", type: "uint256" },
          { name: "minDuration", type: "uint256" },
          { name: "grantsNFT721", type: "bool" },
          { name: "grantsNFT1155", type: "bool" },
          { name: "nft1155TokenId", type: "uint256" },
          { name: "name", type: "string" },
        ],
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "removeTier",
    inputs: [{ name: "tierId", type: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  // ─── Events ──────────────────────────────────────────────────────────────
  {
    type: "event",
    name: "Staked",
    inputs: [
      { name: "user", type: "address", indexed: true },
      { name: "amount", type: "uint256", indexed: false },
      { name: "totalStaked", type: "uint256", indexed: false },
    ],
  },
  {
    type: "event",
    name: "Unstaked",
    inputs: [
      { name: "user", type: "address", indexed: true },
      { name: "amount", type: "uint256", indexed: false },
      { name: "remaining", type: "uint256", indexed: false },
    ],
  },
  {
    type: "event",
    name: "RewardClaimed",
    inputs: [
      { name: "user", type: "address", indexed: true },
      { name: "tierId", type: "uint256", indexed: true },
      { name: "nft721Minted", type: "bool", indexed: false },
      { name: "nft1155Minted", type: "bool", indexed: false },
    ],
  },
  {
    type: "event",
    name: "TierUnlocked",
    inputs: [
      { name: "user", type: "address", indexed: true },
      { name: "tierId", type: "uint256", indexed: true },
      { name: "tierName", type: "string", indexed: false },
    ],
  },
  {
    type: "event",
    name: "TierAdded",
    inputs: [
      { name: "tierId", type: "uint256", indexed: true },
      { name: "name", type: "string", indexed: false },
    ],
  },
  {
    type: "event",
    name: "TierUpdated",
    inputs: [
      { name: "tierId", type: "uint256", indexed: true },
      { name: "name", type: "string", indexed: false },
    ],
  },
  {
    type: "event",
    name: "TierRemoved",
    inputs: [{ name: "tierId", type: "uint256", indexed: true }],
  },
] as const;
