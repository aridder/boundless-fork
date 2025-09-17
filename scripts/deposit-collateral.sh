#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Deposit collateral into the Boundless market
# ----------------------------------------------------------------------
# Wraps `boundless account deposit-collateral`
# ----------------------------------------------------------------------
# Requirements:
# - `boundless` CLI must be installed
# - Environment variables are loaded automatically from `.env.deposit-collateral`
#
# Required ENV:
#   AMOUNT       : Amount of collateral (in HP or USDC depending on chain ID)
#   RPC_URL      : RPC endpoint for the network
#   PRIVATE_KEY  : Private key of wallet (without 0x prefix)
#
# Usage:
#   export AMOUNT=100
#   export RPC_URL=http://localhost:8545
#   export PRIVATE_KEY=abcdef1234...   # no 0x prefix
#   ./scripts/deposit-collateral.sh
#
# Or just use `.env.deposit-collateral` to configure these once.
# ----------------------------------------------------------------------

# Load env file if present
if [ -f ".env.deposit-collateral" ]; then
  # shellcheck disable=SC1091
  source .env.deposit-collateral
fi

if [[ -z "${AMOUNT:-}" ]] || [[ -z "${RPC_URL:-}" ]] || [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Set AMOUNT, RPC_URL, and PRIVATE_KEY." >&2
  echo "These can also be defined in .env.deposit-collateral" >&2
  exit 1
fi

echo "🚀 Depositing $AMOUNT collateral to boundless market..."
boundless account deposit-collateral "$AMOUNT" \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY"