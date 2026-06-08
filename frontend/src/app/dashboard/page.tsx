"use client";

import { AppShell } from "@/components/AppShell";
import { ConnectRequired } from "@/components/ConnectRequired";
import { StakingDashboard } from "@/components/StakingDashboard";

export default function DashboardPage() {
  return (
    <AppShell title="Dashboard" subtitle="Overview of your balances, stake, and tier status.">
      <ConnectRequired>
        <StakingDashboard />
      </ConnectRequired>
    </AppShell>
  );
}
