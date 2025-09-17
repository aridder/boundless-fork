#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Check $ZKC Balance for an address using `boundless zkc balance`
# ----------------------------------------------------------------------
# Requirements:
# - The `boundless` CLI must be installed and available in PATH
# - Environment variables:
#    ACCOUNT                   : address to query balance for
#    RPC_URL                   : RPC endpoint URL
#    CHAIN_ID                  : chain ID (e.g., 1 for Ethereum, 8453 for Base)
#    ZKC_ADDRESS               : deployed ZKC contract address
#    VEZKC_ADDRESS             : deployed VEZKC contract address
#    STAKING_REWARDS_ADDRESS   : deployed staking rewards contract address
#    PRIVATE_KEY               : optional, if needed by the CLI
#
# Usage:
#   export ACCOUNT=0xYourAddress
#   export RPC_URL="https://mainnet.infura.io/v3/YOUR_KEY"
#   export CHAIN_ID=8453
#   export ZKC_ADDRESS=0x...
#   export VEZKC_ADDRESS=0x...
#   export STAKING_REWARDS_ADDRESS=0x...
#   ./scripts/zkc-balance.sh
# ----------------------------------------------------------------------

# Try loading .env.zkc-balance if present
if [ -f ".env.zkc-balance" ]; then
  # shellcheck disable=SC1091
  source .env.zkc-balance
fi

if [[ -z "${ACCOUNT:-}" ]] || [[ -z "${RPC_URL:-}" ]] || [[ -z "${CHAIN_ID:-}" ]] \
   || [[ -z "${ZKC_ADDRESS:-}" ]] || [[ -z "${VEZKC_ADDRESS:-}" ]] || [[ -z "${STAKING_REWARDS_ADDRESS:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Set ACCOUNT, RPC_URL, CHAIN_ID, ZKC_ADDRESS, VEZKC_ADDRESS, and STAKING_REWARDS_ADDRESS." >&2
  echo "You can configure these in .env.zkc-balance (auto-loaded)." >&2
  exit 1
fi

echo "🔍 Fetching ZKC balance for $ACCOUNT on chain $CHAIN_ID..."
boundless zkc balance \
  "$ACCOUNT" \
  --rpc-url "$RPC_URL" \
  --chain-id "$CHAIN_ID" \
  --zkc-address "$ZKC_ADDRESS" \
  --vezkc-address "$VEZKC_ADDRESS" \
  --staking-rewards-address "$STAKING_REWARDS_ADDRESS" \
  ${PRIVATE_KEY:+--private-key "$PRIVATE_KEY"}