"use client";

import { AppShell } from "@/components/AppShell";
import { ConnectRequired } from "@/components/ConnectRequired";
import { TierList } from "@/components/TierList";

export default function TiersPage() {
  return (
    <AppShell title="Reward Tiers" subtitle="View tier requirements and claimable rewards.">
      <ConnectRequired>
        <TierList />
      </ConnectRequired>
    </AppShell>
  );
}
