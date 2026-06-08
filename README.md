# Open Stake

Open Stake is a full-stack staking dApp:
- **Smart contracts (Foundry)** for staking, tiers, and rewards
- **Frontend (Next.js + wagmi + ConnectKit)** to interact with contracts from a wallet

Users stake ERC-20 tokens and unlock rewards over time (ERC-721, ERC-1155, and tier progression).

---

## What’s in this repo

### Contracts (`/` root)
- `src/StakeToken.sol` – test ERC-20 token (optional)
- `src/TierManager.sol` – configurable tier logic
- `src/RewardNFT721.sol` – unique NFT rewards
- `src/RewardBadge1155.sol` – badge rewards
- `src/StakingVault.sol` – core staking contract
- `script/Deploy.s.sol` – deployment script
- `script/set_frontend_env.sh` – writes `frontend/.env.local` from CLI flags
- `test/StakingVault.t.sol` – contract tests

### Frontend (`/frontend`)
- Next.js app using:
  - `wagmi`
  - `connectkit`
  - `viem`
- Supports:
  - Connect wallet
  - Stake / unstake
  - Claim rewards
  - View tiers, status, and network + contract banner

---

## Supported chains

The frontend is configured for:
- **Hardhat/Anvil local chain** (chain id `31337`, RPC `http://127.0.0.1:8545`)
- **Sepolia testnet** (chain id `11155111`)

Config is in `frontend/src/config/wagmi.ts`.

---

## Prerequisites

Install these first:

- **Git**
- **Node.js 18+** (recommended: Node 20)
- **npm**
- **Foundry** (`forge`, `cast`, `anvil`)

Install Foundry:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Verify:

```bash
forge --version
cast --version
anvil --version
node -v
npm -v
```

---

## 1) Clone and install

```bash
git clone <your-repo-url> open-stake
cd open-stake

# install solidity deps (openzeppelin + forge-std)
forge install

# compile contracts
forge build

# run contract tests
forge test -vvv
```

---

## 2) Create wallet(s)

You need at least one EVM wallet (MetaMask recommended).

### For local development (Anvil)
You can use Anvil’s pre-funded test accounts.

1. Start Anvil:
   ```bash
   anvil
   ```
2. Copy one of the printed private keys (test only).
3. Import that private key into MetaMask.
4. Add custom network in MetaMask:
   - Network name: `Anvil Local`
   - RPC URL: `http://127.0.0.1:8545`
   - Chain ID: `31337`
   - Currency symbol: `ETH`

### For Sepolia
1. Create/import wallet in MetaMask.
2. Switch to **Sepolia** network.
3. Fund wallet with Sepolia ETH from a faucet.

---

## 3) Deploy contracts

The deploy script reads:
- `PRIVATE_KEY` (required)
- `STAKING_TOKEN` (optional – use existing ERC20)
- `BADGE_URI` (optional)

### Option A: Deploy to local Anvil

With Anvil running in one terminal, in another terminal:

```bash
cd open-stake

PRIVATE_KEY=<ANVIL_PRIVATE_KEY> forge script script/Deploy.s.sol \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast
```

### Option B: Deploy to Sepolia

```bash
cd open-stake

PRIVATE_KEY=<YOUR_SEPOLIA_PRIVATE_KEY> forge script script/Deploy.s.sol \
  --rpc-url <SEPOLIA_RPC_URL> \
  --broadcast
```

After deploy, save these addresses from logs:
- `StakingVault deployed: ...`
- `StakeToken deployed: ...` (unless using existing token)
- `RewardNFT721 deployed: ...`
- `RewardBadge1155 deployed: ...`

---

## 4) Configure frontend env

Go to frontend:

```bash
cd open-stake/frontend
```

Create `.env.local` from example:

```bash
cp .env.example .env.local
```

Edit `.env.local`:

```dotenv
NEXT_PUBLIC_VAULT_ADDRESS=0x...
NEXT_PUBLIC_TOKEN_ADDRESS=0x...
NEXT_PUBLIC_NFT_ADDRESS=0x...
NEXT_PUBLIC_BADGE_ADDRESS=0x...
NEXT_PUBLIC_WC_PROJECT_ID=...
```

### Where to get `NEXT_PUBLIC_WC_PROJECT_ID`
Create a WalletConnect Cloud project:
- https://cloud.walletconnect.com

Use the project ID in `.env.local`.

> If addresses are missing/zero, the app’s status banner will show **Contracts Missing**.

### Bash helper script (recommended)

Instead of editing `frontend/.env.local` manually, you can generate it with:

