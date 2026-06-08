"use client";

import { useAccount, useChainId } from "wagmi";
import { hardhat, sepolia } from "wagmi/chains";
import { CONTRACTS } from "@/config/contracts";

function shortAddress(address?: string) {
  if (!address) return "Not connected";
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

function shortContract(address: `0x${string}`) {
  if (!address || /^0x0{40}$/i.test(address)) return "Not set";
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

function chainLabel(chainId?: number) {
  if (!chainId) return "Unknown";
  if (chainId === hardhat.id) return `Hardhat/Anvil (${chainId})`;
  if (chainId === sepolia.id) return `Sepolia (${chainId})`;
  return `Unsupported (${chainId})`;
}

function statusPill(ok: boolean) {
  return ok
    ? "inline-flex items-center px-2 py-0.5 rounded-full text-xs bg-emerald-500/20 text-emerald-300"
    : "inline-flex items-center px-2 py-0.5 rounded-full text-xs bg-red-500/20 text-red-300";
}

export function NetworkStatusBanner() {
  const { isConnected, address } = useAccount();
  const chainId = useChainId();

  const isSupportedNetwork = chainId === hardhat.id || chainId === sepolia.id;

  const contracts = [
    { key: "Vault", value: CONTRACTS.stakingVault },
    { key: "Token", value: CONTRACTS.stakingToken },
    { key: "NFT", value: CONTRACTS.rewardNFT },
    { key: "Badge", value: CONTRACTS.rewardBadge },
  ] as const;

  const areContractsConfigured = contracts.every(({ value }) => !/^0x0{40}$/i.test(value));

  return (
    <div className="bg-gray-800/50 border border-gray-700 rounded-xl p-4">
      <div className="flex flex-wrap items-center gap-2 mb-3">
        <span className="text-sm font-semibold text-white">Network & Contract Status</span>
        <span className={statusPill(isConnected)}>{isConnected ? "Wallet Connected" : "Wallet Disconnected"}</span>
        <span className={statusPill(isSupportedNetwork)}>{isSupportedNetwork ? "Supported Network" : "Unsupported Network"}</span>
        <span className={statusPill(areContractsConfigured)}>
          {areContractsConfigured ? "Contracts Configured" : "Contracts Missing"}
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 text-sm">
        <div className="bg-gray-900/70 border border-gray-700 rounded-lg p-3">
          <p className="text-gray-400">Wallet</p>
          <p className="text-white font-medium">{shortAddress(address)}</p>
        </div>

        <div className="bg-gray-900/70 border border-gray-700 rounded-lg p-3">
          <p className="text-gray-400">Network</p>
          <p className="text-white font-medium">{chainLabel(chainId)}</p>
        </div>

        <div className="bg-gray-900/70 border border-gray-700 rounded-lg p-3">
          <p className="text-gray-400">Vault</p>
          <p className="text-white font-medium">{shortContract(CONTRACTS.stakingVault)}</p>
        </div>

        <div className="bg-gray-900/70 border border-gray-700 rounded-lg p-3">
          <p className="text-gray-400">Token</p>
          <p className="text-white font-medium">{shortContract(CONTRACTS.stakingToken)}</p>
        </div>

        <div className="bg-gray-900/70 border border-gray-700 rounded-lg p-3">
          <p className="text-gray-400">NFT</p>
          <p className="text-white font-medium">{shortContract(CONTRACTS.rewardNFT)}</p>
        </div>

        <div className="bg-gray-900/70 border border-gray-700 rounded-lg p-3">
          <p className="text-gray-400">Badge</p>
          <p className="text-white font-medium">{shortContract(CONTRACTS.rewardBadge)}</p>
        </div>
      </div>
    </div>
  );
}
