#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Prepare PoVW work log update from Bento receipts
# ----------------------------------------------------------------------
# Wraps `boundless povw prepare`
# ----------------------------------------------------------------------
# Requirements:
# - `boundless` CLI installed
# - Bento running and producing work receipts
# - Environment variables defined inline or via `.env.povw-prepare`
# ----------------------------------------------------------------------
# Required ENV:
#   POVW_LOG_ID         : Ethereum Log ID address
#   STATE_FILE_LOCATION : Absolute path for the state file
# ----------------------------------------------------------------------
# Usage (first time for LOG_ID):
#   export POVW_LOG_ID=0x1234...
#   export STATE_FILE_LOCATION=/home/aridder/state.bin
#   ./scripts/povw-prepare.sh --new
#
# Usage (subsequent updates):
#   ./scripts/povw-prepare.sh
# ----------------------------------------------------------------------

# Load env file if present
if [ -f ".env.povw" ]; then
  # shellcheck disable=SC1091
  source .env.povw
fi

if [[ -z "${POVW_LOG_ID:-}" ]] || [[ -z "${STATE_FILE_LOCATION:-}" ]]; then
  echo "Error: Missing required environment variables." >&2
  echo "Need POVW_LOG_ID and STATE_FILE_LOCATION." >&2
  echo "These can also be defined in .env-prepare" >&2
  exit 1
fi

# Determine if this is the first invocation
if [[ "${1:-}" == "--new" ]]; then
  echo "🚀 Creating new state file for log ID $POVW_LOG_ID at $STATE_FILE_LOCATION..."
  boundless povw prepare \
    --new "$POVW_LOG_ID" \
    --state "$STATE_FILE_LOCATION" \
    --from-bento \
	--private-key "$PRIVATE_KEY" \
  --log-level trace \
	--rpc-url "$RPC_URL"
else
  echo "🚀 Updating state file at $STATE_FILE_LOCATION..."
  boundless povw prepare \
    --state "$STATE_FILE_LOCATION" \
    --from-bento
fi