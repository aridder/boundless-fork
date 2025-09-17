#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Bridge $ZKC from Ethereum mainnet to Base mainnet using `cast`
# ----------------------------------------------------------------------
# Requirements:
# - Foundry installed (for `cast`)
# - Environment variables:
#    PRIVATE_KEY    : private key of the sender (0x....)
#    AMOUNT         : amount of ZKC in whole tokens (e.g., 10 for 10 ZKC)
#    ETH_MAINNET_RPC_URL : RPC endpoint for Ethereum mainnet
#
# Usage:
#   export PRIVATE_KEY=0x123...
#   export AMOUNT=10
#   export ETH_MAINNET_RPC_URL="https://mainnet.infura.io/v3/YOUR_KEY"
#   ./scripts/bridge.sh
# ----------------------------------------------------------------------

ZKC_TOKEN="0x000006c2A22ff4A44ff1f5d0F2ed65F781F55555"
BASE_BRIDGE="0x3154Cf16ccdb4C6d922629664174b904d80F2C35"
RECIPIENT="0xAA61bB7777bD01B684347961918f1E07fBbCe7CF"
GAS_LIMIT=300000

if [[ -z "${PRIVATE_KEY:-}" ]] || [[ -z "${AMOUNT:-}" ]] || [[ -z "${ETH_MAINNET_RPC_URL:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Set PRIVATE_KEY, AMOUNT, and ETH_MAINNET_RPC_URL." >&2
  exit 1
fi

# Convert whole tokens (AMOUNT) to wei (18 decimals)
AMOUNT_WEI=$(cast --to-wei "$AMOUNT")

echo "Approving Base bridge to spend $AMOUNT ZKC tokens ($AMOUNT_WEI wei)..."
cast send "$ZKC_TOKEN" \
  "approve(address,uint256)" \
  "$BASE_BRIDGE" \
  "$AMOUNT_WEI" \
  --private-key "$PRIVATE_KEY" \
  --rpc-url "$ETH_MAINNET_RPC_URL"

echo "Bridging $AMOUNT ZKC tokens ($AMOUNT_WEI wei) to Base..."
cast send "$BASE_BRIDGE" \
  "bridgeERC20(address,address,uint256,uint32,bytes)" \
  "$ZKC_TOKEN" \
  "$RECIPIENT" \
  "$AMOUNT_WEI" \
  "$GAS_LIMIT" \
  0x \
  --private-key "$PRIVATE_KEY" \
  --rpc-url "$ETH_MAINNET_RPC_URL"

echo "✅ Bridge transaction submitted."