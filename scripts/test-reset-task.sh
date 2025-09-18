#!/bin/bash
set -euo pipefail

ORDER_ID_FRAGMENT="$1"
if [ -z "$ORDER_ID_FRAGMENT" ]; then
  echo "Usage: $0 <order_id_fragment>"
  echo "You can provide a partial or full order ID."
  exit 1
fi

echo "--- [Step 1/2] Look up job_id (proof_id) for order $ORDER_ID_FRAGMENT ---"
SQLITE_FIND_SQL="SELECT json_extract(data, '\$.proof_id') FROM orders WHERE id LIKE '%${ORDER_ID_FRAGMENT}%';"
JOB_ID=$(docker run --rm -i -v bento_broker-data:/db nouchka/sqlite3 /db/broker.db "${SQLITE_FIND_SQL}")

if [ -z "$JOB_ID" ] || [ "$JOB_ID" == "null" ]; then
  echo "[WARN] No proof_id found for order $ORDER_ID in SQLite."
  echo "[INFO] No way to find job_id from Postgres using order_id alone."
  echo "Error: Cannot reset because proof_id not found in SQLite for order $ORDER_ID"
  exit 1
fi

echo "Job ID: $JOB_ID"

echo
echo "--- [Test-Reset] Step 2: Resetting failed tasks for job_id $JOB_ID ---"
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

docker compose exec -T postgres psql -U "$PG_USER" -d "$PG_DB" -c "$PG_SQL"

echo "--- [Test-Reset] Step 3: Resetting order status in SQLite to PendingProving ---"
SQLITE_UPDATE_SQL="UPDATE orders
SET data=json_set(
        json_set(data,'\$.status','PendingProving'),
        '\$.proof_id','$JOB_ID'
    )
WHERE id LIKE '%${ORDER_ID_FRAGMENT}%';"
docker run --rm -i -v bento_broker-data:/db nouchka/sqlite3 /db/broker.db "${SQLITE_UPDATE_SQL}"

echo "--- [Test-Reset] Done. Tasks for job $JOB_ID updated."