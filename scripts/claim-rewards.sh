#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Claim PoVW rewards on Ethereum mainnet
# ----------------------------------------------------------------------
# Wraps `boundless povw claim`
# ----------------------------------------------------------------------
# Requirements:
# - `boundless` CLI installed
# - Environment variables defined inline or via `.env.claim-rewards`
# ----------------------------------------------------------------------
# Required ENV:
#   POVW_LOG_ID              : Ethereum Log ID address
#   PRIVATE_KEY              : Private key for the Log ID (without 0x prefix if CLI requires)
#   RPC_URL                  : Ethereum mainnet RPC endpoint
#   BEACON_CHAIN_RPC_ENDPOINT: Beacon chain RPC endpoint for reading finalized epochs
# ----------------------------------------------------------------------
# Usage:
#   export POVW_LOG_ID=0x1234...
#   export PRIVATE_KEY=abcdef1234...   # no 0x prefix
#   export RPC_URL=https://mainnet.example
#   export BEACON_CHAIN_RPC_ENDPOINT=https://beacon.example
#   ./scripts/claim-rewards.sh
# ----------------------------------------------------------------------

# Load env file if present
if [ -f ".env.claim-rewards" ]; then
  # shellcheck disable=SC1091
  source .env.claim-rewards
fi

if [[ -z "${POVW_LOG_ID:-}" ]] || [[ -z "${PRIVATE_KEY:-}" ]] || [[ -z "${RPC_URL:-}" ]] || [[ -z "${BEACON_CHAIN_RPC_ENDPOINT:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Need POVW_LOG_ID, PRIVATE_KEY, RPC_URL, and BEACON_CHAIN_RPC_ENDPOINT." >&2
  echo "These can also be defined in .env.claim-rewards" >&2
  exit 1
fi

echo "🚀 Claiming rewards for log ID $POVW_LOG_ID..."
boundless povw claim \
  --log-id "$POVW_LOG_ID" \
  --beacon-api-url "$BEACON_CHAIN_RPC_ENDPOINT" \
  --rpc-url "$RPC_URL"