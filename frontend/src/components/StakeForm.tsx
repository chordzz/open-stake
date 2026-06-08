"use client";

import { useState } from "react";
import { formatEther, parseEther } from "viem";
import {
  useApprove,
  useStake,
  useUnstake,
  useTokenBalance,
  useTokenAllowance,
  useStakeInfo,
} from "@/hooks/useStaking";

export function StakeForm() {
  const [amount, setAmount] = useState("");
  const [mode, setMode] = useState<"stake" | "unstake">("stake");

  const { balance } = useTokenBalance();
  const { allowance } = useTokenAllowance();
  const { amount: stakedAmount } = useStakeInfo();

  const { approve, isPending: approving, isConfirming: confirmingApproval } = useApprove();
  const { stake, isPending: staking, isConfirming: confirmingStake } = useStake();
  const { unstake, isPending: unstaking, isConfirming: confirmingUnstake } = useUnstake();

  let parsedAmount = BigInt(0);
  let hasParseError = false;
  try {
    parsedAmount = amount ? parseEther(amount) : BigInt(0);
  } catch {
    hasParseError = true;
    parsedAmount = BigInt(0);
  }

  const maxAmount = mode === "stake" ? balance : stakedAmount;

  const needsApproval = mode === "stake" && parsedAmount > allowance;
  const exceedsMax = !!amount && !hasParseError && parsedAmount > maxAmount;
  const isNonPositive = !!amount && !hasParseError && parsedAmount <= BigInt(0);

  let validationMessage = "";
  if (!amount) {
    validationMessage = "Enter an amount.";
  } else if (hasParseError) {
    validationMessage = "Invalid amount format.";
  } else if (isNonPositive) {
    validationMessage = "Amount must be greater than 0.";
  } else if (exceedsMax) {
    validationMessage = mode === "stake" ? "Amount exceeds wallet balance." : "Amount exceeds staked balance.";
  } else if (mode === "stake" && needsApproval) {
    validationMessage = "Approval required before staking this amount.";
  }

  const hasValidationError = !!amount && (hasParseError || isNonPositive || exceedsMax);

  const isLoading = approving || confirmingApproval || staking || confirmingStake || unstaking || confirmingUnstake;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!amount || hasParseError || parsedAmount <= BigInt(0) || parsedAmount > maxAmount) return;

    if (mode === "stake") {
      if (needsApproval) {
        approve(amount);
      } else {
        stake(amount);
      }
    } else {
      unstake(amount);
    }
  };

  return (
    <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-6">
      <div className="flex gap-2 mb-5">
        <button
          onClick={() => setMode("stake")}
          className={`flex-1 py-2 px-4 rounded-lg font-medium transition-colors ${
            mode === "stake"
              ? "bg-brand-600 text-white"
              : "bg-gray-700 text-gray-300 hover:bg-gray-600"
          }`}
        >
          Stake
        </button>
        <button
          onClick={() => setMode("unstake")}
          className={`flex-1 py-2 px-4 rounded-lg font-medium transition-colors ${
            mode === "unstake"
              ? "bg-red-600 text-white"
              : "bg-gray-700 text-gray-300 hover:bg-gray-600"
          }`}
        >
          Unstake
        </button>
      </div>

      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label className="text-sm text-gray-400 block mb-1">
            Amount ({mode === "stake" ? "available" : "staked"}:{" "}
            {Number(formatEther(maxAmount)).toLocaleString()})
          </label>
          <div className="flex gap-2">
            <input
              type="number"
              step="any"
              min="0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="0.0"
              className={`flex-1 bg-gray-900 border rounded-lg px-4 py-3 text-white placeholder-gray-500 focus:outline-none ${
                hasValidationError
                  ? "border-red-500 focus:border-red-500"
                  : "border-gray-600 focus:border-brand-500"
              }`}
            />
            <button
              type="button"
              onClick={() => setAmount(formatEther(maxAmount))}
              className="px-3 py-3 bg-gray-700 hover:bg-gray-600 rounded-lg text-sm text-gray-300 transition-colors"
            >
              MAX
            </button>
          </div>
          {validationMessage ? (
            <p className={`mt-2 text-sm ${hasValidationError ? "text-red-400" : "text-amber-400"}`}>
              {validationMessage}
            </p>
          ) : null}
        </div>

        <button
          type="submit"
          disabled={isLoading || !amount || hasParseError || parsedAmount <= BigInt(0) || parsedAmount > maxAmount}
          className={`w-full py-3 px-4 rounded-lg font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
            mode === "stake"
              ? "bg-brand-600 hover:bg-brand-700 text-white"
              : "bg-red-600 hover:bg-red-700 text-white"
          }`}
        >
          {isLoading
            ? "Processing..."
            : mode === "stake"
              ? needsApproval
                ? "Approve & Stake"
                : "Stake Tokens"
              : "Unstake Tokens"}
        </button>
      </form>
    </div>
  );
}
