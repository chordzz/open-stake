"use client";

import { ConnectKitButton } from "connectkit";
import { useAccount } from "wagmi";

export function ConnectRequired({ children }: { children: React.ReactNode }) {
  const { isConnected } = useAccount();

  if (!isConnected) {
    return (
      <div className="text-center py-16">
        <h2 className="text-xl text-gray-300 mb-2">Connect your wallet to continue</h2>
        <p className="text-gray-500 text-sm">This page requires a connected wallet.</p>
        <div className="mt-6 flex items-center justify-center">
          <ConnectKitButton.Custom>
            {({ isConnecting, show }) => (
              <button
                onClick={show}
                className="px-5 py-3 rounded-lg bg-brand-600 hover:bg-brand-700 text-white font-semibold transition-colors"
              >
                {isConnecting ? "Opening wallet..." : "Connect Wallet"}
              </button>
            )}
          </ConnectKitButton.Custom>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
