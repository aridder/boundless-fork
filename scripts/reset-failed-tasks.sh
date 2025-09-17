#!/bin/bash

# This script resets failed tasks for a given order. It will:
# 1. Resolve the order id fragment to a job_id (proof_id) from SQLite (broker.db).
# 2. Run update-failed-tasks.sql logic against Postgres scoped only to that job_id.

set -euo pipefail

ORDER_ID_FRAGMENT="$1"
if [ -z "$ORDER_ID_FRAGMENT" ]; then
  echo "Usage: $0 <order_id_fragment>"
  echo "You can provide a partial or full order ID."
  exit 1
fi

echo "--- [Step 1/2] Finding Job ID for Order fragment: ${ORDER_ID_FRAGMENT} ---"

SQLITE_FIND_SQL="SELECT json_extract(data, '\$.proof_id') FROM orders WHERE id LIKE '%${ORDER_ID_FRAGMENT}%';"
JOB_ID=$(docker run --rm -i -v bento_broker-data:/db nouchka/sqlite3 /db/broker.db "${SQLITE_FIND_SQL}")

if [ -z "$JOB_ID" ] || [ "$JOB_ID" == "null" ]; then
  echo "Error: No order found for fragment '${ORDER_ID_FRAGMENT}' or order has no proof_id."
  exit 1
fi

echo "Found Job ID: ${JOB_ID}"
echo ""

echo "--- [Step 2/2] Resetting failed tasks for Job ID: ${JOB_ID} ---"

PG_USER="${POSTGRES_USER:-worker}"
PG_DB="${POSTGRES_DB:-taskdb}"

PG_SQL="
UPDATE tasks
SET state = 'ready', waiting_on = 0, updated_at = now()
WHERE state = 'pending'
  AND job_id = '${JOB_ID}'
  AND job_id IN (SELECT id FROM jobs WHERE state != 'done')
  AND NOT EXISTS (
    SELECT 1
    FROM tasks p
    WHERE p.task_id = ANY(SELECT jsonb_array_elements_text(tasks.prerequisites))
      AND p.job_id = tasks.job_id
      AND p.state NOT IN ('done')
  );
"

docker compose exec -T postgres psql -U "${PG_USER}" -d "${PG_DB}" -c "${PG_SQL}"

echo "Failed tasks for Job ID ${JOB_ID} have been reset."