```bash
cd open-stake

bash script/set_frontend_env.sh \
  --vault 0x... \
  --token 0x... \
  --nft 0x... \
  --badge 0x... \
  --wc YOUR_WALLETCONNECT_PROJECT_ID
```

This writes `frontend/.env.local` with:
- `NEXT_PUBLIC_VAULT_ADDRESS`
- `NEXT_PUBLIC_TOKEN_ADDRESS`
- `NEXT_PUBLIC_NFT_ADDRESS`
- `NEXT_PUBLIC_BADGE_ADDRESS`
- `NEXT_PUBLIC_WC_PROJECT_ID`

Optional: make it executable so you can run `./script/set_frontend_env.sh` directly:

```bash
chmod +x script/set_frontend_env.sh
```

Common errors:
- `Missing one or more required addresses.` → include all required flags: `--vault`, `--token`, `--nft`, `--badge`
- `Unknown argument: ...` → check for typos in flag names
- Env values not reflected in UI → restart frontend dev server after rewriting `.env.local`

---

## 5) Install and run frontend

```bash
cd open-stake/frontend
npm install
npm run dev
```

Open: `http://localhost:3000`

You should see:
- Header + connect wallet CTA
- Network + contract status banner
- Route cards to the main app pages after connecting

### Frontend routes

- `/` – Home (entry page with route cards)
- `/dashboard` – Wallet/stake/tier overview
- `/stake` – Stake and unstake form
- `/tiers` – Tier requirements + claiming UI
- `/admin` – Owner-only admin panel

Production build check:

```bash
npm run build
npm run start
```

---

## 6) First-time user flow (manual test)

1. Connect wallet
2. Ensure wallet network matches deployment chain:
   - local `31337` or
   - Sepolia `11155111`
3. If using local token contract, make sure wallet has stake tokens
   - For local, you can mint via contract owner (or script/cast)
4. Stake tokens in UI
5. Wait/warp time as needed for tiers
6. Claim rewards
7. Unstake and verify balances/status update

---

## 7) Admin flow

Admin = contract owner (deployer by default).

Admin can:
- Add tier
- Update tier
- Remove tier

You can do this from:
- Frontend admin panel (owner-only)
- or `cast` commands

Example `cast` add tier:

```bash
cast send <VAULT_ADDRESS> \
  "addTier((uint256,uint256,bool,bool,uint256,string))" \
  "(1000000000000000000000,2592000,false,true,4,Platinum)" \
  --rpc-url <RPC> --private-key <ADMIN_PRIVATE_KEY>
```

---

## 8) Useful commands

### Contracts

```bash
# compile
forge build

# tests
forge test -vvv

# gas
forge test --gas-report
```

### Frontend

```bash
# dev
npm run dev

# typecheck + production build
npm run build

# start prod build
npm run start
```

---

## 9) Share this project with others (teammate checklist)

When someone else clones the repo, they need:

1. Node + npm + Foundry installed
2. Wallet installed (MetaMask)
3. Access to deployed contract addresses
4. Their own `frontend/.env.local` with:
   - `NEXT_PUBLIC_VAULT_ADDRESS`
   - `NEXT_PUBLIC_TOKEN_ADDRESS`
   - `NEXT_PUBLIC_NFT_ADDRESS`
   - `NEXT_PUBLIC_BADGE_ADDRESS`
   - `NEXT_PUBLIC_WC_PROJECT_ID`
5. Correct network selected in wallet
6. Test ETH (if Sepolia)

Quick teammate setup:

```bash
git clone <repo>
cd open-stake
forge build
cd frontend
npm install
cp .env.example .env.local
# fill in values
npm run dev
```

---

## 10) Troubleshooting

### “No CTA button / blank-looking connect screen”
- Use the center **Connect Wallet** CTA in disconnected state.
- If wallet modal doesn’t open, verify `NEXT_PUBLIC_WC_PROJECT_ID` is set.

### “Unsupported Network”
- Switch wallet to `31337` (local) or `11155111` (Sepolia).

### “Contracts Missing”
- One or more `NEXT_PUBLIC_*_ADDRESS` values are empty/zero.
- Re-check `.env.local` and restart dev server.

### Contract reads/writes fail
- Wrong chain selected for deployed addresses.
- Wallet not connected.
- Not enough gas/test ETH.
- Token not approved before staking.

### npm script warnings (`approve-scripts`)
This repo already contains allowed script entries in `frontend/package.json`. If needed:

```bash
cd frontend
npm approve-scripts --allow-scripts-pending
```

---

## Security notes

- Never expose real mainnet private keys in env files or commits.
- Use throwaway keys for local dev.
- For production, use multisig/timelock for admin actions.

---

## License

MIT
