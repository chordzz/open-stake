"use client";

import { AppShell } from "@/components/AppShell";
import { ConnectRequired } from "@/components/ConnectRequired";
import { StakeForm } from "@/components/StakeForm";

export default function StakePage() {
  return (
    <AppShell title="Stake / Unstake" subtitle="Manage your staking position and token approvals.">
      <ConnectRequired>
        <div className="max-w-2xl">
          <StakeForm />
        </div>
      </ConnectRequired>
    </AppShell>
  );
}
