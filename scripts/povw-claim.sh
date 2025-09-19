#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Claim PoVW rewards
# ----------------------------------------------------------------------
# Wraps `boundless povw claim`
# ----------------------------------------------------------------------
# Requirements:
# - `boundless` CLI installed
# - Environment variables defined inline or via `.env.povw`
# ----------------------------------------------------------------------
# Required ENV:
#   POVW_LOG_ID               : The ID of the log to claim rewards for
#   BEACON_CHAIN_RPC_ENDPOINT : Beacon chain RPC endpoint
#   RPC_URL                   : Ethereum mainnet RPC endpoint
# ----------------------------------------------------------------------
# Usage:
#   export POVW_LOG_ID=0x...
#   export BEACON_CHAIN_RPC_ENDPOINT=https://beacon.example
#   export RPC_URL=https://mainnet.example
#   ./scripts/povw-claim.sh
# ----------------------------------------------------------------------

# Load env file if present
if [ -f ".env.povw" ]; then
  # shellcheck disable=SC1091
  source .env.povw
fi

if [[ -z "${POVW_LOG_ID:-}" ]] || [[ -z "${RPC_URL:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Need POVW_LOG_ID, BEACON_CHAIN_RPC_ENDPOINT, and RPC_URL." >&2
  echo "These can also be defined in .env.povw" >&2
  exit 1
fi

echo "🚀 Claiming rewards for log ID $POVW_LOG_ID..."
boundless povw claim \
  --log-id "${POVW_LOG_ID}" \
  --rpc-url "${RPC_URL}" \
  --beacon-api-url "${BEACON_API_URL}"