UPDATE tasks
SET state = 'ready', waiting_on = 0, updated_at = now()
WHERE state = 'pending'
  AND job_id IN (SELECT id FROM jobs WHERE state != 'done')
  AND NOT EXISTS (
    SELECT 1
    FROM tasks p
    WHERE p.task_id = ANY(SELECT jsonb_array_elements_text(tasks.prerequisites))
      AND p.job_id = tasks.job_id
      AND p.state NOT IN ('done')
  );