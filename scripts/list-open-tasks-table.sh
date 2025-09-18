#!/bin/bash
set -euo pipefail

# This script shows all open (not-done) tasks in a nice table format including order_id, job_id, task_id and state.

PG_USER="${POSTGRES_USER:-worker}"
PG_DB="${POSTGRES_DB:-taskdb}"

echo "--- Listing all non-done tasks from Postgres with their order IDs (if any) ---"

PG_SQL="
SELECT job_id, task_id, state
FROM tasks
WHERE state != 'done'
ORDER BY job_id, task_id;
"

TASK_ROWS=$(docker compose exec -T postgres psql -U "${PG_USER}" -d "${PG_DB}" -A -F '|' -c "${PG_SQL}")

# Print header
printf "%-40s | %-10s | %-10s | %-66s\n" "job_id" "task_id" "state" "order_id"
printf -- "--------------------------------------------------------------------------+-------------+-------------+-------------------------------------------------------------------\n"

# Process rows (skip header from psql)
echo "${TASK_ROWS}" | tail -n +2 | while IFS='|' read -r JOB_ID TASK_ID STATE; do
  if [ -n "$JOB_ID" ]; then
    SQLITE_FIND_SQL="SELECT id FROM orders WHERE json_extract(data, '\$.proof_id') = '${JOB_ID}';"
    ORDER_ID=$(docker run --rm -i -v bento_broker-data:/db nouchka/sqlite3 -readonly /db/broker.db "${SQLITE_FIND_SQL}" | tr -d '\r')
    if [ -z "$ORDER_ID" ]; then
      ORDER_ID="<missing>"
    fi
    printf "%-40s | %-10s | %-10s | %-66s\n" "$JOB_ID" "$TASK_ID" "$STATE" "$ORDER_ID"
  fi
done