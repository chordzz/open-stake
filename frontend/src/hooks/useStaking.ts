"use client";

import { useReadContract, useWriteContract, useWaitForTransactionReceipt, useAccount } from "wagmi";
import { parseEther } from "viem";
import { stakingVaultAbi } from "@/abi/stakingVault";
import { erc20Abi } from "@/abi/erc20";
import { CONTRACTS } from "@/config/contracts";

// ─── Read Hooks ────────────────────────────────────────────────────────────────

export function useStakeInfo() {
  const { address } = useAccount();

  const { data, refetch, isLoading } = useReadContract({
    address: CONTRACTS.stakingVault,
    abi: stakingVaultAbi,
    functionName: "stakes",
    args: address ? [address] : undefined,
    query: { enabled: !!address },
  });

  return {
    amount: data?.[0] ?? BigInt(0),
    stakedAt: data?.[1] ?? BigInt(0),
    lastClaimedTier: data?.[2] ?? BigInt(0),
    refetch,
    isLoading,
  };
}

export function useUserTier() {
  const { address } = useAccount();

  const { data, refetch, isLoading } = useReadContract({
    address: CONTRACTS.stakingVault,
    abi: stakingVaultAbi,
    functionName: "getUserTier",
    args: address ? [address] : undefined,
    query: { enabled: !!address },
  });

  return {
    tierId: data?.[0],
    eligible: data?.[1] ?? false,
    tierName: data?.[2] ?? "",
    refetch,
    isLoading,
  };
}

export function useStakeDuration() {
  const { address } = useAccount();

  const { data, refetch } = useReadContract({
    address: CONTRACTS.stakingVault,
    abi: stakingVaultAbi,
    functionName: "getStakeDuration",
    args: address ? [address] : undefined,
    query: { enabled: !!address },
  });

  return { duration: data ?? BigInt(0), refetch };
}

export function useClaimableTiers() {
  const { address } = useAccount();

  const { data, refetch, isLoading } = useReadContract({
    address: CONTRACTS.stakingVault,
    abi: stakingVaultAbi,
    functionName: "getClaimableTiers",
    args: address ? [address] : undefined,
    query: { enabled: !!address },
  });

  return { tierIds: data ?? [], refetch, isLoading };
}

export function useAllTiers() {
  const { data, refetch, isLoading } = useReadContract({
    address: CONTRACTS.stakingVault,
    abi: stakingVaultAbi,
    functionName: "getAllTiers",
  });

  return { tiers: data ?? [], refetch, isLoading };
}

export function useTotalStaked() {
  const { data, refetch } = useReadContract({
    address: CONTRACTS.stakingVault,
    abi: stakingVaultAbi,
    functionName: "totalStaked",
  });

  return { totalStaked: data ?? BigInt(0), refetch };
}

export function useTokenBalance() {
  const { address } = useAccount();

  const { data, refetch } = useReadContract({
    address: CONTRACTS.stakingToken,
    abi: erc20Abi,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
    query: { enabled: !!address },
  });

  return { balance: data ?? BigInt(0), refetch };
}

export function useTokenAllowance() {
  const { address } = useAccount();

  const { data, refetch } = useReadContract({
    address: CONTRACTS.stakingToken,
    abi: erc20Abi,
    functionName: "allowance",
    args: address ? [address, CONTRACTS.stakingVault] : undefined,
    query: { enabled: !!address },
  });

  return { allowance: data ?? BigInt(0), refetch };
}

export function useIsOwner() {
  const { address } = useAccount();

  const { data } = useReadContract({
    address: CONTRACTS.stakingVault,
    abi: stakingVaultAbi,
    functionName: "owner",
  });

  return { isOwner: !!address && data?.toLowerCase() === address.toLowerCase() };
}

// ─── Write Hooks ───────────────────────────────────────────────────────────────

export function useApprove() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const approve = (amount: string) => {
    writeContract({
      address: CONTRACTS.stakingToken,
      abi: erc20Abi,
      functionName: "approve",
      args: [CONTRACTS.stakingVault, parseEther(amount)],
    });
  };

  return { approve, isPending, isConfirming, isSuccess, hash };
}

export function useStake() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const stake = (amount: string) => {
    writeContract({
      address: CONTRACTS.stakingVault,
      abi: stakingVaultAbi,
      functionName: "stake",
      args: [parseEther(amount)],
    });
  };

  return { stake, isPending, isConfirming, isSuccess, hash };
}

export function useUnstake() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const unstake = (amount: string) => {
    writeContract({
      address: CONTRACTS.stakingVault,
      abi: stakingVaultAbi,
      functionName: "unstake",
      args: [parseEther(amount)],
    });
  };

  return { unstake, isPending, isConfirming, isSuccess, hash };
}

export function useClaimReward() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const claim = () => {
    writeContract({
      address: CONTRACTS.stakingVault,
      abi: stakingVaultAbi,
      functionName: "claimReward",
    });
  };

  return { claim, isPending, isConfirming, isSuccess, hash };
}

export function useClaimSpecificTier() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const claimTier = (tierId: bigint) => {
    writeContract({
      address: CONTRACTS.stakingVault,
      abi: stakingVaultAbi,
      functionName: "claimSpecificTier",
      args: [tierId],
    });
  };

  return { claimTier, isPending, isConfirming, isSuccess, hash };
}

// ─── Admin Write Hooks ─────────────────────────────────────────────────────────

export function useAddTier() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const addTier = (tier: {
    minStakeAmount: bigint;
    minDuration: bigint;
    grantsNFT721: boolean;
    grantsNFT1155: boolean;
    nft1155TokenId: bigint;
    name: string;
  }) => {
    writeContract({
      address: CONTRACTS.stakingVault,
      abi: stakingVaultAbi,
      functionName: "addTier",
      args: [tier],
    });
  };

  return { addTier, isPending, isConfirming, isSuccess, hash };
}

export function useRemoveTier() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const removeTier = (tierId: bigint) => {
    writeContract({
      address: CONTRACTS.stakingVault,
      abi: stakingVaultAbi,
      functionName: "removeTier",
      args: [tierId],
    });
  };

  return { removeTier, isPending, isConfirming, isSuccess, hash };
}
