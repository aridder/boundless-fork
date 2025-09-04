#!/bin/bash

# This script finds and displays the 'data' field of an order
# from the broker.db (SQLite) based on a given job_id (proof_id).

set -euo pipefail

JOB_ID="$1"
if [ -z "$JOB_ID" ]; then
  echo "Usage: $0 <job_id>"
  echo "Note: The job_id corresponds to the 'proof_id' in the order's data."
  exit 1
fi

echo "--- Finding order with Job ID (proof_id): ${JOB_ID} ---"

SQLITE_SQL="
SELECT data
FROM orders
WHERE json_extract(data, '\$.proof_id') = '${JOB_ID}';
"

docker run --rm -i -v bento_broker-data:/db nouchka/sqlite3 /db/broker.db "${SQLITE_SQL}"
