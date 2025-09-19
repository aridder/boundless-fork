#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Get ZKC epoch end time
# ----------------------------------------------------------------------
# Wraps `boundless zkc get-epoch-end-time`
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
#   ./scripts/zkc-get-epoch-end-time.sh <EPOCH_NUMBER>
#
# Example:
#   ./scripts/zkc-get-epoch-end-time.sh 3
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

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <EPOCH_NUMBER>" >&2
    exit 1
fi

EPOCH_NUMBER=$1

echo "🚀 Getting end time for epoch $EPOCH_NUMBER..."
boundless zkc get-epoch-end-time "$EPOCH_NUMBER" \
  --rpc-url "$RPC_URL"