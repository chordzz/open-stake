"use client";

import { useState } from "react";
import { parseEther } from "viem";
import { useAddTier, useRemoveTier, useAllTiers, useIsOwner } from "@/hooks/useStaking";

export function AdminPanel() {
  const { isOwner } = useIsOwner();
  const { tiers, refetch } = useAllTiers();
  const { addTier, isPending: adding, isConfirming: confirmingAdd } = useAddTier();
  const { removeTier, isPending: removing, isConfirming: confirmingRemove } = useRemoveTier();

  const [form, setForm] = useState({
    name: "",
    minStakeAmount: "",
    minDuration: "",
    grantsNFT721: false,
    grantsNFT1155: false,
    nft1155TokenId: "0",
  });

  if (!isOwner) {
    return null;
  }

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();

    addTier({
      minStakeAmount: parseEther(form.minStakeAmount),
      minDuration: BigInt(Number(form.minDuration) * 86400), // days to seconds
      grantsNFT721: form.grantsNFT721,
      grantsNFT1155: form.grantsNFT1155,
      nft1155TokenId: BigInt(form.nft1155TokenId),
      name: form.name,
    });

    setForm({
      name: "",
      minStakeAmount: "",
      minDuration: "",
      grantsNFT721: false,
      grantsNFT1155: false,
      nft1155TokenId: "0",
    });
  };

  const handleRemove = (tierId: number) => {
    if (confirm(`Remove tier ${tierId}? This will swap with the last tier.`)) {
      removeTier(BigInt(tierId));
    }
  };

  const isLoading = adding || confirmingAdd || removing || confirmingRemove;

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <h2 className="text-lg font-semibold text-white">Admin Panel</h2>
        <span className="text-xs bg-yellow-900/50 text-yellow-300 px-2 py-0.5 rounded">
          Owner
        </span>
      </div>

      {/* Add Tier Form */}
      <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-6">
        <h3 className="text-md font-medium text-white mb-4">Add New Tier</h3>
        <form onSubmit={handleAdd} className="space-y-3">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div>
              <label className="text-xs text-gray-400 block mb-1">Tier Name</label>
              <input
                type="text"
                value={form.name}
                onChange={(e) => setForm({ ...form, name: e.target.value })}
                placeholder="e.g. Diamond"
                required
                className="w-full bg-gray-900 border border-gray-600 rounded-lg px-3 py-2 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-brand-500"
              />
            </div>
            <div>
              <label className="text-xs text-gray-400 block mb-1">Min Stake (tokens)</label>
              <input
                type="number"
                step="any"
                min="0"
                value={form.minStakeAmount}
                onChange={(e) => setForm({ ...form, minStakeAmount: e.target.value })}
                placeholder="1000"
                required
                className="w-full bg-gray-900 border border-gray-600 rounded-lg px-3 py-2 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-brand-500"
              />
            </div>
            <div>
              <label className="text-xs text-gray-400 block mb-1">Min Duration (days)</label>
              <input
                type="number"
                min="0"
                value={form.minDuration}
                onChange={(e) => setForm({ ...form, minDuration: e.target.value })}
                placeholder="30"
                required
                className="w-full bg-gray-900 border border-gray-600 rounded-lg px-3 py-2 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-brand-500"
              />
            </div>
            <div>
              <label className="text-xs text-gray-400 block mb-1">ERC-1155 Token ID</label>
              <input
                type="number"
                min="0"
                value={form.nft1155TokenId}
                onChange={(e) => setForm({ ...form, nft1155TokenId: e.target.value })}
                className="w-full bg-gray-900 border border-gray-600 rounded-lg px-3 py-2 text-white text-sm placeholder-gray-500 focus:outline-none focus:border-brand-500"
              />
            </div>
          </div>

          <div className="flex gap-4">
            <label className="flex items-center gap-2 text-sm text-gray-300 cursor-pointer">
              <input
                type="checkbox"
                checked={form.grantsNFT721}
                onChange={(e) => setForm({ ...form, grantsNFT721: e.target.checked })}
                className="rounded border-gray-600 bg-gray-900"
              />
              Grants NFT-721
            </label>
            <label className="flex items-center gap-2 text-sm text-gray-300 cursor-pointer">
              <input
                type="checkbox"
                checked={form.grantsNFT1155}
                onChange={(e) => setForm({ ...form, grantsNFT1155: e.target.checked })}
                className="rounded border-gray-600 bg-gray-900"
              />
              Grants ERC-1155 Badge
            </label>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full py-2.5 px-4 bg-brand-600 hover:bg-brand-700 text-white font-medium rounded-lg transition-colors disabled:opacity-50"
          >
            {isLoading ? "Processing..." : "Add Tier"}
          </button>
        </form>
      </div>

      {/* Existing Tiers Management */}
      {tiers && tiers.length > 0 && (
        <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-6">
          <h3 className="text-md font-medium text-white mb-4">Manage Existing Tiers</h3>
          <div className="space-y-2">
            {tiers.map((tier, idx) => (
              <div key={idx} className="flex items-center justify-between bg-gray-900/50 rounded-lg px-4 py-3">
                <div>
                  <span className="text-white font-medium">{tier.name}</span>
                  <span className="text-gray-400 text-sm ml-2">(ID: {idx})</span>
                </div>
                <button
                  onClick={() => handleRemove(idx)}
                  disabled={isLoading}
                  className="px-3 py-1 bg-red-900/50 hover:bg-red-800/50 text-red-300 text-sm rounded-lg transition-colors disabled:opacity-50"
                >
                  Remove
                </button>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
