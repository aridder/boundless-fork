#!/bin/bash
set -euo pipefail

# This script deletes ALL tasks (and dependencies) for a given order id.
# Workflow:
# 1. Resolve the order id fragment to a job_id (proof_id) from broker.db (SQLite).
# 2. Delete all task_deps, tasks, and the job record from Postgres (taskdb) for that job_id.

ORDER_ID_FRAGMENT="$1"
if [ -z "$ORDER_ID_FRAGMENT" ]; then
  echo "Usage: $0 <order_id_fragment>"
  echo "You can provide a partial or full order ID."
  exit 1
fi

echo "--- [Step 1/2] Lookup job_id (proof_id) for order fragment: ${ORDER_ID_FRAGMENT} ---"
SQLITE_FIND_SQL="SELECT json_extract(data, '\$.proof_id') FROM orders WHERE id LIKE '%${ORDER_ID_FRAGMENT}%';"
JOB_ID=$(docker run --rm -i -v bento_broker-data:/db nouchka/sqlite3 /db/broker.db "${SQLITE_FIND_SQL}")

if [ -z "$JOB_ID" ] || [ "$JOB_ID" == "null" ]; then
  echo "Error: No order found for fragment '${ORDER_ID_FRAGMENT}' or order has no proof_id."
  exit 1
fi

echo "Found Job ID: ${JOB_ID}"
echo ""

echo "--- [Step 2/2] Deleting all tasks for Job ID: ${JOB_ID} ---"
PG_USER="${POSTGRES_USER:-worker}"
PG_DB="${POSTGRES_DB:-taskdb}"

PG_SQL="
DELETE FROM task_deps WHERE job_id = '${JOB_ID}';
DELETE FROM tasks WHERE job_id = '${JOB_ID}';
DELETE FROM jobs WHERE id = '${JOB_ID}';
"

docker compose exec -T postgres psql -U "${PG_USER}" -d "${PG_DB}" -c "${PG_SQL}"

echo "--- Done. Deleted all tasks and job for Job ID ${JOB_ID} ---"