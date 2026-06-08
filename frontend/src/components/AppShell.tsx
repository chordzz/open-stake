"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { ConnectKitButton } from "connectkit";
import { NetworkStatusBanner } from "@/components/NetworkStatusBanner";

const navItems = [
  { href: "/", label: "Home" },
  { href: "/dashboard", label: "Dashboard" },
  { href: "/stake", label: "Stake" },
  { href: "/tiers", label: "Tiers" },
  { href: "/admin", label: "Admin" },
];

export function AppShell({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle: string;
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  return (
    <main className="max-w-5xl mx-auto px-4 py-10">
      <header className="flex flex-col gap-4 mb-8">
        <div className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold text-white">{title}</h1>
            <p className="text-gray-400 text-sm mt-1">{subtitle}</p>
          </div>
          <ConnectKitButton />
        </div>

        <nav className="flex flex-wrap gap-2">
          {navItems.map((item) => {
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`px-3 py-2 rounded-lg text-sm border transition-colors ${
                  active
                    ? "bg-brand-600 border-brand-500 text-white"
                    : "bg-gray-800/60 border-gray-700 text-gray-300 hover:bg-gray-700"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
      </header>

      <section className="mb-8">
        <NetworkStatusBanner />
      </section>

      {children}
    </main>
  );
}
