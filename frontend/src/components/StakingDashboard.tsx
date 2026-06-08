"use client";

import { formatEther } from "viem";
import { useStakeInfo, useUserTier, useStakeDuration, useTotalStaked, useTokenBalance } from "@/hooks/useStaking";

function formatDuration(seconds: bigint): string {
  const s = Number(seconds);
  const days = Math.floor(s / 86400);
  const hours = Math.floor((s % 86400) / 3600);
  const mins = Math.floor((s % 3600) / 60);

  if (days > 0) return `${days}d ${hours}h ${mins}m`;
  if (hours > 0) return `${hours}h ${mins}m`;
  return `${mins}m`;
}

export function StakingDashboard() {
  const { amount, isLoading } = useStakeInfo();
  const { eligible, tierName } = useUserTier();
  const { duration } = useStakeDuration();
  const { totalStaked } = useTotalStaked();
  const { balance } = useTokenBalance();

  if (isLoading) {
    return <div className="animate-pulse bg-gray-800 rounded-xl h-48" />;
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {/* Wallet Balance */}
      <StatCard
        label="Wallet Balance"
        value={`${Number(formatEther(balance)).toLocaleString()} tokens`}
      />

      {/* Your Stake */}
      <StatCard
        label="Your Stake"
        value={`${Number(formatEther(amount)).toLocaleString()} tokens`}
      />

      {/* Staking Duration */}
      <StatCard
        label="Staking Duration"
        value={amount > BigInt(0) ? formatDuration(duration) : "—"}
      />

      {/* Current Tier */}
      <StatCard
        label="Current Tier"
        value={eligible ? tierName : "None"}
        highlight={eligible}
      />

      {/* Total Value Locked */}
      <StatCard
        label="Total Value Locked"
        value={`${Number(formatEther(totalStaked)).toLocaleString()} tokens`}
      />
    </div>
  );
}

function StatCard({ label, value, highlight }: { label: string; value: string; highlight?: boolean }) {
  return (
    <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-5">
      <p className="text-sm text-gray-400 mb-1">{label}</p>
      <p className={`text-xl font-semibold ${highlight ? "text-brand-400" : "text-white"}`}>
        {value}
      </p>
    </div>
  );
}
