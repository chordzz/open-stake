import { getDefaultConfig } from "connectkit";
import { createConfig, http } from "wagmi";
import { hardhat, sepolia } from "wagmi/chains";

// Use Anvil/Hardhat local chain for development, Sepolia for testnet
export const config = createConfig(
  getDefaultConfig({
    chains: [hardhat, sepolia],
    transports: {
      [hardhat.id]: http("http://127.0.0.1:8545"),
      [sepolia.id]: http(),
    },
    walletConnectProjectId: process.env.NEXT_PUBLIC_WC_PROJECT_ID || "",
    appName: "Open Stake",
    appDescription: "Stake tokens, unlock tiered rewards",
  })
);

declare module "wagmi" {
  interface Register {
    config: typeof config;
  }
}
