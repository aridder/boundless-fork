#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Submit PoVW work log update onchain
# ----------------------------------------------------------------------
# Wraps `boundless povw submit`
# ----------------------------------------------------------------------
# Requirements:
# - `boundless` CLI installed
# - Environment variables defined inline or via `.env.povw-submit`
# - State file created with povw-prepare
# ----------------------------------------------------------------------
# Required ENV:
#   STATE_FILE_LOCATION : Path to the state file created by prepare
#   RPC_URL             : Ethereum mainnet RPC endpoint
#   PRIVATE_KEY         : Private key corresponding to POVW_LOG_ID
# ----------------------------------------------------------------------
# Usage:
#   export STATE_FILE_LOCATION=/home/aridder/state.bin
#   export RPC_URL=https://mainnet.example
#   export PRIVATE_KEY=abcdef1234...
#   ./scripts/povw-submit.sh
# ----------------------------------------------------------------------

# Load env file if present
if [ -f ".env.povw-submit" ]; then
  # shellcheck disable=SC1091
  source .env.povw-submit
fi

if [[ -z "${STATE_FILE_LOCATION:-}" ]] || [[ -z "${RPC_URL:-}" ]] || [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Need STATE_FILE_LOCATION, RPC_URL, and PRIVATE_KEY." >&2
  echo "These can also be defined in .env.povw-submit" >&2
  exit 1
fi

echo "🚀 Submitting work log update from $STATE_FILE_LOCATION..."
boundless povw submit \
  --state "$STATE_FILE_LOCATION" \
  --rpc-url "$RPC_URL"