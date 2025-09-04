#!/bin/bash

# This script performs a full reset of a failed order by:
# 1. Deleting the job, tasks, and task dependencies from the PostgreSQL database (taskdb).
# 2. Resetting the corresponding order's status to 'PendingProving' in the SQLite database (broker.db).

set -euo pipefail

JOB_ID="$1"
if [ -z "$JOB_ID" ]; then
  echo "Usage: $0 <job_id>"
  echo "Note: The job_id is the UUID associated with the failed job, which corresponds to the 'proof_id' in the order."
  exit 1
fi

echo "--- [Step 1/2] Resetting PostgreSQL data for Job ID: ${JOB_ID} ---"
PG_USER="${POSTGRES_USER:-worker}"
PG_DB="${POSTGRES_DB:-taskdb}"
PG_SQL="
DELETE FROM public.task_deps WHERE job_id = '${JOB_ID}';
DELETE FROM public.tasks WHERE job_id = '${JOB_ID}';
DELETE FROM public.jobs WHERE id = '${JOB_ID}';
"
# The psql command returns the number of rows affected by the last command.
PG_RESULT=$(docker compose exec -T postgres psql -U "${PG_USER}" -d "${PG_DB}" -c "${PG_SQL}")
echo "PostgreSQL cleanup complete. Result: ${PG_RESULT}"


echo ""
echo "--- [Step 2/2] Resetting SQLite order status to PendingProving for Job ID: ${JOB_ID} ---"
# The job_id from the logs corresponds to the proof_id in the order's JSON data blob.
SQLITE_SQL="
UPDATE orders
SET data = json_set(
               json_set(data, '\$.status', 'PendingProving'),
               '\$.proof_id', NULL
           )
WHERE json_extract(data, '\$.proof_id') = '${JOB_ID}';
SELECT 'SQLite: Order status reset for ' || changes() || ' order(s).';
"
# The sqlite3 command will output the result of the final SELECT statement.
SQLITE_RESULT=$(docker run --rm -i -v bento_broker-data:/db nouchka/sqlite3 /db/broker.db "${SQLITE_SQL}")
echo "${SQLITE_RESULT}"

echo ""
echo "--- Reset complete. The broker should now pick up the order for proving. ---"