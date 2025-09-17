#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Bridge $ZKC from Base mainnet back to Ethereum mainnet using `cast`
# ----------------------------------------------------------------------
# Requirements:
# - Foundry installed (for `cast`)
# - Environment variables:
#    PRIVATE_KEY    : private key of the sender (0x....)
#    AMOUNT         : amount of ZKC in whole tokens (e.g., 10 for 10 ZKC)
#    BASE_RPC_URL   : RPC endpoint for Base mainnet
#    RECIPIENT      : L1 Ethereum address to receive ZKC
#    BASE_ZKC_ADDR  : ZKC token contract address on Base
#
# Usage:
#   export PRIVATE_KEY=0x123...
#   export AMOUNT=10
#   export BASE_RPC_URL="https://base-mainnet.infura.io/v3/YOUR_KEY"
#   export BASE_ZKC_ADDR=0x...
#   export RECIPIENT=0xYourEthereumAddress
#   ./scripts/bridge-base-to-mainnet.sh
# ----------------------------------------------------------------------

BASE_BRIDGE="0x3154Cf16ccdb4C6d922629664174b904d80F2C35"
GAS_LIMIT=300000

if [[ -z "${PRIVATE_KEY:-}" ]] || [[ -z "${AMOUNT:-}" ]] || [[ -z "${BASE_RPC_URL:-}" ]] \
   || [[ -z "${RECIPIENT:-}" ]] || [[ -z "${BASE_ZKC_ADDR:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Set PRIVATE_KEY, AMOUNT, BASE_RPC_URL, RECIPIENT, and BASE_ZKC_ADDR." >&2
  exit 1
fi

# Convert whole tokens (AMOUNT) to wei (18 decimals)
AMOUNT_WEI=$(cast --to-wei "$AMOUNT")

echo "Approving Base bridge to spend $AMOUNT ZKC tokens on Base ($AMOUNT_WEI wei)..."
cast send "$BASE_ZKC_ADDR" \
  "approve(address,uint256)" \
  "$BASE_BRIDGE" \
  "$AMOUNT_WEI" \
  --private-key "$PRIVATE_KEY" \
  --rpc-url "$BASE_RPC_URL"

echo "Bridging $AMOUNT ZKC tokens ($AMOUNT_WEI wei) from Base to Ethereum mainnet for $RECIPIENT..."
cast send "$BASE_BRIDGE" \
  "bridgeERC20(address,address,uint256,uint32,bytes)" \
  "$BASE_ZKC_ADDR" \
  "$RECIPIENT" \
  "$AMOUNT_WEI" \
  "$GAS_LIMIT" \
  0x \
  --private-key "$PRIVATE_KEY" \
  --rpc-url "$BASE_RPC_URL"

echo "✅ Bridge back transaction submitted. Remember: withdrawals Base → Ethereum require finality delay before funds are claimable."