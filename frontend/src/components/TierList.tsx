"use client";

import { formatEther } from "viem";
import { useAllTiers, useClaimableTiers, useClaimSpecificTier } from "@/hooks/useStaking";

function formatDuration(seconds: bigint): string {
  const s = Number(seconds);
  const days = Math.floor(s / 86400);
  if (days >= 1) return `${days} day${days > 1 ? "s" : ""}`;
  const hours = Math.floor(s / 3600);
  return `${hours} hour${hours > 1 ? "s" : ""}`;
}

export function TierList() {
  const { tiers, isLoading: tiersLoading } = useAllTiers();
  const { tierIds: claimable, isLoading: claimableLoading } = useClaimableTiers();
  const { claimTier, isPending, isConfirming } = useClaimSpecificTier();

  if (tiersLoading) {
    return <div className="animate-pulse bg-gray-800 rounded-xl h-64" />;
  }

  if (!tiers || tiers.length === 0) {
    return (
      <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-6 text-center text-gray-400">
        No tiers configured yet.
      </div>
    );
  }

  const claimableSet = new Set(claimable.map((id) => Number(id)));

  return (
    <div className="space-y-3">
      <h2 className="text-lg font-semibold text-white mb-3">Reward Tiers</h2>
      {tiers.map((tier, index) => {
        const isClaimable = claimableSet.has(index);

        return (
          <div
            key={index}
            className={`border rounded-xl p-5 transition-colors ${
              isClaimable
                ? "border-brand-500/50 bg-brand-900/10"
                : "border-gray-700 bg-gray-800/50"
            }`}
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="text-lg font-semibold text-white">{tier.name}</span>
                <span className="text-xs bg-gray-700 text-gray-300 px-2 py-0.5 rounded">
                  Tier {index}
                </span>
              </div>
              {isClaimable && (
                <button
                  onClick={() => claimTier(BigInt(index))}
                  disabled={isPending || isConfirming}
                  className="px-4 py-1.5 bg-brand-600 hover:bg-brand-700 text-white text-sm font-medium rounded-lg transition-colors disabled:opacity-50"
                >
                  {isPending || isConfirming ? "Claiming..." : "Claim"}
                </button>
              )}
            </div>

            <div className="grid grid-cols-2 gap-2 text-sm">
              <div>
                <span className="text-gray-400">Min Stake: </span>
                <span className="text-white">
                  {Number(formatEther(tier.minStakeAmount)).toLocaleString()} tokens
                </span>
              </div>
              <div>
                <span className="text-gray-400">Min Duration: </span>
                <span className="text-white">{formatDuration(tier.minDuration)}</span>
              </div>
              <div className="col-span-2 flex gap-3 mt-1">
                {tier.grantsNFT721 && (
                  <span className="text-xs bg-purple-900/50 text-purple-300 px-2 py-0.5 rounded">
                    NFT-721
                  </span>
                )}
                {tier.grantsNFT1155 && (
                  <span className="text-xs bg-blue-900/50 text-blue-300 px-2 py-0.5 rounded">
                    Badge #{Number(tier.nft1155TokenId)}
                  </span>
                )}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
