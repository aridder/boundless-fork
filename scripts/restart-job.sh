#!/bin/bash

# This script restarts a failed job by cleaning up its old tasks and resetting its state.

set -e

JOB_ID=$1

if [ -z "$JOB_ID" ]; then
  echo "Usage: $0 <job_id>"
  exit 1
fi

echo "Restarting job: $JOB_ID"

# Path to the SQL file
SQL_FILE_PATH="$(dirname "$0")/../restart_failed_job.sql"

if [ ! -f "$SQL_FILE_PATH" ]; then
    echo "Error: SQL file not found at $SQL_FILE_PATH"
    exit 1
fi

# Execute the SQL file, passing the JOB_ID as a variable to psql
docker compose exec -T postgres psql \
    -U "${POSTGRES_USER:-worker}" \
    -d "${POSTGRES_DB:-taskdb}" \
    -v job_id="$JOB_ID" \
    -f "/dev/stdin" < "$SQL_FILE_PATH"

echo "Job $JOB_ID has been reset and is ready to be processed again."
