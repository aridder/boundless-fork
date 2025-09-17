#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Withdraw $ZKC from Base mainnet to Ethereum mainnet
# ----------------------------------------------------------------------
# This handles the initiation step of the withdrawal flow.
# After this, you must wait out the Base → Ethereum dispute/finality window
# (approximately 7 days) before finalizing the withdrawal on Ethereum L1.
#
# Requirements:
# - Foundry installed (for `cast`)
# - Environment variables:
#    PRIVATE_KEY    : private key (0x....)
#    AMOUNT         : amount of ZKC to withdraw in whole tokens (e.g., 10)
#    BASE_RPC_URL   : RPC for Base mainnet
#    BASE_ZKC_ADDR  : address of ZKC token on Base
#    RECIPIENT      : Ethereum L1 address to receive ZKC
#
# Usage:
#   export PRIVATE_KEY=0x123...
#   export AMOUNT=10
#   export BASE_RPC_URL="https://base-mainnet.infura.io/v3/YOUR_KEY"
#   export BASE_ZKC_ADDR=0x...
#   export RECIPIENT=0xYourEthereumAddress
#   ./scripts/withdraw-base-to-mainnet.sh
# ----------------------------------------------------------------------

PORTAL="0x4200000000000000000000000000000000000010"  # Base canonical bridge portal
GAS_LIMIT=300000

if [[ -z "${PRIVATE_KEY:-}" ]] || [[ -z "${AMOUNT:-}" ]] || [[ -z "${BASE_RPC_URL:-}" ]] \
   || [[ -z "${RECIPIENT:-}" ]] || [[ -z "${BASE_ZKC_ADDR:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Set PRIVATE_KEY, AMOUNT, BASE_RPC_URL, BASE_ZKC_ADDR, and RECIPIENT." >&2
  exit 1
fi

# Convert to wei
AMOUNT_WEI=$(cast --to-wei "$AMOUNT")

echo "Approving Portal to spend $AMOUNT ZKC tokens on Base ($AMOUNT_WEI wei)..."
cast send "$BASE_ZKC_ADDR" \
  "approve(address,uint256)" \
  "$PORTAL" \
  "$AMOUNT_WEI" \
  --private-key "$PRIVATE_KEY" \
  --rpc-url "$BASE_RPC_URL"

echo "Initiating withdrawal of $AMOUNT ZKC tokens ($AMOUNT_WEI wei) from Base to Ethereum recipient $RECIPIENT..."
cast send "$PORTAL" \
  "initiateWithdrawal(address,uint256,address)" \
  "$BASE_ZKC_ADDR" \
  "$AMOUNT_WEI" \
  "$RECIPIENT" \
  --private-key "$PRIVATE_KEY" \
  --rpc-url "$BASE_RPC_URL"

echo "✅ Withdrawal initiated. Wait for the Base → Ethereum finality window, then finalize on Ethereum L1."