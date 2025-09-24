#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Get current ZKC epoch
# ----------------------------------------------------------------------
# Wraps `boundless zkc get-current-epoch`
# ----------------------------------------------------------------------
# Requirements:
# - `boundless` CLI installed
# - Environment variables defined inline or via `.env.povw`
# ----------------------------------------------------------------------
# Required ENV:
#   RPC_URL             : Ethereum mainnet RPC endpoint
# ----------------------------------------------------------------------
# Usage:
#   export RPC_URL=https://mainnet.example
#   ./scripts/zkc-get-current-epoch.sh
# ----------------------------------------------------------------------

# Load env file if present
if [ -f ".env.povw" ]; then
  # shellcheck disable=SC1091
  source .env.povw
fi

if [[ -z "${RPC_URL:-}" ]]; then
  echo "Error: Missing required environment variable RPC_URL." >&2
  echo "This can also be defined in .env.povw" >&2
  exit 1
fi

echo "🚀 Getting current ZKC epoch..."
boundless zkc get-current-epoch --rpc-url "$RPC_URL"