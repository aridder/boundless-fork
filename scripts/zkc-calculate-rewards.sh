#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Calculate ZKC rewards
# ----------------------------------------------------------------------
# Wraps `boundless zkc calculate-rewards`
# ----------------------------------------------------------------------
# Requirements:
# - `boundless` CLI installed
# - Environment variables defined inline or via `.env.povw`
# ----------------------------------------------------------------------
# Required ENV:
#   RPC_URL      : Ethereum mainnet RPC endpoint
#   PRIVATE_KEY  : Private key for the account
# ----------------------------------------------------------------------
# Usage:
#   export RPC_URL=https://mainnet.example
#   export PRIVATE_KEY=abcdef1234...
#   ./scripts/zkc-calculate-rewards.sh <ACCOUNT>
# ----------------------------------------------------------------------

# Load env file if present
if [ -f ".env.povw" ]; then
  # shellcheck disable=SC1091
  source .env.povw
fi

if [[ -z "${RPC_URL:-}" ]] || [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Need RPC_URL and PRIVATE_KEY." >&2
  echo "These can also be defined in .env.povw" >&2
  exit 1
fi

echo "🚀 Calculating ZKC rewards for account $POVW_LOG_ID..."
boundless zkc calculate-rewards --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" "$POVW_LOG_ID"