-- Verify roles

BEGIN;

SELECT id, name, description, run_list, env_run_lists, default_attr, override_attr, created_at, updated_at FROM goiardi.roles WHERE FALSE;

ROLLBACK;
