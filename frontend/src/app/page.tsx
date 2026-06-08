"use client";

import Link from "next/link";
import { AppShell } from "@/components/AppShell";
import { ConnectRequired } from "@/components/ConnectRequired";

export default function Home() {
  return (
    <AppShell title="Open Stake" subtitle="Stake tokens. Unlock tiers. Earn NFTs & badges.">
      <ConnectRequired>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <RouteCard
            href="/dashboard"
            title="Dashboard"
            description="View wallet balance, stake status, duration, and current tier."
          />
          <RouteCard
            href="/stake"
            title="Stake / Unstake"
            description="Approve token spend and manage stake and withdrawals."
          />
          <RouteCard
            href="/tiers"
            title="Reward Tiers"
            description="Check tier requirements and claim available rewards."
          />
          <RouteCard
            href="/admin"
            title="Admin"
            description="Owner-only controls for adding, updating, and removing tiers."
          />
        </div>
      </ConnectRequired>
    </AppShell>
  );
}

function RouteCard({ href, title, description }: { href: string; title: string; description: string }) {
  return (
    <Link
      href={href}
      className="bg-gray-800/50 border border-gray-700 rounded-xl p-5 hover:bg-gray-700/60 transition-colors"
    >
      <h2 className="text-white font-semibold text-lg">{title}</h2>
      <p className="text-gray-400 text-sm mt-1">{description}</p>
    </Link>
  );
}
