"use client";

import { AppShell } from "@/components/AppShell";
import { ConnectRequired } from "@/components/ConnectRequired";
import { AdminPanel } from "@/components/AdminPanel";

export default function AdminPage() {
  return (
    <AppShell title="Admin" subtitle="Owner-only tier management and protocol controls.">
      <ConnectRequired>
        <AdminPanel />
      </ConnectRequired>
    </AppShell>
  );
}
