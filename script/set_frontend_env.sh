#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash script/set_frontend_env.sh \
    --vault 0x... \
    --token 0x... \
    --nft 0x... \
    --badge 0x... \
    [--wc YOUR_WALLETCONNECT_PROJECT_ID]

This writes frontend/.env.local for the Next.js app.
EOF
}

VAULT=""
TOKEN=""
NFT=""
BADGE=""
WC=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault) VAULT="$2"; shift 2 ;;
    --token) TOKEN="$2"; shift 2 ;;
    --nft) NFT="$2"; shift 2 ;;
    --badge) BADGE="$2"; shift 2 ;;
    --wc) WC="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$VAULT" || -z "$TOKEN" || -z "$NFT" || -z "$BADGE" ]]; then
  echo "Missing one or more required addresses."
  usage
  exit 1
fi

cat > frontend/.env.local <<EOF
NEXT_PUBLIC_VAULT_ADDRESS=$VAULT
NEXT_PUBLIC_TOKEN_ADDRESS=$TOKEN
NEXT_PUBLIC_NFT_ADDRESS=$NFT
NEXT_PUBLIC_BADGE_ADDRESS=$BADGE
NEXT_PUBLIC_WC_PROJECT_ID=$WC
EOF

echo "Wrote frontend/.env.local"
