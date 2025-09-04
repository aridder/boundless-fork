UPDATE public.jobs
SET
    state = 'failed',
    error = NULL,
    reported = false
WHERE
    id = '5be5aabb-b4aa-4e5b-94db-c9d4ef58a86'::uuid;